#!/bin/bash
# system.sh
# System/maintenance helpers: logs, backup, update.
# comments MUST be English only.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BOT_SERVICE_NAME="mtprobot"
MT_SERVICE_NAME="MTProxy"

CONFIG_FILE="$SCRIPT_DIR/config.json"
DB_FILE="$SCRIPT_DIR/data/proxies.sqlite3"
BACKUP_DIR="$SCRIPT_DIR/backups"


ensure_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this command as root (or use sudo) for system-level operations." >&2
    exit 1
  fi
}

show_logs_bot() {
  echo "=== Logs for $BOT_SERVICE_NAME ==="
  journalctl -u "$BOT_SERVICE_NAME" -n 100 --no-pager || echo "No logs for $BOT_SERVICE_NAME."
}

show_logs_mtproxy() {
  echo "=== Logs for $MT_SERVICE_NAME ==="
  journalctl -u "$MT_SERVICE_NAME" -n 100 --no-pager || echo "No logs for $MT_SERVICE_NAME."
}

backup_config_db() {
  mkdir -p "$BACKUP_DIR"

  local ts
  ts="$(date +%Y%m%d_%H%M%S)"

  local cfg_backup="$BACKUP_DIR/config_${ts}.json"
  local db_backup="$BACKUP_DIR/proxies_${ts}.sqlite3"

  echo "=== Creating backup ==="
  if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$cfg_backup"
    echo "[*] Saved config backup: $cfg_backup"
  else
    echo "[!] $CONFIG_FILE not found; skipping."
  fi

  if [ -f "$DB_FILE" ]; then
    cp "$DB_FILE" "$db_backup"
    echo "[*] Saved DB backup: $db_backup"
  else
    echo "[!] $DB_FILE not found; skipping."
  fi
}

update_repo() {
  # Optional helper: if this directory is a git repo, pull latest
  if [ -d "$SCRIPT_DIR/.git" ]; then
    echo "=== Updating repository (git pull) ==="
    (cd "$SCRIPT_DIR" && git pull --ff-only) || echo "git pull failed."
  else
    echo "This directory is not a git repository; skipping git pull."
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  logs-bot       Show recent logs for mtprobot service.
  logs-mtproxy   Show recent logs for MTProxy service.
  backup         Backup config.json and data/proxies.sqlite3 into backups/.
  update-repo    If this directory is a git repo, run 'git pull --ff-only'.
EOF
}

main() {
  local cmd="${1:-}"

  case "$cmd" in
    logs-bot)
      show_logs_bot
      ;;
    logs-mtproxy)
      show_logs_mtproxy
      ;;
    backup)
      backup_config_db
      ;;
    update-repo)
      update_repo
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
