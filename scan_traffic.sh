#!/usr/bin/env bash
set -e
PCAP_FILE="logs/traffic_localhost.pcap"
PORT=9009
DURATION=8
echo "[SCAN] Running quick nmap on localhost..."
nmap -p $PORT 127.0.0.1 || true
echo "[SCAN] Capturing $DURATION seconds of loopback traffic to $PCAP_FILE..."
sudo timeout $DURATION tcpdump -i lo -w "$PCAP_FILE" "tcp port $PORT" 2>/dev/null || true
echo "[SCAN] Capture complete."
