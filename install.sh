#!/bin/bash
set -e

echo "Starting Ultimate AI Trader setup..."

# Update system & install dependencies
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

# Build and install TA-Lib from source (required for Ubuntu 24.04+)
cd /tmp
curl -L -O https://sourceforge.net/projects/ta-lib/files/ta-lib/0.4.0/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib
./configure --prefix=/usr
make
make install
ldconfig
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

# Create cronjob for retraining (binance, kucoin, kraken)
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/ultimate-ai-trader/cronjobs/retrain_daily.sh") | crontab -

# Pull Docker images and start services (if docker-compose.yml exists)
if [ -f docker-compose.yml ]; then
  docker-compose up -d --build
fi

echo "✅ Installation Complete."
echo "Binance, KuCoin, and Kraken AI trainers are ready."
echo "Access the dashboard at http://149.102.131.127:8080"
