#!/bin/bash
# setup_pybot.sh
# One-shot installer/updater for Python MTProxy bot.
# - Creates venv in project root
# - Installs python-telegram-bot and python-dotenv
# - Creates systemd service for the bot
# comments MUST be English only.

set -euo pipefail

# scripts/ -> project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"
SERVICE_NAME="mtprobot"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "=== Python MTProxy bot setup ==="
echo "[*] Project root: $SCRIPT_DIR"
echo "[*] Virtualenv:   $VENV_DIR"
echo

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root (or via sudo)." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 not found. Run prereq.sh install first." >&2
  exit 1
fi

# Create or reuse venv
if [ ! -d "$VENV_DIR" ]; then
  echo "[*] Creating virtualenv..."
  python3 -m venv "$VENV_DIR"
else
  echo "[*] Virtualenv already exists, reusing: $VENV_DIR"
fi

# Install Python dependencies
echo "[*] Installing/upgrading pip and required packages..."
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install "python-telegram-bot>=20,<21" python-dotenv

# Create .env skeleton if it does not exist
ENV_FILE="$SCRIPT_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "[*] Creating .env skeleton at $ENV_FILE"
  cat > "$ENV_FILE" <<EOF
# Telegram bot token
BOT_TOKEN=

# Owner and admin IDs (Telegram numeric IDs)
OWNER_ID=
ADMIN_IDS=

# MTProxy systemd service name
MTPROXY_SERVICE_NAME=MTProxy

# MTProxy port and optional TLS domain
MTPROXY_PORT=443
MTPROXY_TLS_DOMAIN=

# SQLite database path
DB_PATH=./data/mtproxy-bot.db
EOF
  echo "[!] Please edit .env and fill BOT_TOKEN, OWNER_ID, ADMIN_IDS before starting the bot."
fi

# Create systemd service
echo "[*] Writing systemd service file: $SERVICE_FILE"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=MTPro-Py Telegram management bot
After=network.target

[Service]
Type=simple
WorkingDirectory=${SCRIPT_DIR}
ExecStart=${VENV_DIR}/bin/python -m bot.bot
Restart=always
RestartSec=5

EnvironmentFile=${ENV_FILE}

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Reloading systemd daemon..."
systemctl daemon-reload
echo "[*] Enabling bot service on boot..."
systemctl enable "$SERVICE_NAME"

echo "=== setup_pybot.sh finished ==="
echo "You can now manage the bot service using pybot.sh or mtpro_py_manager.sh."
