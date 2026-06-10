# DOC-90 Implementation Plan

## Scope

- Update editor and workflow manuals for the current workspace route.
- Add source badge definitions.
- Keep sample learning as a separate production-safe path.
- Update `docs/TEST.md` manual coverage note.
- Run standard verification and write proof docs.

## Target Files

- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `README.md`
- `docs/TEST.md`
- `docs/review/autopilot/DOC-90_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/DOC-90_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `DOC-90` RUNNING and create plan docs.
- [x] Update manual workflow order and source badge explanations.
- [x] Add a concise README pointer if needed.
- [x] Update `docs/TEST.md`.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `DOC-90` COMPLETE, update pointer/dependencies, and commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Selected `HexTileMap` -> Resources -> Generate -> Paint -> Catalog -> Validate -> QA -> Export flow is explained.
- [x] Resource source badge meanings are explained.
- [x] Sample learning is a separate chapter/path.
- [x] No analog test is added.
