#!/bin/bash
cd /opt/ultimate-ai-trader/ai_models
source ../venv/bin/activate
python3 train_binance.py
python3 train_kucoin.py
python3 train_kraken.py
