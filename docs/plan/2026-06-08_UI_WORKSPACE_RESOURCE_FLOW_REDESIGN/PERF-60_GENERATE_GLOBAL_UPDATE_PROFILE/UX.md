# PERF-60 Generate / Global Update Performance UX

Date: 2026-06-08

## User goal

A user changing orientation, regenerating a map, applying a document, or running validation should understand whether the pause comes from generation, applying data to scene layers, tile redraw, or validation.

## Review flow

1. Classify each heavy operation by user-visible trigger.
2. Trace the synchronous code path that runs on the editor thread.
3. Measure representative headless timings where a scripted path exists.
4. Prioritize improvements for PERF-61 and PERF-62.

## Output

- `docs/review/roadmap/GENERATE_UPDATE_PERFORMANCE_PROFILE_2026-06-08.md`
