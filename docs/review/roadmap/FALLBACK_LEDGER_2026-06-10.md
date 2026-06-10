# Fallback Ledger 2026-06-10

Roadmap: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ROADMAP.md`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`
Source feedback: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/_feedbacks/UNQUEUED_REQUIREMENTS_EXTRACT_2026-06-10.md`

This ledger records fallback-like behavior that must not remain as unstated prose. A row is not approval for hidden fallback; it is a tracked decision with owner, status, removal condition, and proof.

## Status Vocabulary

| status | meaning |
|---|---|
| `retained-explicit-state` | Intentional product state. It remains only while named, visible, and tested. |
| `forbidden-normal-ui` | Not allowed in normal production UI; may exist in debug/report/test internals when bounded. |
| `temporary-queued` | Transitional behavior with a queue task or removal condition. |
| `tracked-backlog` | Nonblocking work is represented by existing queue task ids. |
| `policy-deferred` | Explicitly outside current queue by policy, with a revisit condition. |

## Ledger

| id | category | item | owner | status | removal condition | test proof | queue connection |
|---|---|---|---|---|---|---|---|
| `LG-01` | manual override | Manual project Resource override wins over document dependency hydration until the user clears or replaces it. | Workspace binding service / asset context | `retained-explicit-state` | None by default; remove only if product policy stops supporting manual source precedence. | `docs/TEST.md` coverage for `RES-11`, `NODE-20`, `NODE-23`; `./tools/test.sh`. | No removal task; keep as explicit source state. |
| `LG-02` | sample / fallback | Bundled samples are learning sources and must not satisfy production asset selection silently. | Settings/Samples UI, asset slot state, sample duplicator | `retained-explicit-state` | None for learning flow; production fallback remains forbidden. | `docs/TEST.md` coverage for `SAMPLE-10`, `SAMPLE-11`, `SAMPLE-12`, `SAMPLE-40`, `SAMPLE-41`, `PKG-70`, `PKG-71`; `./tools/test.sh`. | `SETTINGS-NEXT-10`, `SAMPLE-NEXT-10`, `UI-METRIC-05`. |
| `LG-03` | sample / fallback | Direct bundled sample selection is warning/learning state, not Generate/Paint production source. | Asset slot state / Generate-Paint source registry | `forbidden-normal-ui` | Main flow must continue to prefer project resources; sample source must be duplicated to project before production use. | `docs/TEST.md` coverage for `TEST-42`, `SAMPLE-41`, `PKG-71`; `./tools/test.sh`. | `UI-METRIC-05`, `SAMPLE-NEXT-10`. |
| `LG-04` | debug | Debug report may include raw paths/internal state, but normal UI must not expose debug labels, raw paths, node paths, or internal state text. | Workspace UI contracts / Copy Debug Report | `forbidden-normal-ui` | Normal UI screen contracts and UI metric P0 gate pass with debug leakage count 0. | `docs/TEST.md` coverage for `UI-00`, `UI-02`, `FB-02`, `SCREEN-*`; `./tools/test.sh`. | `UI-METRIC-00`, `UI-METRIC-02`, `UI-METRIC-05`, `DOC-NEXT-90`. |
| `LG-05` | legacy / fallback | Numeric tile fallback is not a production missing-catalog solution; missing catalog assignment is a validation issue. | Document validation / catalog adapter | `forbidden-normal-ui` | Existing validation path remains the only production response for missing catalog assignment. | `docs/TEST.md` coverage for `RES-10`, `ASSET-30`, `PKG-71`, editor numeric fallback control absence; `./tools/test.sh`. | `UI-METRIC-02`, `UI-METRIC-05`. |
| `LG-06` | legacy / debug | Raw JSON/path/internal state wording is not normal workflow language. | UI contracts / manual docs / debug report | `forbidden-normal-ui` | Raw detail remains in debug/report surfaces only, or is replaced by typed UI fields. | `docs/TEST.md` coverage for `UI-00`, `DOC-90`, typed property/state coverage; `./tools/test.sh`. | `UI-METRIC-00`, `UI-METRIC-05`, `DOC-NEXT-90`. |
| `LG-07` | mirror | Existing private `_generation_*` fields may remain only as transitional mirrors after `HexMapGenerationRunState`. | Generate run state / Generate Dock | `temporary-queued` | `STATE-NEXT-11` inventories fields and removes them or makes them read-only mirrors with tests. | `docs/TEST.md` coverage for `STATE-10`; `./tools/test.sh`. | `STATE-NEXT-11`. |
| `LG-08` | debug | Runtime debug overlay rendering is separate from normal gameplay rendering and validation focus behavior. | `HexTileMapLayer` runtime/debug overlay boundary | `tracked-backlog` | `ARCH-NEXT-22` separates debug overlay renderer and proves normal rendering remains distinct. | `docs/TEST.md` coverage for current debug scene/helper behavior; `./tools/test.sh`. | `ARCH-NEXT-22`, `UI-METRIC-05`. |
| `LG-09` | manual process | Public package upload remains a human release step, not an autopilot queue action. | Release process owner | `policy-deferred` | Revisit only when a release automation policy and credentials flow exist. | Final packaging task proof and manual release notes. | No queue task; `PROC-NEXT-90` only regenerates dist. |
| `LG-10` | manual visual test | New analog/manual UI test documents are deferred during CLEAN UI work unless the user explicitly asks. | Test policy / UI roadmap owner | `policy-deferred` | Revisit after UI metric gates and screen polish tasks, or when the user asks for analog verification. | `docs/TEST.md` CLEAN UI analog test policy; `./tools/test.sh`. | No queue task by policy. |

## Queue Connection Summary

| ledger area | primary queue ids |
|---|---|
| Manual override source state | retained explicit state, no removal queue |
| Sample learning and production separation | `SETTINGS-NEXT-10`, `SAMPLE-NEXT-10`, `UI-METRIC-05` |
| Debug leakage / raw detail / normal UI exclusion | `UI-METRIC-00`, `UI-METRIC-02`, `UI-METRIC-05`, `DOC-NEXT-90` |
| Legacy numeric fallback exclusion | `UI-METRIC-02`, `UI-METRIC-05` |
| Generation private mirror retirement | `STATE-NEXT-11` |
| Debug overlay extraction | `ARCH-NEXT-22` |
| Manual release upload | policy-deferred, no queue |
| Analog UI test creation | policy-deferred, no queue |

## Review Rule

Future phase reviews must add a row here or a queue candidate when a self-review, plan, or test result introduces new fallback-like behavior.
