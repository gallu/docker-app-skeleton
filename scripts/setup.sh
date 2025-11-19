#!/bin/sh

echo "=== Initializing project directories ==="

# ---- 1. create directories ----
mkdir -p src
mkdir -p storage/db
mkdir -p storage/logs
mkdir -p storage/cache

echo "Directories created."


# ---- 2. permissions (optional but useful) ----
# Linux / WSL: 読み書き可能な最低限の権限を付与
chmod -R 755 src storage

# PHP-FPM が書き込むディレクトリ（logs, cache）は writable にしておく
chmod -R 775 storage/logs storage/cache

# Linux の場合のみ、www-data に所有権を合わせる（Windows対策のため実行可否判定）
if id "www-data" >/dev/null 2>&1; then
    echo "Detected www-data user. Fixing ownership..."
    chown -R www-data:www-data storage/logs storage/cache || true
fi

echo "Permissions updated."


# ---- 3. WSL / Windows メッセージ ----
if grep -qi "microsoft" /proc/version 2>/dev/null; then
    echo "Detected WSL environment."
    echo "Note: File permissions may not fully apply on Windows filesystems."
fi

echo "Setup completed."

