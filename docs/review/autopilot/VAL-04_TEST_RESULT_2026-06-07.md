# VAL-04 Test Result 2026-06-07

## Command

```sh
./tools/test.sh
```

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

Test run directory:

```text
.godot_user/test-runs/20260607-025840-89127
```

## Notes

- `tests/test_hex_adapter.gd` passed with pass/fail matrix coverage for all accepted core validation rules.
- Covered rules: `document.payload_outside_map`, `document.orphan_payload`, `document.catalog_missing`, `document.tile_missing`, `document.dependency_missing`, and `document.object_on_wall`.
- macOS emitted the known nonfatal CA certificate error documented in `docs/TEST.md`.
- Existing editor test warnings about intentionally invalid adjacency/source/mask fixtures remained nonfatal and expected.
