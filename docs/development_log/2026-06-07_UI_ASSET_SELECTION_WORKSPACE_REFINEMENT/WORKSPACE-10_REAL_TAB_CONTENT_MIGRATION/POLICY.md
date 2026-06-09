# WORKSPACE-10 Policy

## Adopted Decisions

- Add a reusable workspace asset panel for tab-level Resource selection.
- Back tab asset slots with `HexMapWorkspaceAssetContext`.
- Expose `tab_has_component()`, `asset_slot_count()`, and `tab_asset_slot_ids()` so tests inspect public state instead of private nodes.
- Keep Paint mounted as the painting/editing surface and move setup responsibilities into owning tabs.

## Rejected Decisions

- Do not build full screen-specific editors in this task.
- Do not add analog tests during CLEAN UI work.
- Do not make sample assets satisfy production tab completion.

## Boundary

- This task makes tabs non-empty and gives them owned asset slots.
- Later SCREEN tasks will replace compact panels with richer task-specific editors.
