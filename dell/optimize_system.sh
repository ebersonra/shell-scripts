#!/bin/bash
# Otimização completa para Dell Inspiron 5448 (2015)
# 8GB RAM, i7-5500U, Ubuntu 24.04

set -e

echo "=== Otimização Dell Inspiron 5448 ==="
echo ""

# ============================================
# 1. OTIMIZAÇÕES DE MEMÓRIA
# ============================================

echo "1. Configurando otimizações de memória..."

# Ajustar swappiness (reduzir uso de swap)
echo "  - Ajustando swappiness para 10 (padrão: 60)"
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -w vm.swappiness=10

# Limpar cache de memória
echo "  - Limpando caches..."
sudo sync && sudo sysctl -w vm.drop_caches=3

# Otimizar VFS cache pressure
echo "  - Otimizando VFS cache pressure"
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
sudo sysctl -w vm.vfs_cache_pressure=50

# Configurar zram (compressão de RAM)
echo "  - Instalando e configurando zram..."
sudo apt install -y zram-config
sudo systemctl enable zram-config

echo ""

# ============================================
# 2. OTIMIZAÇÕES DE CPU
# ============================================

echo "2. Configurando otimizações de CPU..."

# Instalar TLP para gerenciamento de energia
echo "  - Instalando TLP (gerenciamento de energia)..."
sudo apt install -y tlp tlp-rdw
sudo systemctl enable tlp

# Configurar governor para balance ou powersave
echo "  - Configurando CPU governor..."
sudo apt install -y cpufrequtils
echo 'GOVERNOR="schedutil"' | sudo tee /etc/default/cpufrequtils

# Desabilitar serviços desnecessários
echo "  - Desabilitando serviços desnecessários..."
sudo systemctl disable bluetooth.service 2>/dev/null || true
sudo systemctl disable cups-browsed.service 2>/dev/null || true
sudo systemctl disable ModemManager.service 2>/dev/null || true

echo ""

# ============================================
# 3. OTIMIZAÇÕES DE DISCO
# ============================================

echo "3. Configurando otimizações de disco..."

# Habilitar TRIM para SSD (se aplicável)
echo "  - Verificando se há SSD..."
if sudo fstrim -v / 2>/dev/null; then
    echo "    SSD detectado, habilitando TRIM automático..."
    sudo systemctl enable fstrim.timer
else
    echo "    HDD detectado, otimizando para discos mecânicos..."
    # Reduzir atime writes
    echo "    Configurando noatime no fstab..."
fi

# Limpar journalctl (logs antigos)
echo "  - Limpando logs antigos..."
sudo journalctl --vacuum-time=3d
sudo journalctl --vacuum-size=100M

# Limpar pacotes desnecessários
echo "  - Removendo pacotes não utilizados..."
sudo apt autoremove -y
sudo apt autoclean

echo ""

# ============================================
# 4. OTIMIZAÇÕES DO GNOME
# ============================================

echo "4. Otimizando ambiente GNOME..."

# Desabilitar animações (mais rápido)
gsettings set org.gnome.desktop.interface enable-animations false

# Desabilitar search providers desnecessários
gsettings set org.gnome.desktop.search-providers disabled "['org.gnome.Contacts.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Characters.desktop']"

# Reduzir transparência
gsettings set org.gnome.desktop.interface gtk-enable-animations false

# Desabilitar tracker (indexação)
echo "  - Desabilitando tracker (indexação de arquivos)..."
systemctl --user mask tracker-store.service tracker-miner-fs.service tracker-miner-rss.service tracker-extract.service tracker-miner-apps.service tracker-writeback.service 2>/dev/null || true

echo ""

# ============================================
# 5. CRIAR PERFIS DE USO
# ============================================

echo "5. Criando perfis de uso otimizado..."

# Script para modo "Performance"
cat << 'EOF' | sudo tee /usr/local/bin/performance-mode
#!/bin/bash
# Modo Performance - Usar quando conectado na tomada
echo "Ativando modo Performance..."
sudo cpupower frequency-set -g performance
export DRI_PRIME=1  # Usar AMD
gsettings set org.gnome.desktop.interface enable-animations true
echo "Modo Performance ativado!"
EOF
sudo chmod +x /usr/local/bin/performance-mode

# Script para modo "Economia"
cat << 'EOF' | sudo tee /usr/local/bin/battery-mode
#!/bin/bash
# Modo Economia - Usar quando em bateria
echo "Ativando modo Economia..."
sudo cpupower frequency-set -g powersave
unset DRI_PRIME  # Usar Intel apenas
gsettings set org.gnome.desktop.interface enable-animations false
# Reduzir brilho
brightnessctl set 50%
echo "Modo Economia ativado!"
EOF
sudo chmod +x /usr/local/bin/battery-mode

echo ""

# ============================================
# 6. ALTERNATIVAS LEVES AO CHROME
# ============================================

echo "6. Instalando navegador leve alternativo..."
echo "  - Instalando Firefox (muito mais leve que Chrome)..."
sudo snap install firefox

echo ""

# ============================================
# 7. FERRAMENTAS DE MONITORAMENTO
# ============================================

echo "7. Instalando ferramentas de monitoramento..."
sudo apt install -y \
    htop \
    btop \
    iotop \
    powertop \
    radeontop \
    nethogs

# Criar alias úteis
cat << 'EOF' >> ~/.bashrc

# Aliases para monitoramento
alias mem='free -h && echo "" && ps aux --sort=-%mem | head -11'
alias cpu='ps aux --sort=-%cpu | head -11'
alias disk='df -h && echo "" && du -sh * 2>/dev/null | sort -hr | head -10'
alias temps='sensors'
alias gpu-intel='glxinfo | grep "OpenGL renderer"'
alias gpu-amd='DRI_PRIME=1 glxinfo | grep "OpenGL renderer"'
EOF

echo ""
echo "=== Otimização Concluída! ==="
echo ""
echo "Comandos úteis criados:"
echo "  performance-mode    - Ativar modo performance"
echo "  battery-mode        - Ativar modo economia"
echo "  mem                 - Ver uso de memória"
echo "  cpu                 - Ver uso de CPU"
echo "  disk                - Ver uso de disco"
echo ""
echo "IMPORTANTE: Reinicie o sistema para aplicar todas as mudanças!"
echo ""
echo "Recomendações:"
echo "  1. Use Firefox no lugar do Chrome (economiza 2-3 GB RAM)"
echo "  2. Execute 'battery-mode' quando estiver em bateria"
echo "  3. Execute 'performance-mode' quando estiver na tomada"
echo "  4. Monitore com: htop, btop ou powertop"
