#!/bin/bash
set -e

echo "Starting Ultimate AI Trader setup..."

# 1. Update system & install dependencies
apt update && apt upgrade -y
apt install -y python3 python3-pip python3-venv git docker.io docker-compose ufw fail2ban curl build-essential wget

# 2. Enable and start Docker
systemctl enable docker
systemctl start docker

# 3. Clone project repo if needed
if [ ! -d "/opt/ultimate-ai-trader" ]; then
  git clone https://github.com/kosalabtw/ultimate-ai-trader.git /opt/ultimate-ai-trader
else
  echo "Repo already cloned"
fi

cd /opt/ultimate-ai-trader

# 4. Build and install TA-Lib C library if missing
if [ ! -f "/usr/lib/libta_lib.so.0.0.0" ]; then
  echo "Installing TA-Lib C library..."
  cd /tmp
  wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
  tar -xzf ta-lib-0.4.0-src.tar.gz
  cd ta-lib
  ./configure --prefix=/usr
  make -j$(nproc)
  make install
  ldconfig
  cd /opt/ultimate-ai-trader
  ln -sf /usr/lib/libta_lib.so.0.0.0 /usr/lib/libta_lib.so
  ln -sf /usr/lib/libta_lib.so /usr/lib/x86_64-linux-gnu/libta_lib.so
fi

# 5. Create and activate Python venv
python3 -m venv venv
source venv/bin/activate

# 6. Upgrade pip and install Python dependencies
pip install --upgrade pip
pip install ta-lib

# 7. Setup firewall
ufw allow ssh
ufw allow 8080
ufw --force enable

# 8. Fail2Ban setup
systemctl enable fail2ban
systemctl start fail2ban

# 9. Pull Docker images and start services
docker-compose up -d --build

echo "✅ Setup complete. Access the dashboard at http://<YOUR_VM_IP>:8080"
