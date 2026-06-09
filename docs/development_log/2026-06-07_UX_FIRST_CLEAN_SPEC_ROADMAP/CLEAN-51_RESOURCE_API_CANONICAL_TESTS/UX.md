# CLEAN-51 Resource API Canonical Tests UX

## Goal

Make the clean Resource/API contract explicit in automated tests so public authoring APIs stay canonical as the UI/docs continue to move.

## User Contract

- Canonical documents save and load with typed child resources.
- Adapter roundtrip uses canonical resources and catalog keys.
- Catalogs hold Resource references such as `TileSet` and `PackedScene`.
- Object definitions hold `PackedScene` resources.
- Dependency validation reports missing or mismatched Resource references.
- Missing catalog assignment is validation feedback, not a silent numeric tile apply path.
- Runtime queries accept `HexMapDocumentResource` directly.

## Non-Goals

- This task does not redesign API names.
- This task does not regenerate package artifacts.
