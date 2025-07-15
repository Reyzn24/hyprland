#!/bin/bash

# Nome do remote do rclone (ajuste se for diferente)
REMOTE_NAME="gdrive"

# Caminho local onde será montado
MOUNT_DIR="$HOME/gdrive"

# Tempo máximo de espera para montar  (em segundos)
MOUNT_TIMEOUT=35

# Verifica se a pasta já existe, senão cria
mkdir -p "$MOUNT_DIR"

# Verifica se já está montado
if mount | grep -q "$MOUNT_DIR"; then
    echo "Google Drive já está montado em $MOUNT_DIR"
    notify-send "Google Drive" "Já está montado: ($MOUNT_DIR)"
else
    echo "Montando Google Drive em $MOUNT_DIR..."
    rclone mount "$REMOTE_NAME:" "$MOUNT_DIR" 
    --vfs-cache-mode writes \
    --vfs-cache-max-size 2G \
    --dir-cache-time 1h \
    --poll-interval 1m \
    --buffer-size 0M \
    --drive-chunk-size 64M \
    --umask 002 \
    --allow-other \
    --daemon \
    --log-file "$LOG_FILE" \
    --log-level INFO

    
    # Aguarda até que o ponto de montagem esteja ativo (timeout de 10s)
    timeout=$MOUNT_TIMEOUT
    while ! mount | grep -q "$MOUNT_DIR"; do
        sleep 1
        ((timeout--))
        if [ $timeout -le 0 ]; then
            echo "Falha ao montar o Google Drive em $REMOTE_NAME"
            notify-send "Erro ao montar Google Drive:" "($REMOTE_NAME)"
            exit 1
        fi
    done

    # Notificação de sucesso
    notify-send "Google Drive" "Montado com sucesso: ($REMOTE_NAME)"
fi

# Reinicia o Nautilus para reconhecer a montagem
echo "Reiniciando Nautilus..."
nautilus -q &

echo "Google Drive montado e Nautilus recarregado."

