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

# Ensure TA-Lib C library is installed (skip if already installed)
if ! ldconfig -p | grep -q libta_lib; then
  echo "Building TA-Lib C library from source..."
  apt install -y build-essential curl
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
python3 -m venv venv
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

# Pull Docker images and start services
docker-compose up -d --build

echo "Setup complete. Access the dashboard at http://<vscode_annotation details='%5B%7B%22title%22%3A%22hardcoded
