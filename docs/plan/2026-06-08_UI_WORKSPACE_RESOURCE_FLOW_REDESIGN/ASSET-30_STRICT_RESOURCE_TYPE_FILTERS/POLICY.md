# ASSET-30 Policy

## Adoption

- Asset slot type filters are part of the UI contract, not only validation metadata.
- Concrete addon Resource classes are required for Level Document, Tile Catalog, Layer Stack, Object DB, Label DB, and Movement Profile.
- Flexible profile slots must explicitly report why they remain `Resource`.
- Tooltips must include expected type information for typed and flexible slots.

## Boundaries

- `HexMapEditorAssetSlotState` owns the slot type contract and snapshot metadata.
- `HexMapEditorAssetSlotControl` owns the visible `EditorResourcePicker` base type.
- Workspace panels provide the slot-specific type and purpose data.

## Non-Adoption

- Do not add new profile Resource classes in this task.
- Do not preserve generic `Resource` for typed slots to satisfy old tests.
- Do not add an analog test during CLEAN UI work.

## Task-Local Decisions

- Validation Rule Suite, Generation Profile, and Export Profile remain flexible `Resource` slots until concrete classes exist, but must report a flexibility reason.
- PackedScene slots are out of the current workspace asset context and are documented as not currently mounted in this task.
