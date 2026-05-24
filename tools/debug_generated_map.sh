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

"$GODOT_BIN" --path . --scene res://debug/generated_map_debug.tscn
