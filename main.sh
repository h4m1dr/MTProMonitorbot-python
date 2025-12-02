#!/bin/bash
# main.sh
# Primary entrypoint for MTPro-Py.
# For now it simply delegates to mtpro_py_manager.sh.
# comments MUST be English only.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGER="$SCRIPT_DIR/mtpro_py_manager.sh"

if [ ! -f "$MANAGER" ]; then
  echo "Error: mtpro_py_manager.sh not found next to main.sh" >&2
  exit 1
fi

if [ ! -x "$MANAGER" ]; then
  chmod +x "$MANAGER" 2>/dev/null || true
fi

exec "$MANAGER" "$@"
