#!/usr/bin/env bash

# 1. Escolher tipo aleatório
case $((RANDOM % 3)) in
    0)
        RATING="safe"
        FOLDER="wallpaper_save"
        ;;
    1)
        RATING="questionable"
        FOLDER="wallpaper_questionable"
        ;;
    2)
        RATING="explicit"
        FOLDER="wallpaper_explicit"
        ;;
esac

# 2. Criar pasta de destino
WALLPAPER_DIR="$HOME/Imagens/$FOLDER"
mkdir -p "$WALLPAPER_DIR"

# 3. Página aleatória e requisição
page=$((1 + RANDOM % 1000))
response=$(curl -s "https://konachan.com/post.json?tags=rating%3A$RATING&limit=1&page=$page")

# 4. Extrair link e extensão
link=$(echo "$response" | jq -r '.[0].file_url')
ext=$(echo "$link" | awk -F. '{print $NF}')
filename="konachan_${RATING}_$(date +%Y%m%d%H%M%S).$ext"
downloadPath="$WALLPAPER_DIR/$filename"

# 5. Baixar imagem
curl -s "$link" -o "$downloadPath"

# 6. Aplicar wallpaper
~/.config/hypr/scripts/wallpaper.sh "$downloadPath"
waypaper --wallpaper "$downloadPath"

# 7. Tocar som (se o arquivo existir)
[ -f ~/.config/sound/Message.mp3 ] && paplay ~/.config/sound/Message.mp3 &

# 8. Notificação
notify-send "✨ Wallpaper aplicado!" "Konachan ($RATING)"

# Comentários:
# safe         → Imagens seguras para todos os públicos
# questionable → Sugestivas, sem nudez explícita
# explicit     → Conteúdo adulto/nudez

