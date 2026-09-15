# ⚡ PLANO DE AÇÃO RÁPIDO - Dell Inspiron 5448
# Prioridade: Alta → Média → Baixa

## 🔴 AÇÕES IMEDIATAS (Fazer AGORA)

### 1. Trocar Chrome por Firefox (Libera ~2GB RAM instantaneamente)
```bash
sudo snap install firefox
# Importe seus favoritos e senhas do Chrome
# Desinstale Chrome depois: sudo apt remove google-chrome-stable
```
**Impacto**: ★★★★★ (Maior ganho único)
**Tempo**: 5 minutos

### 2. Limpar memória e processos
```bash
# Fechar Chrome completamente
killall chrome

# Limpar cache
sudo sync && sudo sysctl -w vm.drop_caches=3

# Ver o que está consumindo RAM
ps aux --sort=-%mem | head -15
```
**Impacto**: ★★★★☆
**Tempo**: 2 minutos

### 3. Configurar swappiness (Reduzir uso de swap)
```bash
# Reduzir swappiness de 60 para 10
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -w vm.swappiness=10
```
**Impacto**: ★★★★☆
**Tempo**: 1 minuto

---

## 🟡 AÇÕES IMPORTANTES (Fazer HOJE)

### 4. Instalar e configurar TLP (Economia de energia)
```bash
sudo apt install -y tlp tlp-rdw
sudo systemctl enable tlp
sudo tlp start
```
**Impacto**: ★★★★☆ (Bateria dura 30-50% mais)
**Tempo**: 3 minutos

### 5. Habilitar zram (Compressão de RAM)
```bash
sudo apt install -y zram-config
sudo systemctl enable zram-config
sudo systemctl start zram-config
```
**Impacto**: ★★★☆☆ (Ganha ~1.5GB RAM efetiva)
**Tempo**: 2 minutos

### 6. Desabilitar serviços desnecessários
```bash
sudo systemctl disable bluetooth.service
sudo systemctl disable cups-browsed.service
sudo systemctl disable ModemManager.service
```
**Impacto**: ★★★☆☆
**Tempo**: 2 minutos

### 7. Configurar GPU AMD básico
```bash
# Instalar drivers
sudo apt install -y mesa-vulkan-drivers mesa-utils vulkan-tools

# Testar
glxinfo | grep "OpenGL renderer"
DRI_PRIME=1 glxinfo | grep "OpenGL renderer"
```
**Impacto**: ★★★☆☆ (Para apps gráficos pesados)
**Tempo**: 5 minutos

---

## 🟢 AÇÕES COMPLEMENTARES (Fazer esta SEMANA)

### 8. Limpar disco e logs
```bash
sudo apt autoremove -y
sudo apt autoclean
sudo journalctl --vacuum-time=3d
```
**Impacto**: ★★☆☆☆ (Libera espaço)
**Tempo**: 3 minutos

### 9. Otimizar GNOME
```bash
# Desabilitar animações
gsettings set org.gnome.desktop.interface enable-animations false

# Desabilitar tracker (indexação)
systemctl --user mask tracker-store.service tracker-miner-fs.service
```
**Impacto**: ★★★☆☆ (Interface mais fluida)
**Tempo**: 2 minutos

### 10. Instalar ferramentas de monitoramento
```bash
sudo apt install -y htop btop iotop powertop radeontop
```
**Impacto**: ★★☆☆☆ (Diagnóstico)
**Tempo**: 2 minutos

---

## 📊 GANHOS ESPERADOS

### Memória
- **Antes**: 8.90/8.0 GB (111% - swapping pesado)
- **Depois**: 4.5-5.5/8.0 GB (60-70% - confortável)
- **Ganho**: ~3-4 GB livres

### CPU
- **Antes**: Load average 8.90 (sistema sufocado)
- **Depois**: Load average 2.0-3.0 (fluido)
- **Ganho**: 60-70% menos carga

### Bateria
- **Antes**: ~2-3 horas
- **Depois**: ~4-5 horas
- **Ganho**: 50-80% mais autonomia

