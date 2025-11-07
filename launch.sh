#!/usr/bin/env bash
set -e
open_in_xterm() {
  TITLE="$1"
  CMD="$2"
  if command -v xterm >/dev/null 2>&1; then
    xterm -hold -T "$TITLE" -e bash -c "$CMD" &
  elif command -v gnome-terminal >/dev/null 2>&1; then
    gnome-terminal -- bash -lc "$CMD; exec bash" &
  else
    bash -c "$CMD" > "logs/${TITLE}.log" 2>&1 &
    echo "Started $TITLE in background; output -> logs/${TITLE}.log"
  fi
}
echo "[LAUNCH] Starting server..."
open_in_xterm "server" "python3 server.py"
sleep 1
echo "[LAUNCH] Starting client Alice..."
open_in_xterm "client_alice" "python3 client.py --name Alice"
sleep 1
echo "[LAUNCH] Starting client Bob..."
open_in_xterm "client_bob" "python3 client.py --name Bob"
echo "[LAUNCH] Launched. If no GUI, check logs/*.log"
