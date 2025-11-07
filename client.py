#!/usr/bin/env python3
# client.py
import socket, threading, struct, argparse, sys
from crypto import load_key, encrypt_message, decrypt_message

HOST = "127.0.0.1"
PORT = 9009

def recv_all(sock, n):
    data = b""
    while len(data) < n:
        chunk = sock.recv(n - len(data))
        if not chunk:
            return None
        data += chunk
    return data

def receiver(sock, key):
    try:
        while True:
            hdr = recv_all(sock, 4)
            if not hdr:
                print("[CLIENT] Server closed connection.")
                break
            (length,) = struct.unpack("!I", hdr)
            data = recv_all(sock, length)
            if data is None:
                print("[CLIENT] Broken stream.")
                break
            try:
                plaintext = decrypt_message(key, data)
                try:
                    text = plaintext.decode()
                except:
                    text = repr(plaintext)
                print(f"\n[RECV] {text}\n> ", end="", flush=True)
            except Exception as e:
                import binascii
                hexpreview = binascii.hexlify(data[:16]).decode()
                print(f"\n[RECV] <INVALID or UNAUTHORIZED MESSAGE preview={hexpreview}> \n> ", end="", flush=True)
    except Exception as e:
        print(f"[CLIENT] Receiver thread exception: {e}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True, help="Your display name (Alice/Bob)")
    args = parser.parse_args()
    name = args.name[:32]

    try:
        key = load_key()
    except FileNotFoundError:
        print("ERROR: key.bin not found. Run setup.sh first to create key.bin.")
        sys.exit(1)

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((HOST, PORT))

    name_bytes = name.encode()
    if len(name_bytes) > 255:
        name_bytes = name_bytes[:255]
    sock.sendall(bytes([len(name_bytes)]) + name_bytes)

    t = threading.Thread(target=receiver, args=(sock, key), daemon=True)
    t.start()

    print(f"[CLIENT] Connected as {name}. Type messages and press Enter to send.")
    try:
        while True:
            msg = input("> ")
            if msg.strip().lower() in ("exit", "quit"):
                print("[CLIENT] Bye.")
                break
            pt = f"{name}: {msg}".encode()
            blob = encrypt_message(key, pt)
            hdr = struct.pack("!I", len(blob))
            sock.sendall(hdr + blob)
    except KeyboardInterrupt:
        print("\n[CLIENT] Interrupted by user.")
    finally:
        sock.close()

if __name__ == "__main__":
    main()
