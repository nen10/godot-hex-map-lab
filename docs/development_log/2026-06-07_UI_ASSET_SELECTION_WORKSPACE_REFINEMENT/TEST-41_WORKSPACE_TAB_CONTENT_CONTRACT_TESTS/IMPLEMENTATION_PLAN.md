# TEST-41 Implementation Plan

## Scope

Add a dedicated workspace tab content contract test that enumerates component ids and asset slot ids for every tab.

## Files

- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `TEST-41` `RUNNING`.
2. Add a dedicated editor test for workspace tab component ids and asset slot ids.
3. Assert component rows expose stable tab, component id, class, responsibility, source owner, and slot metadata.
4. Assert Paint does not own Document setup components.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`.
7. Self-review, repair, update queue proof, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Every workspace tab has expected component ids.
- [x] Asset-owning tabs expose expected asset slot ids and counts.
- [x] Component metadata contract is asserted.
- [x] Tests avoid private node paths.
- [x] Queue proof and next READY task are clear.
