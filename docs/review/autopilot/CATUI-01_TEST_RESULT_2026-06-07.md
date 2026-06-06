# CATUI-01 Test Result 2026-06-07

## Command

```sh
./tools/test.sh
```

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

Test run directory:

```text
.godot_user/test-runs/20260607-022703-39466
```

## Repair Note

An intermediate full-suite run exited successfully but emitted a script error in the new Generate Dock catalog selector test because the fixture called `_overlay_item_tile_configs()` without current overlay data. The test now installs a minimal overlay data fixture before asserting item tile configs. The full suite then passed without script errors.

## Notes

- `tests/test_editor_plugin.gd` passed with new Generate Dock floor/wall/overlay catalog selector coverage.
- `tests/test_editor_plugin.gd` passed with new Edit Dock default floor/wall, per-mode tile payload, object assignment, and numeric fallback coverage.
- macOS emitted the known nonfatal CA certificate error documented in `docs/TEST.md`.
- Existing editor test warnings about intentionally invalid adjacency/source/mask fixtures remained nonfatal and expected.
