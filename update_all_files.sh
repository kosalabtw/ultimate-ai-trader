#!/bin/bash
set -e

echo "Updating all project files..."

# Create directories
mkdir -p ai_models bot/strategies web_dashboard/templates utils cronjobs

# install.sh
cat > install.sh <<'EOF'
#!/bin/bash
set -e

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

# Set timezone to UTC
timedatectl set-timezone UTC

# Create virtual environment
pip3 install virtualenv
virtualenv venv
source venv/bin/activate

# Install Freqtrade
pip install freqtrade
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
EOF

# freqtrade_config.json
cat > freqtrade_config.json <<'EOF'
{
  "api_key": "YOUR_API_KEY_HERE",
  "api_secret": "YOUR_API_SECRET_HERE",
  "exchange": {
    "name": "binance",
    "ccxt_config": {},
    "ccxt_async_config": {},
    "type": "spot"
  },
  "pair_whitelist": ["BTC/USDT", "ETH/USDT"],
  "stake_currency": "USDT",
  "stake_amount": 10,
  "dry_run": true
}
EOF

# freqtrade_config_kucoin.json
cat > freqtrade_config_kucoin.json <<'EOF'
{
  "api_key": "YOUR_API_KEY_HERE",
  "api_secret": "YOUR_API_SECRET_HERE",
  "exchange": {
    "name": "kucoin",
    "ccxt_config": {},
    "ccxt_async_config": {},
    "type": "spot"
  },
  "pair_whitelist": ["BTC/USDT", "ETH/USDT"],
  "stake_currency": "USDT",
  "stake_amount": 10,
  "dry_run": true
}
EOF

# freqtrade_config_kraken.json
cat > freqtrade_config_kraken.json <<'EOF'
{
  "api_key": "YOUR_API_KEY_HERE",
  "api_secret": "YOUR_API_SECRET_HERE",
  "exchange": {
    "name": "kraken",
    "ccxt_config": {},
    "ccxt_async_config": {},
    "type": "spot"
  },
  "pair_whitelist": ["BTC/USDT", "ETH/USDT"],
  "stake_currency": "USDT",
  "stake_amount": 10,
  "dry_run": true
}
EOF

# ai_models/train_binance.py
cat > ai_models/train_binance.py <<'EOF'
from model_utils import train_model

def main():
    exchange = "binance"
    train_model(exchange)

if __name__ == '__main__':
    main()
EOF

# ai_models/train_kucoin.py
cat > ai_models/train_kucoin.py <<'EOF'
from model_utils import train_model

def main():
    exchange = "kucoin"
    train_model(exchange)

if __name__ == '__main__':
    main()
EOF

# ai_models/train_kraken.py
cat > ai_models/train_kraken.py <<'EOF'
from model_utils import train_model

def main():
    exchange = "kraken"
    train_model(exchange)

if __name__ == '__main__':
    main()
EOF

# ai_models/model_utils.py
cat > ai_models/model_utils.py <<'EOF'
def train_model(exchange):
    print(f"[INFO] Training model for {exchange}...")
    # Placeholder for actual training logic
    # Save model to disk after training
    print(f"[SUCCESS] Model for {exchange} saved.")
EOF

# bot/main.py
cat > bot/main.py <<'EOF'
import time
from strategies.transformer_rl import run_strategy

if __name__ == '__main__':
    while True:
        run_strategy()
        time.sleep(60)
EOF

# bot/arbitrage.py
cat > bot/arbitrage.py <<'EOF'
def run_arbitrage():
    print("[ARBITRAGE] Running arbitrage strategy...")
    # Placeholder for arbitrage logic
EOF

# bot/risk_manager.py
cat > bot/risk_manager.py <<'EOF'
def manage_risk():
    print("[RISK] Managing risk...")
    # Placeholder for risk management logic
EOF

# bot/strategies/transformer_rl.py
cat > bot/strategies/transformer_rl.py <<'EOF'
def run_strategy():
    print("[AI STRATEGY] Running Transformer-RL model...")
    # Predict + trade logic here
EOF

# web_dashboard/app.py
cat > web_dashboard/app.py <<'EOF'
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def index():
    return render_template("index.html")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

# web_dashboard/templates/index.html
cat > web_dashboard/templates/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>AI Crypto Bot Dashboard</title></head>
<body>
  <h1>Welcome to your AI Trading Dashboard</h1>
</body>
</html>
EOF

# utils/api_keys.py
cat > utils/api_keys.py <<'EOF'
import os

def get_api_keys():
    return {
        "api_key": os.getenv("API_KEY"),
        "api_secret": os.getenv("API_SECRET")
    }
EOF

# utils/security.py
cat > utils/security.py <<'EOF'
def secure_config():
    print("[SECURITY] Securing configuration...")
    # Placeholder for security logic
EOF

# utils/telegram_alerts.py
cat > utils/telegram_alerts.py <<'EOF'
import os
import requests

def send_alert(message):
    token = os.getenv("TELEGRAM_TOKEN")
    chat_id = os.getenv("TELEGRAM_CHAT_ID")
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    requests.post(url, data={"chat_id": chat_id, "text": message})
EOF

# cronjobs/retrain_daily.sh
cat > cronjobs/retrain_daily.sh <<'EOF'
#!/bin/bash
cd /opt/ultimate-ai-trader/ai_models
source ../venv/bin/activate
python3 train_binance.py
python3 train_kucoin.py
python3 train_kraken.py
EOF
chmod +x cronjobs/retrain_daily.sh

# cronjobs/backup.sh
cat > cronjobs/backup.sh <<'EOF'
#!/bin/bash
tar czf /opt/ultimate-ai-trader/backups/backup_$(date +%F).tar.gz /opt/ultimate-ai-trader/user_data
EOF
chmod +x cronjobs/backup.sh

# .env.example
cat > .env.example <<'EOF'
API_KEY=your_api_key_here
API_SECRET=your_api_secret_here
TELEGRAM_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id
EOF

# README.md
cat > README.md <<'EOF'
# Ultimate AI Trader

A secure, cloud-based, AI-enhanced crypto trading robot supporting Binance, KuCoin, and Kraken.

## Features

- Automated trading with AI strategies
- Multi-exchange support (Binance, KuCoin, Kraken)
- Web dashboard
- Telegram alerts
- Daily retraining via cron

## Installation

```bash
sudo bash install.sh
```

## Directory Structure

(see repo for details)
EOF

echo "✅ All files updated!"