# LD2-04 Test Result

作成日: 2026-06-07
Queue task: `LD2-04`
Command: `./tools/test.sh`
Result: PASS

## Passing Run

`./tools/test.sh` completed successfully under Godot `v4.6.2.stable.official.71f334935`.

Latest run directory:

```text
.godot_user/test-runs/20260607-005023-19651
```

Passing scripts:

- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`

## LD2-04 Coverage Added

- `tests/test_hex_adapter.gd` verifies pure v2 document map and payload entries roundtrip through `HexMapDocumentAdapter`.
- `tests/test_hex_adapter.gd` verifies deleting a v2 cell removes terrain assignments, overlay assignments, object placements, label placements, and empty zones.
- `tests/test_hex_tile_map_layer.gd` verifies `HexTileMapLayer.apply_document()` displays pure v2 terrain, overlay, object, and label payloads.
- `docs/TEST.md` now lists v2 adapter roundtrip, deleted-cell cleanup, and v2 display coverage.

## Repair Record

An initial `./tools/test.sh` run exposed a script error in `tests/test_hex_tile_map_layer.gd`: `HexTileMapLayer.apply_document()` still returned early when `document.map == null`, which rejected pure v2 documents whose map is stored in a terrain layer. The guard was repaired to reject only null documents and defer map lookup to `HexMapDocumentAdapter.to_map_resource()`.

## Non-Fatal Output

Godot printed the known macOS system CA certificate message:

```text
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

`docs/TEST.md` documents this as non-fatal when the command exits successfully. The editor tests also emitted expected warning-path messages and still reported all tests passed.

## Classification

- `implementation-regression`: none after repair
- `test-expectation-wrong`: none
- `pre-existing`: known warning-path editor output
- `environment`: known macOS CA certificate message
- `repair-now`: none
