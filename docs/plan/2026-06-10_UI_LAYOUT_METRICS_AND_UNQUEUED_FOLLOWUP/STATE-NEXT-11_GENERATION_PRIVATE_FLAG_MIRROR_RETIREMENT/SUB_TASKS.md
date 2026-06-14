# STATE-NEXT-11 Generation private flag mirror retirement Sub Tasks

## Complexity

Class: C3

Reason:
- The task removes multiple legacy private state mirrors and rewires generation progress/cancel/control state to a single run-state source.
- It requires touching the dock generation path, generation run-state snapshot consumers, and tests/queue proof artifacts.
- Public generation behavior must remain unchanged while changing internal ownership.

Required artifacts:
- _generation_* mirror inventory and replacement decision table
- Runtime migration with read-only accessor plan
- Tests covering run-state-driven progress/cancel/visibility behavior
- Queue proof entry and required review/test artifacts

## _generation_* Inventory & Classification

| field | location | initial state | classification | replacement plan |
|---|---|---|---|---|
| `_generation_progress_container` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | UI handle node | KEEP | Keep as UI node handle |
| `_generation_progress_status_label` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | UI handle node | KEEP | Keep as UI node handle |
| `_generation_progress_bar` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | UI handle node | KEEP | Keep as UI node handle |
| `_generation_progress_cancel_button` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | UI handle node | KEEP | Keep as UI node handle |
| `_generation_progress_hide_token` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | timer/control token | KEEP | Not state mirror; keep |
| `_generation_progress_scheduled_hide_token` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | timer/control token | KEEP | Not state mirror; keep |
| `_generation_progress_hide_after_msec` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | timer/control state | KEEP | Not generation status mirror; keep |
| `_generation_running` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | state mirror | RETIRE | Source-of-truth from `HexMapGenerationRunState.running` |
| `_generation_cancel_requested` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | state mirror | RETIRE | Source-of-truth from `HexMapGenerationRunState.cancel_requested` |
| `_generation_progress` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | state mirror | RETIRE | Source-of-truth from `HexMapGenerationRunState.progress` |
| `_generation_status` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | state mirror | RETIRE | Source-of-truth from `HexMapGenerationRunState.status` |
| `_generation_progress_step` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | state mirror | RETIRE | Source-of-truth from `HexMapGenerationRunState.step` |
| `_generation_progress_visible_started_msec` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | state mirror | RETIRE | Source-of-truth from `HexMapGenerationRunState.progress_visible_started_msec` |
| `_generation_pressed` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` (not present) | absent in source | N/A | No replacement required; confirm absence in audit evidence |
| `_generation_combination_limit` | `addons/hex_map_kit/editor/hex_map_gen_dock.gd` (not present) | absent in source | N/A | No replacement required; confirm absence in audit evidence |

## Planned Migration Tasks

1. Add/adjust run-state-backed accessors in `hex_map_gen_dock.gd` for:
   - `running`, `cancel_requested`, `progress`, `status`, `step`, `progress_visible_started_msec`.
2. Replace all direct reads/writes to retired mirrors with read/write accessors using `HexMapGenerationRunState`.
3. Keep UI node handles and timer tokens as-is.
4. Add tests proving:
   - dock status/progress snapshots follow run-state updates;
   - progress visibility timestamp, cancel request, and running state are reflected from run-state;
   - no writable mirror fields are required for behavior.
5. Update queue proof/log and fallback ledger row condition.
