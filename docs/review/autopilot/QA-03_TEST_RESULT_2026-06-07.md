# QA-03 Test Result 2026-06-07

## Scope

- Task: `QA-03`
- Plan: `docs/plan/2026-06-06_QA-03_SEED_PROMOTION/`
- Implementation under test:
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `tests/test_editor_plugin.gd`
  - `docs/TEST.md`

## Targeted Check

```sh
HEX_MAP_TEST_RUN_ID=qa03-target-20260607-042242-9239 /Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/qa03-target-test_editor_plugin.log --path . --script res://tests/test_editor_plugin.gd
```

Result: PASS

## Completion Check

```sh
./tools/test.sh
```

Result: PASS

Godot: `v4.6.2.stable.official.71f334935`

Run root: `.godot_user/test-runs/20260607-042256-9551/`

Passing scripts:

- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`

Notes:

- macOS certificate `get_system_ca_certificates` messages appeared with exit code 0; this is documented as non-fatal in `docs/TEST.md`.
- Existing warning-path tests intentionally emit invalid adjacency, missing source, empty mask, empty deductor, and empty overlay source warnings.
