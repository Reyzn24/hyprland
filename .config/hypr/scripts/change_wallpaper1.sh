#!/bin/bash

WALLPAPERS_DIR="$HOME/.config/wallpapers" # Pasta de wallpapers padrão
LAST_WALLPAPER_FILE="/tmp/last_wallpaper" # Arquivo temporário para guardar o último wallpaper

# Pega uma lista de todos os wallpapers na pasta
mapfile -t WALLPAPERS < <(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "Nenhum wallpaper encontrado em $WALLPAPERS_DIR"
    exit 1
fi

CURRENT_INDEX=-1

# Tenta encontrar o índice do wallpaper atual
if [ -f "$LAST_WALLPAPER_FILE" ]; then
    LAST_WP=$(cat "$LAST_WALLPAPER_FILE")
    for i in "${!WALLPAPERS[@]}"; do
        if [[ "${WALLPAPERS[$i]}" == "$LAST_WP" ]]; then
            CURRENT_INDEX=$i
            break
        fi
    done
fi

NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPERS[@]} ))
NEW_WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"

echo "$NEW_WALLPAPER" > "$LAST_WALLPAPER_FILE"

swaybg -i "$NEW_WALLPAPER" -m fill # Ou o modo que preferir (stretch, fit, center, etc.)

