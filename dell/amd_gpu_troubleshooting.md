# Guia de Configuração: AMD Radeon R7 M260 + Intel HD 5500
# Dell Inspiron 5448 - Sistema Híbrido (Switchable Graphics)

## ENTENDENDO O SISTEMA HÍBRIDO

Seu notebook tem 2 GPUs:
1. **Intel HD Graphics 5500** (integrada) - Baixo consumo, sempre ativa
2. **AMD Radeon R7 M260** (dedicada) - Mais potente, só ativa sob demanda

O Linux usa **PRIME (DRI_PRIME)** para alternar entre elas.

## CONFIGURAÇÃO PASSO A PASSO

### Passo 1: Verificar se as GPUs são reconhecidas

```bash
# Ver todas as GPUs
lspci | grep -i vga

# Deve mostrar algo como:
# 00:02.0 VGA compatible controller: Intel Corporation HD Graphics 5500
# 08:00.0 Display controller: Advanced Micro Devices [AMD/ATI] Topaz XT [Radeon R7 M260/M265]
```

### Passo 2: Verificar drivers instalados

```bash
# Ver módulos carregados
lsmod | grep -E "(amdgpu|radeon|i915)"

# Ver informações da GPU AMD
sudo lshw -C display
```

### Passo 3: Instalar drivers open-source (AMDGPU)

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar mesa e drivers AMD
sudo apt install -y \
    mesa-vulkan-drivers \
    mesa-utils \
    vulkan-tools \
    radeontop \
    linux-firmware

# Adicionar firmware AMD (pode não estar na ISO padrão)
sudo apt install -y firmware-amd-graphics
```

### Passo 4: Verificar qual GPU está ativa

```bash
# Ver GPU Intel (padrão)
glxinfo | grep "OpenGL renderer"

# Ver GPU AMD (forçada)
DRI_PRIME=1 glxinfo | grep "OpenGL renderer"
```

**Resultado esperado:**
- Sem DRI_PRIME: `Mesa Intel(R) HD Graphics 5500`
- Com DRI_PRIME=1: `AMD Radeon R7 M260` ou `AMD TOPAZ`

### Passo 5: Configurar uso da AMD

#### Opção A: Por aplicação (Recomendado)

Rodar app específico na AMD:
```bash
DRI_PRIME=1 google-chrome
DRI_PRIME=1 your-game
DRI_PRIME=1 blender
```

#### Opção B: Criar launchers customizados

Para Chrome na GPU AMD:
```bash
sudo nano /usr/share/applications/chrome-amd.desktop
```

Adicione:
```ini
[Desktop Entry]
Name=Chrome (AMD GPU)
Exec=env DRI_PRIME=1 /usr/bin/google-chrome-stable %U
Icon=google-chrome
Type=Application
Categories=Network;WebBrowser;
```

#### Opção C: Usar AMD por padrão (NÃO RECOMENDADO para bateria)

```bash
echo "export DRI_PRIME=1" >> ~/.profile
```

⚠️ **Aviso**: Isso vai drenar a bateria rapidamente!

## TROUBLESHOOTING

### Problema 1: "glxinfo não encontrado"

```bash
sudo apt install mesa-utils
```

### Problema 2: AMD não aparece em glxinfo

```bash
# Verificar se módulo está carregado
lsmod | grep amdgpu

# Se não estiver, carregar manualmente
sudo modprobe amdgpu

# Adicionar ao carregamento automático
echo "amdgpu" | sudo tee -a /etc/modules
```

### Problema 3: DRI_PRIME=1 ainda mostra Intel

**Causa**: Sua GPU pode estar usando driver `radeon` antigo ao invés de `amdgpu`

**Solução**: Forçar uso do amdgpu
```bash
# Adicionar parâmetro ao GRUB
sudo nano /etc/default/grub

# Adicionar à linha GRUB_CMDLINE_LINUX_DEFAULT:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash radeon.cik_support=0 amdgpu.cik_support=1"

# Atualizar GRUB
sudo update-grub

# Reiniciar
sudo reboot
```

### Problema 4: Tela preta após configuração

**Solução 1**: Remover configurações e usar Xorg ao invés de Wayland
```bash
# Fazer logout
# Na tela de login, clicar no ícone de engrenagem
# Selecionar "Ubuntu on Xorg"
# Fazer login
```

**Solução 2**: Voltar configuração do GRUB
```bash
# Boot em recovery mode
# Editar /etc/default/grub
# Remover parâmetros do amdgpu
# sudo update-grub
# sudo reboot
```

### Problema 5: AMD reconhecida mas baixo desempenho

```bash
# Verificar power profile
cat /sys/class/drm/card1/device/power_dpm_state

