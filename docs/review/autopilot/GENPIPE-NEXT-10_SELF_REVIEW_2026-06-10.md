# GENPIPE-NEXT-10 Self Review 2026-06-10

Task: `GENPIPE-NEXT-10_GENERATION_RESULT_RESOURCE_AND_REPLAY_API`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GENPIPE-NEXT-10_GENERATION_RESULT_RESOURCE_AND_REPLAY_API/`
Optional execution log: none

## Execution Summary

Added `HexGenerationResultResource` as the durable candidate boundary for generated results. Generate batch rows now carry a replayable result Resource with primary/candidate/validation/preview scope, QA scored rows expose result id and replay state, and promotion uses the result Resource when available while recording result id/source metadata on the promoted Level Document.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/adapter/hex_generation_result_resource.gd` | Added generated candidate Resource with scope and replay helpers. |
| `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | Attaches result Resources to batch rows and promotes replayable results through `promote_generation_result()`. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd` | Exposes result id, replay availability, and result scope in QA snapshots. |
| `tests/test_hex_adapter.gd` | Added save/load and replay scope coverage for `HexGenerationResultResource`. |
| `tests/test_editor_plugin.gd` | Added Generate batch, QA scored row, replay, and promotion metadata assertions. |
| `docs/TEST.md` | Documented `GENPIPE-NEXT-10` coverage. |
| `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GENPIPE-NEXT-10_GENERATION_RESULT_RESOURCE_AND_REPLAY_API/` | Added C4 planning artifacts. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Result Resource | done | Matches plan. | none |
| Batch row payload | done | Existing row dictionaries remain the view model with Resource payload attached. | none |
| Replay/promotion | done | Promotion uses result replay when present and keeps existing seed fallback. | none |
| Pipeline graph UI | deferred | Belongs to queued `GENPIPE-NEXT-20`. | `GENPIPE-NEXT-20` |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Primary/overlay/filter/candidate/validation scope defined | pass | Resource scope exposes primary map, overlay map, candidate document, validation result/summary, preview, and metadata. |
| Generate can replay/promote result resources | pass | Generate tests assert row Resource, replay document, and promotion metadata. |
| QA can replay/promote result resources | pass | QA tests assert result id/replay scope and promoted document result metadata. |
| Resource is durable | pass | Adapter test saves/loads the Resource and replays the loaded candidate document. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | pass | `.godot_user/ui-metrics/20260610-212438-8456/workspace_layout_metrics.md` |
| P0 failures | pass | `0` |
| P1 issues | pass | `0` |
| UI metric applicability | pass | Generate/QA state-facing task. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| Pipeline graph UI | existing queue id | `GENPIPE-NEXT-20`. |
| Profile behavior schema | existing queue id | `PROFILE-NEXT-10`. |
| Full row dictionary replacement | policy-deferred | Rows remain view models; result Resource is the durable payload. Revisit only if reducer/event work requires row model removal. |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: `./tools/test.sh`
- Result: pass
- UI metric report: `.godot_user/ui-metrics/20260610-212438-8456/workspace_layout_metrics.md`
- Notes: Godot emitted existing macOS CA certificate warnings and expected warning-path messages; no test failed.
