#!/usr/bin/env bash
set -e

echo "=== INSTALL GS-NETCAT ==="
curl -fsSL https://gsocket.io/y -o gsocket_install.sh

bash gsocket_install.sh
rm gsocket_install.sh

echo "=== SETUP GS-NETCAT SYSTEMD SERVICE ==="

read -p "Masukkan SECRET GSocket: " SECRET

BIN=$(which gs-netcat)
if [ -z "$BIN" ]; then
  echo "Error: gs-netcat tidak ditemukan setelah install."
  exit 1
fi

SERVICE_FILE="/etc/systemd/system/gsocket.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=GSocket Listener Auto
After=network.target

[Service]
ExecStart=$BIN -l -s $SECRET -e /bin/bash
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Service file dibuat di: $SERVICE_FILE"

sudo systemctl daemon-reload
sudo systemctl enable gsocket
sudo systemctl restart gsocket

echo "=== DONE ==="
systemctl status gsocket --no-pager -l
