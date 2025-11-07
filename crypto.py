# crypto.py
# AES-256-GCM helpers.
import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

KEY_FILE = "key.bin"

def generate_key():
    key = AESGCM.generate_key(bit_length=256)
    with open(KEY_FILE, "wb") as f:
        f.write(key)
    return key

def load_key():
    with open(KEY_FILE, "rb") as f:
        return f.read()

def encrypt_message(key: bytes, plaintext: bytes, aad: bytes = None) -> bytes:
    aesgcm = AESGCM(key)
    nonce = os.urandom(12)
    ct = aesgcm.encrypt(nonce, plaintext, aad)
    return nonce + ct

def decrypt_message(key: bytes, data: bytes, aad: bytes = None) -> bytes:
    if len(data) < 12:
        raise ValueError("encrypted data too short")
    nonce = data[:12]
    ct = data[12:]
    aesgcm = AESGCM(key)
    return aesgcm.decrypt(nonce, ct, aad)
