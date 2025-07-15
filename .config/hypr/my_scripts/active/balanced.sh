#!/bin/bash

# Define governor e desativa Turbo Boost
sudo cpupower frequency-set -g schedutil
echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null

# Notificação
notify-send "Modo: Balanceado" "Governor: schedutil | Turbo Boost: desativado"
