#!/bin/bash
set -e

echo "=== Instalando dependências do sistema ==="
sudo apt-get update -qq
sudo apt-get install -y curl git build-essential libpq-dev libvips sqlite3 nginx certbot python3-certbot-nginx

echo "=== Instalando Docker ==="
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker $USER
fi

echo "=== Instalando Docker Compose ==="
if ! command -v docker compose &> /dev/null; then
  sudo apt-get install -y docker-compose-plugin
fi

echo "=== Configurando firewall ==="
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

echo "=== Configuração concluída! ==="
echo "Faça logout e login novamente para usar Docker sem sudo."
echo "Depois execute: docker compose up -d"
