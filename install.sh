#!/bin/bash
set -e

echo "Starting Ultimate AI Trader setup..."

apt update && apt upgrade -y
apt install -y python3 python3-pip git docker.io docker-compose ufw fail2ban curl

systemctl enable docker
systemctl start docker

if [ ! -d "/opt/ultimate-ai-trader" ]; then
  git clone https://github.com/kosalabtw/ultimate-ai-trader.git /opt/ultimate-ai-trader
else
  echo "Repo already cloned"
fi

cd /opt/ultimate-ai-trader

timedatectl set-timezone UTC

pip3 install virtualenv
virtualenv venv
source venv/bin/activate

pip install freqtrade
freqtrade create-userdir --userdir user_data

cp freqtrade_config.json user_data/config.json

ufw allow ssh
ufw allow 8080
ufw --force enable

systemctl enable fail2ban
systemctl start fail2ban

(crontab -l 2>/dev/null; echo "0 2 * * * /opt/ultimate-ai-trader/cronjobs/retrain_daily.sh") | crontab -

if [ -f docker-compose.yml ]; then
  docker-compose up -d --build
fi

echo "✅ Installation Complete."
echo "Binance, KuCoin, and Kraken AI trainers are ready."
echo "Access the dashboard at http://<YOUR_VM_IP>:8080"
