# LD2-05 Test Result

作成日: 2026-06-07
Queue task: `LD2-05`
Command: `./tools/test.sh`
Result: PASS

## Passing Run

`./tools/test.sh` completed successfully under Godot `v4.6.2.stable.official.71f334935`.

Latest run directory:

```text
.godot_user/test-runs/20260607-010327-39273
```

Passing scripts:

- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`

## LD2-05 Coverage Added

- `tests/test_editor_plugin.gd` verifies Edit Dock loading a pure v2 `HexMapDocumentResource` from path.
- `tests/test_editor_plugin.gd` verifies the loaded v2 document applies terrain, overlay, object, and label payloads to `HexTileMapLayer`.
- `tests/test_editor_plugin.gd` verifies editing a loaded v2 document updates typed terrain assignments.
- `tests/test_editor_plugin.gd` verifies saving preserves typed v2 terrain, overlay, object, and label resources.
- `tests/test_editor_plugin.gd` verifies exporting a map from a loaded v2 document preserves orientation and walls.
- `docs/TEST.md` now lists v2 Edit Dock load/edit/save/export coverage.

## Repair Record

Two repair-now items were found and fixed before the passing run:

- Adapter refactor introduced an undeclared `key` in v2 zone cleanup, which prevented dependent scripts from compiling.
- The v2 empty-zone cleanup block was accidentally nested under a `continue`, so deleted-cell cleanup left empty zones behind.

Both were repaired in `addons/hex_map_kit/adapter/hex_map_document_adapter.gd` and verified by the final passing `./tools/test.sh` run.

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
