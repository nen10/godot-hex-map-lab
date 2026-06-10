# GENPIPE-NEXT-10 Sub Tasks

Task: `GENPIPE-NEXT-10_GENERATION_RESULT_RESOURCE_AND_REPLAY_API`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Adopt / Defer Decisions

| candidate | decision | reason |
|---|---|---|
| `HexGenerationResultResource` | adopt | Generated candidates need a Resource boundary before graph/UI work. |
| Replay-to-document API | adopt | Generate and QA should promote from a result object, not only seed row dictionaries. |
| Result scope snapshot | adopt | Primary/overlay/candidate/validation scope must be inspectable. |
| Pipeline graph UI | defer | Explicitly queued as `GENPIPE-NEXT-20`. |

## Sub Tasks

| id | work | completion signal |
|---|---|---|
| `GENPIPE-NEXT-10.01` | Add `HexGenerationResultResource`. | Resource stores seed, status, primary/overlay/candidate document, validation result/summary, preview, score, and replay scope. |
| `GENPIPE-NEXT-10.02` | Attach result resources to Generate batch rows. | Batch rows expose `generation_result` and replay availability. |
| `GENPIPE-NEXT-10.03` | Promote QA/Generate rows through result replay. | Promotion preserves metadata and uses the result Resource when present. |
| `GENPIPE-NEXT-10.04` | Add Resource/API/editor tests and docs. | Tests cover save/load, row resource presence, replay, promotion, and QA snapshot exposure. |

## Non Goals

- Do not build a pipeline graph UI.
- Do not replace Generation Profile behavior schemas.
- Do not change generator algorithms or scoring formulas.
