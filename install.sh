# ...existing code...

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
