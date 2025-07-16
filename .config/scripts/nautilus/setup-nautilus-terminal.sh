#!/usr/bin/env bash
set -e

# ------------------------
# Verifica a distribuição
# ------------------------
if [ -f /etc/os-release ]; then
    . /etc/os-release
    distro=$ID
else
    echo "Sistema não suportado."
    exit 1
fi

# ------------------------
# Função para definir o terminal padrão
# ------------------------
definir_terminal() {
    read -p "Digite o terminal que deseja usar como padrão (ex: kitty, alacritty, gnome-terminal): " terminal

    if [[ -z "$terminal" ]]; then
        echo "Terminal inválido. Abortando."
        exit 1
    fi

    echo "Configurando $terminal como terminal padrão para a extensão..."

    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal "$terminal"
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal use-generic-terminal-name "true"
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal keybindings "<Ctrl><Alt>t"

    echo "Configuração concluída!"
}

# ------------------------
# Caso Arch Linux
# ------------------------
if [[ "$distro" == "arch" || "$distro" == "manjaro" ]]; then
    echo "Distribuição detectada: Arch Linux"

    if ! pacman -Q nautilus-open-any-terminal &>/dev/null; then
        echo "Extensão não encontrada. Instalando via yay..."
        yay -S --noconfirm nautilus-open-any-terminal
    else
        echo "Extensão já está instalada."
    fi

    definir_terminal
    exit 0

# ------------------------
# Caso Fedora
# ------------------------
elif [[ "$distro" == "fedora" ]]; then
    echo "Distribuição detectada: Fedora"

    if ! rpm -q nautilus-open-any-terminal &>/dev/null; then
        echo "Habilitando repositório COPR..."
        sudo dnf copr enable monkeygold/nautilus-open-any-terminal -y

        echo "Instalando extensão..."
        sudo dnf install nautilus-open-any-terminal -y
    else
        echo "Extensão já está instalada."
    fi

    definir_terminal
    exit 0

# ------------------------
# Outro sistema
# ------------------------
else
    echo "Distribuição $distro não suportada por este script."
    exit 1
fi
