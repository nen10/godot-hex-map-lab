# SAMPLE-40 Policy

## Adoption

- `Duplicate To Project` is the primary sample-to-production bridge.
- The duplicate action must create project-owned catalog, texture, and scene copies.
- The duplicated catalog must become the workspace Catalog asset with `SOURCE_PROJECT` row state.
- The Settings panel must expose what changed after duplication.

## Boundaries

- `HexMapSampleSettingsPanel` owns the visible sample learning rows and duplicate dialog/action.
- `HexMapSampleAssetDuplicator` owns actual file/resource copy behavior.
- Workspace asset context propagation remains the existing session/context responsibility.

## Non-Adoption

- Do not reintroduce `Open` until there is a real preview or editor focus target.
- Do not add a sample execution fallback.
- Do not add new analog tests during CLEAN UI work.

## Task-Local Decisions

- The visible duplicate button is only shown on the bundled catalog row because the texture and scene are copied as catalog dependencies.
- A headless action helper may simulate the file-dialog selected path while exercising the same duplicate action path.
