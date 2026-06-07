# PKG-70 Implementation Plan

## Scope

Add an explicit sample-as-learning package contract test and document its coverage.

## Files

- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `PKG-70` `RUNNING`.
2. Add an editor/package-facing test that loads sample catalog, tile texture, and sample scene.
3. Assert sample mode OFF does not inject samples into Generate/Paint.
4. Assert sample mode ON exposes sample catalog learning candidates.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`.
7. Self-review, repair, update queue proof, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Sample catalog, tile texture, and object scene are loadable.
- [x] Sample mode OFF does not inject main selector fallbacks.
- [x] Sample mode ON exposes learning candidates.
- [x] Package manifest check remains part of `./tools/test.sh`.
- [x] Queue proof and next READY task are clear.
