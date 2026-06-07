# DOC-51 Implementation Plan

## Scope

Add focused sample onboarding documentation to README and manuals.

## Files

- `README.md`
- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MANUAL_PACKAGE.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `DOC-51` `RUNNING`.
2. Add README sample onboarding summary.
3. Expand editor plugin manual Settings / Samples workflow.
4. Expand workflow manual sample onboarding path.
5. Cross-reference package sample contents without making samples production defaults.
6. Run `./tools/test.sh`.
7. Self-review, repair, update queue proof, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Sample mode is documented as learning/onboarding.
- [x] Project asset selection remains production workflow.
- [x] Duplicate sample to project is explained.
- [x] Package sample contents are cross-referenced.
- [x] Queue proof and next READY task are clear.
