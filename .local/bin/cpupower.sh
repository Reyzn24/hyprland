#!/usr/bin/env bash

# Verifica se cpupower e kitty estão instalados
if ! command -v cpupower >/dev/null || ! command -v kitty >/dev/null; then
  echo "cpupower e kitty não encontrados."
  read -p "Deseja instalar cpupower e kitty agora? (s/n): " resposta
  if [[ "$resposta" =~ ^[Ss]$ ]]; then
    echo "Instalando cpupower e kitty..."
    sudo pacman -S --noconfirm cpupower kitty
    if [ $? -ne 0 ]; then
      echo "Falha na instalação do cpupower e kitty. Abortando."
      exit 1
    fi
  else
    echo "cpupower e kitty são necessários para o script funcionar. Abortando."
    exit 1
  fi
fi

# Obs: Entradas em ingles pois acho legal assim. 

clear
echo "Select CPU governor:"
echo "1) power-save"
echo "2) balanced"
echo "3) performance"
echo "4) Check current governor"
echo -n "#? "
read -r escolha

case "$escolha" in
  1)
    sudo cpupower frequency-set -g powersave
    echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    notify-send "Mode: Power-Save" "Governor: powersave"
    ;;
  2)
    sudo cpupower frequency-set -g schedutil
    echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    notify-send "Mode: Balanced" "Governor: schedutil"
    ;;
  3)
    sudo cpupower frequency-set -g performance
    echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    notify-send "Modo: Performance" "Governor: performance | Turbo Boost: enable"
    ;;
  4)
    GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    notify-send "CPU Governor:" "$GOVERNOR"
    ;;
  *)
    echo "Opção inválida!"
    exit 1
    ;;
esac
