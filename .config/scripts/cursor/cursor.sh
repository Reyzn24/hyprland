#!/bin/bash

echo "#---------------------------------------------------------------#"
echo "# Configurando tema e tamanho do cursor no sistema        ...   #"
echo "#---------------------------------------------------------------#"

CURSOR_DIRS=("/usr/share/icons" "$HOME/.icons")

echo "Detectando temas de cursor instalados..."
CURSORES=()
for DIR in "${CURSOR_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        for CURSOR in "$DIR"/*; do
            if [ -f "$CURSOR/index.theme" ]; then
                NAME=$(basename "$CURSOR")
                CURSORES+=("$NAME")
            fi
        done
    fi
done

if [ ${#CURSORES[@]} -eq 0 ]; then
    echo "Nenhum cursor encontrado nas pastas padrão."
    exit 1
fi

echo "Cursores encontrados:"
select CURSOR_ESCOLHIDO in "${CURSORES[@]}"; do
    if [[ -n "$CURSOR_ESCOLHIDO" ]]; then
        echo "Cursor escolhido: $CURSOR_ESCOLHIDO"
        break
    else
        echo "Opção inválida. Tente novamente."
    fi
done

# Tamanho do cursor
read -rp "Digite o tamanho desejado para o cursor (ex: 24): " CURSOR_SIZE
CURSOR_SIZE=${CURSOR_SIZE:-24}  # valor padrão se vazio

echo "Tamanho definido: $CURSOR_SIZE"

# GTK
mkdir -p "$HOME/.icons/default"
cat > "$HOME/.icons/default/index.theme" <<EOF
[Icon Theme]
Inherits=$CURSOR_ESCOLHIDO
EOF
echo "Cursor definido para GTK em ~/.icons/default/index.theme"

# X11
XFILE="$HOME/.Xresources"
[ -f "$HOME/.Xdefaults" ] && XFILE="$HOME/.Xdefaults"
sed -i '/Xcursor.theme/d' "$XFILE" 2>/dev/null || true
sed -i '/Xcursor.size/d' "$XFILE" 2>/dev/null || true
echo "Xcursor.theme: $CURSOR_ESCOLHIDO" >> "$XFILE"
echo "Xcursor.size: $CURSOR_SIZE" >> "$XFILE"
echo "Cursor definido para X11 em $XFILE"

# Hyprland
HYPRCONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPRCONF" ]; then
    echo "Configurando Hyprland..."

    # Atualiza ou adiciona envs
    ENV_THEME="env = XCURSOR_THEME,$CURSOR_ESCOLHIDO"
    ENV_SIZE="env = XCURSOR_SIZE,$CURSOR_SIZE"

    sed -i "/^env = XCURSOR_THEME.*/d" "$HYPRCONF"
    sed -i "/^env = XCURSOR_SIZE.*/d" "$HYPRCONF"
    echo "$ENV_THEME" >> "$HYPRCONF"
    echo "$ENV_SIZE" >> "$HYPRCONF"

    # Remove exec-once antigos
    sed -i '/exec-once *=.*xsetroot -cursor_name/d' "$HYPRCONF"
    sed -i '/exec-once *=.*hyprctl setcursor/d' "$HYPRCONF"

    # Adiciona novos exec-once
    echo "exec-once = xsetroot -cursor_name $CURSOR_ESCOLHIDO" >> "$HYPRCONF"
    echo "exec-once = hyprctl setcursor $CURSOR_ESCOLHIDO $CURSOR_SIZE" >> "$HYPRCONF"

    echo "Hyprland configurado com tema e tamanho."
else
    echo "Arquivo $HYPRCONF não encontrado. Pulando Hyprland."
fi

echo ""
echo "Cursor '$CURSOR_ESCOLHIDO' (tamanho $CURSOR_SIZE) configurado com sucesso!"
echo "Para aplicar no X11: xrdb $XFILE"
echo "Para aplicar no Hyprland: Super+Shift+R ou reinicie a sessão"
