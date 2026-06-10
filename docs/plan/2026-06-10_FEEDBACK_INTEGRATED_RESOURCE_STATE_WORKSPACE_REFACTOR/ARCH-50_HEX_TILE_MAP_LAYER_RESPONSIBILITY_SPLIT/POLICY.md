# ARCH-50 Policy

## Adopted Decisions

- `HexTileMapLayer` remains the coordinator scene node.
- Resource binding preparation belongs to `HexTileMapResourceBinding`.
- Document apply preparation belongs to `HexMapDocumentApplier`.
- Existing object, gameplay, and debug helper behavior is preserved.

## Rejected Decisions

- Do not break runtime helper API value to chase a pure architecture split.
- Do not migrate every responsibility at once.
- Do not add analog tests for this architecture slice.

## Resource / API / UI Boundary

- Resource: `HexMapResource` and `HexMapDocumentResource` conversion/preparation move to helpers.
- API: `HexTileMapLayer` continues to expose `apply_map`, `apply_document`, and runtime helpers.
- UI: No UI behavior changes are intended.

## Compatibility

The addon is unpublished, but runtime helper continuity is explicitly preserved by the roadmap acceptance.
