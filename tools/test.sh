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

RUN_ID="${HEX_MAP_TEST_RUN_ID:-$(date +%Y%m%d-%H%M%S)-$$}"
LOG_DIR="$ROOT_DIR/.godot_user/test-runs/$RUN_ID/logs"
mkdir -p "$LOG_DIR"
TEST_JOBS="${TEST_JOBS:-1}"

"$ROOT_DIR/tools/package_addon.sh" --check

TEST_SCRIPTS=(
  "res://tests/test_hex_core.gd"
  "res://tests/test_hex_map_generation.gd"
  "res://tests/test_hex_adapter.gd"
  "res://tests/test_hex_tile_map_layer.gd"
  "res://tests/test_workspace_state_transitions.gd"
  "res://tests/test_asset_slot_state.gd"
  "res://tests/test_generation_run_state.gd"
  "res://tests/test_paint_interaction_state.gd"
  "res://tests/test_workspace_screen_contracts.gd"
  "res://tests/test_workspace_layout_metrics.gd"
  "res://tests/test_editor_plugin.gd"
  "res://tests/test_debug_scenes.gd"
)

run_test_script() {
  local test_script="$1"
  local log_name
  log_name="$(basename "$test_script").log"
  HEX_MAP_TEST_RUN_ID="$RUN_ID" "$GODOT_BIN" \
    --headless \
    --log-file "$LOG_DIR/$log_name" \
    --path . \
    --script "$test_script"
}

if (( TEST_JOBS <= 1 )); then
  for test_script in "${TEST_SCRIPTS[@]}"; do
    run_test_script "$test_script"
  done
  exit 0
fi

failures=0
pids=()
for test_script in "${TEST_SCRIPTS[@]}"; do
  run_test_script "$test_script" &
  pids+=("$!")
  if (( ${#pids[@]} >= TEST_JOBS )); then
    if ! wait "${pids[0]}"; then
      failures=$((failures + 1))
    fi
    pids=("${pids[@]:1}")
  fi
done

for pid in "${pids[@]}"; do
  if ! wait "$pid"; then
    failures=$((failures + 1))
  fi
done

if (( failures > 0 )); then
  exit 1
fi
