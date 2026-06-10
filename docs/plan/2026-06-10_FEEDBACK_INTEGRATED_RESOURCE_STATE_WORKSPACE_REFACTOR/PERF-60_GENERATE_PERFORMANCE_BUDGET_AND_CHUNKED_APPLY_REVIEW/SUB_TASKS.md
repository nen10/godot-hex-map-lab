# PERF-60 Generate Performance Budget And Chunked Apply Review Sub Tasks

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Carry forward the 2026-06-08 measured Generate/global update profile. | Adopt | It already measures generation, validation, direct TileMap apply, `HexTileMapLayer.apply_map`, layer-stack apply, and single-cell document update across map sizes. |
| Review the current 2026-06-10 Generate/apply/validation paths before setting budgets. | Adopt | `STATE-10`, progress UI, debounce, and `ARCH-50` changed the shape of the code since the older profile. |
| Define map-size budgets and budget-overrun UI policy. | Adopt | The roadmap requires size-specific update budgets and progress/busy/cancel policy. |
| Decide whether chunked apply is required. | Adopt | Large maps still perform main-thread clear/write/redraw paths, so chunking must be classified before future pipeline work. |
| Implement chunked apply now. | Reject | `PERF-60` is a review and budget task; implementing chunked scene-tree mutation belongs in a later Generate/apply task. |

## Scheduled Task

No follow-up task is scheduled from this slice. Chunked apply implementation is recorded as a future requirement in the performance budget review.
