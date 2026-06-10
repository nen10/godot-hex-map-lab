# PROC-90 Test Result 2026-06-10

## Commands

```sh
tools/package_addon.sh
./tools/test.sh
cmp -s dist/hex_map_kit-0.3.0.manifest.txt .godot_user/package-check/20260610-115923-68158/hex_map_kit-0.3.0.manifest.txt
cmp -s dist/hex_map_kit-0.3.0.zip .godot_user/package-check/20260610-115923-68158/hex_map_kit-0.3.0.zip
```

## Result

PASS

## Package Output

- `dist/hex_map_kit-0.3.0.manifest.txt`
- `dist/hex_map_kit-0.3.0.zip`
- Package-check artifacts: `.godot_user/package-check/20260610-115923-68158/`

## Notes

- `test_hex_core.gd`: all tests passed.
- `test_hex_map_generation.gd`: all tests passed.
- `test_hex_adapter.gd`: all tests passed.
- `test_hex_tile_map_layer.gd`: all tests passed.
- `test_workspace_state_transitions.gd`: all tests passed.
- `test_asset_slot_state.gd`: all tests passed.
- `test_generation_run_state.gd`: all tests passed.
- `test_paint_interaction_state.gd`: all tests passed.
- `test_workspace_screen_contracts.gd`: all tests passed.
- `test_editor_plugin.gd`: all tests passed.
- `test_debug_scenes.gd`: all tests passed.
- The run emitted the existing macOS CA certificate warnings and expected generation/editor warnings from negative-path tests.
- Regenerated `dist` artifacts match the temporary package-check manifest and zip.