### GPU
- **Antes**: Intel apenas (desempenho limitado)
- **Depois**: Intel + AMD sob demanda
- **Ganho**: 70% mais performance gráfica quando necessário

---

## 🎯 SCRIPTS PRONTOS PARA USAR

Execute na ordem:

### Passo 1: Script principal de otimização
```bash
cd ~
chmod +x optimize_system.sh
./optimize_system.sh
```

### Passo 2: Configurar GPU AMD
```bash
chmod +x setup_amd_gpu.sh
./setup_amd_gpu.sh
```

### Passo 3: Reiniciar
```bash
sudo reboot
```

---

## 📱 COMANDOS ÚTEIS PÓS-INSTALAÇÃO

### Monitorar memória
```bash
free -h
htop
btop
```

### Monitorar CPU
```bash
top
htop
sensors  # Temperaturas
```

### Monitorar GPU
```bash
# Intel (sempre ativa)
intel_gpu_top

# AMD (quando em uso)
radeontop
watch -n 1 'DRI_PRIME=1 glxinfo | grep "OpenGL renderer"'
```

### Monitorar bateria e energia
```bash
tlp-stat -b  # Status da bateria
powertop     # Consumo detalhado
```

### Alternar perfis
```bash
performance-mode  # Quando na tomada
battery-mode      # Quando em bateria
```

---

## ⚠️ O QUE EVITAR

❌ **NÃO fazer**:
1. Usar GPU AMD o tempo todo (drena bateria)
2. Manter muitas abas do Chrome abertas (>10)
3. Deixar apps rodando em background desnecessariamente
4. Usar Wayland se tiver problemas com GPU (use Xorg)
5. Instalar drivers proprietários AMD (não funcionam para R7 M260)

✅ **SEMPRE fazer**:
1. Usar Firefox para navegação diária
2. Ativar `battery-mode` quando desconectar da tomada
3. Monitorar uso com `htop` regularmente
4. Fechar apps não usados
5. Limpar cache/logs mensalmente

---

## 🔧 SOLUÇÃO DE PROBLEMAS

### Sistema lento após otimização
```bash
# Reverter swappiness
sudo sysctl -w vm.swappiness=60

# Reativar serviços
sudo systemctl enable bluetooth.service
```

### GPU AMD não funciona
```bash
# Ver logs
sudo dmesg | grep -i amd
sudo dmesg | grep -i drm

# Forçar carregamento do módulo
sudo modprobe amdgpu

# Ver se está detectada
lspci | grep -i amd
```

### Bateria durando menos
```bash
# Verificar TLP
sudo tlp-stat -s

# Reconfigurar
sudo tlp start
```

---

## 📈 PRÓXIMOS PASSOS (Opcional)

Se ainda quiser mais performance depois:

1. **Upgrade de hardware**:
   - SSD (se ainda usa HDD) → Maior impacto
   - Mais 8GB RAM (16GB total) → Elimina gargalo
   - Pasta térmica nova → Reduz throttling

2. **Distro mais leve**:
   - Linux Mint Xfce
   - Ubuntu MATE
   - Lubuntu
   (Consomem 60% menos RAM que GNOME)

3. **Desktop Environment mais leve**:
   - XFCE (500MB RAM)
   - LXDE (300MB RAM)
   vs GNOME atual (1.2GB RAM)

---

## ✅ CHECKLIST FINAL

Marque conforme for fazendo:

- [ ] Firefox instalado e configurado como padrão
- [ ] Chrome fechado/desinstalado
- [ ] Swappiness configurado (10)
- [ ] TLP instalado e ativado
- [ ] zram habilitado
- [ ] Serviços desnecessários desabilitados
- [ ] GPU AMD testada (DRI_PRIME=1)
- [ ] GNOME otimizado (animações off)
- [ ] Ferramentas de monitoramento instaladas
- [ ] Sistema reiniciado
- [ ] Memória < 60% após boot
- [ ] Load average < 2.0 em idle

**Meta**: 5-6/8 GB RAM livre após boot + navegação leve
**Realidade antes**: 8.90/8.0 GB (111%)
**Realidade depois**: 4.5-5.5/8.0 GB (60-70%) ✅
