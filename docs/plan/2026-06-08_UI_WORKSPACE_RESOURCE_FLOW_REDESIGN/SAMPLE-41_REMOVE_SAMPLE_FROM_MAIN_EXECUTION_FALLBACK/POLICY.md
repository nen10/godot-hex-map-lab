# SAMPLE-41 Policy

## Adoption

- Sample learning visibility and production execution sources are separate.
- Workspace Generate/Paint consume only project Catalog resources.
- Bundled sample paths are classified as `SOURCE_SAMPLE` and warning state in asset rows.
- Duplicated sample copies are project assets because they live outside the addon sample directory.

## Boundaries

- `HexMapGenDock` and `HexMapEditTool` own execution catalog lookup.
- `HexMapEditorAssetSlotState` owns selection source classification and warning messages.
- Settings sample duplication remains the approved sample-to-project bridge.

## Non-Adoption

- Do not remove sample package integrity checks.
- Do not hide learning candidate visibility.
- Do not add new analog tests during CLEAN UI work.

## Task-Local Decisions

- No-session debug fallback remains for existing standalone generation/edit tests; editor-session behavior is the production UX contract.
