# UI-METRIC-07 Implementation Plan

## Scope

- Add a standard Godot test script that runs runtime Workspace layout metric reports.
- Write JSON and Markdown reports under `.godot_user/ui-metrics/<run-id>/`.
- Add the script to `tools/test.sh`.
- Update `docs/TEST.md` with report output details.
- Run `./tools/test.sh`; repair true P0 failures or evaluator false positives.
- Write proof docs, update queue status/proof, and commit.

## Target Files

- `tests/test_workspace_layout_metric_gate.gd`
- `tools/test.sh`
- `docs/TEST.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-07_TEST_SH_INTEGRATION/`
- `docs/review/autopilot/UI-METRIC-07_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/UI-METRIC-07_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Steps

- Mark `UI-METRIC-07` RUNNING and create plan docs.
- Add the metric gate test script and report writer helpers.
- Add the test script to `tools/test.sh`.
- Document report output.
- Run `./tools/test.sh`.
- Repair any P0 failures or evaluator false positives.
- Write proof docs.
- Mark `UI-METRIC-07` COMPLETE, update pointer, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Runtime snapshot collector | Gate cannot build scenario snapshots. | Metric gate test. |
| P0 evaluator | Gate does not fail on P0 failures. | Metric gate test asserts zero actual P0 failures. |
| Report output | Reports are missing or unreadable. | File existence and JSON parse assertions. |
| Standard verification | `tools/test.sh` misses gate script. | `./tools/test.sh`. |
| P1 report-only | P1 issues accidentally fail standard tests. | Gate test records P1 count without failing on it. |

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- `tools/test.sh` runs the Workspace P0 metric gate.
- JSON and Markdown reports are written under `.godot_user/ui-metrics/<run-id>/`.
- P0 failure count is zero for current representative Workspace scenarios.
- P1 counts remain report-only.
