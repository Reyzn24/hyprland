#!/usr/bin/env bash

mkdir -p ~/Imagens/wallpaper

page=$((1 + RANDOM % 1000)); 

response=$(curl "https://konachan.com/post.json?tags=rating%3Aquestionable&limit=1&page=$page")

link=$(echo "$response" | jq '.[0].file_url' -r); 

ext=$(echo "$link" | awk -F. '{print $NF}')

downloadPath="$HOME/Imagens/wallpaper/konachan_random_image_$(date +%Y%m%d%H%M%S).$ext"

curl "$link" -o "$downloadPath"

~/.config/hypr/scripts/wallpaper.sh "$downloadPath"

waypaper --wallpaper "$downloadPath"

# 🔔 TOQUE ao aplicar wallpaper
paplay ~/.config/sound/Message.mp3 &

# 🖼 Notificação
notify-send "✨ Wallpaper aplicado!" "Konachan ($ext)"

# rating:safe         → Imagens seguras para todos os públicos
# rating:questionable → Imagens sugestivas (pode ter sensualidade, mas sem nudez explícita)
# rating:explicit     → Imagens com nudez ou conteúdo adulto explícito

