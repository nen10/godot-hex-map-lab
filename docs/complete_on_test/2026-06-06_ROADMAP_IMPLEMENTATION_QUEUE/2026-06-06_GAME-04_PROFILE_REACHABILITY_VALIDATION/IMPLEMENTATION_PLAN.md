# GAME-04 Implementation Plan

Date: 2026-06-07

## Steps

1. Mark `GAME-04` as `RUNNING` in the queue.
2. Add profile reachability validation to `HexMapDocumentValidator`.
3. Use `HexGameplayLayerData.from_document()` and `HexGrid.connected_area()`.
4. Add `tests/test_hex_adapter.gd` fixtures for:
   - unreachable important points under a blocking profile;
   - passable-wall profile resolving the same fixture;
   - blocked important point issue metadata.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`, self-review, repair if needed, update queue proof, and commit.
