#!/usr/bin/env bash
PORT=9009
HOST=127.0.0.1
COUNT=5
echo "[ATTACK] Sending $COUNT malformed packets to $HOST:$PORT (localhost only)..."
for i in $(seq 1 $COUNT); do
  head -c 40 /dev/urandom | nc $HOST $PORT || true
  sleep 0.5
done
echo "[ATTACK] Done."
