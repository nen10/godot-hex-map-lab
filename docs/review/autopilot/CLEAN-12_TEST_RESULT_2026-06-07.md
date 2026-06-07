# CLEAN-12 Test Result

date: 2026-06-07
task: CLEAN-12_OBJECT_DATABASE_CANONICAL_RESOURCE
status: PASS

## Commands

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/c12_test_hex_adapter.log --path . --script tests/test_hex_adapter.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/c12_test_hex_tile_map_layer.log --path . --script tests/test_hex_tile_map_layer.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/c12_test_debug_scenes.log --path . --script tests/test_debug_scenes.gd
./tools/test.sh
```

## Result

- `tests/test_hex_adapter.gd`: PASS
- `tests/test_hex_tile_map_layer.gd`: PASS
- `tests/test_debug_scenes.gd`: PASS
- `./tools/test.sh`: PASS
- Godot: `v4.6.2.stable.official.71f334935`
- Package check: PASS

## Notes

- macOS certificate warnings from Godot were non-fatal and match the known `docs/TEST.md` note.
