# CAT-01 Test Result 2026-06-07

## Command

```sh
./tools/test.sh
```

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

Test run directory:

```text
.godot_user/test-runs/20260607-014609-85331
```

## Notes

- `tests/test_hex_adapter.gd` passed with new `HexTileCatalogResource` / `HexTileCatalogEntry` coverage.
- macOS emitted the known nonfatal CA certificate error documented in `docs/TEST.md`.
- Existing editor test warnings about intentionally invalid adjacency/source/mask fixtures remained nonfatal and expected.
