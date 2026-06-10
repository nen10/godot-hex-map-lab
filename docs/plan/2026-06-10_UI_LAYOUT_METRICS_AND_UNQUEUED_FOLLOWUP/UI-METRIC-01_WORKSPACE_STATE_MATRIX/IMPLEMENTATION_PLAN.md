# UI-METRIC-01 Implementation Plan

## Scope

- Create `docs/ui/WORKSPACE_STATE_MATRIX.md`.
- Define stable state ids for the minimum states listed in UI layout metric policy.
- For each state, define input summary, expected visible output, forbidden visible output, primary tabs, and state sources.
- Run standard verification and write proof docs.
- Update queue status, dependency sweep, proof log, and current pointer.

## Target Files

- `docs/ui/WORKSPACE_STATE_MATRIX.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-01_WORKSPACE_STATE_MATRIX/`
- `docs/review/autopilot/UI-METRIC-01_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/UI-METRIC-01_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Steps

- Mark `UI-METRIC-01` RUNNING and create plan docs.
- Create `WORKSPACE_STATE_MATRIX.md`.
- Run `./tools/test.sh`.
- Write self-review and test-result docs.
- Mark `UI-METRIC-01` COMPLETE, promote dependency-satisfied tasks, update proof, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| `WORKSPACE_UI_CONTRACT.md` | State matrix contradicts tab contract. | Use same tab names, component/state-source language. |
| UI layout metric policy | Minimum scenario list is incomplete. | Matrix covers the listed minimum Workspace states. |
| Later scenario builder | State ids are too prose-like for automation. | Use stable snake_case state ids. |
| Standard repo verification | Docs-only change still needs baseline proof. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- No selected node state defines expected and forbidden output.
- Selected node without resources and selected with resources states define expected and forbidden output.
- Sample on/off states define expected and forbidden output.
- Generate preview/running/apply states define expected and forbidden output.
- Validation, QA, Export, and Settings states define expected and forbidden output.
