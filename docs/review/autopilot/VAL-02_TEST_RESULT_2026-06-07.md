# VAL-02 Test Result 2026-06-07

## Command

```sh
./tools/test.sh
```

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

Test run directory:

```text
.godot_user/test-runs/20260607-024927-71920
```

## Notes

- `tests/test_editor_plugin.gd` passed with Validation dashboard button, grouped issue row, selected issue state, and cell-scoped HexTileMapLayer highlight coverage.
- `tests/test_hex_adapter.gd` continued to pass with the core `HexMapDocumentValidator` rule coverage from `VAL-01`.
- macOS emitted the known nonfatal CA certificate error documented in `docs/TEST.md`.
- Existing editor test warnings about intentionally invalid adjacency/source/mask fixtures remained nonfatal and expected.
