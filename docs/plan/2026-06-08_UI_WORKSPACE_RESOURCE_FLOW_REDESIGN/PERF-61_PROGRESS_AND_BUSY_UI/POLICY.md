# PERF-61 Progress And Busy UI Policy

Date: 2026-06-08

## Decisions

- Reuse the existing inline generation ProgressBar instead of adding a modal overlay.
- Coarse progress is acceptable for synchronous validation/apply steps.
- Cancel only applies to threaded generation, not synchronous apply/redraw.
- PERF-61 reports busy state. Debounce and incremental redraw belong to PERF-62.

## Non-goals

- Do not add new analog tests.
- Do not change generation/apply semantics.
- Do not hide expensive operations behind sample-only shortcuts.
