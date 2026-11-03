## Shell para instalar o Java e o Gradle no Ubuntu 20.04.

#### Configurando o arquivo <em>passwd.txt</em> com a senha do seu usuário root.
```
$ touch passwd.txt && vim passwd.txt
```
### Instalando Java.
#### Instalando Java JDK Default para Ubuntu 20.04. Ex: Java JDK 11.
```
$ ./env-dev.sh 
```
#### Instalando uma versão especifica do Java. Ex: Java JDK 8
```
$ ./env-dev.sh 8
```
### Instalando Gradle.
#### Execute o script a baixo:
```
$ ./env-dev.sh
```
#### Responda as perguntas a baixo:
```
Do you have a specific version? [y] or [n] .:
```
#### Se tiver uma versão especifica, responda a pergunta a baixo seguindo o padrão do exemplo:
```
What's your version? Ex: v4.10.5
```

## Comandos globais (`dell-*`)

O repositório é a **fonte da verdade**. `link-global.sh` cria symlinks em `/usr/local/bin` — edições nos `.sh` do projeto valem na hora, sem recopiar.

```bash
cd /caminho/para/shell-scripts
sudo ./link-global.sh          # cria/atualiza links
./link-global.sh --list        # ver mapeamento
sudo ./link-global.sh --remove # remove links deste repo
```

Depois, em **qualquer terminal** (sem `cd` no projeto):

| Comando global | Equivalente no repo |
|----------------|---------------------|
| `env-dev.sh` | `./env-dev.sh` |
| `git-config-user.sh` | `./git-config-user.sh` |
| `dell.sh` | `./dell.sh` |
| `sudo dell-optimize-system` | `./dell/optimize_system.sh` |
| `sudo dell-setup-amd-gpu` | `./dell/setup_amd_gpu.sh` |
| `sudo dell-fix-amd-error` | `./dell/fix_amd_error.sh` |
| `dell-link-global --list` | `./link-global.sh --list` |

Se mover o clone do projeto, rode de novo `sudo ./link-global.sh` (ou `sudo dell-link-global`) para apontar os links ao novo caminho.

## dell-cursor-rules

Sincroniza as rules globais de `~/.cursor/rules/*.mdc` para o `.cursor/rules/` de cada repositório em `~/Documentos/_Developer/_github` (inclui repos via symlink; ignora `*.worktrees`), para que o Cursor IDE e os cloud agents as apliquem.

```bash
dell-cursor-rules status                 # pendências por repo (rc=1 se houver)
dell-cursor-rules sync --dry-run         # mostra o que faria
dell-cursor-rules sync                   # copia/atualiza, cópias em .git/info/exclude
dell-cursor-rules sync --track           # idem, sem exclude (para commitar a rule no repo)
```

- Cópias são idênticas à fonte; o hash de cada cópia fica em `.cursor/rules/.dell-cursor-rules.sha` (sempre excluído do git).
- Rule local diferente ou cópia editada à mão nunca é sobrescrita: vira conflito (rc=3).
- Por padrão as cópias não entram em commit (protege repos públicos). Use `--track` só onde a rule deve ser versionada.
- Não faz commit: cada repo segue o fluxo normal de PR.

### Contexto por projeto (`~/agent-context/`)

Arquivo curto (≤ 2 KB) por projeto que os agentes leem no lugar do histórico do chat: estado atual, decisões, pendências, regras e links. Quem terminar um trabalho atualiza o arquivo.

```bash
dell-cursor-rules context init 4u2-fia-bot shell-scripts   # cria a partir do template (não sobrescreve)
dell-cursor-rules context ls                               # tamanho e data; avisa acima de 2 KB
```

A pasta fica fora de qualquer repo (modo 700); não coloque segredos, telefones nem conteúdo de mensagens nela.
