# Implementation Plan

## Scope

Create the pipeline graph research/decision proof for Generate/QA after the result Resource boundary exists.

## Target Files

- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GENPIPE-NEXT-20_PIPELINE_GRAPH_UI_RESEARCH_AND_SPIKE/PIPELINE_GRAPH_DECISION.md`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Implementation Steps

1. Compare Resource pass, linear pipeline, and node graph approaches.
2. Record the selected direction and rejected options.
3. Map any future UI work to policy-scoped conditions rather than adding unqueued implementation.
4. Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with review coverage.
5. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Node graph implementation | reject | Current workflow does not justify graph editing. |
| Linear step UI implementation | defer | Decision proof only; no new UI task is required now. |
| Resource inspector implementation | defer | Existing result scope is test-covered; UI can be queued if future review asks for it. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Result Resource boundary | Decision ignores new API. | Decision doc references `HexGenerationResultResource`. |
| Future graph work | Ambiguous scope causes overbuild. | Decision doc explicitly rejects node graph now. |
| Process proof | Docs-only task lacks verification. | `./tools/test.sh` and self-review. |

## Docs Updates

- Add `PIPELINE_GRAPH_DECISION.md`.
- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `GENPIPE-NEXT-20` review coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Decision doc compares all three options.
- Pass graph is explicitly scoped or rejected.
- Queue proof and current pointer are updated.
- `./tools/test.sh` passes.
