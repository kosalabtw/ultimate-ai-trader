#!/bin/bash
set -e

echo "Starting Ultimate AI Trader setup..."

# Update system & install dependencies
apt update && apt upgrade -y
apt install -y python3 python3-pip git docker.io docker-compose ufw fail2ban curl build-essential software-properties-common

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

# Install TA-Lib C library if not present
if [ ! -f "/usr/lib/libta_lib.so" ]; then
  echo "Installing TA-Lib C library..."
  cd /tmp
  curl -L -O https://sourceforge.net/projects/ta-lib/files/ta-lib/0.4.0/ta-lib-0.4.0-src.tar.gz
  tar -xzf ta-lib-0.4.0-src.tar.gz
  cd ta-lib
  ./configure --prefix=/usr
  make
  make install
  ldconfig
  cd /opt/ultimate-ai-trader
  # Symlink for Ubuntu 24.04 linker
  ln -sf /usr/lib/libta_lib.so /usr/lib/x86_64-linux-gnu/libta_lib.so || true
fi

# Install Python 3.11 from deadsnakes PPA if not present
if ! command -v python3.11 >/dev/null 2>&1; then
  apt install -y software-properties-common
  add-apt-repository -y ppa:deadsnakes/ppa
  apt update
  apt install -y python3.11 python3.11-venv python3.11-dev
fi

# Create and activate Python 3.11 virtual environment
python3.11 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install ta-lib freqtrade

# Setup firewall
ufw allow ssh
ufw allow 8080
ufw --force enable

# Fail2Ban setup (basic)
systemctl enable fail2ban
systemctl start fail2ban

# Pull Docker images and start services
docker-compose up -d --build

echo "Setup complete. Access the dashboard
