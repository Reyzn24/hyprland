#!/usr/bin/env bash

# Script para usar "Abrir no Terminal" do Nautilus com Kitty no lugar do GNOME Terminal

set -e

# 1. Habilitar o repositório COPR
echo "➤ Habilitando repositório COPR para nautilus-open-any-terminal..."
sudo dnf copr enable monkeygold/nautilus-open-any-terminal -y

# 2. Instalar a extensão
echo "➤ Instalando extensão nautilus-open-any-terminal..."
sudo dnf install nautilus-open-any-terminal -y

# 3. Criar ou sobrescrever o gnome-terminal fake
echo "➤ Criando script que redireciona gnome-terminal para kitty..."

cat << 'EOF' | sudo tee /usr/bin/gnome-terminal > /dev/null
#!/bin/bash
kitty "$@"
EOF

sudo chmod +x /usr/bin/gnome-terminal

# 4. Reiniciar o Nautilus
echo "➤ Reiniciando o Nautilus..."
nautilus -q

echo "Tudo pronto! Agora o 'Abrir no Terminal' do Nautilus vai abrir o Kitty"
