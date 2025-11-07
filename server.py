#!/usr/bin/env python3
# server.py
import socket, threading, struct, binascii, os
from datetime import datetime

HOST = "127.0.0.1"
PORT = 9009
LOG_DIR = "logs"
LOG_FILE = os.path.join(LOG_DIR, "chat.log")
os.makedirs(LOG_DIR, exist_ok=True)

clients = {}
lock = threading.Lock()

def log_event(text: str):
    now = datetime.now().isoformat()
    with open(LOG_FILE, "a") as f:
        f.write(f"{now} {text}\n")

def recv_all(sock, n):
    data = b""
    while len(data) < n:
        chunk = sock.recv(n - len(data))
        if not chunk:
            return None
        data += chunk
    return data

def handle_client(conn, addr):
    try:
        name_len_bytes = conn.recv(1)
        if not name_len_bytes:
            conn.close()
            return
        name_len = name_len_bytes[0]
        name = conn.recv(name_len).decode(errors="ignore")
        with lock:
            clients[conn] = name
        print(f"[SERVER] {name} connected from {addr}")
        log_event(f"CONNECT {name} {addr}")

        while True:
            hdr = recv_all(conn, 4)
            if not hdr:
                break
            (length,) = struct.unpack("!I", hdr)
            if length == 0:
                continue
            data = recv_all(conn, length)
            if data is None:
                break

            preview = binascii.hexlify(data[:16]).decode()
            log_event(f"MESSAGE {name} len={length} preview={preview}")

            with lock:
                for c in list(clients.keys()):
                    if c is not conn:
                        try:
                            c.sendall(hdr + data)
                        except Exception as e:
                            print(f"[SERVER] Error sending to client: {e}")

    except Exception as e:
        print(f"[SERVER] Exception for {addr}: {e}")
    finally:
        with lock:
            nm = clients.pop(conn, "<unknown>")
        log_event(f"DISCONNECT {nm}")
        try:
            conn.close()
        except:
            pass
        print(f"[SERVER] {nm} disconnected")

def main():
    print("[SERVER] Starting server...")
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.bind((HOST, PORT))
    sock.listen(5)
    print(f"[SERVER] Listening on {HOST}:{PORT}")
    try:
        while True:
            conn, addr = sock.accept()
            t = threading.Thread(target=handle_client, args=(conn, addr), daemon=True)
            t.start()
    except KeyboardInterrupt:
        print("[SERVER] Shutting down (Ctrl-C)")
    finally:
        sock.close()

if __name__ == "__main__":
    main()
