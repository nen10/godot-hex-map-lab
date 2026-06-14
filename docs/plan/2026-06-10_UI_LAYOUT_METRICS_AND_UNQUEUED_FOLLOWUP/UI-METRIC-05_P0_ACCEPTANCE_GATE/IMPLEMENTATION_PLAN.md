# UI-METRIC-05 Implementation Plan

## Scope

- Extend `HexUILayoutMetricEvaluator` with P0 gate report semantics.
- Add P0 failure categories for sample fallback in production and unreachable primary action.
- Add tests for synthetic P0 fail/pass reports and JSON serialization.
- Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- Run `./tools/test.sh`.
- Write self-review and test-result proof, update queue status/proof, and commit.

## Target Files

- `addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd`
- `tests/test_workspace_layout_metric_evaluator.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-05_P0_ACCEPTANCE_GATE/`
- `docs/review/autopilot/UI-METRIC-05_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/UI-METRIC-05_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Steps

- Mark `UI-METRIC-05` RUNNING and create plan docs.
- Add `evaluate_p0()` and P0 report JSON serialization support.
- Add sample fallback and unreachable primary action P0 checks.
- Extend evaluator tests with synthetic P0 failing and passing snapshots.
- Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- Run `./tools/test.sh`.
- Write proof docs.
- Mark `UI-METRIC-05` COMPLETE, promote dependency-satisfied tasks, update proof log, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Warn-only evaluator | P0 changes break UI-METRIC-04 report behavior. | Existing evaluator tests still pass. |
| P0 category coverage | Required P0 categories are missing. | Synthetic P0 failure test. |
| Passing path | Gate cannot represent clean snapshots. | Synthetic clean P0 test. |
| JSON output | `UI-METRIC-07` cannot consume report. | P0 report JSON parse assertion. |
| Standard verification | Gate API/test breaks package/test flow. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- Visible no-op button, missing required scroll, state contradiction, sample fallback in production, debug leakage, required generic Resource picker, and unreachable primary action produce P0 failures.
- P0 report can pass with zero failures.
- P0 report serializes to JSON.
- Actual standard test gate integration remains queued to `UI-METRIC-07`.
