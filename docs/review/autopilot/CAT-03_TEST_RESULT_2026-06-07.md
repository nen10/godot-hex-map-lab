# CAT-03 Test Result 2026-06-07

## Command

```sh
./tools/test.sh
```

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

Test run directory:

```text
.godot_user/test-runs/20260607-015727-99811
```

## Repair Note

An intermediate run failed because the new document fallback assertion expected flat-top `q=2` at `Vector2i(2, 0)`. The correct TileMap cell is produced by `HexMapTileAdapter.vector_to_map_cell(HexVector.q_axis().scaled(2))`. The assertion was repaired and the full suite was rerun successfully.

## Notes

- `tests/test_hex_adapter.gd` passed with catalog-backed map, overlay, and document adapter coverage.
- macOS emitted the known nonfatal CA certificate error documented in `docs/TEST.md`.
- Existing editor test warnings about intentionally invalid adjacency/source/mask fixtures remained nonfatal and expected.
