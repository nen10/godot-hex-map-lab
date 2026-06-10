# Implementation Plan

## Scope

Move current screen-specific panel Control construction out of `HexMapWorkspace` and into existing screen scripts as static builders, while preserving current visible UI, component ids, signals, and snapshots.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_resources_screen.gd`
- `addons/hex_map_kit/editor/hex_map_catalog_screen.gd`
- `addons/hex_map_kit/editor/hex_map_layers_screen.gd`
- `addons/hex_map_kit/editor/hex_map_validate_screen.gd`
- `addons/hex_map_kit/editor/hex_map_qa_screen.gd`
- `addons/hex_map_kit/editor/hex_map_export_screen.gd`
- `addons/hex_map_kit/editor/hex_map_paint_screen.gd`
- `addons/hex_map_kit/editor/hex_map_settings_screen.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Planned Implementation Steps

1. Add builder ownership metadata to screen scripts.
2. Add static builder methods for simple panel construction:
   - Resources context panel.
   - Missing unique resources panel.
   - Catalog detail panel.
   - Layer stack role panel.
   - Validation issue navigator.
   - QA seed lab panel.
   - Export purpose and destination panels.
   - Settings preferences panel.
3. Add a Settings screen role script for Settings-owned physical components.
4. Update Workspace mount methods to call builders, assign returned references, connect signals, add roots to tab pages, and register components.
5. Expose screen component owner data through Workspace or registry contract.
6. Extend headless tests to verify component owner scripts and builder ownership.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Move refresh logic into screen classes | defer | That is a larger state/render split and not required for physical node construction proof. |
| Replace all panels with Control subclasses | defer/reject | Current screen scripts can own builders with less churn. |
| Redesign layouts | defer | Queued separately. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Screen builder methods | Missing component ownership or node references. | New/updated `test_editor_plugin.gd` assertions. |
| Workspace mount flow | Existing tab content or signals break. | Existing editor plugin tests and workspace snapshot tests. |
| UI metric reports | Layout P0 regression. | `./tools/test.sh` metric report with P0 failures = 0. |
| Packaging | New scripts or uid files missing. | `tools/package_addon.sh --check` through `./tools/test.sh`. |

## Docs Updates

- Update `docs/TEST.md` with `ARCH-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Screen-specific Control builders live in screen scripts.
- Workspace mount methods are thin host/context/dispatcher wrappers.
- Screen contract tests cover builder ownership per component.
- `./tools/test.sh` passes.
- UI metric report has P0 failures = 0.
