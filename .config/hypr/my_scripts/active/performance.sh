#!/bin/bash

# Define governor e ativa Turbo Boost
sudo cpupower frequency-set -g performance
echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null

# Notificação
notify-send "Modo: Desempenho" "Governor: performance | Turbo Boost: ativado"
