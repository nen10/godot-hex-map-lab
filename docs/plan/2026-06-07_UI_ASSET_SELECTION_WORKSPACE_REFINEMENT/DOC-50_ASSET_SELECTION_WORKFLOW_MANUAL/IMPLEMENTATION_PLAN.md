# DOC-50 Implementation Plan

## Scope

Update public-facing manual docs so project asset selection is the default workflow and samples are isolated to learning/onboarding.

## Files

- `README.md`
- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MANUAL_PACKAGE.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `DOC-50` `RUNNING`.
2. Update README editor workflow summary.
3. Update editor plugin manual screen workflows and sample wording.
4. Update workflow manual project-asset sequence and sample boundary.
5. Update package manual production/sample distinction.
6. Run `./tools/test.sh`.
7. Self-review, repair, update queue proof, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Project asset selection is the main workflow.
- [x] Samples are isolated to learning/onboarding.
- [x] `Use Sample Tiles` is not normal setup.
- [x] No analog test files are added.
- [x] Queue proof and next READY task are clear.
