#!/bin/bash

# --- Configurações ---
REMOTE_NAME="gdrive"
MOUNT_DIR="$HOME/gdrive"
LOG_FILE="$HOME/.local/share/rclone/mount.log"

# --- TimeOut ---
MOUNT_TIMEOUT=15

# --- Script ---
mkdir -p "$MOUNT_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

if findmnt -n --target "$MOUNT_DIR" > /dev/null; then
    echo "Google Drive já está montado em $MOUNT_DIR"
    notify-send "Google Drive" "Já está montado."
    exit 0
fi

echo "Montando Google Drive em $MOUNT_DIR..."
rclone mount "$REMOTE_NAME:" "$MOUNT_DIR" \
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

# --- VERIFICAÇÃO ROBUSTA ---
# Tenta listar o conteúdo da montagem. Se falhar, a montagem não está funcional.
# O timeout garante que o script não fique preso indefinidamente.
if timeout "$MOUNT_TIMEOUT"  ls -l "$MOUNT_DIR" > /dev/null 2>&1; then
    echo "Montagem realizada e verificada com sucesso."
    notify-send "Google Drive" "Montado com sucesso em $MOUNT_DIR"
    # Agora sim, podemos abrir o gerenciador de arquivos com segurança.
    gio open "$MOUNT_DIR"
else
    echo "Falha ao verificar a montagem do Google Drive."
    echo "Tentando desmontar para limpar o sistema..."
    fusermount -u "$MOUNT_DIR"
    echo "Verifique o log para detalhes do erro em: $LOG_FILE"
    notify-send "Erro ao montar Google Drive" "A verificação falhou. Verifique o log."
    exit 1
fi

exit 0
