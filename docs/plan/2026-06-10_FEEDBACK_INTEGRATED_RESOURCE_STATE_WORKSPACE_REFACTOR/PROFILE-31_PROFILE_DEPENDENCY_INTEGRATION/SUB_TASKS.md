# PROFILE-31 Profile Dependency Integration Sub Tasks

## Goal

Connect the concrete profile Resource classes from `PROFILE-30` to document dependencies, workspace context hydration, and the QA / Validate / Export tab state.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Treat concrete profile dependencies as normal shared document dependencies | Adopt | This matches RES-10 / RES-11 ownership and keeps project resources attached to the selected Level Document. |
| B. Add profile-specific dependency type validation | Adopt | A dependency row marked as Validation Rule Suite / Generation Profile / Export Profile must not silently accept a generic Resource. |
| C. Make missing profiles blocking validation errors | Reject | The roadmap requires optional/missing state; tabs should show missing profile state without making the whole workspace invalid. |
| D. Redesign QA / Validate / Export workflows | Defer | Screen ownership and deeper workflow redesign are scheduled under later SCREEN / STATE tasks. |

## Scheduled Task

No scheduled task is required.
