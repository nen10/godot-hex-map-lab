# DOC-70 Self Review

Task: `DOC-70_WORKFLOW_MANUAL`  
Queue: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`  
Plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DOC-70_WORKFLOW_MANUAL/`

## Execution Summary

Updated the workflow manual and README so the primary production route is `Build graph -> Promote layer -> Paint -> Export handoff`. Resource setup is now described as support shelves for map semantics, while QA/Validate are support/parked flows rather than the main route.

## Changed Files

| file | change |
|---|---|
| `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DOC-70_WORKFLOW_MANUAL/SUB_TASKS.md` | Added task scope and candidate matrix. |
| `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DOC-70_WORKFLOW_MANUAL/UX.md` | Added desired user experience and rejected old flow. |
| `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DOC-70_WORKFLOW_MANUAL/POLICY.md` | Added documentation policy and fallback/mirror decisions. |
| `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DOC-70_WORKFLOW_MANUAL/IMPLEMENTATION_PLAN.md` | Added implementation scope and test path. |
| `docs/manual/MANUAL_WORKFLOW.md` | Reworked the primary workflow around Build graph, Promote, Paint, and Export handoff. |
| `README.md` | Updated editor authoring summary to match the new workflow. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| none | none | none | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Manual uses `Build graph -> Promote layer -> Paint -> Export handoff` | PASS | `docs/manual/MANUAL_WORKFLOW.md` §2 and `README.md` usage summary. |
| Resource list is not the primary route | PASS | Resources/Catalog/Layers are documented as support shelves. |
| QA/Validate are not centered | PASS | Manual describes them as support lens / support flow. |
| Samples are learning assets only | PASS | Setup and support boundaries keep samples optional and non-default. |
| No analog test added | PASS | No analog test files created. |
| Standard test passes | PASS | `TEST_JOBS=4 ./tools/test.sh` run id `20260615-193412-87175`, exit 0. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | PASS | Manual §2 starts with `Build graph -> Promote layer -> Paint -> Export handoff`, not resource rows. |
| What user can do | PASS | Manual gives concrete steps: Generate graph, preview output, promote document content, paint, and export handoff. |
| (graph task) chain runs | not applicable | DOC-70 is documentation; graph chain was proven in GRAPH-12/GRAPH-12A/GRAPH-13. |
| Label-heavy but metrics pass | no | Documentation rejects resource-list-first flow and describes work surfaces by task. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | recorded | `.godot_user/ui-metrics/20260615-193412-87175/workspace_layout_metrics.md` |
| P0 failures | `0` | report shows `total_p0_failures: 0` |
| P1 issues | `0` | report shows `total_p1_issues: 0` |
| UI metric applicability | docs task | Standard test ran; UI metrics are regression proof only. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| Samples as production route | Explicit reject | Manual keeps samples as learning/onboarding only. |
| Resources-first route | Explicit reject | Manual makes Resources a support shelf. |
| QA/Validate main route | Explicit reject | Manual marks both as support/parked flows. |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: `TEST_JOBS=4 ./tools/test.sh`
- Result: PASS, exit 0, run id `20260615-193412-87175`
- Notes: macOS CA certificate warnings and known Godot warnings appeared, but command exited 0.
