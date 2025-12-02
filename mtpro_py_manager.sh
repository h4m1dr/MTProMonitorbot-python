#!/bin/bash
# mtpro_py_manager.sh
# Single entrypoint for Python-based MTProxy manager.
# comments MUST be English only.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Files that should be executable when this manager runs
AUTO_EXEC_FILES=(
  "prereq.sh"
  "mtproxy.sh"
  "pybot.sh"
  "system.sh"
  "setup_pybot.sh"
)

make_helpers_executable() {
  for f in "${AUTO_EXEC_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$f" ]; then
      chmod +x "$SCRIPT_DIR/$f" 2>/dev/null || true
    fi
  done
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

print_header() {
  clear
  echo "==========================================="
  echo "       MTPro-Py | Python MTProxy Manager   "
  echo "==========================================="
  echo
}

pause() {
  echo
  read -rp "Press Enter to continue..." _
}

run_or_warn() {
  # $1 = relative script path, $2... = args
  local script="$1"
  shift || true

  local path="$SCRIPT_DIR/$script"

  if [ ! -f "$path" ]; then
    echo "Error: $script not found next to mtpro_py_manager.sh" >&2
    pause
    return 1
  fi

  if [ ! -x "$path" ]; then
    chmod +x "$path" 2>/dev/null || true
  fi

  "$path" "$@"
}

menu_install_prereq() {
  print_header
  echo "[1] Install prerequisites (python3, venv, pip3, git, curl)"
  echo
  echo "This will use your system package manager (apt/yum/dnf)."
  echo
  read -rp "Continue? [y/N]: " ans
  ans=${ans:-N}
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    sudo "$SCRIPT_DIR/prereq.sh" install
  else
    echo "Aborted."
  fi
  pause
}

menu_prereq_status() {
  print_header
  echo "=== Prerequisites status ==="
  echo
  run_or_warn "prereq.sh" status || true
  pause
}

menu_mtproxy_install() {
  print_header
  echo "=== MTProxy installation (official wrapper) ==="
  echo
  echo "This will run the official installer wrapper."
  echo
  read -rp "Continue? [y/N]: " ans
  ans=${ans:-N}
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    sudo "$SCRIPT_DIR/mtproxy.sh" install
  else
    echo "Aborted."
  fi
  pause
}

menu_mtproxy_status() {
  print_header
  echo "=== MTProxy status ==="
  echo
  run_or_warn "mtproxy.sh" status || true
  pause
}

menu_pybot_install() {
  print_header
  echo "=== Python MTProxy bot install/update ==="
  echo
  echo "This will run setup_pybot.sh and (re)start the 'mtprobot' service."
  echo
  read -rp "Continue? [y/N]: " ans
  ans=${ans:-N}
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    sudo "$SCRIPT_DIR/pybot.sh" install
  else
    echo "Aborted."
  fi
  pause
}

menu_pybot_status() {
  print_header
  echo "=== Python MTProxy bot status ==="
  echo
  run_or_warn "pybot.sh" status || true
  pause
}

menu_logs() {
  print_header
  echo "=== Logs menu ==="
  echo
  echo "1) Show mtprobot logs"
  echo "2) Show MTProxy logs"
  echo "0) Back to main menu"
  echo
  read -rp "Select an option: " choice
  case "$choice" in
    1)
      sudo "$SCRIPT_DIR/system.sh" logs-bot || true
      ;;
    2)
      sudo "$SCRIPT_DIR/system.sh" logs-mtproxy || true
      ;;
    0|*)
      ;;
  esac
  pause
}

menu_backup() {
  print_header
  echo "=== Backup config and DB ==="
  echo
  echo "This will copy:"
  echo "  - config.json"
  echo "  - data/proxies.sqlite3"
  echo "into backups/ with timestamped filenames."
  echo
  read -rp "Continue? [y/N]: " ans
  ans=${ans:-N}
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    sudo "$SCRIPT_DIR/system.sh" backup || true
  else
    echo "Aborted."
  fi
  pause
}

main_menu() {
  while true; do
    print_header
    echo "Main Menu (Python edition)"
    echo
    echo "1) Install prerequisites (python3, venv, pip3, git, curl)"
    echo "2) Show prerequisites status"
    echo "3) Install MTProxy (official wrapper)"
    echo "4) Show MTProxy status"
    echo "5) Install/Update Python bot (mtprobot)"
    echo "6) Show Python bot status"
    echo "7) Logs (mtprobot / MTProxy)"
    echo "8) Backup config + DB"
    echo "0) Exit"
    echo
    read -rp "Select an option: " choice
    case "$choice" in
      1) menu_install_prereq ;;
      2) menu_prereq_status ;;
      3) menu_mtproxy_install ;;
      4) menu_mtproxy_status ;;
      5) menu_pybot_install ;;
      6) menu_pybot_status ;;
      7) menu_logs ;;
      8) menu_backup ;;
      0)
        echo "Bye."
        exit 0
        ;;
      *)
        echo "Invalid option."
        sleep 1
        ;;
    esac
  done
}

main() {
  make_helpers_executable
  main_menu
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
