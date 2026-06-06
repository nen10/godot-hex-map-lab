#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./tools/export_chatai_zip.sh [output.zip]

Creates a repository zip for handing the current working tree to ChatGPT.
The archive includes uncommitted and untracked files, but excludes local
Git/Godot/cache/debug generated files.

Default output:
  ${TMPDIR:-/tmp}/godot-hex-map-lab-YYYYMMDD-HHMMSS.zip
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_NAME="$(basename "$ROOT_DIR")"
CALLER_DIR="$(pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_PATH="${1:-${TMPDIR:-/tmp}/${REPO_NAME}-${STAMP}.zip}"

if [[ "$OUT_PATH" = /* ]]; then
  OUT_ABS="$OUT_PATH"
else
  OUT_ABS="$CALLER_DIR/$OUT_PATH"
fi

case "$OUT_ABS" in
  "$ROOT_DIR"/*)
    echo "Output path must be outside the repository to avoid archiving the zip itself." >&2
    echo "Use /tmp or another external directory." >&2
    exit 2
    ;;
esac

if ! command -v zip >/dev/null 2>&1; then
  echo "zip command not found." >&2
  exit 127
fi

mkdir -p "$(dirname "$OUT_ABS")"
rm -f "$OUT_ABS"

cd "$(dirname "$ROOT_DIR")"

zip -r -9 -q "$OUT_ABS" "$REPO_NAME" \
  -x "$REPO_NAME/.git/*" \
  -x "$REPO_NAME/.godot/*" \
  -x "$REPO_NAME/.godot_user/*" \
  -x "$REPO_NAME/.godot_home/*" \
  -x "$REPO_NAME/.test/*" \
  -x "$REPO_NAME/.codex/*" \
  -x "$REPO_NAME/debug/output/*" \
  -x "$REPO_NAME/debug/assets/*" \
  -x "$REPO_NAME/.DS_Store" \
  -x "$REPO_NAME/*/.DS_Store" \
  -x "$REPO_NAME/*/*/.DS_Store" \
  -x "$REPO_NAME/*/*/*/.DS_Store" \
  -x "$REPO_NAME/*.log" \
  -x "$REPO_NAME/*/*.log" \
  -x "$REPO_NAME/*/*/*.log" \
  -x "$REPO_NAME/*/*/*/*.log"

printf 'Created: %s\n' "$OUT_ABS"
printf 'Size: '
du -h "$OUT_ABS" | awk '{print $1}'

mv "$OUT_ABS" "$CALLER_DIR/../"
printf 'Moved to: %s\n' "$CALLER_DIR/../$(basename "$OUT_ABS")"
