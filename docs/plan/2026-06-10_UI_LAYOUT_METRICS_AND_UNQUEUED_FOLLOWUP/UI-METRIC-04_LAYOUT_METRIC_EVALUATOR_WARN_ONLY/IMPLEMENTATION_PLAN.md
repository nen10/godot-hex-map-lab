# UI-METRIC-04 Implementation Plan

## Scope

- Add `HexUILayoutMetricEvaluator` under addon editor testing helpers.
- Emit warn-only findings for text truncation, resource row geometry, missing scroll reachability, large dead area, visible debug leakage, no-op action, generic picker specificity, and state contradiction.
- Add a Godot test that verifies each warning category from a synthetic snapshot and evaluates a runtime Workspace snapshot without failing on warnings.
- Wire the evaluator test into `tools/test.sh` and document it in `docs/TEST.md`.
- Write self-review and test-result proof, update queue status/proof, and commit.

## Target Files

- `addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd`
- `tests/test_workspace_layout_metric_evaluator.gd`
- `tools/test.sh`
- `docs/TEST.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-04_LAYOUT_METRIC_EVALUATOR_WARN_ONLY/`
- `docs/review/autopilot/UI-METRIC-04_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/UI-METRIC-04_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Steps

- Mark `UI-METRIC-04` RUNNING and create plan docs.
- Implement evaluator report schema and warning category checks.
- Add synthetic category coverage and runtime Workspace report smoke test.
- Add the test script to `tools/test.sh`.
- Update `docs/TEST.md`.
- Run `./tools/test.sh`.
- Write self-review and test-result docs.
- Mark `UI-METRIC-04` COMPLETE, promote dependency-satisfied tasks, update proof log, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Snapshot schema | Evaluator cannot read collector output. | Runtime Workspace snapshot test. |
| Category coverage | Required warning categories are missing. | Synthetic snapshot category assertions. |
| Warn-only behavior | Current warnings accidentally fail tests. | Test asserts report shape, not zero warnings. |
| JSON output | Later gate/report tools cannot consume the result. | Report JSON parse assertion. |
| Standard verification | New test breaks package/test flow. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- Required metric categories produce severity `warn` findings.
- Runtime Workspace snapshot evaluation returns a report without fail-gating warning count.
- `docs/TEST.md` documents UI-METRIC-04 coverage.
- `tools/test.sh` runs the evaluator test.
