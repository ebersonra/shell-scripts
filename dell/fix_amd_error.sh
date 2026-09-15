#!/bin/bash
# Script para reverter AMD R7 M260 para driver radeon (legado)
# Resolve erro: "VBIOS did not find boot engine clock value"

set -e

echo "=== Revertendo para driver radeon legado ==="
echo ""

# 1. Remover parâmetros do amdgpu do GRUB
echo "1. Removendo configuração forçada do amdgpu..."

# Backup do GRUB
sudo cp /etc/default/grub /etc/default/grub.backup.$(date +%Y%m%d)

# Remover parâmetros amdgpu se existirem
sudo sed -i 's/radeon\.cik_support=0 amdgpu\.cik_support=1//g' /etc/default/grub
sudo sed -i 's/amdgpu\.si_support=1 radeon\.si_support=0//g' /etc/default/grub

# Adicionar parâmetros para forçar driver radeon
if ! grep -q "radeon.dpm=1" /etc/default/grub; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="radeon.dpm=1 /' /etc/default/grub
fi

echo "  Configuração do GRUB atualizada"

# 2. Blacklistar amdgpu (forçar uso do radeon)
echo ""
echo "2. Blacklistando driver amdgpu..."

cat << 'EOF' | sudo tee /etc/modprobe.d/blacklist-amdgpu.conf
# Blacklist amdgpu para usar radeon legado
# AMD Radeon R7 M260 tem melhor suporte no driver antigo
blacklist amdgpu
EOF

echo "  Driver amdgpu blacklistado"

# 3. Garantir que radeon será carregado
echo ""
echo "3. Configurando carregamento do radeon..."

if ! grep -q "^radeon$" /etc/modules 2>/dev/null; then
    echo "radeon" | sudo tee -a /etc/modules
fi

# 4. Atualizar initramfs e GRUB
echo ""
echo "4. Atualizando initramfs e GRUB..."
sudo update-initramfs -u
sudo update-grub

echo ""
echo "=== Configuração concluída! ==="
echo ""
echo "IMPORTANTE: Reinicie o sistema agora:"
echo "  sudo reboot"
echo ""
echo "Após reiniciar:"
echo "  - O erro do amdgpu não aparecerá mais"
echo "  - A GPU AMD funcionará com driver radeon"
echo "  - Use 'DRI_PRIME=1' para ativar AMD normalmente"
echo ""
echo "Para verificar qual driver está ativo após boot:"
echo "  lsmod | grep -E '(amdgpu|radeon)'"
echo "  Deve mostrar apenas: radeon"
