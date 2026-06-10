# Pipeline Graph Decision

Task: `GENPIPE-NEXT-20_PIPELINE_GRAPH_UI_RESEARCH_AND_SPIKE`
Date: 2026-06-10

## Current Boundary

`GENPIPE-NEXT-10` introduced `HexGenerationResultResource` as the durable generated candidate payload. Current Generate and QA flows are:

1. Configure generation inputs.
2. Generate candidate map/overlay data.
3. Store candidate scope in `HexGenerationResultResource`.
4. Validate candidate document.
5. Compare QA score rows.
6. Replay/promote one result to the Level Document.

The workflow is linear and candidate-centered. There is no current user operation that edits arbitrary pass dependencies.

## Option Matrix

| option | fit | cost | risk | decision |
|---|---|---|---|---|
| Resource pass detail | High. Exposes `HexGenerationResultResource.scope_snapshot()` and validates the Resource boundary. | Low. Existing result Resource already stores scope. | Low. Can remain a detail surface, not a workflow rewrite. | Adopt as future UI scope if inspection is requested. |
| Linear pipeline stepper | Medium-high. Explains Generate to QA to promotion without graph complexity. | Medium. Requires compact step UI and state mapping. | Medium. Could duplicate existing status/progress rows if rushed. | Defer; queue only if UI review asks for clearer pipeline sequencing. |
| Node graph editor | Low today. Current flow has no arbitrary pass wiring. | High. Requires graph model, editing rules, persistence, validation, and new tests. | High. Overstates current product complexity and risks becoming a prototype-only surface. | Reject for this roadmap cycle. |

## Decision

Do not build a node graph UI for the current roadmap.

The supported near-term direction is a Resource pass detail surface that can display the existing result Resource scope:

- result id
- seed
- primary map presence
- overlay map presence
- candidate document presence
- validation result presence
- preview availability
- replay availability

This is scoped as a future UI enhancement, not required work for this task. Current tests already prove the Resource/API boundary and QA/Generate promotion path.

## Pass Graph Scope

Pass graph is explicitly rejected as an editable graph for this roadmap cycle.

A non-editable "result scope" view is acceptable later if it reads directly from `HexGenerationResultResource.scope_snapshot()` and does not introduce graph-specific persistence. That view should be treated as an inspector/detail surface, not a graph editor.

## Revisit Conditions

Reconsider graph UI only if at least one of these becomes true:

- Generation profiles gain multiple ordered passes that users can reorder or branch.
- Validation/generation passes need visible dependency debugging beyond result scope.
- QA needs to compare alternative pass paths, not just seed candidates.

Until then, Generate and QA should stay focused on candidate generation, comparison, and promotion.

## Queue Impact

No new queue item is required now.

Existing queued work remains correctly separated:

- `PROFILE-NEXT-10` owns concrete profile behavior schemas.
- `STATE-NEXT-10` owns root reducer/event model expansion.
- `STATE-NEXT-11` owns generation private flag mirror retirement.
