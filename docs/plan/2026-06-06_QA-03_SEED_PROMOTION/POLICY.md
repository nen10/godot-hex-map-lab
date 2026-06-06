# QA-03 Policy

## Decisions

- Promotion regenerates from the chosen seed snapshot instead of copying transient current map state.
- Promoted resources use `HexMapDocumentResource.VERSION_V2` and `HexMapDocumentMetadataResource` fields already present in the schema.
- Metadata snapshots are sanitized for persistence; runtime-only generation ids and object references are not required as saved metadata.
- Promotion helpers return documents and do not force a save dialog in this task.

## Compatibility

- Existing Generate Dock save behavior for `HexMapResource` and `HexOverlayResource` is unchanged.
- Batch results remain valid input for future UI table work.
- QA-04 remains responsible for golden seed fixtures and preview artifacts.

## Test Policy

- Add editor plugin headless tests for batch-row promotion, v2 document metadata, and save/load roundtrip.
- Update `docs/TEST.md` because editor plugin Test path gains seed promotion coverage.
- Final proof requires `./tools/test.sh`.
