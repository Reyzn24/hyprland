#!/bin/bash
set -e  # Para o script se qualquer comando falhar

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

# Escolha manual do shell
echo ""
echo "Qual shell você está usando?"
select SHELL_CHOICE in "bash" "zsh" "fish"; do
    case $SHELL_CHOICE in
        bash)
            PROFILE_FILE="$HOME/.bashrc"
            if ! grep -q 'export PATH=\$HOME/.npm-global/bin:\$PATH' "$PROFILE_FILE"; then
                echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> "$PROFILE_FILE"
            fi
            echo "Configuração adicionada ao $PROFILE_FILE"
            break
            ;;
        zsh)
            PROFILE_FILE="$HOME/.zshrc"
            if ! grep -q 'export PATH=\$HOME/.npm-global/bin:\$PATH' "$PROFILE_FILE"; then
                echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> "$PROFILE_FILE"
            fi
            echo "Configuração adicionada ao $PROFILE_FILE"
            break
            ;;
        fish)
            PROFILE_FILE="$HOME/.config/fish/config.fish"
            if ! grep -q 'set -U fish_user_paths ~/.npm-global/bin' "$PROFILE_FILE"; then
                echo 'set -U fish_user_paths ~/.npm-global/bin $fish_user_paths' >> "$PROFILE_FILE"
            fi
            echo "Configuração adicionada ao $PROFILE_FILE"
            break
            ;;
        *)
            echo "Opção inválida. Escolha 1, 2 ou 3."
            ;;
    esac
done

# Aplica PATH na sessão atual
export PATH="$HOME/.npm-global/bin:$PATH"

# Menu: Instalar ou Desinstalar
echo ""
echo "Antes de continuar, selecione uma opção:"
select ACTION in "Instalar" "Desinstalar"; do
    case $ACTION in
        Instalar)
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
            break
            ;;
        Desinstalar)
            echo ""
            echo "Qual CLI você deseja desinstalar?"
            select UNINSTALL_CHOICE in "Claude (Anthropic)" "Gemini (Google)"; do
                case $REPLY in
                    1)
                        echo "Desinstalando Claude CLI..."
                        npm uninstall -g @anthropic-ai/claude-code
                        echo "Claude CLI desinstalado com sucesso!"
                        break
                        ;;
                    2)
                        echo "Desinstalando Gemini CLI..."
                        npm uninstall -g @google/gemini-cli
                        echo "Gemini CLI desinstalado com sucesso!"
                        break
                        ;;
                    *)
                        echo "Opção inválida. Escolha 1 ou 2."
                        ;;
                esac
            done
            break
            ;;
        *)
            echo "Opção inválida. Escolha 1 ou 2."
            ;;
    esac
done

echo ""
echo "Operação concluída! Reinicie o terminal ou rode:"
echo "source $PROFILE_FILE"
