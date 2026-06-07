# SCREEN-24 Policy

## Adopted Decisions

- `HexMapEditTool` owns current brush mode and payload state.
- `HexMapWorkspace` exposes a Paint brush screen snapshot and mode selection helper.
- Missing brush assets report the owning tab/component/slot so the user can fix configuration in Catalog or Object/Label assets.
- Normal paint controls hide source id, atlas coordinates, raw object id, and raw label id.

## Rejected Decisions

- Do not reintroduce numeric tile fallback as a normal Paint path.
- Do not add Zone mode in this task without the underlying edit mode and document mutation contract.
- Do not make sample catalog or sample object scene the Paint completion proof.

## Resource / API / UI Boundary

- Catalog/Object/Label asset screens own asset creation and definition selection.
- Paint screen reads selected assets and exposes the current brush state.
- Cleanup tasks own remaining raw variant, spawn condition, and schema field cleanup.

## Task-Local Decisions

- Brush modes map to current edit modes: Terrain = Floor/Wall tile, Overlay = Overlay tile, Object = Object, Label = Label.
- Missing asset CTA uses stable ids rather than UI text: `target_tab`, `target_component_id`, and `target_slot_id`.