# Se estiver em "battery", mudar para "performance"
echo "performance" | sudo tee /sys/class/drm/card1/device/power_dpm_state
```

### Problema 6: Monitorar se AMD está sendo usada

```bash
# Terminal 1: Monitorar AMD
radeontop

# Terminal 2: Rodar app na AMD
DRI_PRIME=1 glxgears

# Você deve ver atividade no radeontop
```

## BENCHMARKS

### Teste básico (glxgears)

```bash
# Intel
glxgears
# Resultado esperado: ~800-1200 FPS

# AMD
DRI_PRIME=1 glxgears
# Resultado esperado: ~2000-4000 FPS (se funcionando)
```

### Teste com glmark2

```bash
# Instalar
sudo apt install glmark2

# Intel
glmark2

# AMD
DRI_PRIME=1 glmark2

# AMD deve ter score 2-3x maior que Intel
```

## OTIMIZAÇÕES ADICIONAIS

### 1. Desabilitar AMD quando não usar (economizar bateria)

Criar script toggle:
```bash
cat << 'EOF' > ~/toggle-gpu.sh
#!/bin/bash
if [ "$DRI_PRIME" = "1" ]; then
    unset DRI_PRIME
    echo "Usando Intel (economia)"
else
    export DRI_PRIME=1
    echo "Usando AMD (performance)"
fi
EOF
chmod +x ~/toggle-gpu.sh
```

### 2. Ver temperatura da GPU

```bash
# Instalar sensors
sudo apt install lm-sensors
sudo sensors-detect

# Ver temperaturas
sensors

# Monitorar GPU AMD
watch -n 1 'cat /sys/class/drm/card1/device/hwmon/hwmon*/temp1_input'
```

### 3. Limitar TDP da AMD (reduzir calor/consumo)

```bash
# Ver TDP atual
cat /sys/class/drm/card1/device/hwmon/hwmon*/power1_cap

# Limitar a 15W (exemplo)
echo 15000000 | sudo tee /sys/class/drm/card1/device/hwmon/hwmon*/power1_cap
```

## QUANDO USAR CADA GPU

### Use Intel (padrão) para:
- Navegação web
- Edição de texto
- Email
- Tarefas de escritório
- **Qualquer coisa em bateria**

### Use AMD (DRI_PRIME=1) para:
- Edição de vídeo/imagem (DaVinci, GIMP, Blender)
- Jogos
- Renderização 3D
- Machine Learning
- **Apenas quando conectado na tomada**

## DRIVER PROPRIETÁRIO AMD (NÃO RECOMENDADO)

⚠️ **Aviso**: AMD descontinuou drivers proprietários para GPUs antigas.
A R7 M260 (2015) não tem suporte oficial.

**Use sempre os drivers open-source (mesa/amdgpu)** que estão integrados ao kernel.

## VERIFICAÇÃO FINAL

Após configurar tudo, execute:
```bash
# 1. Ver GPUs
lspci | grep -i vga

# 2. Ver drivers
lsmod | grep -E "(amdgpu|i915)"

# 3. Testar Intel
glxinfo | grep "OpenGL renderer"

# 4. Testar AMD
DRI_PRIME=1 glxinfo | grep "OpenGL renderer"

# 5. Se tudo funcionar:
# Intel deve mostrar: Mesa Intel HD Graphics 5500
# AMD deve mostrar: AMD Radeon R7 M260 ou AMD TOPAZ
```

## DESEMPENHO ESPERADO

### Intel HD 5500 (Broadwell GT2)
- OpenGL: 4.6
- DirectX: 11.2
- Passmark: ~700
- Uso: Tarefas leves

### AMD Radeon R7 M260 (Oland/Cape Verde)
- OpenGL: 4.5
- DirectX: 11.2
- Passmark: ~1200 (70% melhor que Intel)
- Uso: Gaming leve, edição

**Conclusão**: A AMD não é uma GPU poderosa para padrões modernos (2015),
mas é 70% melhor que a Intel integrada para tarefas gráficas.
