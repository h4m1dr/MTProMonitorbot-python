#!/bin/bash
# pybot.sh
# Backend helpers for Python MTProxy bot: install, start, stop, status.
# comments MUST be English only.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/scripts/setup_pybot.sh"

SERVICE_NAME="mtprobot"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"


has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ensure_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this command as root (or use sudo)." >&2
    exit 1
  fi
}

pybot_install_or_update() {
  ensure_root

  if [ ! -x "$SETUP_SCRIPT" ]; then
    echo "Error: $SETUP_SCRIPT not found or not executable." >&2
    echo "Make sure scripts/setup_pybot.sh exists and is chmod +x." >&2
    exit 1
  fi

  echo "=== Installing / Updating Python MTProxy bot ==="
  bash "$SETUP_SCRIPT"

  echo
  echo "=== Enabling and restarting $SERVICE_NAME ==="
  systemctl daemon-reload
  systemctl enable "$SERVICE_NAME" || true
  systemctl restart "$SERVICE_NAME" || true

  echo
  pybot_status
}

pybot_start() {
  ensure_root
  echo "Starting $SERVICE_NAME..."
  systemctl start "$SERVICE_NAME"
  pybot_status
}

pybot_stop() {
  ensure_root
  echo "Stopping $SERVICE_NAME..."
  systemctl stop "$SERVICE_NAME" || true
  pybot_status
}

pybot_restart() {
  ensure_root
  echo "Restarting $SERVICE_NAME..."
  systemctl restart "$SERVICE_NAME"
  pybot_status
}

pybot_status() {
  echo "=== Python bot service status ==="

  if [ -f "$SERVICE_FILE" ]; then
    echo "[*] Service file: $SERVICE_FILE"
  else
    echo "[!] Service file not found at $SERVICE_FILE"
  fi

  if has_cmd systemctl; then
    systemctl --no-pager --full status "$SERVICE_NAME" || true
  else
    echo "systemctl not available; cannot show status."
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  install   Run scripts/setup_pybot.sh and (re)create systemd service.
  start     Start mtprobot service.
  stop      Stop mtprobot service.
  restart   Restart mtprobot service.
  status    Show mtprobot systemd status.
EOF
}

main() {
  local cmd="${1:-}"

  case "$cmd" in
    install)
      pybot_install_or_update
      ;;
    start)
      pybot_start
      ;;
    stop)
      pybot_stop
      ;;
    restart)
      pybot_restart
      ;;
    status)
      pybot_status
      ;;
    ""|-h|--help|help)
      usage
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      usage
      exit 1
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
