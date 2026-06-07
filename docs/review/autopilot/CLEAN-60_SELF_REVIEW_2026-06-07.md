# CLEAN-60 Self Review

## Scope

- Tightened package manifest required paths to include the sample catalog scene dependency.
- Added sample catalog test assertions for no debug path text, packaged scene path, existing scene resource, and validator clean.
- Updated package/test docs and CLEAN-60 plan packet.
- Promoted CLEAN-61 to READY after dependency sweep.

## Acceptance

- Sample catalog has no debug path: `tests/test_hex_adapter.gd` checks the `.tres` text does not contain `debug/`.
- Missing scene is prevented: `object.spawn_marker` references `res://addons/hex_map_kit/assets/sample_spawn_marker.tscn`, and the test checks `ResourceLoader.exists(...)`.
- Package manifest includes sample dependencies: `tools/package_addon.sh --check` now requires `sample_hex_tiles.png`, `sample_hex_tile_catalog.tres`, and `sample_spawn_marker.tscn`.
- Sample catalog validator clean: existing validator assertion remains passing.

## Verification

- `git diff --check` PASS.
- `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`.
- Existing macOS `get_system_ca_certificates` errors and editor warning fixtures remain non-fatal known output.

## Review Result

- repair-now: none.
- follow-up-ready: none.
- known-env-failure: none.
- accepted-risk: committed `dist/` regeneration is intentionally deferred to CLEAN-61.
- manual-optional: none.
