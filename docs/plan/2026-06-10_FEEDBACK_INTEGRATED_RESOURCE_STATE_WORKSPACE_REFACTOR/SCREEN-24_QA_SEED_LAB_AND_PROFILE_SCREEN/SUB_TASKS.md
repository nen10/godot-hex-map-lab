# SCREEN-24 QA Seed Lab and Profile Screen Sub Tasks

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Make QA screen state explicitly own Seed Lab workflow, not only expose generation dock helpers. | Adopt | The roadmap asks for a QA tab, so completion must be visible as QA-owned state. |
| Expose Generation Profile use and score table state in QA snapshots. | Adopt | This is the acceptance path for profile-driven score comparison. |
| Expose selected seed and promote target state before and after batch execution. | Adopt | Promotion is the user decision point; the UI contract must name it. |
| Explain Generate candidate vs QA draft/promotion boundary. | Adopt | Users need to understand that Generate previews candidates and QA promotes one to the Level Document. |
| Build a new visual analog test for the QA tab. | Defer | CLEAN UI work does not add new analog tests unless requested. Headless screen contract plus self-review is sufficient for this slice. |
| Redesign generation scoring internals. | Defer | `STATE-10` already provides generation run state; this task is the QA screen contract over existing behavior. |

## Scheduled Task

No follow-up task is scheduled from this slice. The adopted scope fits `SCREEN-24`.
