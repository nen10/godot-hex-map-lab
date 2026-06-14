# Implementation Plan

## Scope

Add clearer visual-state summaries to Resources, Layers, and Export screens while preserving existing asset-selection and action workflows.

## Target Files

- `addons/hex_map_kit/editor/hex_map_resources_screen.gd`
- `addons/hex_map_kit/editor/hex_map_layers_screen.gd`
- `addons/hex_map_kit/editor/hex_map_export_screen.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Extend Resources context panel with readiness and source-badge summary labels and expose `resources_visual_summary`.
2. Extend Layers role panel with role-tree summary/rows labels and expose `role_tree_summary`.
3. Extend Export panels with runtime handoff summary/readiness labels and expose `runtime_handoff_summary`.
4. Update tests to assert snapshot and mounted-label proof for Resources, Layers, and Export.
5. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
6. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Fine-grained role editing | defer | Covered by `LAYER-NEXT-10`. |
| Paint viewport affordances | defer | Covered by `PAINT-NEXT-10`. |
| Package build UI decision | defer | Covered by `EXPORT-NEXT-10`. |
| Replacing typed asset slots | reject | Existing slots are the correct Resource selection surface. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Resources screen context | Summary duplicates stale state. | Tests compare visual summary to selected/resource group snapshots. |
| Layers role rows | Role tree text drifts from role rows. | Tests inspect role tree counts and mounted label text after layer creation. |
| Export workflow state | Runtime handoff readiness drifts from destination/source state. | Tests inspect readiness rows before and after destination/export. |
| UI metrics | Extra labels cause P0/P1 layout regressions. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `SCREEN-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Resources snapshot/mounted UI exposes selected node, document/dependency readiness, source badges, and next actions.
- Layers snapshot/mounted UI exposes role tree counts and role rows.
- Export snapshot/mounted UI exposes runtime handoff readiness rows and result state.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
