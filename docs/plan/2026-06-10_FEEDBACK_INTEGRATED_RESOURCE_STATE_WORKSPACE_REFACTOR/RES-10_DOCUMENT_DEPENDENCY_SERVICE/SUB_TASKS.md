# RES-10 Sub Tasks

## Task Resolution

task resolution:

- task candidate: add adapter-layer dependency service
  - goal / UX: callers should not manually scan `HexMapDocumentResource.dependencies`.
  - decision: adopt in this task.
  - summary: Add `HexMapDocumentDependencyService` with find/set/remove/hydrate/validate helpers.
- task candidate: extend dependency kind vocabulary for shared resources
  - goal / UX: shared resource kinds should be named once and reused by service/tests.
  - decision: adopt in this task.
  - summary: Add movement/profile dependency kind constants to `HexMapDocumentDependencyResource`.
- task candidate: hydrate Workspace context from document dependencies
  - goal / UX: selecting a document fills Workspace resources automatically.
  - decision: defer to `RES-11`.
  - summary: `RES-10` creates the service boundary only; Workspace integration is the next task.
- task candidate: introduce concrete Validation/Generation/Export profile classes
  - goal / UX: profile dependencies become typed Resource classes.
  - decision: defer to `PROFILE-30`.
  - summary: Until concrete classes exist, profile dependencies validate as generic `Resource`.

## Scheduled Tasks

No new Scheduled task is added by this task.

Reason:

- Workspace hydration is already `RES-11_DOCUMENT_DEPENDENCY_HYDRATION`.
- Concrete profile Resource classes are already `PROFILE-30_CONCRETE_PROFILE_RESOURCES`.

## Completion Boundary

`RES-10` is complete when:

- Document dependency service can add, find, update, remove, hydrate, and validate shared project dependencies.
- Tile Catalog, Object DB, Label DB, Movement Profile, Validation Suite, Generation Profile, and Export Profile have service-level kind constants and hydration keys.
- Tests cover dependency CRUD, hydration, required/optional validation, and type mismatch validation.
