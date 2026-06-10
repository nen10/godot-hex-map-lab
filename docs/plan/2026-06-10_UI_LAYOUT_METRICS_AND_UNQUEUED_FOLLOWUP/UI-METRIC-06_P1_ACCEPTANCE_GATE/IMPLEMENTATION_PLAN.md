# UI-METRIC-06 Implementation Plan

## Scope

- Extend `HexUILayoutMetricEvaluator` with P1 report semantics.
- Promote text truncation, resource row geometry, and dead area warning categories into P1 issues.
- Add disabled-action-without-tooltip and summary-only task tab P1 checks.
- Extend evaluator tests with synthetic P1 fail/pass reports and JSON serialization.
- Update `docs/TEST.md`.
- Run `./tools/test.sh`.
- Write proof docs, update queue status/proof, and commit.

## Target Files

- `addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd`
- `tests/test_workspace_layout_metric_evaluator.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-06_P1_ACCEPTANCE_GATE/`
- `docs/review/autopilot/UI-METRIC-06_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/UI-METRIC-06_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Steps

- Mark `UI-METRIC-06` RUNNING and create plan docs.
- Add `evaluate_p1()` and P1 report JSON serialization support.
- Add P1 issue checks and synthetic fixtures.
- Update `docs/TEST.md`.
- Run `./tools/test.sh`.
- Write proof docs.
- Mark `UI-METRIC-06` COMPLETE, update pointer, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Warn/P0 evaluator | P1 changes break existing report semantics. | Existing evaluator tests still pass. |
| P1 category coverage | Required P1 categories are missing. | Synthetic P1 issue test. |
| Passing path | P1 report cannot represent clean snapshots. | Synthetic clean P1 test. |
| JSON output | Later command/report tooling cannot consume report. | P1 report JSON parse assertion. |
| Standard verification | New P1 API/test breaks package/test flow. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- Resource row compression, normal-width label truncation, large dead area, disabled action without tooltip, and summary-only task tab produce P1 issues.
- P1 report can pass with zero issues.
- P1 report serializes to JSON.
- Standard P1 failure integration remains queued to `UI-METRIC-07`.
