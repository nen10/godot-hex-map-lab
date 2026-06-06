# LD2-06 Test Result

作成日: 2026-06-07
Queue task: `LD2-06`
Command: `./tools/test.sh`
Result: PASS

## Passing Run

`./tools/test.sh` completed successfully under Godot `v4.6.2.stable.official.71f334935`.

Latest run directory:

```text
.godot_user/test-runs/20260607-010740-45203
```

Passing scripts:

- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`

## LD2-06 Coverage Added

- `tests/test_debug_scenes.gd` verifies a runtime `HexTileMapLayer` loads a saved v2 `HexMapDocumentResource` path.
- `tests/test_debug_scenes.gd` verifies the runtime helper rejects a missing document path.
- `tests/test_debug_scenes.gd` verifies v2 terrain, overlay, object, and label payloads apply through the runtime path.
- `docs/TEST.md` now lists runtime v2 document path-load coverage.

## Non-Fatal Output

Godot printed the known macOS system CA certificate message:

```text
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

`docs/TEST.md` documents this as non-fatal when the command exits successfully. The editor tests also emitted expected warning-path messages and still reported all tests passed.

## Classification

- `implementation-regression`: none
- `test-expectation-wrong`: none
- `pre-existing`: known warning-path editor output
- `environment`: known macOS CA certificate message
- `repair-now`: none
