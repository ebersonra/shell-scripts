#!/bin/bash
# Script para configurar AMD Radeon R7 M260 no Dell Inspiron 5448
# Ubuntu 24.04 com sistema híbrido Intel + AMD

set -e

echo "=== Configuração AMD Radeon R7 M260 + Intel HD 5500 ==="
echo ""

# 1. Verificar estado atual
echo "1. Verificando GPUs disponíveis..."
lspci | grep -i vga
echo ""

# 2. Instalar drivers AMD open-source (AMDGPU)
echo "2. Instalando drivers AMD..."
sudo apt update
sudo apt install -y \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers:i386 \
    libgl1-mesa-dri:i386 \
    mesa-utils \
    vulkan-tools \
    radeontop \
    firmware-amd-graphics

# 3. Verificar se AMDGPU está carregado
echo ""
echo "3. Verificando módulos do kernel..."
lsmod | grep -E "(amdgpu|radeon|i915)"

# 4. Configurar switcheroo para alternar entre GPUs
echo ""
echo "4. Configurando DRI_PRIME para uso da AMD..."
cat << 'EOF' | sudo tee /etc/profile.d/amd-prime.sh
# Usar AMD Radeon por padrão em aplicações
export DRI_PRIME=1
EOF

# 5. Testar qual GPU está ativa
echo ""
echo "5. Testando GPUs..."
echo "GPU Intel (padrão):"
glxinfo | grep "OpenGL renderer"
echo ""
echo "GPU AMD (forçada com DRI_PRIME=1):"
DRI_PRIME=1 glxinfo | grep "OpenGL renderer"

# 6. Criar script para rodar apps na AMD
cat << 'EOF' | sudo tee /usr/local/bin/run-on-amd
#!/bin/bash
# Executar aplicação na GPU AMD
DRI_PRIME=1 "$@"
EOF
sudo chmod +x /usr/local/bin/run-on-amd

# 7. Verificar consumo de energia
echo ""
echo "6. Informações de energia da GPU..."
if [ -f /sys/class/drm/card1/device/power_dpm_state ]; then
    cat /sys/class/drm/card1/device/power_dpm_state
fi

echo ""
echo "=== Configuração concluída! ==="
echo ""
echo "Para usar a AMD em aplicações específicas:"
echo "  run-on-amd google-chrome"
echo "  DRI_PRIME=1 your-app"
echo ""
echo "Para monitorar uso da AMD:"
echo "  radeontop"
echo ""
echo "ATENÇÃO: A AMD só será usada quando explicitamente solicitado"
echo "para economizar bateria. O sistema usa Intel por padrão."
