#!/usr/bin/env bash

# Arquivo que armazena o último tipo usado
STATE_FILE="$HOME/.cache/last_wallpaper_rating"
mkdir -p "$(dirname "$STATE_FILE")"

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
        FOLDER="wallpaper_save"
        ;;
    *)
        # fallback
        RATING="safe"
        FOLDER="wallpaper_save"
        ;;
esac

# Salva o tipo atual como o último para a próxima execução
echo "$RATING" > "$STATE_FILE"

# Criar pasta de destino
WALLPAPER_DIR="$HOME/Imagens/$FOLDER"
mkdir -p "$WALLPAPER_DIR"

# Página aleatória
page=$((1 + RANDOM % 1000))

# Busca imagem da API
response=$(curl -s "https://konachan.com/post.json?tags=rating%3A$RATING&limit=1&page=$page")
link=$(echo "$response" | jq -r '.[0].file_url')
ext=$(echo "$link" | awk -F. '{print $NF}')
filename="konachan_${RATING}_$(date +%Y%m%d%H%M%S).$ext"
downloadPath="$WALLPAPER_DIR/$filename"

# Baixar
curl -s "$link" -o "$downloadPath"

# Aplicar
~/.config/hypr/scripts/wallpaper.sh "$downloadPath"
waypaper --wallpaper "$downloadPath"

# Som opcional
[ -f ~/.config/sound/Message.mp3 ] && paplay ~/.config/sound/Message.mp3 &

# Notificação
notify-send "✨ Wallpaper aplicado!" "Konachan ($RATING)"

