#!/bin/bash

# --- Script para alterar o fundo do sddm-astronaut-theme --- #
# --- Uso: ./sddm-wallpaper.sh /caminho/para/sua/imagem.png ---#

# --- Variáveis ---
THEME_DIR="/usr/share/sddm/themes/sddm-astronaut-theme"
CONFIG_FILE="$THEME_DIR/Themes/astronaut.conf"
DEST_DIR="$THEME_DIR/Backgrounds"
FINAL_NAME="wallpaper-sddm.png"

# Config Log
VERBOSE=false  # Troque para false se não quiser ver mensagens

# Função log
log (){
    $VERBOSE && echo "$@"
}

# Função para aguardar a linha "Background=" aparecer no arquivo
wait_for_background_line() {
    local timeout=5
    local count=0

    log "Procurando pela linha com 'Background=' em '$CONFIG_FILE'..."

    while ! grep -q "^Background=" "$CONFIG_FILE"; do
        if [ $count -ge $timeout ]; then
            echo "ERRO: A linha 'Background=' não foi encontrada em até $timeout segundos."
            exit 1
        fi
        sleep 1
        ((count++))
    done

    log "Linha 'Background=' encontrada!"
}

# --- Verificações Iniciais (executadas como usuário normal) ---

if [ -z "$1" ]; then
    echo "ERRO: Você precisa fornecer o caminho da imagem como argumento."
    echo "Uso: ./$0 /caminho/para/imagem.png"
    exit 1
fi

SOURCE_IMAGE="$1"

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "ERRO: A imagem '$SOURCE_IMAGE' não foi encontrada."
    exit 1
fi

if [ ! -d "$THEME_DIR" ] || [ ! -f "$CONFIG_FILE" ]; then
    echo "ERRO: O tema 'sddm-astronaut-theme' ou seu arquivo de configuração não foi encontrado."
    exit 1
fi

# --- Confirmação ---
echo "Você deseja aplicar este wallpaper?"
echo "1) yes"
echo "2) no"
read -p "#? " user_choice

user_choice_lower=$(echo "$user_choice" | tr '[:upper:]' '[:lower:]')

case "$user_choice_lower" in
    'y'|'yes')
        echo "Digite sua senha para continuar..."
        sudo -v
        if [ $? -ne 0 ]; then
            echo "ERRO: Autenticação sudo falhou ou foi cancelada."
            exit 1
        fi

        IMAGE_NAME=$(basename "$FINAL_NAME")

        log "-> Removendo imagem antiga, se existir..."
        sudo rm -f "$DEST_DIR/$IMAGE_NAME"

        log "-> Copiando a imagem para '$DEST_DIR' e renomeando..."
        sudo cp "$SOURCE_IMAGE" "$DEST_DIR/$IMAGE_NAME"

        wait_for_background_line

        log "-> Atualizando a linha 'Background=' com nova imagem..."
        sudo sed -i "s|^Background=.*|Background=Backgrounds/$IMAGE_NAME|" "$CONFIG_FILE"

        log "Sucesso! O fundo foi alterado para '$IMAGE_NAME'."
        notify-send "SDDM atualizado" "Novo wallpaper aplicado!"
        exit 0
        ;;

    *)
        log "Operação cancelada pelo usuário."
        exit 1
        ;;
esac
