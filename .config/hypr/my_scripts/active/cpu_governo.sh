#!/bin/bash

# Lê o modo atual do escalonador de frequência da CPU (governador) do primeiro núcleo (cpu0)
GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

# Exibe no terminal o modo atual da CPU (por exemplo: performance, powersave, etc.)
echo "CPU: $GOVERNOR"

