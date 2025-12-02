#!/bin/bash
# install_mtproxy_core.sh
# Thin wrapper to install MTProxy using HirbodBehnam/MTProtoProxyInstaller
# comments MUST be English only.

set -euo pipefail

INSTALL_URL="https://raw.githubusercontent.com/HirbodBehnam/MTProtoProxyInstaller/master/MTProtoProxyOfficialInstall.sh"
TMP_SCRIPT="/tmp/MTProtoProxyOfficialInstall.sh"

ensure_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (or use sudo)." >&2
    exit 1
  fi
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

fetch_installer() {
  echo "=== Downloading official MTProxy installer ==="
  if has_cmd curl; then
    curl -fsSL "$INSTALL_URL" -o "$TMP_SCRIPT"
  elif has_cmd wget; then
    wget -q "$INSTALL_URL" -O "$TMP_SCRIPT"
  else
    echo "Error: neither curl nor wget found. Install one of them first." >&2
    exit 1
  fi
  chmod +x "$TMP_SCRIPT"
}

run_installer() {
  echo "=== Running official installer ==="
  bash "$TMP_SCRIPT"
}

cleanup() {
  if [ -f "$TMP_SCRIPT" ]; then
    rm -f "$TMP_SCRIPT"
  fi
}

main() {
  ensure_root
  fetch_installer
  run_installer
  cleanup
  echo
  echo "=== MTProxy installation completed (via official installer). ==="
  echo "You can check status from mtproxy.sh or mtpro_py_manager.sh."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
