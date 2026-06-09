# CLEAN-61 Policy

## Decisions

- Follow `docs/manual/MANUAL_PACKAGE.md`: the generated zip is addon-only and excludes `docs/`, `tests/`, `debug/`, `tools/`, `examples/`, `.godot_user/`, and `dist/`.
- Treat clean-spec docs as repository documentation, not addon zip contents.
- Force-add generated `dist` files because `dist/` is ignored but this queue task explicitly requires committed artifacts.
- Release upload remains a manual human step.

## Verification

- `./tools/package_addon.sh` regenerates `dist/`.
- Compare a temporary `--check` manifest against committed `dist` manifest.
- Scan manifest for dev-only roots and legacy/migration docs.
- `./tools/test.sh` remains the completion test path.
