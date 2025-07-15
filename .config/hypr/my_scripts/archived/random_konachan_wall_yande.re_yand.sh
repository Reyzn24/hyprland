#!/usr/bin/env bash

# Criar pasta destino
mkdir -p ~/Imagens/wallpaper

# Alternar entre Konachan e Yande.re
if (( RANDOM % 2 )); then
    SITE_NAME="Konachan"
    BASE_URL="https://konachan.com"
else
    SITE_NAME="Yande.re"
    BASE_URL="https://yande.re"
fi

# Página aleatória e chamada à API
page=$((1 + RANDOM % 1000))
response=$(curl -s "$BASE_URL/post.json?tags=rating%3Asafe&limit=1&page=$page")

# Extrair link e extensão
link=$(echo "$response" | jq -r '.[0].file_url')
ext=$(echo "$link" | awk -F. '{print $NF}')
filename="anime_${SITE_NAME,,}_$(date +%Y%m%d%H%M%S).$ext"
downloadPath="$HOME/Imagens/wallpaper/$filename"

# Baixar imagem
curl -s "$link" -o "$downloadPath"

# Aplicar com script personalizado + waypaper
~/.config/hypr/scripts/wallpaper.sh "$downloadPath"
waypaper --wallpaper "$downloadPath"

# Notificação
notify-send "✨ Wallpaper aplicado!" "$SITE_NAME ($ext)"

