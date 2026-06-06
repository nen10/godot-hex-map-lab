# PKG-03 Policy

Task: `PKG-03`  
Created: 2026-06-07  
Status: RUNNING

## Decisions

- The addon package includes only `addons/hex_map_kit/`.
- The manifest must include required addon files and exclude `docs/`, `tests/`, `debug/`, `tools/`, `examples/`, `.godot/`, `.godot_user/`, and `dist/`.
- `--check` mode writes under `.godot_user/` so normal test runs do not create release artifacts.
- Normal mode writes the zip and manifest under `dist/`.
- The package version is read from `addons/hex_map_kit/plugin.cfg`.
- Public upload remains a human check and is not automated.

## Compatibility

- This task updates package metadata and documentation, not saved map schema.
- The migration guide documents v0.2 to v0.3 workflow changes and compatibility expectations.

