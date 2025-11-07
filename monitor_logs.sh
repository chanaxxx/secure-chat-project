#!/usr/bin/env bash
LOG_FILE="logs/chat.log"
if [ ! -f "$LOG_FILE" ]; then
  echo "[MONITOR] No log file: $LOG_FILE"
  exit 1
fi
echo "[MONITOR] Tailing $LOG_FILE..."
tail -F "$LOG_FILE" | python3 -u - <<'PY'
import sys, re
suspicious_count = 0
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    print("[LOG] " + line)
    m = re.search(r"MESSAGE .* len=(\d+)", line)
    if m:
        l = int(m.group(1))
        if l < 20:
            suspicious_count += 1
            print("[ALERT] Short encrypted message len=%d" % l)
    if "INVALID" in line or "DISCONNECT" in line:
        suspicious_count += 1
        print("[ALERT] Invalid/disconnect event:", line)
    if suspicious_count >= 3:
        print("=== HIGH-LEVEL ALERT: multiple suspicious events detected ===")
        suspicious_count = 0
PY
