#!/bin/bash
# mtproxy.sh
# Backend helpers for MTProxy installation and status (Python edition).
# comments MUST be English only.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the official wrapper (Hirbod installer wrapper)
INSTALL_WRAPPER="$SCRIPT_DIR/scripts/install_mtproxy_core.sh"

MT_SERVICE_NAME="MTProxy"
MT_SERVICE_FILE="/etc/systemd/system/${MT_SERVICE_NAME}.service"
MT_CONFIG_DIR="/opt/MTProxy/objs/bin"
MT_CONFIG_FILE="${MT_CONFIG_DIR}/mtconfig.conf"


has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ensure_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this command as root (or use sudo)." >&2
    exit 1
  fi
}

mtproxy_is_installed() {
  if [ -f "$MT_SERVICE_FILE" ] || systemctl list-units --all | grep -q "$MT_SERVICE_NAME.service"; then
    return 0
  fi
  return 1
}

mtproxy_show_status() {
  echo "=== MTProxy status ==="

  if ! mtproxy_is_installed; then
    echo "MTProxy service not installed."
  else
    echo "[*] systemd unit:"
    systemctl --no-pager --full status "$MT_SERVICE_NAME" || true
  fi

  echo
  echo "[*] Config/binary path:"
  if [ -d "$MT_CONFIG_DIR" ]; then
    ls -l "$MT_CONFIG_DIR"
  else
    echo "Directory $MT_CONFIG_DIR does not exist."
  fi

  echo
  if [ -f "$MT_CONFIG_FILE" ]; then
    echo "[*] mtconfig.conf exists at $MT_CONFIG_FILE"
    grep -E '^(PORT=|SECRET_|TAG=|TLS_DOMAIN=)' "$MT_CONFIG_FILE" || true
  else
    echo "mtconfig.conf not found at $MT_CONFIG_FILE"
  fi

  echo
  echo "[*] Listening ports:"
  if has_cmd ss; then
    ss -tulnp | grep -Ei 'mtproto|MTProxy' || echo "No MTProxy ports detected (or ss not showing them)."
  else
    echo "Command ss not found; skipping port listing."
  fi
}

mtproxy_install_official() {
  ensure_root

  if [ ! -x "$INSTALL_WRAPPER" ]; then
    echo "Error: $INSTALL_WRAPPER not found or not executable." >&2
    echo "Make sure scripts/install_mtproxy_core.sh exists and is chmod +x." >&2
    exit 1
  fi

  echo "=== Running official MTProxy installer wrapper ==="
  bash "$INSTALL_WRAPPER"
  echo
  echo "=== MTProxy installation finished. Final status: ==="
  mtproxy_show_status
}

mtproxy_uninstall_basic() {
  ensure_root

  echo "=== Basic MTProxy uninstall ==="
  echo "This will try to stop the service, disable it, and remove binary/config folder."
  read -rp "Are you sure you want to remove MTProxy? [y/N]: " ans
  ans=${ans:-N}

  if [[ ! "$ans" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    return 0
  fi

  # Stop and disable service if present
  if mtproxy_is_installed; then
    echo "[*] Stopping MTProxy.service..."
    systemctl stop "$MT_SERVICE_NAME" 2>/dev/null || true
    echo "[*] Disabling MTProxy.service..."
    systemctl disable "$MT_SERVICE_NAME" 2>/dev/null || true

    if [ -f "$MT_SERVICE_FILE" ]; then
      echo "[*] Removing $MT_SERVICE_FILE"
      rm -f "$MT_SERVICE_FILE"
    fi
    systemctl daemon-reload || true
  else
    echo "MTProxy.service not installed; skipping service removal."
  fi

  # Remove config/binary folder
  if [ -d "$MT_CONFIG_DIR" ]; then
    echo "[*] Removing $MT_CONFIG_DIR"
    rm -rf "$MT_CONFIG_DIR"
  else
    echo "$MT_CONFIG_DIR not found; skipping."
  fi

  echo "Basic MTProxy uninstall completed."
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  install     Run official MTProxy installer wrapper (interactive).
  status      Show MTProxy systemd status and config.
  uninstall   Basic uninstall: stop/disable service and remove binary/config.
EOF
}

main() {
  local cmd="${1:-}"

  case "$cmd" in
    install)
      mtproxy_install_official
      ;;
    status)
      mtproxy_show_status
      ;;
    uninstall)
      mtproxy_uninstall_basic
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
