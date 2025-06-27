# 1. Install system dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential wget curl git python3 python3-pip docker.io docker-compose ufw fail2ban software-properties-common

# 2. Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# 3. Install TA-Lib C library
cd /tmp
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib
./configure --prefix=/usr
make -j$(nproc)
sudo make install
sudo ldconfig
sudo ln -sf /usr/lib/libta_lib.so /usr/lib/x86_64-linux-gnu/libta_lib.so || true

# 4. Install Python 3.11 and venv if needed
if ! command -v python3.11 >/dev/null 2>&1; then
  sudo apt install -y software-properties-common
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt update
  sudo apt install -y python3.11 python3.11-venv python3.11-dev
fi

# 5. Clone your repo if needed
if [ ! -d "/opt/ultimate-ai-trader" ]; then
  sudo git clone https://github.com/kosalabtw/ultimate-ai-trader.git /opt/ultimate-ai-trader
  sudo chown -R $USER:$USER /opt/ultimate-ai-trader
fi

cd /opt/ultimate-ai-trader

# 6. Create and activate Python 3.11 venv
python3.11 -m venv venv
source venv/bin/activate

# 7. Install Python dependencies
pip install --upgrade pip
pip install ta-lib

# 8. Setup firewall
sudo ufw allow ssh
sudo ufw allow 8080
sudo ufw --force enable

# 9. Fail2Ban setup
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 10. Pull Docker images and start services
sudo docker-compose up -d --build

echo "Setup complete. Access the dashboard at http://<YOUR_VM_IP>:8080"# ...existing code...

# Install TA-Lib C library if not present
if [ ! -f "/usr/lib/libta_lib.so" ]; then
  echo "Installing TA-Lib C library..."
  apt install -y build-essential wget
  cd /tmp
  wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
  tar -xzf ta-lib-0.4.0-src.tar.gz
  cd ta-lib
  ./configure --prefix=/usr
  make -j$(nproc)
  make install
  ldconfig
  cd /opt/ultimate-ai-trader
  ln -sf /usr/lib/libta_lib.so /usr/lib/x86_64-linux-gnu/libta_lib.so || true
fi

# Install Python 3.11 and venv if needed
if ! command -v python3.11 >/dev/null 2>&1; then
  apt install -y software-properties-common
  add-apt-repository -y ppa:deadsnakes/ppa
  apt update
  apt install -y python3.11 python3.11-venv python3.11-dev
fi

python3.11 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install ta-lib

# ...rest of your script...
