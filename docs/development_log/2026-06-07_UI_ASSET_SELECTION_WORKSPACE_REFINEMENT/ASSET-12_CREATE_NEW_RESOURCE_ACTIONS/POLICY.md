# ASSET-12 Policy

## Adopted Decisions

- Resource creation is centralized in a helper so every slot creates the same type for a slot id.
- Save paths use Godot resource paths and `.tres` files.
- Successful creation immediately assigns the new Resource to `HexMapWorkspaceAssetContext`.
- Asset slot controls expose Save As dialog hooks and selected path signals; tests use public methods and snapshots.

## Rejected Decisions

- Do not duplicate bundled samples in this task.
- Do not silently assign sample catalog, scene, or tiles to new project Resources.
- Do not migrate every tab UI in this task.

## Boundary

- This task creates the reusable create-new contract and tests it.
- Later screen tasks decide where each slot is displayed and which create actions are visible by default.
