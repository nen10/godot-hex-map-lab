# PERF-NEXT-11 Sub Tasks

Task: `PERF-NEXT-11_LARGE_MAP_VALIDATION_PROGRESS`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Adopt / Defer Decisions

| candidate | decision | reason |
|---|---|---|
| Validator phase progress callback | adopt | Large document validation needs observable traversal state. |
| Validate workflow progress snapshot | adopt | Validate screen must expose busy/progress state, not only final issues. |
| Generate validation busy connection | adopt | Generate already has a validating step; document validation should feed it. |
| Per-cell progress ticks | defer | Phase-level traversal is sufficient for this task and avoids callback volume on very large maps. |

## Sub Tasks

| id | work | completion signal |
|---|---|---|
| `PERF-NEXT-11.01` | Add validation progress reporting to `HexMapDocumentValidator`. | Callback receives monotonic phase snapshots and result summary records the final progress state. |
| `PERF-NEXT-11.02` | Surface validation progress through Validate workflow state. | Validate snapshots and run result expose progress state/current phase. |
| `PERF-NEXT-11.03` | Connect generation validation to Generate progress controls. | Direct generation validation updates the existing validating progress state. |
| `PERF-NEXT-11.04` | Add adapter/editor tests and test docs. | Tests cover progress callback, Validate state, and Generate validation progress. |

## Non Goals

- Do not change validation issue semantics.
- Do not add modal progress UI.
- Do not add per-cell callback spam for every visited cell.
