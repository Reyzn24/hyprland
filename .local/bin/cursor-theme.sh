#!/bin/bash

set -e

#-------------------------------------------------#
#  Configurando tema e tamanho do cursor via Rofi #
#-------------------------------------------------#

# --- Variáveis de configuração ---
ROFI_THEME="$HOME/.config/rofi/config-compact.rasi"
GTK_ICONS_DIR="$HOME/.icons"
HYPRLAND_CURSOR_CONF="$HOME/.config/hypr/hyprland/cursor.conf"

# --- Lógica do Script ---
CURSOR_DIRS=("/usr/share/icons" "$GTK_ICONS_DIR")

# Buscar cursores com index.theme
CURSORES=()
for DIR in "${CURSOR_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        for CURSOR in "$DIR"/*; do
            if [ -f "$CURSOR/index.theme" ]; then
                CURSORES+=("$(basename "$CURSOR")")
            fi
        done
    fi
done

if [ ${#CURSORES[@]} -eq 0 ]; then
    notify-send "Erro" "Nenhum cursor encontrado."
    exit 1
fi

# Menu para escolher o cursor
CURSOR_ESCOLHIDO=$(printf '%s
' "${CURSORES[@]}" | rofi -dmenu -p "Escolha o cursor:" -theme "$ROFI_THEME")
if [ -z "$CURSOR_ESCOLHIDO" ]; then
    notify-send "Cancelado" "Nenhum cursor foi selecionado."  
    exit 1
fi

# Menu para escolher o tamanho
CURSOR_SIZE=$(seq 20 32 | rofi -dmenu -p "Tamanho do cursor:" -theme "$ROFI_THEME")
if [ -z "$CURSOR_SIZE" ]; then 
    notify-send "Cancelado" "Nenhum tamanho foi selecionado." && exit 1
fi

# GTK
mkdir -p "$GTK_ICONS_DIR/default"
cat > "$GTK_ICONS_DIR/default/index.theme" <<EOF
[Icon Theme]
Inherits=$CURSOR_ESCOLHIDO
EOF

# X11
XFILE="$HOME/.Xresources"
[ -f "$HOME/.Xdefaults" ] && XFILE="$HOME/.Xdefaults"
sed -i '/Xcursor.theme/d' "$XFILE" 2>/dev/null || true
sed -i '/Xcursor.size/d' "$XFILE" 2>/dev/null || true
echo "Xcursor.theme: $CURSOR_ESCOLHIDO" >> "$XFILE"
echo "Xcursor.size: $CURSOR_SIZE" >> "$XFILE"

# Hyprland
cat > "$HYPRLAND_CURSOR_CONF" <<EOF
# Este arquivo é gerenciado pelo script cursor-test.sh
env = XCURSOR_THEME,$CURSOR_ESCOLHIDO
env = XCURSOR_SIZE,$CURSOR_SIZE
exec-once = xsetroot -cursor_name $CURSOR_ESCOLHIDO
exec-once = hyprctl setcursor $CURSOR_ESCOLHIDO $CURSOR_SIZE
EOF

# Aplicar Xresources
command -v xrdb &>/dev/null && xrdb "$XFILE"

# Aplicar Hyprland agora
if command -v hyprctl &>/dev/null; then
    hyprctl setcursor "$CURSOR_ESCOLHIDO" "$CURSOR_SIZE"
fi

# Notificação final
notify-send "Cursor aplicado" "Tema: $CURSOR_ESCOLHIDO
Tamanho: $CURSOR_SIZE"
