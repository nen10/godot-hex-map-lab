# STATE-NEXT-11 Implementation Plan

## Scope

- Remove writable `_generation_*` mirrors for generation state from `HexMapGenDock` where they shadow `HexMapGenerationRunState`.
- Add/adjust run-state-backed accessors and writes in the dock generation lifecycle.
- Preserve all run/cancel/progress/visibility behavior.
- Add tests proving run-state ownership and regression safety.
- Update `docs/plan/.../IMPLEMENTATION_QUEUE.md`, `docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md`, and autopilot self-review/test-result artifacts.

## Target Files

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_generation_run_state.gd`
- `tests/test_generation_run_state.gd`
- `tests/test_editor_generation.gd`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`
- `docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/STATE-NEXT-11_GENERATION_PRIVATE_FLAG_MIRROR_RETIREMENT/`
- `docs/review/autopilot/STATE-NEXT-11_SELF_REVIEW_2026-06-14.md`
- `docs/review/autopilot/STATE-NEXT-11_TEST_RESULT_2026-06-14.md`

## Planned Steps

1. Add run-state helper methods in `HexMapGenDock`:
   - `_generation_run_state_progress()`
   - `_generation_run_state_status_text()`
   - `_generation_progress_step()`
   - `_generation_progress_visible_started_msec()`
   - `_is_generation_running()`
   - `_is_generation_cancel_requested()`
   - `_set_generation_running()`
   - `_set_generation_progress_visible_started_msec()`
2. Replace all retired mirror writes in dock lifecycle methods:
   - `request_generation_cancel`, `_generate_map`, thread callbacks, start/end methods, and progress UI path.
3. Update `hex_map_generation_run_state.gd`:
   - Own `progress_visible_started_msec` and expose it in status/progress/view snapshots.
4. Update tests:
   - `tests/test_generation_run_state.gd`: status visibility timestamp/snapshot assertions.
   - `tests/test_editor_generation.gd`: add run-state-driven progress assertion and remove direct private mirror manipulation.
5. Update queue row status/proof log and fallback ledger condition.
6. Run `./tools/test.sh`.
7. If green, write self-review and test-result docs; commit only this task.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Dock progress/cancel lifecycle | medium | `tests/test_editor_generation.gd` full progress lifecycle path |
| Run-state ownership contracts | medium | `tests/test_generation_run_state.gd` state/status/visibility assertions |
| Queue and fallback ledger | low | queue proof + fallback row condition |

## Planned Completion Criteria

- Retired mirror fields are removed or accessed only as run-state-backed derived getters.
- Cancel/prepare/generate/progress/hide UX behavior is unchanged from user-visible perspective.
- New tests demonstrate behavior follows run-state updates and does not require duplicate private mirror writes.
- `STATE-NEXT-11` is marked `COMPLETE` in queue with proof-log entry and self-review/test-result artifacts added.
