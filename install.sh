#!/bin/bash
set -e

echo "Starting Ultimate AI Trader setup..."

# Update system & install dependencies (including TA-Lib build deps)
apt update && apt upgrade -y
apt install -y python3 python3-pip python3-venv python3.12-venv git docker.io docker-compose ufw fail2ban curl build-essential libta-lib0 libta-lib0-dev

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

# Set timezone to UTC
timedatectl set-timezone UTC

# Create and activate Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip and install Python dependencies (including TA-Lib)
pip install --upgrade pip
pip install freqtrade ta-lib

# Create user directory for Freqtrade
freqtrade create-userdir --userdir user_data

# Copy default config
cp freqtrade_config.json user_data/config.json

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

echo "✅ Installation Complete."
echo "Binance, KuCoin, and Kraken AI trainers are ready."
echo "Access the dashboard at http://149.102.131.127:8080"
