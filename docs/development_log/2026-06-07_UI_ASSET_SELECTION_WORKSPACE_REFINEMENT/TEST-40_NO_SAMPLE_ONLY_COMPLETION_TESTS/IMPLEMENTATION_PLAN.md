# TEST-40 Implementation Plan

## Scope

Add an explicit no-sample-only editor test contract and document where sample/package integrity is verified.

## Files

- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `TEST-40` `RUNNING`.
2. Add an editor test that creates project resources through feature-screen APIs while sample mode remains OFF.
3. Assert project asset slot state uses `SOURCE_PROJECT` and no selected asset path comes from bundled sample assets.
4. Keep Settings / Samples ON/OFF assertions in the existing sample settings test.
5. Update `docs/TEST.md` with TEST-40 coverage and package/sample boundary.
6. Run `./tools/test.sh`.
7. Self-review, repair, update queue proof, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Feature-screen contract asserts sample mode OFF.
- [x] Feature-screen contract asserts project asset slot state.
- [x] Feature-screen contract does not use bundled sample success as feature completion.
- [x] Sample mode ON/OFF remains in Settings / Samples coverage.
- [x] Package/sample integrity ownership is documented.
- [x] Queue proof and next READY task are clear.
