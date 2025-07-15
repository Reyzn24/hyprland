#!/usr/bin/env bash

# Nome da configuração do QuickShell
QUICKSHELL_CONFIG_NAME="ii"

# Padrões XDG
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Diretórios base
CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"
CACHE_DIR="$XDG_CACHE_HOME/quickshell"
STATE_DIR="$XDG_STATE_HOME/quickshell"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Arquivo que armazena o último tipo usado
STATE_FILE="$STATE_DIR/last_wallpaper_rating"
mkdir -p "$STATE_DIR"

# Lê o último tipo usado
if [[ -f "$STATE_FILE" ]]; then
    LAST=$(<"$STATE_FILE")
else
    LAST="explicit"
fi

# Define o próximo tipo com base no último
case "$LAST" in
    safe)
        RATING="questionable"
        FOLDER="wallpaper_questionable"
        ;;
    questionable)
        RATING="explicit"
        FOLDER="wallpaper_explicit"
        ;;
    explicit)
        RATING="safe"
        FOLDER="wallpaper_safe"
        ;;
    *)
        RATING="safe"
        FOLDER="wallpaper_safe"
        ;;
esac

# Salva o tipo atual como o último para a próxima execução
echo "$RATING" > "$STATE_FILE"

# Diretório de destino
WALLPAPER_DIR="$HOME/Imagens/$FOLDER"
mkdir -p "$WALLPAPER_DIR"

# Página aleatória
page=$((1 + RANDOM % 1000))

# Busca imagem
response=$(curl -s "https://konachan.com/post.json?tags=rating%3A$RATING&limit=1&page=$page")
link=$(echo "$response" | jq -r '.[0].file_url')
ext=$(echo "$link" | awk -F. '{print $NF}')
filename="konachan_${RATING}_$(date +%Y%m%d%H%M%S).$ext"
downloadPath="$WALLPAPER_DIR/$filename"

# Baixar imagem
curl -s "$link" -o "$downloadPath"

# Aplicar como wallpaper e paleta de cores
if [[ -x "$SCRIPT_DIR/switchwall.sh" ]]; then
    "$SCRIPT_DIR/switchwall.sh" --image "$downloadPath"
else
    swww img "$downloadPath"
fi

# Som opcional
[ -f ~/.config/sound/Message.mp3 ] && paplay ~/.config/sound/Message.mp3" &

# Notificação
notify-send "✨ Wallpaper aplicado!" "Konachan ($RATING)"
