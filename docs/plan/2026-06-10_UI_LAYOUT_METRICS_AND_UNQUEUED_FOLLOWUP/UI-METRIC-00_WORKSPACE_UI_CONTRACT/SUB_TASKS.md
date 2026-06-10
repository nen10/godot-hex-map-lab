# UI-METRIC-00 Workspace UI Contract Sub Tasks

## Complexity

Class: C4
Reason:
- This task defines a multi-tab Workspace UI contract used by later layout snapshot and metric gate work.
- It affects Resources, Generate, Paint, Catalog, Layers, Validate, QA, Export, and Settings.
- It must preserve Resource row, button, debug, and sample boundaries while leaving state matrix and evaluator implementation to later tasks.

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
| Create `docs/ui/WORKSPACE_UI_CONTRACT.md`. | Adopt | This is the required deliverable for UI metric contract foundation. |
| Include all current Workspace tabs. | Adopt | Metric collection must know the expected purpose and required components per tab. |
| Use stable component ids from `HexMapWorkspaceComponentRegistry`. | Adopt | Later tests can compare snapshots to registry-backed ids instead of private node names. |
| Include Resource row, button, debug, and sample contracts. | Adopt | Acceptance explicitly calls out these cross-cutting contracts. |
| Define initial warn/fail threshold names. | Adopt | Later metric evaluator needs named thresholds before code exists. |
| Create `docs/ui/WORKSPACE_STATE_MATRIX.md` now. | Reject | `UI-METRIC-01` owns state matrix. |
| Implement static audit or runtime snapshot collector now. | Reject | `UI-METRIC-02` and `UI-METRIC-03` own tooling. |
| Change product UI now to satisfy all thresholds. | Reject | This task defines contract; later UI and metric tasks enforce/repair. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Workspace state matrix | `UI-METRIC-01` | already queued | State scenarios need their own document and acceptance. |
| Static UI audit | `UI-METRIC-02` | already queued | Source scanning belongs to audit tooling. |
| Runtime layout snapshot collector | `UI-METRIC-03` | already queued | Godot Control tree collection is a separate implementation task. |
| Metric evaluator / gates | `UI-METRIC-04`, `UI-METRIC-05`, `UI-METRIC-06` | already queued | This task defines names and thresholds, not enforcement. |
| Full screen redesign | later screen tasks | already queued | UI contract can expose risks without redesigning screens in this slice. |

## Scheduled Task

No scheduled task is added from this slice.
