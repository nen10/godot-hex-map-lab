# LST-01 Test Result 2026-06-07

## Command

```sh
./tools/test.sh
```

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

Test run directory:

```text
.godot_user/test-runs/20260607-020239-6684
```

## Repair Note

Two intermediate runs exposed script issues in the new layer stack resource:

- Static constructors could not reference `HexLayerStackResource` by class name during compile.
- Assigning an untyped array to exported `Array[Resource]` failed.

Both were repaired by explicitly loading the resource script in static constructors and building typed `Array[Resource]` template arrays. The full suite then passed without layer-stack script errors.

## Notes

- `tests/test_hex_tile_map_layer.gd` passed with new layer stack template and save/load coverage.
- macOS emitted the known nonfatal CA certificate error documented in `docs/TEST.md`.
- Existing editor test warnings about intentionally invalid adjacency/source/mask fixtures remained nonfatal and expected.
