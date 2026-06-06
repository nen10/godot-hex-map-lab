# LST-02 Test Result 2026-06-07

## Command

```sh
./tools/test.sh
```

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

Test run directory:

```text
.godot_user/test-runs/20260607-020950-14279
```

## Notes

- `tests/test_hex_tile_map_layer.gd` passed with v2 document routing into layer-stack terrain and overlay role children.
- The same test keeps the plain `TileMapLayer` document adapter path covered for compatibility.
- macOS emitted the known nonfatal CA certificate error documented in `docs/TEST.md`.
- Existing editor test warnings about intentionally invalid adjacency/source/mask fixtures remained nonfatal and expected.
