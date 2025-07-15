#!/bin/bash

WALLPAPERS_DIR="$HOME/.config/wallpapers"  # Caminho seguro para os wallpapers
LAST_WALLPAPER_FILE="$WALLPAPERS_DIR/last_wallpaper"  # Arquivo para salvar o último wallpaper
SWAYBG_PID_FILE="$WALLPAPERS_DIR/swaybg.pid"  # Arquivo para armazenar o PID do swaybg

# Certifique-se de que o diretório de wallpapers existe
mkdir -p "$WALLPAPERS_DIR"

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
            # Verifica se há um processo anterior do swaybg e mata
            if [ -f "$SWAYBG_PID_FILE" ]; then
                kill "$(cat "$SWAYBG_PID_FILE")" 2>/dev/null
                rm "$SWAYBG_PID_FILE"
            fi
            swaybg -i "$LAST_WP" -m fill & echo $! > "$SWAYBG_PID_FILE"
            exit 0
        fi
    fi
    # Se não houver arquivo de último wallpaper ou ele não existir mais, usa o primeiro da lista
    NEW_WALLPAPER="${WALLPAPERS[0]}"
    echo "$NEW_WALLPAPER" > "$LAST_WALLPAPER_FILE"
    # Inicia o swaybg e salva o PID
    swaybg -i "$NEW_WALLPAPER" -m fill & echo $! > "$SWAYBG_PID_FILE"
    exit 0
fi

# Lógica para mudar para o próximo wallpaper (quando chamado com um argumento, ex: "next")
if [ "$1" = "next" ]; then
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

    # Verifica se há um processo anterior do swaybg e mata
    if [ -f "$SWAYBG_PID_FILE" ]; then
        kill "$(cat "$SWAYBG_PID_FILE")" 2>/dev/null
        rm "$SWAYBG_PID_FILE"
    fi

    # Inicia o novo wallpaper e salva o PID
    swaybg -i "$NEW_WALLPAPER" -m fill & echo $! > "$SWAYBG_PID_FILE"
fi


