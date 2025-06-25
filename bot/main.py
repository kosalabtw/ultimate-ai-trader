import time
from strategies.transformer_rl import run_strategy

if __name__ == '__main__':
    while True:
        run_strategy()
        time.sleep(60)
