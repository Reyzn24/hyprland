#!/usr/bin/env bash

# Pasta de Wallpaper
WALLPAPER_DIR="$HOME/Imagens/Wallpapers"

# Tipo de transição ao definir o wallpaper
TRANSITION_TYPE= "--transition-type any"

# Escolhe uma imagem aleatória
RANDOM_IMAGE=$(find "WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

# Definindo o Wallpaper
[ -n "$RANDOM_IMAGE"] && swww img "$RANDOM_IMAGE" "$TRANSITION_TYPE"
