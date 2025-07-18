#!/bin/bash

# Verifica se o processo do Rofi já está em execução
if pgrep -x "rofi" > /dev/null
then
    # Se o Rofi estiver aberto, o processo é encerrado
    pkill -x "rofi"
else
    # Se não, o script para escolher o cursor é executado
    bash ~/.config/nero/scripts/cursor-theme.sh
fi