#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

GODOT_BIN="${GODOT_BIN:-}"
if [[ -z "$GODOT_BIN" ]]; then
  if [[ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]]; then
    GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
  elif command -v godot >/dev/null 2>&1; then
    GODOT_BIN="$(command -v godot)"
  elif command -v godot4 >/dev/null 2>&1; then
    GODOT_BIN="$(command -v godot4)"
  else
    echo "Godot executable not found. Set GODOT_BIN=/path/to/Godot." >&2
    exit 127
  fi
fi

LOG_DIR="$ROOT_DIR/.godot_user"
mkdir -p "$LOG_DIR"

TEST_SCRIPTS=(
  "res://tests/test_hex_core.gd"
  "res://tests/test_hex_map_generation.gd"
  "res://tests/test_hex_adapter.gd"
)

for test_script in "${TEST_SCRIPTS[@]}"; do
  log_name="$(basename "$test_script").log"
  "$GODOT_BIN" \
    --headless \
    --log-file "$LOG_DIR/$log_name" \
    --path . \
    --script "$test_script"
done
