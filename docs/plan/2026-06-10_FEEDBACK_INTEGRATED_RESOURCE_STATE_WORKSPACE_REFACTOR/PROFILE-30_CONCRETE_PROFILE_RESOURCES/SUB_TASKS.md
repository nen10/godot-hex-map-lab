# PROFILE-30 Concrete Profile Resources Sub Tasks

## Goal

Replace generic `Resource` profile slots with concrete Resource classes for validation, generation, and export profiles.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Keep generic `Resource` slots | Reject | The roadmap explicitly requires concrete picker filters. |
| B. Add minimal concrete Resource classes | Adopt | This removes generic picker ambiguity without inventing full profile behavior. |
| C. Integrate concrete profiles into document dependency hydration UI states | Defer | `PROFILE-31` owns dependency/tab integration follow-through after concrete classes exist. |

## Scheduled Task

No scheduled task is required.
