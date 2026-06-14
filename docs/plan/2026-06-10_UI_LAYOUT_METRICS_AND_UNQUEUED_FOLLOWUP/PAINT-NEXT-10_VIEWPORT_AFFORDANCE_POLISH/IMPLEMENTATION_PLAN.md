# Implementation Plan

## Scope

Add a visible Paint affordance board that summarizes brush cursor, selected cell, target layer, mode, and last edit feedback from existing Paint interaction state and viewport edit traces.

## Target Files

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Add a mounted Paint affordance label to `HexMapEditTool`.
2. Add `paint_affordance_board` rows derived from interaction state, selected/hovered cell, target, mode, and last edit trace.
3. Expose the board through `paint_workspace_snapshot()` and `paint_brush_screen_snapshot()`.
4. Refresh the mounted label after mode/target/brush and viewport edit updates.
5. Add workspace-level viewport input test assertions for Paint affordance sync.
6. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| New viewport input behavior | reject | Existing viewport edit path works and is already tested. |
| Resource setup controls in Paint | reject | Existing ownership rules put setup in Resources/Catalog/Layers. |
| Root event model | defer | Covered by `STATE-NEXT-10`. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Paint interaction state | Board gets stale after viewport edit. | Workspace viewport edit test inspects Paint snapshot. |
| Mounted Paint UI | Affordance stays headless-only. | Mounted text assertions. |
| Target highlight/last hit | Cursor and selected cell disagree. | Test checks cell keys and target highlight. |
| UI metrics | New label causes layout regressions. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `PAINT-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Paint snapshot exposes structured cursor/mode/target/selected-cell/last-edit affordance rows.
- Mounted Paint affordance text updates after a viewport edit.
- Workspace-level Paint snapshot proves viewport edit sync.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
