# SCREEN-22 Policy

## Adopted Decisions

- `HexMapWorkspaceAssetContext.SLOT_LAYER_STACK` is the single workspace source of truth for the selected Layer Stack.
- Layers tab actions use project `HexLayerStackResource` assets created or selected through the shared asset panel.
- Template duplication saves a standard authoring or minimal runtime template to a project path before selecting it.
- Target root selection delegates to scene-node scanning and records target readiness in the screen snapshot.
- Role actions delegate to the existing `HexMapEditTool` Layer Stack application behavior so target mutation stays in the editor tool boundary.

## Rejected Decisions

- Do not silently assign sample or built-in templates as the selected project Layer Stack.
- Do not make raw NodePath text the normal target picker contract.
- Do not duplicate existing role apply logic inside `HexMapWorkspace`.

## Resource / API / UI Boundary

- `HexLayerStackResource` remains the Resource/API contract for roles and template data.
- `HexMapWorkspace` owns screen-level action helpers and snapshots for the Layers tab.
- `HexMapEditTool` owns target resolution, role rows, and actual scene-layer application/clear operations.

## Task-Local Decisions

- Template ids are `standard` and `minimal`; unknown ids are invalid.
- A Layers screen snapshot reports project asset state, template candidates, role rows, and target readiness together for headless verification.
