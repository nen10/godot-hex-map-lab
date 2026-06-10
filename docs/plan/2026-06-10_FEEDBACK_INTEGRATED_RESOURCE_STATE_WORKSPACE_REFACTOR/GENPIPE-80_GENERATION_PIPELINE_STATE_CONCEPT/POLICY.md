# GENPIPE-80 Policy

## Adopted Decisions

- `HexMapDocumentResource` is the final committed authoring resource.
- `HexGenerationProfileResource` owns generation inputs and must not own generated cells.
- Current Generate Preview state is transient editor state.
- A future Generation Result model is the right home for persisted primary, overlay, filter, and candidate maps.
- Resource pass or linear pipeline work may happen before any node graph UI.

## Rejected Decisions

- Do not add a node graph editor before Resource/API ownership exists.
- Do not store full intermediate graphs inside Level Document metadata.
- Do not treat QA rows as durable results without a save/load model.
- Do not add UI controls for intermediate maps just because current overlay query controls are graph-like.

## Resource / API / UI Boundary

- Resource: future persistent intermediates belong in `GenerationResultResource` or equivalent typed Resource artifacts.
- API: replay should work from profile/result data without a live dock instance.
- UI: Generate stays preview/apply/progress; QA stays seed comparison/promotion; graph concepts remain backlog/research.
- Document: Level Document may store concise provenance references or summaries, but it should remain usable without loading a graph.

## Compatibility

The addon is unpublished, so a future result schema can be clean. Backward compatibility should only be added if a roadmap explicitly scopes saved-result migration.
