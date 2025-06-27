#!/bin/bash
set -e

INSTALLER_VERSION="1.0.0"
CREATED_DATE="2024-06-27"

# Get file creation or modification time
CREATED_TIME=$(stat -c %w "$0")
if [ "$CREATED_TIME" = "-" ]; then
  CREATED_TIME=$(stat -c %y "$0")
fi

echo "Ultimate AI Trader Installer version: $INSTALLER_VERSION"
echo "Script created on: $CREATED_DATE"
echo "Script file creation time: $CREATED_TIME"
echo "Script run at: $(date)"
echo "Starting Ultimate AI Trader setup..."

# Update system & install dependencies
apt update && apt upgrade -y
apt install -y python3 python3-pip git docker.io docker-compose ufw fail2ban curl

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

# Setup firewall
ufw allow ssh
ufw allow 8080
ufw --force enable

# Fail2Ban setup (basic)
systemctl enable fail2ban
systemctl start fail2ban

# Pull Docker images and start services
docker-compose up -d --build

echo "Setup complete. Access the dashboard at http://<YOUR_VM_IP>:8080"
