# RES-10 UX

## User Goal

When a Level Document owns shared project resources, the editor should be able to recover those resources from the document itself. This task builds the Resource/API foundation so later Workspace screens can show `Document Dependency` sources instead of silently falling back to samples or requiring repeated manual selection.

## Operation Steps

1. Code receives a `HexMapDocumentResource`.
2. Code sets a dependency for a shared project resource by semantic kind and optional role.
3. Re-setting the same kind/role updates the existing dependency instead of adding duplicates.
4. Code can find or remove the dependency without scanning arrays directly.
5. Code can hydrate a dependency map for Tile Catalog, Object DB, Label DB, Movement Profile, Validation Suite, Generation Profile, and Export Profile.
6. Code can validate missing required dependencies and type mismatches through a single service call.

## Adopted UX

- Shared resource recovery is Resource-first and document-owned.
- Role and required state are first-class dependency fields.
- Source badge information is represented as dependency metadata/source fields for later UI hydration.

## Retained UX

- `HexMapDocumentResource.dependencies` remains the storage location.
- Existing document validator behavior remains valid.
- Profile slots remain generic `Resource` until concrete classes are introduced.

## Removed Or Deferred UX

- Workspace auto-hydration is deferred to `RES-11`.
- Node writeback is deferred to `NODE-20`.
- Concrete profile class UX is deferred to `PROFILE-30`.

## Existing UX Interference

Any caller that manually scans dependency arrays should move to the service over time. This task does not need to update all call sites before the service exists.
