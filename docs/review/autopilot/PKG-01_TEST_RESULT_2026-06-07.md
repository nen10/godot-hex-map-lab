# PKG-01 Test Result

Task: `PKG-01`  
Date: 2026-06-07  
Status: PASS

## Commands

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/pkg01_test_debug_scenes.log --path . --script res://tests/test_debug_scenes.gd
./tools/test.sh
```

## Result

- Targeted debug scene test: PASS.
- Full test suite: PASS on Godot `v4.6.2.stable.official.71f334935`.

## Notes

- Debug-scene coverage now checks `examples/basic_runtime/runtime_query_example.tscn`, `examples/editor_workflow/editor_workflow_example.tscn`, the runtime helper script, and the sample catalog path.
- Example source checks assert the sample scripts do not preload `res://addons/hex_map_kit/editor/`.
- The macOS certificate `ret != noErr` message remains a known non-fatal Godot output noted in `docs/TEST.md`.

