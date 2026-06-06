# VAL-01 Test Result 2026-06-07

## Command

```sh
./tools/test.sh
```

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

Test run directory:

```text
.godot_user/test-runs/20260607-024021-58177
```

## Repair Note

An intermediate run exposed that the new missing-catalog and missing-tile fixture wrote a catalog key through the legacy tile override path while the document also had typed terrain layers. The fixture now creates a typed terrain assignment with `catalog_key`, so it exercises the v2 document path validated by `VAL-01`.

## Notes

- `tests/test_hex_adapter.gd` passed with outside-map tile payload, orphan label payload, missing dependency, object-on-wall, missing catalog resource, and missing catalog tile coverage.
- macOS emitted the known nonfatal CA certificate error documented in `docs/TEST.md`.
- Existing editor test warnings about intentionally invalid adjacency/source/mask fixtures remained nonfatal and expected.
