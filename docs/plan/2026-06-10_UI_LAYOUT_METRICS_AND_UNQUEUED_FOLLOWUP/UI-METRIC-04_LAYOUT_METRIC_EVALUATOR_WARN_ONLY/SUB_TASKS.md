# UI-METRIC-04 Layout Metric Evaluator Warn-only Sub Tasks

## Complexity

Class: C4
Reason:
- This task adds runtime metric evaluation across multiple UX risk categories.
- It must define warning schema without prematurely creating pass/fail acceptance gates.
- It touches addon testing helpers, standard Godot tests, queue proof, and test documentation.

Required artifacts:
- Task Resolution candidate matrix
- Scheduled Task Audit
- UX Candidate Matrix
- Fallback / Mirror Handling table
- State / Invariant Table
- Dependency / Test Matrix
- Standard test proof

## Task Resolution Candidate Matrix

| candidate | decision | reason |
|---|---|---|
| Add `HexUILayoutMetricEvaluator` with warn-only report schema. | Adopt | This is the required deliverable and feeds later gates. |
| Emit warning category, severity, path, message, and evidence. | Adopt | Later P0/P1 tasks need stable machine-readable findings. |
| Cover text truncation, resource row geometry, scroll, dead area, debug leakage, no-op action, picker specificity, and state contradiction. | Adopt | These are the UI-METRIC-04 acceptance categories. |
| Test current runtime Workspace snapshots without failing on warnings. | Adopt | Warn-only means current UI findings are observable but nonblocking. |
| Use synthetic snapshots to prove each category. | Adopt | Current UI may not naturally trigger every category on one run. |
| Add P0/P1 failure thresholds now. | Reject | P0/P1 gates are already queued as `UI-METRIC-05` and `UI-METRIC-06`. |
| Persist `.godot_user/ui-metrics` reports from `tools/test.sh` now. | Reject | Standard report output and integration are queued as `UI-METRIC-07`. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| P0 acceptance gate | `UI-METRIC-05` | already queued | This task must not fail standard tests on warnings. |
| P1 acceptance gate | `UI-METRIC-06` | already queued | P1 severity thresholds need separate tuning. |
| Standard metric report output / test.sh P0 gate | `UI-METRIC-07` | already queued | Persistent report output and failure integration are later. |
| UI task self-review template metric reference | `UI-METRIC-08` | already queued | This task only creates the report shape. |

## Scheduled Task

No scheduled task is added from this slice.
