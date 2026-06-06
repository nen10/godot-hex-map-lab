# LD2-01 Test Result

作成日: 2026-06-07
Queue task: `LD2-01`
Command: `./tools/test.sh`
Final result: PASS

## Final Passing Run

`./tools/test.sh` completed successfully under Godot `v4.6.2.stable.official.71f334935`.

Latest run directory:

```text
.godot_user/test-runs/20260607-003059-96846
```

Passing scripts:

- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`

## LD2-01 Coverage Added

- `tests/test_hex_adapter.gd` now verifies that a v2 `HexMapDocumentResource` with terrain layers, overlay layers, object placements, label placements, zones, metadata, and dependencies saves and loads through `.tres`.
- `tests/test_hex_adapter.gd` now verifies that a v1-style document still saves/loads with legacy `map`, `tile_overrides`, `objects`, and `labels` after v2 fields are added.
- `docs/TEST.md` now lists the v2 schema and v1 fixture compatibility coverage.

## Repair Record

An earlier LD2-01 run exposed two implementation issues:

- `HexMapDocumentDependencyResource` attempted to export `resource_path`, which conflicts with Godot `Resource.resource_path`.
- The v2 zone test assigned an untyped Array to an `Array[Vector3i]` export.

Both were repaired before the final passing run:

- Dependency schema now uses `dependency_path`.
- The test now assigns a typed `Array[Vector3i]`.
- The `resource_path` collision was documented in `docs/knowledge/DEV_GODOT.md`.

## Non-Fatal Output

Godot printed the known macOS system CA certificate message:

```text
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

`docs/TEST.md` documents this as non-fatal when the command exits successfully. The editor tests also emitted expected warning-path messages and still reported all tests passed.

## Classification

- `implementation-regression`: repaired
- `test-expectation-wrong`: repaired
- `pre-existing`: none
- `environment`: none
- `repair-now`: none remaining
