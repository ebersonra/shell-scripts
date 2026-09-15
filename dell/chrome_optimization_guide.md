# Guia de Otimização do Google Chrome
# Para sistemas com 8GB RAM

## PROBLEMA IDENTIFICADO
Seu Chrome está com ~15 processos ativos, consumindo provavelmente 3-4 GB de RAM.
Isso sozinho representa 40-50% da sua memória total.

## SOLUÇÕES RECOMENDADAS

### Opção 1: SUBSTITUIR O CHROME (Mais Efetiva)

#### Firefox (Recomendado)
- Consome 50-60% menos RAM que Chrome
- Mesma compatibilidade
- Sincronização nativa
```bash
sudo snap install firefox
```

#### Brave Browser
- Baseado em Chromium (mesma base do Chrome)
- Bloqueador de ads nativo (reduz uso de memória)
- 30-40% mais leve que Chrome
```bash
sudo apt install -y apt-transport-https curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser
```

### Opção 2: OTIMIZAR O CHROME (Se não quiser trocar)

#### A. Habilitar flags de economia de memória

Abra no Chrome: `chrome://flags`

Habilite estas flags:
- `#automatic-tab-discarding` → Enabled
- `#tab-freeze` → Enabled
- `#intensive-wake-up-throttling` → Enabled
- `#battery-saver-mode-available` → Enabled

#### B. Editar lançador do Chrome

```bash
sudo nano /usr/share/applications/google-chrome.desktop
```

Altere a linha `Exec=` para:
```
Exec=/usr/bin/google-chrome-stable --process-per-site --disable-features=CalculateNativeWinOcclusion --enable-features=QuietNotificationPrompts,BackForwardCache:TimeToLiveInBackForwardCacheInSeconds/300,ParallelDownloading %U
```

Salve com `Ctrl+O`, `Enter`, `Ctrl+X`

#### C. Instalar extensão de gerenciamento de abas

**The Great Suspender** (ou similar):
- Suspende abas inativas automaticamente
- Libera memória de abas não usadas
- Alternativas: Tab Suspender, Auto Tab Discard

#### D. Limitar número de processos

Crie um wrapper para o Chrome:
```bash
sudo nano /usr/local/bin/chrome-limited
```

Adicione:
```bash
#!/bin/bash
# Limitar Chrome a 4GB de RAM
systemd-run --user --scope -p MemoryMax=4G -p MemoryHigh=3.5G /usr/bin/google-chrome-stable "$@"
```

Salve e dê permissão:
```bash
sudo chmod +x /usr/local/bin/chrome-limited
```

Use: `chrome-limited` ao invés de `google-chrome`

#### E. Configurações do Chrome

No Chrome, vá em `chrome://settings/performance`:
- ✅ Ativar "Economia de memória"
- ✅ Ativar "Economia de energia"
- ✅ "Liberar memória de guias inativas"

### Opção 3: USAR CHROME APENAS PARA NECESSIDADES ESPECÍFICAS

#### Navegação Geral → Firefox/Brave
- Sites normais
- YouTube, streaming
- Redes sociais

#### Chrome → Apenas para:
- Web apps que exigem Chrome (ex: Google Meet, alguns apps web)
- Desenvolvimento web (DevTools)

## COMANDOS DE MONITORAMENTO

### Ver uso de memória do Chrome em tempo real
```bash
watch -n 2 'ps aux | grep chrome | awk "{sum+=\$6} END {print sum/1024 \" MB\"}"'
```

### Ver processos do Chrome ordenados por memória
```bash
ps aux | grep chrome | sort -k4 -r | head -15
```

### Matar Chrome quando estiver travando
```bash
killall chrome
# ou
pkill -9 chrome
```

### Ver quantas abas/processos estão abertos
```bash
ps aux | grep chrome | wc -l
```

## BOAS PRÁTICAS

1. **Feche abas não usadas**: Cada aba = 50-200 MB de RAM
2. **Use marcadores**: Não deixe abas abertas "para lembrar"
3. **Desabilite extensões não usadas**: Cada uma consome memória
4. **Limpe cache regularmente**: `chrome://settings/clearBrowserData`
5. **Considere perfis separados**: Um para trabalho, outro pessoal

## EXTENSÕES QUE AJUDAM

### Obrigatórias (economizam RAM):
- **uBlock Origin**: Bloqueia ads/scripts pesados
- **The Great Suspender**: Suspende abas automaticamente
- **OneTab**: Converte abas em lista (libera memória)

### Remover (consomem muita RAM):
- Grammarly
- Honey
- Extensões de screenshot de página inteira
- Tradutores pesados

## COMPARAÇÃO DE CONSUMO

Com 10 abas abertas (média):

| Navegador | RAM Usada | Processos |
|-----------|-----------|-----------|
| Chrome    | 3.5-4 GB  | 15-20     |
| Firefox   | 1.5-2 GB  | 4-6       |
| Brave     | 2.5-3 GB  | 10-15     |

**Conclusão**: Trocar para Firefox liberaria ~2 GB de RAM instantaneamente.
