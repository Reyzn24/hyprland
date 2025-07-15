#!/bin/bash

WALLPAPERS_DIR="$HOME/.config/wallpapers" # Certifique-se que o caminho está correto
LAST_WALLPAPER_FILE="/hypr/last_wallpaper" # Arquivo temporário para guardar o último wallpaper

# Pega uma lista de todos os wallpapers na pasta
mapfile -t WALLPAPERS < <(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "Nenhum wallpaper encontrado em $WALLPAPERS_DIR"
    exit 1
fi

# Se nenhum argumento for passado (chamado na inicialização, por exemplo)
if [ -z "$1" ]; then
    if [ -f "$LAST_WALLPAPER_FILE" ]; then
        LAST_WP=$(cat "$LAST_WALLPAPER_FILE")
        if [ -f "$LAST_WP" ]; then # Verifica se o arquivo do último wallpaper ainda existe
            swaybg -i "$LAST_WP" -m fill
            exit 0
        fi
    fi
    # Se não houver arquivo de último wallpaper ou ele não existir mais, usa o primeiro da lista
    NEW_WALLPAPER="${WALLPAPERS[0]}"
    echo "$NEW_WALLPAPER" > "$LAST_WALLPAPER_FILE"
    swaybg -i "$NEW_WALLPAPER" -m fill
    exit 0
fi

# Lógica para mudar para o próximo wallpaper (quando chamado com um argumento, ex: "next")
if [ "$1" == "next" ]; then
    CURRENT_INDEX=-1
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
fi

