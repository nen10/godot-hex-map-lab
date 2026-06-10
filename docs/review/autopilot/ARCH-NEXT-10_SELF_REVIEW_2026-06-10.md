# ARCH-NEXT-10 Self Review 2026-06-10

Task: `ARCH-NEXT-10_PHYSICAL_WORKSPACE_UI_NODE_EXTRACTION`
Status: COMPLETE

## Summary

Moved physical Workspace panel construction for Resources, Catalog, Layers, Validate, QA, Export, and Settings into screen scripts. `HexMapWorkspace` now keeps the host/context/dispatcher role for those panels: it calls screen builders, stores returned Control references, connects existing signals, registers components, and runs existing refresh methods.

## Changed Files

- `addons/hex_map_kit/editor/hex_map_resources_screen.gd`
- `addons/hex_map_kit/editor/hex_map_catalog_screen.gd`
- `addons/hex_map_kit/editor/hex_map_layers_screen.gd`
- `addons/hex_map_kit/editor/hex_map_validate_screen.gd`
- `addons/hex_map_kit/editor/hex_map_qa_screen.gd`
- `addons/hex_map_kit/editor/hex_map_export_screen.gd`
- `addons/hex_map_kit/editor/hex_map_settings_screen.gd`
- `addons/hex_map_kit/editor/hex_map_settings_screen.gd.uid`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-10_PHYSICAL_WORKSPACE_UI_NODE_EXTRACTION/`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Acceptance

| requirement | result | evidence |
|---|---|---|
| Workspace is tab host/context/dispatcher | pass | Workspace mount methods are thin wrappers around screen builders and still own signal/context wiring. |
| Screen-specific UI node construction moves to screen scripts | pass | Screen scripts expose `build_*` methods and `component_owner_rows()`. |
| Screen contract tests cover class ownership | pass | `tests/test_editor_plugin.gd` checks registry owner rows, mounted node metadata, screen script owner rows, and builder ids. |
| Existing visual/task surface is preserved | pass | Existing editor plugin tests and UI metric scenarios pass. |

## Plan Deviation

| item | classification | reason |
|---|---|---|
| Added `HexMapSettingsScreen` | planned-scope refinement | Settings had no screen role script, but it owns physical preferences/sample settings components and needed the same ownership proof as other tabs. |

## Repair-Now Audit

None.

## Sample-Only Completion Audit

No sample-only success was used as completion proof. The change is ownership/structure and is verified through component contracts, mounted node metadata, and runtime UI metric scenarios.

## UI Metric Review

- report: `.godot_user/ui-metrics/20260610-184324-48462/workspace_layout_metrics.md`
- P0 failures: `0`
- P1 issues: `0`
- applicability: UI-facing Workspace architecture task; metric proof is required.

## Tests

- `./tools/test.sh`

Known nonblocking output:
- macOS CA certificate warnings from Godot.
- Existing negative-path warnings in generation/source query tests.
