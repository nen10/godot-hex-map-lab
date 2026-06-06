# GAME-01 Test Result 2026-06-07

## Command

```sh
./tools/test.sh
```

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

Test run directory:

```text
.godot_user/test-runs/20260607-030448-96957
```

## Repair Note

An intermediate run showed that the gameplay fixture wrote catalog keys through the legacy tile override path while the test document used typed terrain layers. The fixture was repaired to use explicit typed terrain assignments, matching the v2 document path.

## Notes

- `tests/test_hex_core.gd` passed with movement profile default passability, cost override, blocker key, blocker tag, and wall behavior coverage.
- `tests/test_hex_adapter.gd` passed with movement profile resource roundtrip and gameplay layer data extraction from map/document/catalog/object state.
- macOS emitted the known nonfatal CA certificate error documented in `docs/TEST.md`.
- Existing editor test warnings about intentionally invalid adjacency/source/mask fixtures remained nonfatal and expected.
