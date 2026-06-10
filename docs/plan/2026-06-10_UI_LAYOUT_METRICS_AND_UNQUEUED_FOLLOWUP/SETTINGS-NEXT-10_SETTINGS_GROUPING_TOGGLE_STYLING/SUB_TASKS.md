# SETTINGS-NEXT-10 Sub Tasks

Task: `SETTINGS-NEXT-10_SETTINGS_GROUPING_TOGGLE_STYLING`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Adopt / Defer Decisions

| candidate | decision | reason |
|---|---|---|
| Settings group model | adopt | Settings must visibly separate Sample Learning, Debug, Project Defaults, and UI Preferences. |
| Tooltip-backed boolean controls | adopt | Booleans should be explicit checks/toggles with detail in tooltips, not prose boolean text. |
| Move production defaults into Settings | reject | Resource ownership policy keeps production asset selection in Resources. |
| Sample detail drawer | defer | Already queued as `SAMPLE-NEXT-10`. |

## Sub Tasks

| id | work | completion signal |
|---|---|---|
| `SETTINGS-NEXT-10.01` | Add Settings group rows/snapshot metadata. | Snapshot exposes all four group ids. |
| `SETTINGS-NEXT-10.02` | Group the mounted Settings/sample controls. | Sample and debug controls are visibly separated. |
| `SETTINGS-NEXT-10.03` | Add tooltip metadata for boolean checks/toggles. | Snapshot exposes checkbox rows with non-empty tooltips. |
| `SETTINGS-NEXT-10.04` | Extend tests and test docs. | Existing Settings test covers grouping and toggle styling. |

## Non Goals

- Do not add sample detail drawer behavior.
- Do not reintroduce sample production fallback.
- Do not move Movement Profile selection into Settings.
