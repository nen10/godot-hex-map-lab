#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_CFG="$ROOT_DIR/addons/hex_map_kit/plugin.cfg"
MODE="build"
OUTPUT_DIR=""

usage() {
  cat <<'USAGE'
Usage: tools/package_addon.sh [--check] [--output-dir DIR]

Build an addon-only Hex Map Kit package.

Options:
  --check          Validate package manifest and build a temporary zip under .godot_user/.
  --output-dir    Write artifacts to DIR instead of dist/ or .godot_user/package-check/.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      MODE="check"
      shift
      ;;
    --output-dir)
      if [[ $# -lt 2 ]]; then
        echo "--output-dir requires a directory" >&2
        exit 2
      fi
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! -f "$PLUGIN_CFG" ]]; then
  echo "Missing plugin.cfg: $PLUGIN_CFG" >&2
  exit 1
fi

VERSION="$(
  awk -F= '/^version=/ {
    gsub(/"/, "", $2)
    print $2
    exit
  }' "$PLUGIN_CFG"
)"

if [[ -z "$VERSION" ]]; then
  echo "Could not read version from $PLUGIN_CFG" >&2
  exit 1
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  if [[ "$MODE" == "check" ]]; then
    RUN_ID="${HEX_MAP_PACKAGE_RUN_ID:-$(date +%Y%m%d-%H%M%S)-$$}"
    OUTPUT_DIR="$ROOT_DIR/.godot_user/package-check/$RUN_ID"
  else
    OUTPUT_DIR="$ROOT_DIR/dist"
  fi
fi

mkdir -p "$OUTPUT_DIR"

PACKAGE_NAME="hex_map_kit-$VERSION"
MANIFEST_PATH="$OUTPUT_DIR/$PACKAGE_NAME.manifest.txt"
ZIP_PATH="$OUTPUT_DIR/$PACKAGE_NAME.zip"

python3 - "$ROOT_DIR" "$MANIFEST_PATH" <<'PY'
import os
import sys

root_dir = sys.argv[1]
manifest_path = sys.argv[2]
addon_root = os.path.join(root_dir, "addons", "hex_map_kit")
required_paths = {
    "addons/hex_map_kit/LICENSE",
    "addons/hex_map_kit/plugin.cfg",
    "addons/hex_map_kit/plugin.gd",
    "addons/hex_map_kit/core/hex_vector.gd",
    "addons/hex_map_kit/core/hex_map_generator.gd",
    "addons/hex_map_kit/adapter/hex_map_document_resource.gd",
    "addons/hex_map_kit/adapter/hex_tile_map_layer.gd",
    "addons/hex_map_kit/editor/hex_map_gen_dock.gd",
    "addons/hex_map_kit/assets/sample_hex_tiles.png",
    "addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
    "addons/hex_map_kit/assets/sample_spawn_marker.tscn",
}
excluded_prefixes = (
    "docs/",
    "tests/",
    "debug/",
    "tools/",
    "examples/",
    ".godot/",
    ".godot_user/",
    "dist/",
)

if not os.path.isdir(addon_root):
    raise SystemExit(f"Missing addon directory: {addon_root}")

paths = []
for dirpath, dirnames, filenames in os.walk(addon_root):
    dirnames[:] = sorted(
        name for name in dirnames
        if name not in {".git", "__pycache__"}
    )
    for filename in sorted(filenames):
        if filename in {".DS_Store"}:
            continue
        absolute = os.path.join(dirpath, filename)
        relative = os.path.relpath(absolute, root_dir).replace(os.sep, "/")
        paths.append(relative)

paths.sort()
path_set = set(paths)
missing = sorted(required_paths - path_set)
if missing:
    raise SystemExit("Package manifest is missing required paths:\n" + "\n".join(missing))

excluded = [
    path for path in paths
    if path.startswith(excluded_prefixes)
]
if excluded:
    raise SystemExit("Package manifest includes dev-only paths:\n" + "\n".join(excluded))

os.makedirs(os.path.dirname(manifest_path), exist_ok=True)
with open(manifest_path, "w", encoding="utf-8", newline="\n") as handle:
    for path in paths:
        handle.write(path + "\n")
PY

python3 - "$ROOT_DIR" "$ZIP_PATH" "$MANIFEST_PATH" <<'PY'
import os
import stat
import sys
import zipfile

root_dir = sys.argv[1]
zip_path = sys.argv[2]
manifest_path = sys.argv[3]

with open(manifest_path, "r", encoding="utf-8") as handle:
    paths = [line.strip() for line in handle if line.strip()]

os.makedirs(os.path.dirname(zip_path), exist_ok=True)
with zipfile.ZipFile(zip_path, "w") as archive:
    for relative in paths:
        absolute = os.path.join(root_dir, relative)
        with open(absolute, "rb") as source:
            info = zipfile.ZipInfo(relative)
            info.date_time = (2026, 1, 1, 0, 0, 0)
            mode = stat.S_IMODE(os.stat(absolute).st_mode)
            info.external_attr = mode << 16
            archive.writestr(info, source.read(), compress_type=zipfile.ZIP_DEFLATED)
PY

python3 - "$ZIP_PATH" <<'PY'
import sys
import zipfile

zip_path = sys.argv[1]
excluded_prefixes = (
    "docs/",
    "tests/",
    "debug/",
    "tools/",
    "examples/",
    ".godot/",
    ".godot_user/",
    "dist/",
)
required_paths = {
    "addons/hex_map_kit/plugin.cfg",
    "addons/hex_map_kit/plugin.gd",
    "addons/hex_map_kit/assets/sample_hex_tiles.png",
    "addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
    "addons/hex_map_kit/assets/sample_spawn_marker.tscn",
}

with zipfile.ZipFile(zip_path, "r") as archive:
    names = set(archive.namelist())
    missing = sorted(required_paths - names)
    excluded = sorted(name for name in names if name.startswith(excluded_prefixes))

if missing:
    raise SystemExit("Package zip is missing required paths:\n" + "\n".join(missing))
if excluded:
    raise SystemExit("Package zip includes dev-only paths:\n" + "\n".join(excluded))
PY

printf 'Package manifest: %s\n' "$MANIFEST_PATH"
printf 'Package zip: %s\n' "$ZIP_PATH"
