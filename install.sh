#!/bin/bash
set -e

echo "Starting Ultimate AI Trader setup..."

# Update system & install ALL dependencies
apt update && apt upgrade -y
apt install -y python3 python3-pip git docker.io docker-compose ufw fail2ban curl build-essential python3-venv python3.12-venv

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Clone project repo
if [ ! -d "/opt/ultimate-ai-trader" ]; then
  git clone https://github.com/kosalabtw/ultimate-ai-trader.git /opt/ultimate-ai-trader
else
  echo "Repo already cloned"
fi

cd /opt/ultimate-ai-trader

# RADICAL FIX: Build and install TA-Lib C library from source (required for Ubuntu 24.04+)
if ! ldconfig -p | grep -q libta_lib; then
  echo "Building TA-Lib from source..."
  cd /tmp
  curl -L -O https://sourceforge.net/projects/ta-lib/files/ta-lib/0.4.0/ta-lib-0.4.0-src.tar.gz
  tar -xzf ta-lib-0.4.0-src.tar.gz
  cd ta-lib
  ./configure --prefix=/usr
  make
  make install
  ldconfig
  cd /opt/ultimate-ai-trader
else
  echo "TA-Lib C library already installed."
fi

# Create and activate Python virtual environment
if [ ! -d "venv" ]; then
  python3 -m venv venv
fi
source venv/bin/activate

# Upgrade pip and install Python dependencies (including TA-Lib)
pip install --upgrade pip
pip install freqtrade ta-lib

# Setup firewall
ufw allow ssh
ufw allow 8080
ufw --force enable

# Fail2Ban setup (basic)
systemctl enable fail2ban
systemctl start fail2ban

# Pull Docker images and start services (if docker-compose.yml exists)
if [ -f docker-compose.yml ]; then
  docker-compose up -d --build
fi

echo "✅ Radical Installation Complete."
echo "Binance, KuCoin, and Kraken AI trainers are ready."
echo "Access the dashboard at http://<YOUR_VM_IP>:8080"
