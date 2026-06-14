# Implementation Plan

## Scope

Add fine-grained Layer Stack role editing for visibility, locked state, z-index, and writable source in the Layers workspace screen.

## Target Files

- `addons/hex_map_kit/editor/hex_map_layers_screen.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Extend `HexMapLayersScreen.build_layer_stack_role_panel()` with selected role editor controls and expose them in the build dictionary.
2. Store role editor controls in `HexMapWorkspace` and refresh them from `layer_stack_screen_snapshot()`.
3. Add `select_layer_stack_role()` and `update_layer_stack_role_properties()` workspace APIs.
4. Update matching Layer Stack entry fields/metadata and mirror applicable state to an existing selected target role layer.
5. Extend Layers tests to assert mounted controls, resource row updates, and target node reflection.
6. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Resource schema expansion | reject | Metadata already supports locked/writable source and keeps this task small. |
| Editable tree cells | defer | A single selected-role editor is clearer and less brittle. |
| Paint target affordance feedback | defer | Covered by `PAINT-NEXT-10`. |
| Root reducer events | defer | Covered by `STATE-NEXT-10`. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Role row source | Rows do not reflect edited metadata. | Layers workflow test inspects `role_rows`. |
| Target HexTileMap role layer | Node state does not match resource state. | Layers workflow test inspects child TileMapLayer. |
| Mounted controls | Screen remains summary-only. | Layers workflow test inspects editor snapshot and mounted text. |
| UI metrics | New controls cause layout regressions. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `LAYER-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Layers snapshot exposes role editor controls and selected role state.
- Editing visible/locked/z-index/writable source updates the Layer Stack resource entry.
- Existing selected target role layers reflect visible/z-index and carry locked/writable metadata.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
