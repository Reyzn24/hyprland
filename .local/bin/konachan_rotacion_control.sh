#!/usr/bin/env bash

# Arquivo que armazena o último tipo usado
STATE_FILE="$HOME/.cache/last_wallpaper_rating"
mkdir -p "$(dirname "$STATE_FILE")"

# Define o tipo de transição ao aplicar o wallpaper
#TRANSITION_TYPE="--transition-type outer"
#TRANSITION_POS="--transition-pos 0.5,0.5"
#TRANSITION_FPS="--transition-fps 60"
#TRANSITION_DURATION="--transition-duration 1" 

# Tipos de animações
# grow, fade, wipe, outer e none

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
esac

# Salva o tipo atual como o último para a próxima execução
echo "$RATING" > "$STATE_FILE"

# Criar pasta de destino
WALLPAPER_DIR="$HOME/Imagens/$FOLDER"
mkdir -p "$WALLPAPER_DIR"

# Criar pasta de cache
CACHE_DIR="$HOME/Imagens/Wallpapers"
mkdir -p "$CACHE_DIR"

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

# Copiando imagem para cache apenas se não for explícita
if [[ "$RATING" != "explicit" ]]; then
    cp "$downloadPath" "$CACHE_DIR"
fi

# Aplicando wallpaper
caelestia wallpaper -f "$downloadPath"

~/.config/hypr/scripts/wallpaper.sh "$downloadPath" 

# swww img "$downloadPath" $TRANSITION_TYPE $TRANSITION_POS $TRANSITION_FPS $TRANSITION_DURATION

# Som de notificação
# [ -f ~/.config/sound/Message.mp3 ] && paplay ~/.config/sound/Message.mp3 &

# Notificação
notify-send "✨ Wallpaper aplicado!" "Konachan ($RATING)"

# Aplicar Wallpaper no SDDM
kitty --class sddm-wallpapers -e $HOME/.local/bin/sddm-wallpaper.sh "$downloadPath"

#kitty --class sddm-wallpapers -e bash -c "$HOME/.config/scripts/wallpaper/sddm-wallpaper.sh "$downloadPath" \"$1\"; read -p 'Pressione Enter para sair...'" 

#kitty --class sddm-wallpapers -e bash -c '"$0" "$1"' "$HOME/.config/scripts/wallpaper/sddm-wallpaper.sh" "$downloadPath"