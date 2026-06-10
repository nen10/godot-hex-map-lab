# UI-00 Workspace UI Contracts Sub Tasks

## Goal

Define the visible Workspace UI contracts before first-impression repairs change row layout, Settings labels, or Generate status presentation.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Write per-tab screen contract | Adopt | Later screen work needs a stable distinction between always-visible information, tooltip detail, and debug report content. |
| B. Write Workspace state-machine contract | Adopt | STATE-60 introduced root ViewState/dispatch; UI work should consume that boundary instead of recombining private flags. |
| C. Inventory visible controls | Adopt | UI-01/UI-02/UI-03 need a baseline list of controls to keep, simplify, hide, or move. |
| D. Write Resource row spec | Adopt | Resource rows are the first visible first-impression target and need a compact/adaptive contract before code changes. |
| E. Write debug label policy | Adopt | Debug, filepath, node path, raw JSON, and internal state need a single rule for normal UI vs tooltip/debug report. |
| F. Redesign Resource rows in this task | Reject | UI-01 owns implementation of the row layout; UI-00 defines the contract only. |
| G. Simplify Settings labels in this task | Reject | UI-02 owns the actual Settings UI change. |
| H. Repair Generate dead space in this task | Reject | UI-03 owns Generate visual repair and must keep existing Generate behavior stable. |
| I. Add analog UI test | Reject | CLEAN UI work does not add new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.

The accepted documents directly unblock `UI-01`, `UI-02`, and `UI-03`; no extra queue item is needed.
