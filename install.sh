#!/bin/bash
set -e

echo "Starting Ultimate AI Trader setup..."

# 1. Update system & install all required dependencies
apt update && apt upgrade -y
apt install -y python3 python3-pip git docker.io docker-compose ufw fail2ban curl build-essential python3-venv python3.12-venv

# 2. Enable and start Docker
systemctl enable docker
systemctl start docker

# 3. Clone project repo if not already present
if [ ! -d "/opt/ultimate-ai-trader" ]; then
  git clone https://github.com/kosalabtw/ultimate-ai-trader.git /opt/ultimate-ai-trader
else
  echo "Repo already cloned"
fi

cd /opt/ultimate-ai-trader

# 4. Build and install TA-Lib from source (required for Ubuntu 24.04+)
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

# 5. Set timezone to UTC (optional, comment out if not wanted)
timedatectl set-timezone UTC

# 6. Create and activate Python virtual environment
if [ ! -d "venv" ]; then
  python3 -m venv venv
fi
source venv/bin/activate

# 7. Upgrade pip and install Python dependencies (including TA-Lib)
pip install --upgrade pip
pip install freqtrade ta-lib

# 8. Create user directory for Freqtrade
if [ ! -d "user_data" ]; then
  freqtrade create-userdir --userdir user_data
fi

# 9. Copy default config if it exists
if [ -f freqtrade_config.json ]; then
  cp freqtrade_config.json user_data/config.json
fi

# 10. Setup firewall
ufw allow ssh
ufw allow 8080
ufw --force enable

# 11. Fail2Ban setup (basic)
systemctl enable fail2ban
systemctl start fail2ban

# 12. Create cronjob for retraining (binance, kucoin, kraken)
if [ -d cronjobs ] && [ -f cronjobs/retrain_daily.sh ]; then
  (crontab -l 2>/dev/null; echo "0 2 * * * /opt/ultimate-ai-trader/cronjobs/retrain_daily.sh") | crontab -
fi

# 13. Pull Docker images and start services (if docker-compose.yml exists)
if [ -f docker-compose.yml ]; then
  docker-compose up -d --build
fi

echo "✅ Installation Complete."
echo "Binance, KuCoin, and Kraken AI trainers are ready."
echo "Access the dashboard at http://149.102.131.127:8080"
