#!/bin/bash
# =========================================
# setup.sh - Secure Chat Project Setup Script
# =========================================
# This script prepares your CentOS VM to run
# the Secure Chat System project.
# It ensures nmap is installed so ./scan_traffic.sh won't print "nmap: command not found".
# =========================================

set -euo pipefail

echo "[SETUP] Checking package manager and installing basic packages..."

# Install required tools:
#  - python3 : run scripts
#  - tcpdump : capture traffic
#  - nmap    : port scanning (used by scan_traffic.sh)
#  - nmap-ncat / nc : netcat for simple TCP tests
#  - tmux    : terminal multiplexer for demo panes
sudo dnf makecache --assumeyes || true
sudo dnf install -y python3 tcpdump nmap nmap-ncat nc tmux || true
sudo dnf install wireshark wireshark-cli -y
sudo dnf groupinstall "Development Tools" -y
sudo dnf config-manager --set-enabled crb
sudo dnf makecache
sudo dnf install libpcap-devel -y
sudo dnf install tcl-devel gcc make libpcap-devel -y
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf makecache
sudo dnf install hping3 -y

# Enable CodeReady Builder (provides libpcap-devel and other developer headers)
sudo dnf config-manager --set-enabled crb

# Update metadata and install libpcap-devel
sudo dnf makecache
sudo dnf install libpcap-devel -y


# Try to install hping3 if available (optional)
echo "[SETUP] Checking for hping3 (optional attack simulator)..."
if ! sudo dnf install -y hping3; then
    echo "[WARNING] hping3 not available in repo; skipping (optional tool)."
fi

# Try to install wireshark-cli (tshark) for pcap inspection (optional)
echo "[SETUP] Installing wireshark-cli (tshark) if available..."
if ! sudo dnf install -y wireshark-cli; then
    echo "[WARN] wireshark-cli not available or failed to install. You can install it later if needed."
fi

# Ensure pip (Python package manager) is available
if ! python3 -m pip --version &>/dev/null; then
    echo "[SETUP] pip not found — installing python3-pip..."
    # epel-release sometimes needed on older setups; try python3-pip directly first
    if ! sudo dnf install -y python3-pip; then
        echo "[WARN] python3-pip install failed; trying epel-release then python3-pip..."
        sudo dnf install -y epel-release || true
        sudo dnf install -y python3-pip || true
    fi
fi

# Install Python packages (user site to avoid sudo pip issues)
echo "[SETUP] Installing Python packages (cryptography)..."
python3 -m pip install --user cryptography

# Create logs directory and placeholder log file
mkdir -p logs
touch logs/chat.log
chmod 664 logs/chat.log || true

# Generate encryption key using crypto.py if available
if [ -f "crypto.py" ]; then
    echo "[SETUP] Generating AES key file (key.bin)..."
    python3 - <<'PY'
from crypto import generate_key
k = generate_key()
print("Wrote key.bin ({} bytes)".format(len(k)))
PY
else
    echo "[WARNING] crypto.py not found! Please ensure crypto.py exists in this directory."
fi

# Final check: verify nmap exists (so scan_traffic.sh won't error)
if command -v nmap >/dev/null 2>&1; then
    echo "[SETUP] nmap installed: $(command -v nmap)"
else
    echo "[WARN] nmap not found in PATH after install. You can install it manually: sudo dnf install -y nmap"
fi

echo "[SETUP] Environment ready!"
echo "  - key.bin present? : $( [ -f key.bin ] && echo 'yes' || echo 'no' )"
echo "  - nmap present?    : $( command -v nmap >/dev/null 2>&1 && echo 'yes' || echo 'no' )"
echo
echo "You can now run:"
echo "  ./scan_traffic.sh    # captures localhost traffic and uses nmap"
echo "  ./launch.sh          # launch server + clients (or run them manually)"
echo "Or start a demo with tmux:"
echo "  tmux new -s securechat"
