# PERF-62 Incremental Update And Debounce Policy

Date: 2026-06-08

## Decisions

- Debounce continuous tile-setting preview changes in the Generate dock.
- Keep direct apply methods synchronous for explicit command paths and tests.
- Use the PERF-61 progress surface to report queued and applied states.
- Treat deeper visible-region redraw and document metadata/apply separation as future follow-up unless this task can complete it safely.

## Non-goals

- Do not change generated map data semantics.
- Do not add new analog tests.
- Do not hide production behavior behind sample assets.
