#!/usr/bin/env bash
# cursor_rules.sh — Sincroniza as rules globais (~/.cursor/rules/*.mdc) para o
# .cursor/rules/ de cada repositório, para que Cursor IDE e cloud agents as leiam.
#
# Uso:
#   dell-cursor-rules status                    # pendências por repo (rc=1 se houver)
#   dell-cursor-rules sync [--dry-run]           # copia faltantes / atualiza gerenciadas
#   dell-cursor-rules sync [--dry-run] --track [--force-public] <repo>...  # sem exclude, só nesses repos
#   dell-cursor-rules context init <projeto>...  # cria ~/agent-context/<projeto>.md (não sobrescreve)
#   dell-cursor-rules context ls                 # lista contextos (avisa acima de 2 KB)
#
# Regras:
#   - Cópias são byte-idênticas à fonte; o controle fica em .cursor/rules/.dell-cursor-rules.sha.
#   - Nunca sobrescreve rule local diferente nem cópia gerenciada editada à mão (conflito, rc=3).
#   - Por padrão cada cópia vai para .git/info/exclude (não entra em commit por acidente);
#     --track pula o exclude só nos repos nomeados (recusa repo público sem --force-public).
#   - Não faz commit: cada repo segue o fluxo normal de PR.
set -euo pipefail
shopt -s nullglob

SRC="${CURSOR_RULES_SRC:-$HOME/.cursor/rules}"
ROOT="${CURSOR_RULES_REPOS:-$HOME/Documentos/_Developer/_github}"
MANIFEST=".dell-cursor-rules.sha"
CTX="${AGENT_CONTEXT_DIR:-$HOME/agent-context}"
CTX_MAX=2048
DRY=false
TRACK=false
FORCE_PUBLIC=false
TRACK_REPOS=()

usage() { sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; }
die() { echo "erro: $*" >&2; exit 1; }
sha() { sha256sum "$1" | cut -d' ' -f1; }

