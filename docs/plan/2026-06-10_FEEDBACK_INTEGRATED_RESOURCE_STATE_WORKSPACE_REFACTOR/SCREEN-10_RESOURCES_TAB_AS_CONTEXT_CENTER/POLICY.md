# SCREEN-10 Policy

## Adopted Decisions

- Resources is the selected HexTileMap and project-resource context center.
- Visible labels use node/resource names and status, not node paths or file paths.
- Source badges are visible because they explain resource ownership and hydration.
- Missing-resource actions must be visible as action state, not only implied by disabled row controls.

## Rejected Decisions

- Do not silently fill missing resources from bundled samples.
- Do not move Catalog/Layers/Export ownership into this task.
- Do not expose raw dependency snapshots as normal UI.
- Do not add analog tests for CLEAN UI.

## Boundaries

- `HexMapWorkspace` composes the Resources screen snapshot and visible panel text.
- `HexMapWorkspaceAssetContext` remains the source of resource/source badge state.
- `HexMapWorkspaceBindingService` remains the binding/writeback authority.
- Resource picker row internals remain owned by `HexMapWorkspaceAssetPanel`.
