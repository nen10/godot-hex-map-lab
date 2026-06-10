# GENPIPE-NEXT-20 Sub Tasks

Task: `GENPIPE-NEXT-20_PIPELINE_GRAPH_UI_RESEARCH_AND_SPIKE`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Adopt / Defer Decisions

| candidate | decision | reason |
|---|---|---|
| Pipeline graph decision doc | adopt | The task is a research/spike item and needs explicit option scoring. |
| Resource pass scope | adopt | `GENPIPE-NEXT-10` created a Resource boundary that should guide UI scope. |
| Full node graph prototype | reject unless evidence changes | Current Generate/QA workflows are linear and candidate-based. |
| Code UI implementation | defer | This task decides scope; implementation belongs in a later explicitly queued UI task if needed. |

## Sub Tasks

| id | work | completion signal |
|---|---|---|
| `GENPIPE-NEXT-20.01` | Compare Resource pass, linear pipeline, and node graph options. | Decision table records fit, cost, risk, and recommendation. |
| `GENPIPE-NEXT-20.02` | Scope or reject pass graph. | Decision doc explicitly scopes supported pass graph or rejects it. |
| `GENPIPE-NEXT-20.03` | Update queue proof and docs. | `IMPLEMENTATION_QUEUE.md`, self-review, and test result link decision proof. |

## Non Goals

- Do not add a node graph control.
- Do not change generation algorithms.
- Do not create a new implementation follow-up unless the decision finds blocking missing work.
