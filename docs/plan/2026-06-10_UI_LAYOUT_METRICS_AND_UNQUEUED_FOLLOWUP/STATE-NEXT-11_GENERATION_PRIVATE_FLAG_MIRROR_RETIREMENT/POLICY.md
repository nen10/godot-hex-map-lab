# STATE-NEXT-11 Policy

## Adopted Decisions

- Keep `_generation_progress_container`, `_generation_progress_status_label`, `_generation_progress_bar`, and `_generation_progress_cancel_button` as UI node handles.
- Remove writable `_generation_*` mirrors for generation state (`_generation_running`, `_generation_cancel_requested`, `_generation_progress`, `_generation_status`, `_generation_progress_step`, `_generation_progress_visible_started_msec`) from Dock ownership.
- Introduce/retain run-state-first accessors in `HexMapGenDock` and update all state writes through `HexMapGenerationRunState`.
- Add `progress_visible_started_msec` to `HexMapGenerationRunState` and include it in `to_status_snapshot`, `to_progress_snapshot`, and `to_view_state`.
- Preserve behavior for generate controls, cancel behavior, and progress hide timing.

## Rejected Decisions

- Keep duplicate local fields as writable mirrors while also updating run state.
- Move/normalize progress visibility timing from dock timer behavior.
- Remove cancel-button disable/enable semantics during generation lifecycle.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| `_generation_running` | retire mirror | Prevents source-of-truth drift and duplicate state | retired in `STATE-NEXT-11` with run-state assertions in `tests/test_editor_generation.gd` and `tests/test_generation_run_state.gd` | `tests/test_editor_generation.gd`, `tests/test_generation_run_state.gd` |
| `_generation_cancel_requested` | retire mirror | Cancel path must be single-owned for thread/read consistency | retired in `STATE-NEXT-11`; thread path reads `run_state`-owned flag | `tests/test_editor_generation.gd`, `tests/test_generation_run_state.gd` |
| `_generation_progress` | retire mirror | Progress bar/percent must derive from one snapshot source | retired in `STATE-NEXT-11` with run-state snapshot assertions | `tests/test_editor_generation.gd`, `tests/test_generation_run_state.gd` |
| `_generation_status` | retire mirror | Status text remains stable and debounced from one source | retired in `STATE-NEXT-11`; status text comes from `to_view_state` source text | `tests/test_editor_generation.gd` |
| `_generation_progress_step` | retire mirror | Keeps phase semantics consistent across status/progress updates | retired in `STATE-NEXT-11`; step assertions through status snapshots | `tests/test_editor_generation.gd` |
| `_generation_progress_visible_started_msec` | retire mirror | Prevents drift in minimum visible-delay timing | retired in `STATE-NEXT-11`; value asserted via status/progress snapshots | `tests/test_generation_run_state.gd` |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| `HexMapGenerationRunState.running` | Single source of truth for generation active/inactive | dual writes from dock state | tests/read/write assertions in `tests/test_generation_run_state.gd` |
| `HexMapGenerationRunState.progress` | Single source of truth for numeric progress | stale local values could misreport progress UI | `tests/test_editor_generation.gd` and `tests/test_generation_run_state.gd` |
| `HexMapGenerationRunState.status` | Single source of truth for progress label/status | stale local status causing inconsistent button/cancel behavior | existing progress lifecycle tests |
| `HexMapGenerationRunState.progress_visible_started_msec` | Single source of truth for minimum hide timing | early/late hide timer drift | `tests/test_generation_run_state.gd` |
