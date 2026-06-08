# PERF-62 Incremental Update And Debounce UX

Date: 2026-06-08

## User goal

Dragging or stepping tile settings should not reapply the whole visible map on every intermediate value. The UI should show that an update is queued, then apply the latest value once.

## Flow

1. A user changes orientation, tile size, tile source, atlas coordinates, or catalog tile selection.
2. The dock shows an inline queued update status.
3. Additional changes refresh the pending update instead of immediately running another full apply.
4. After the short debounce interval, the latest settings are applied once and the normal progress completion state appears.

## Visible contract

- Direct explicit apply paths still work.
- Debounced update status uses the existing ProgressBar/current-step text.
- No modal UI is introduced.
- PERF-62 does not attempt a full redraw architecture rewrite.
