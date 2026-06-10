# UI-METRIC-03 Layout Snapshot Collector Sub Tasks

## Complexity

Class: C4
Reason:
- This task adds runtime editor UI test infrastructure with scenario building and JSON snapshot serialization.
- It touches addon testing helpers, standard Godot tests, and test documentation.
- It intentionally stops before warning evaluation and failure gates, which are already queued.

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
| Add a reusable `HexUILayoutSnapshotCollector`. | Adopt | The next metric evaluator needs a stable visible Control snapshot shape. |
| Add a Workspace scenario builder. | Adopt | Snapshot proof must cover meaningful Workspace states rather than a single sample path. |
| Capture rect, minimum size, text, base type, tooltip, scroll parent, and metadata. | Adopt | These fields map directly to UI contract and state-matrix risk classes. |
| Serialize snapshots as deterministic JSON text. | Adopt | Later report tooling can consume the same artifact shape. |
| Add warn/fail metric scoring now. | Reject | Warn-only evaluator is `UI-METRIC-04`; P0/P1 gates are `UI-METRIC-05` and `UI-METRIC-06`. |
| Write JSON files under `.godot_user/ui-metrics` now. | Reject | Persistent report output belongs with evaluator and `tools/test.sh` integration. |
| Use bundled samples as the only scenario. | Reject | Sample-only completion is explicitly not production feature completion. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Warn-only metric evaluator | `UI-METRIC-04` | already queued | Collector should only provide raw snapshot data. |
| P0 acceptance gate | `UI-METRIC-05` | already queued | Failure semantics require separate metric policy. |
| P1 acceptance gate | `UI-METRIC-06` | already queued | P1 scoring is broader than collector readiness. |
| Standard metric report output | `UI-METRIC-07` | already queued | `tools/test.sh` gate/report integration is intentionally later. |
| Sample-only scenario | none | rejected | It would violate the roadmap source-of-truth. |

## Scheduled Task

No scheduled task is added from this slice.
