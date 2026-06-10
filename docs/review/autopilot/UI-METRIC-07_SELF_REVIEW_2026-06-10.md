# UI-METRIC-07 Self Review 2026-06-10

Task: `UI-METRIC-07_TEST_SH_INTEGRATION`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-07_TEST_SH_INTEGRATION/`

## Execution Summary

Added `tests/test_workspace_layout_metric_gate.gd` and wired it into `tools/test.sh`. Standard verification now runs runtime Workspace P0 metric gate scenarios and writes JSON/Markdown reports under `.godot_user/ui-metrics/<run-id>/`; P0 failures fail the test, while P1 issue counts remain report-only.

## Changed Files

| file | change |
|---|---|
| `tests/test_workspace_layout_metric_gate.gd` | Added runtime metric gate test, report generation, P0 zero-failure assertion, and P1 report-only summary. |
| `tools/test.sh` | Added `tests/test_workspace_layout_metric_gate.gd` to the standard test script list. |
| `docs/TEST.md` | Documented metric report output and UI-METRIC-07 coverage. |
| `addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd` | Narrowed P0 false-positive promotion for no-op actions, debug wording, and required picker specificity before actual gate integration. |
| `tests/test_workspace_layout_metric_evaluator.gd` | Updated synthetic picker metadata to keep P0 required-picker coverage after the promotion refinement. |
| `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-07_TEST_SH_INTEGRATION/` | Added C4 planning docs. |
| `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md` | Marked `UI-METRIC-07` complete, advanced pointer to `UI-METRIC-08`, and added proof. |

## Plan Deviation

| planned item | actual result | reason | queue / proof |
|---|---|---|---|
| Repair true P0 failures if found | No product UI repair was needed | Actual representative scenarios produced P0 failures = 0 after evaluator false-positive narrowing. | Metric report `.godot_user/ui-metrics/20260610-182250-17270/` |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| `tools/test.sh` runs P0 gate. | Pass | `tools/test.sh` includes `res://tests/test_workspace_layout_metric_gate.gd`; standard test output shows it passed. |
| P0 failure count is a standard test gate. | Pass | Gate test asserts `total_p0_failures == 0`; failures would exit nonzero. |
| P1 remains report-only. | Pass | Gate test records `total_p1_issues` but does not assert zero. |
| JSON report is written. | Pass | `.godot_user/ui-metrics/20260610-182250-17270/workspace_layout_metrics.json`. |
| Markdown report is written. | Pass | `.godot_user/ui-metrics/20260610-182250-17270/workspace_layout_metrics.md`. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| UI task self-review template metric reference | Existing queue id | `UI-METRIC-08` |
| P1 standard failure integration | Policy-deferred | Roadmap says P1 can stay separate initially; revisit after P0 integration is stable. |
| Expanded viewport/state matrix | Policy-deferred | Representative scenario matrix is the initial standard gate; expand in later metric/UI task if needed. |

## Repair-now Review

No repair-now items remain.

Pre-verification repair:
- Narrowed runtime P0 promotion to avoid false positives from allowed debug-report controls, placeholder text, and generic pickers without required-picker metadata.

## Test Review

- Command: `./tools/test.sh`
- Result: Pass.
- Package manifest: `.godot_user/package-check/20260610-182250-17275/hex_map_kit-0.3.0.manifest.txt`
- Package zip: `.godot_user/package-check/20260610-182250-17275/hex_map_kit-0.3.0.zip`
- Metric report: `.godot_user/ui-metrics/20260610-182250-17270/workspace_layout_metrics.md`
- Metric result: P0 failures = 0, P1 issues = 0.
- Notes: Known macOS CA certificate warnings and existing editor negative-path warnings appeared with exit code 0.
