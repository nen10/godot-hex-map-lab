# CATUI-01 Implementation Plan

## Scope

Add catalog key selector controls in Generate Dock and Edit Dock, wire them to existing numeric fallback state, add headless tests, update test docs, run the full suite, self-review, queue proof, and commit.

## Steps

1. Load the sample `HexTileCatalogResource` by default in both docks.
2. Add filtered `OptionButton` selectors for floor, wall, overlay, and object defaults.
3. On selector change, resolve the catalog entry and copy effective source/atlas/alternative values into existing numeric state.
4. Extend Generate Dock overlay item pool rows with catalog key selectors and keep copy buttons numeric-compatible.
5. Extend Edit Dock tile payload and default target tile settings with catalog selectors.
6. Add editor plugin tests for Generate Dock and Edit Dock catalog-backed defaults plus numeric fallback retention.
7. Update `docs/TEST.md`.
8. Run `./tools/test.sh`; repair failures in-task.
9. Write self-review/test-result docs, update queue proof, and commit.
