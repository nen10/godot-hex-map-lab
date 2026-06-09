# RES-11 Policy

## Adopted Decisions

- `HexMapDocumentDependencyService` remains the only dependency lookup API.
- `HexMapWorkspaceAssetContext` owns both current resource and source metadata for each slot.
- `Document Dependency` source applies only to resources copied from selected document dependencies.
- Project/manual source wins over document dependency source during repeated hydration.
- Missing document dependencies clear prior dependency-derived selections instead of using samples.

## Rejected Decisions

- Do not classify every hydrated resource as a project asset in panel sync.
- Do not use bundled samples as production completion proof.
- Do not mutate selected document dependencies when a user manually overrides a workspace slot.

## Boundaries

- Resource/API: dependency service returns dependency snapshots; workspace context stores selected resources and source labels.
- UI: asset slot state renders source labels through snapshots and tooltips.
- Editor workflow: workspace root triggers hydration from Level Document changes and then refreshes dependent screens.

## Task-local Open Decisions

- Keep source metadata internal to the workspace context snapshot surface; no serialized resource migration is required for the unpublished addon.