repos() {
  local d rp
  declare -A seen=()
  for d in "$ROOT"/*/; do
    d=${d%/}
    [[ $d == *.worktrees ]] && continue
    [[ -e "$d/.git" ]] || continue
    rp=$(realpath -- "$d")
    [[ -n ${seen[$rp]:-} ]] && continue
    seen[$rp]=1
    printf '%s\n' "$d"
  done
}

atomic_write() { # destino  (conteúdo via stdin)
  local tmp
  tmp=$(mktemp "$(dirname "$1")/.tmp.XXXXXX")
  if cat > "$tmp" && chmod 644 "$tmp" && mv -f -- "$tmp" "$1"; then return 0; fi
  rm -f -- "$tmp"; return 1
}

is_tracked_repo() { # repo -> 0 se nomeado em --track
  local n; for n in "${TRACK_REPOS[@]}"; do [[ $(basename "$1") == "$n" ]] && return 0; done; return 1
}

check_track_repos() {
  local n d url vis
  for n in "${TRACK_REPOS[@]}"; do
    [[ $n =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "--track: nome de repo inválido: $n"
    d="$ROOT/$n"
    [[ -e $d/.git ]] || die "--track: repo não encontrado: $n"
    url=$(git -C "$d" remote get-url origin 2>/dev/null | sed -E 's#.*github.com[:/]##; s#\.git$##') || url=
    vis=$( [[ -n $url ]] && gh repo view "$url" --json visibility -q .visibility 2>/dev/null || echo DESCONHECIDA)
    if [[ $vis != PRIVATE ]] && ! $FORCE_PUBLIC; then
      die "--track recusado em $n (visibilidade: $vis). Use --force-public se for intencional."
    fi
    echo "aviso: --track em $n ($vis): as rules NÃO vão para .git/info/exclude e podem ser commitadas." >&2
  done
}

manifest_get() { # repo name -> sha gravado (ou vazio)
  local m="$1/.cursor/rules/$MANIFEST"
  if [[ -f $m ]]; then awk -v n="$2" '$2==n{print $1}' "$m"; fi
}

manifest_set() { # repo name sha
  local m="$1/.cursor/rules/$MANIFEST" tmp
  tmp=$(mktemp "$(dirname "$m")/.tmp.XXXXXX")
  if { if [[ -f $m ]]; then awk -v n="$2" '$2!=n' "$m"; fi; printf '%s %s\n' "$3" "$2"; } > "$tmp" \
     && mv -f -- "$tmp" "$m"; then return 0; fi
  rm -f -- "$tmp"; return 1
}

exclude_add() { # repo path-relativo
  local gitdir ex
  gitdir=$(git -C "$1" rev-parse --absolute-git-dir) || return 0
  ex="$gitdir/info/exclude"
  mkdir -p "$gitdir/info"; touch "$ex"
  grep -qxF "$2" "$ex" || printf '%s\n' "$2" >> "$ex"
}

state() { # repo srcfile -> missing|same|outdated|conflict
  local name dst rec
  name=$(basename "$2"); dst="$1/.cursor/rules/$name"
  [[ -e $dst ]] || { echo missing; return; }
  cmp -s "$2" "$dst" && { echo same; return; }
  rec=$(manifest_get "$1" "$name")
  [[ -n $rec && $(sha "$dst") == "$rec" ]] && echo outdated || echo conflict
}

FILES=()
load_files() {
  [[ -d $SRC ]] || die "fonte não encontrada: $SRC"
  [[ -d $ROOT ]] || die "pasta de repos não encontrada: $ROOT"
  FILES=("$SRC"/*.mdc)
  ((${#FILES[@]})) || die "nenhum .mdc em $SRC"
}

cmd_status() {
  local r f s pend=0
  while read -r r; do
    for f in "${FILES[@]}"; do
      s=$(state "$r" "$f")
      [[ $s == same ]] && continue
      printf '%-36s %-40s %s\n' "$(basename "$r")" "$(basename "$f")" "$s"; pend=$((pend + 1))
    done
  done < <(repos)
  ((pend == 0)) || return 1
}

cmd_sync() {
  local r f s name dst n=0 c=0
  while read -r r; do
    for f in "${FILES[@]}"; do
      name=$(basename "$f"); dst="$r/.cursor/rules/$name"; s=$(state "$r" "$f")
      case $s in
        missing|outdated)
          echo "[$s] $(basename "$r")/.cursor/rules/$name"
          if ! $DRY; then
            mkdir -p "$r/.cursor/rules"
            atomic_write "$dst" < "$f"
            manifest_set "$r" "$name" "$(sha "$dst")"
            exclude_add "$r" ".cursor/rules/$MANIFEST"
            exclude_add "$r" ".cursor/rules/.tmp.*"
            is_tracked_repo "$r" || exclude_add "$r" ".cursor/rules/$name"
          fi
          n=$((n + 1)) ;;
        conflict)
          echo "[conflito: rule local diferente ou editada] $(basename "$r")/.cursor/rules/$name" >&2
          c=$((c + 1)) ;;
      esac
    done
  done < <(repos)
  echo "$n arquivo(s) $($DRY && echo 'seriam ')atualizado(s), $c conflito(s). Commit/PR fica com cada repo."
  ((c == 0)) || return 3
}

ctx_template() {
  cat <<TPL
# Contexto: $1
<!-- Lido pelos agentes no lugar do histórico do chat. Máx. ~2 KB. Atualize ao terminar um trabalho. -->
<!-- NUNCA coloque aqui segredos, tokens, senhas, telefones, e-mails ou conteúdo de mensagens. -->
Atualizado: $(date '+%Y-%m-%d %H:%M %Z') por <agente>

## Estado atual

## Decisões

## Pendências

## Regras específicas

## Links (PRs, issues, docs)
TPL
}

cmd_context() {
  local sub=${1:-} p f sz
  shift || true
  case $sub in
    init)
      (($#)) || { usage >&2; exit 2; }
      for p in "$@"; do  # valida tudo antes de criar qualquer coisa
        [[ $p =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "nome inválido: $p"
      done
      [[ -L $CTX ]] && die "$CTX é symlink; recusado"
      [[ -d $(dirname -- "$CTX") ]] || die "pasta pai inexistente: $(dirname -- "$CTX")"
      if git -C "$(dirname -- "$CTX")" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        die "$CTX ficaria dentro de um repo git; recusado"
      fi
      [[ -d $CTX ]] || mkdir -- "$CTX"
      chmod 700 -- "$CTX" || die "não consegui aplicar modo 700 em $CTX"
      for p in "$@"; do
        f="$CTX/$p.md"
        if [[ -e $f ]]; then echo "[existe] $f"; continue; fi
        (umask 077; set -C; ctx_template "$p" > "$f") || die "falha ao criar $f"
        echo "[criado] $f"
      done ;;
    ls)
      (($# == 0)) || { usage >&2; exit 2; }
      [[ -d $CTX ]] || { echo "nenhum contexto em $CTX"; return 0; }
      for f in "$CTX"/*.md; do
        sz=$(stat -c %s "$f")
        printf '%-32s %6s B  %s%s\n' "$(basename "$f" .md)" "$sz" "$(date -r "$f" '+%Y-%m-%d %H:%M')" \
          "$( ((sz > CTX_MAX)) && echo '  [acima de 2 KB: resumir]')"
      done ;;
    *) usage >&2; exit 2 ;;
  esac
}

case "${1:-}" in
  context) shift; cmd_context "$@" ;;
  status) [[ $# -eq 1 ]] || { usage >&2; exit 2; }; load_files; cmd_status ;;
  sync)
    shift
    while (($#)); do
      case $1 in
        --dry-run) DRY=true ;;
        --track) TRACK=true ;;
        --force-public) FORCE_PUBLIC=true ;;
        -*) usage >&2; exit 2 ;;
        *) $TRACK || { usage >&2; exit 2; }; TRACK_REPOS+=("$1") ;;
      esac
      shift
    done
    if $TRACK && ((${#TRACK_REPOS[@]} == 0)); then die "--track exige ao menos um repo"; fi
    if $FORCE_PUBLIC && ! $TRACK; then die "--force-public só vale com --track"; fi
    load_files
    if $TRACK; then check_track_repos; fi
    cmd_sync ;;
  -h|--help|"") usage ;;
  *) usage >&2; exit 2 ;;
esac
