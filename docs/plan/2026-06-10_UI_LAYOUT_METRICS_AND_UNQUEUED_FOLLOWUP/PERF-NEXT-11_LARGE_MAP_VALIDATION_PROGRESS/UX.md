# PERF-NEXT-11 UX

## User Job

A developer validates a larger Level Document and needs to see that validation is actively traversing document phases instead of appearing stalled.

## Required Visible State

| state | UX requirement |
|---|---|
| Validate run busy | Validate workflow state reports running and a current phase while validation is active. |
| Validate result progress | Final Validate snapshots keep the completed progress state for the most recent run. |
| Generate validation busy | Generate validation reuses the existing progress controls and validating step. |
| Traversal scale | Progress summary includes document counts so large-map validation is explainable. |

## First Impression Bar

- Validation must feel like an active workflow, not a silent synchronous operation.
- Generate and Validate should use consistent busy/progress language.
- Progress text should name work phases, not raw internal data or JSON.

## Rejections

| rejected option | reason |
|---|---|
| Snapshot-only progress | Does not help visible busy state. |
| Per-cell UI updates | Too noisy and likely to degrade large-map validation. |
| Separate Generate validation widget | Existing Generate progress controls already own busy state. |
