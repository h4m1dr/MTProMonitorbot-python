#!/bin/bash
# prereq.sh
# Install base prerequisites for Python MTProxy bot: python3, venv, git, curl, etc.
# comments MUST be English only.

set -euo pipefail

detect_pkg_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v yum >/dev/null 2>&1; then
    echo "yum"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  else
    echo "none"
  fi
}

ensure_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this command as root (or use sudo)." >&2
    exit 1
  fi
}

install_prereqs() {
  ensure_root
  local pm
  pm="$(detect_pkg_manager)"

  if [ "$pm" = "none" ]; then
    echo "Error: no supported package manager found (apt, yum, dnf)." >&2
    exit 1
  fi

  echo "=== Installing base packages using $pm ==="

  case "$pm" in
    apt)
      apt-get update -y
      apt-get install -y python3 python3-venv python3-pip git curl
      ;;
    yum)
      yum install -y python3 python3-venv python3-pip git curl
      ;;
    dnf)
      dnf install -y python3 python3-venv python3-pip git curl
      ;;
  esac

  echo
  echo "=== Versions ==="
  python3 --version || true
  pip3 --version || true
  git --version || true
  curl --version || true
}

show_prereq_status() {
  echo "=== Prerequisites status ==="

  if command -v python3 >/dev/null 2>&1; then
    echo "[*] python3: $(python3 --version 2>/dev/null || echo found)"
  else
    echo "[!] python3: NOT FOUND"
  fi

  if python3 -m venv --help >/dev/null 2>&1; then
    echo "[*] python3-venv: available"
  else
    echo "[!] python3-venv: NOT CONFIRMED (check your python3 installation)"
  fi

  if command -v pip3 >/dev/null 2>&1; then
    echo "[*] pip3: $(pip3 --version 2>/dev/null || echo found)"
  else
    echo "[!] pip3: NOT FOUND"
  fi

  if command -v git >/dev/null 2>&1; then
    echo "[*] git: $(git --version 2>/dev/null || echo found)"
  else
    echo "[!] git: NOT FOUND"
  fi

  if command -v curl >/dev/null 2>&1; then
    echo "[*] curl: $(curl --version 2>/dev/null | head -n1 || echo found)"
  else
    echo "[!] curl: NOT FOUND"
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  install   Install python3, venv, pip3, git, curl.
  status    Show current status/versions of prerequisites.
EOF
}

main() {
  local cmd="${1:-}"

  case "$cmd" in
    install)
      install_prereqs
      ;;
    status)
      show_prereq_status
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
