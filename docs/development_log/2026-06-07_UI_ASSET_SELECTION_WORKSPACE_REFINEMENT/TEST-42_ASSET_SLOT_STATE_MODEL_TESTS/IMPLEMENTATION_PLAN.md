# TEST-42 Implementation Plan

## Scope

Add a named asset-slot state matrix test that ties missing/invalid/project/sample/duplicate states together.

## Files

- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `TEST-42` `RUNNING`.
2. Add asset-slot state assertions for required missing, invalid type, selected project asset, and explicit sample source.
3. Add workspace sample mode OFF/ON assertions for main selector candidate visibility.
4. Assert duplicate sample-to-project enters asset context and Catalog asset slot as `SOURCE_PROJECT`.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`.
7. Self-review, repair, update queue proof, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Missing required asset state is covered.
- [x] Invalid type state is covered.
- [x] Selected project asset state is covered.
- [x] Sample mode OFF/ON visibility states are covered.
- [x] Duplicate sample project state is covered.
- [x] Queue proof and next READY task are clear.
