#!/usr/bin/env bash

clear

set -euo pipefail

echo "#------------------------#"
echo "# Configurando bluetooth #"
echo "#------------------------#"

# Pacotes necessários para cada gerenciador
PACKAGES_FEDORA=(bluez bluez-tools blueman pipewire pipewire-pulseaudio wireplumber)
PACKAGES_ARCH=(bluez bluez-utils blueman pipewire pipewire-pulse wireplumber)

# Detecta gerenciador de pacotes
if command -v dnf &>/dev/null; then
    DISTRO="fedora"
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
    ENABLE_SERVICE_CMD="sudo systemctl enable --now bluetooth.service"
    ENABLE_SERVICE_WIREPLUMBER="systemctl --user enable --now wireplumber.service"
    PACKAGES=("${PACKAGES_FEDORA[@]}")
elif command -v pacman &>/dev/null; then
    DISTRO="arch"
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    ENABLE_SERVICE_CMD="sudo systemctl enable --now bluetooth.service"
    ENABLE_SERVICE_WIREPLUMBER="systemctl --user enable --now wireplumber.service"
    PACKAGES=("${PACKAGES_ARCH[@]}")
else
    echo "Gerenciador de pacotes não suportado pelo script."
    exit 1
fi

echo "Gerenciador de pacotes detectado: $PKG_MANAGER"

# Função para verificar se pacote está instalado
is_installed() {
    local pkg=$1
    if [[ "$PKG_MANAGER" == "dnf" ]]; then
        rpm -q "$pkg" &>/dev/null
    elif [[ "$PKG_MANAGER" == "pacman" ]]; then
        pacman -Q "$pkg" &>/dev/null
    fi
}

# Lista dos pacotes que precisam instalar
to_install=()

echo "Verificando pacotes instalados..."

for pkg in "${PACKAGES[@]}"; do
    if is_installed "$pkg"; then
        echo "Pacote '$pkg' Já instalado, pulando."
    else
        echo "Pacote '$pkg' NÃO instalado, instalando."
        to_install+=("$pkg")
    fi
done

if (( ${#to_install[@]} > 0 )); then
    echo "Instalando pacotes: ${to_install[*]}"
    $INSTALL_CMD "${to_install[@]}"
else
    echo "Todos os pacotes já estavam instalados."
fi

if systemctl is-active --quiet bluetooth.service; then
    echo "bluetooth.service já está ativo."
else
    echo "Ativando serviço Bluetooth..."
    if ! $ENABLE_SERVICE_CMD; then
        echo "Erro ao ativar o serviço Bluetooth."
        exit 1
    fi
fi

if systemctl --user is-active --quiet wireplumber.service; then
    echo "Wireplumber.service já está ativo."
else
    echo "Ativando serviço wireplumber.service..."
    if ! $ENABLE_SERVICE_WIREPLUMBER; then
        echo "Erro ao ativar o serviço Wireplumber."
        exit 1
    fi
fi

echo "Instalação e configuração concluídas!"