# PKG-71 Implementation Plan

## Scope

Add a clean project asset flow test and document the package/manual contract.

## Files

- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/manual/MANUAL_PACKAGE.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `PKG-71` `RUNNING`.
2. Add clean project flow test: plugin load, missing validation before selection, new document, new catalog, user TileSet, user object scene.
3. Update package/test docs.
4. Run `./tools/test.sh`.
5. Self-review, repair, update queue proof, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Plugin load is covered.
- [x] Missing asset validation before selection is covered.
- [x] New document and catalog project assets are covered.
- [x] User TileSet and user object scene are covered.
- [x] Package/manual docs are updated.
- [x] Queue proof confirms no READY tasks remain.
