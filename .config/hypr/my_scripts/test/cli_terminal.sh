#!/bin/bash

# Verifica se o usuário está usando uma distribuição baseada em Arch
if ! command -v pacman &>/dev/null; then
    echo "Este script é feito para sistemas com pacman (ex: Arch Linux, Manjaro)."
    exit 1
fi

# Instala dependências
echo "Instalando Node.js e npm..."
sudo pacman -Sy --noconfirm nodejs npm

# Configura diretório global do npm
echo "Configurando npm para uso global sem sudo..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Cofigurando o shell
echo ""
echo "Qual shell você está usando?"
select SHELL_CHOICE in "bash" "zsh" "fish"; do
    case $SHELL_CHOICE in
        bash)
            echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> "$HOME/.bashrc"
            PROFILE_FILE="$HOME/.bashrc"
            break
            ;;
        zsh)
            echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> "$HOME/.zshrc"
            PROFILE_FILE="$HOME/.zshrc"
            break
            ;;
        fish)
            echo 'set -U fish_user_paths ~/.npm-global/bin $fish_user_paths' >> "$HOME/.config/fish/config.fish"
            PROFILE_FILE="$HOME/.config/fish/config.fish"
            break
            ;;
        *)
            echo "Opção inválida. Escolha 1, 2 ou 3."
            ;;
    esac
done

# Atualiza PATH na sessão atual
export PATH=$HOME/.npm-global/bin:$PATH

# Permite escolher entre Gemini e Claude
echo ""
echo "Qual CLI você deseja instalar?"
select CHOICE in "Gemini (Google)" "Claude (Anthropic)"; do
    case $REPLY in
        1)
            echo "Instalando Gemini CLI..."
            npm install -g @google/gemini-cli
            echo "Gemini CLI instalado com sucesso!"
            break
            ;;
        2)
            echo "Instalando Claude CLI..."
            npm install -g @anthropic-ai/claude-code
            echo "Claude CLI instalado com sucesso!"
            break
            ;;
        *)
            echo "Opção inválida. Escolha 1 ou 2."
            ;;
    esac
done

echo ""
echo "Instalação concluída! Reinicie o terminal ou rode 'source $PROFILE_FILE' para aplicar o PATH."
