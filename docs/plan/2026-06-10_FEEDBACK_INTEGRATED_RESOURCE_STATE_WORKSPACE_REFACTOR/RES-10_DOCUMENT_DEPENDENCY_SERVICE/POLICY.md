# RES-10 Policy

## Adopted Decisions

- `HexMapDocumentDependencyService` is the adapter-layer owner for dependency lookup and mutation.
- Dependency identity is `(kind, role)`.
- `set_dependency()` updates an existing dependency with the same identity instead of appending duplicates.
- `required`, `source_badge`, and metadata are preserved in service snapshots.
- Generic profile dependencies are valid `Resource` dependencies until concrete profile classes exist.

## Rejected Decisions

- Do not make Workspace context hydration part of this task.
- Do not add node binding/writeback behavior here.
- Do not encode dependency kinds as ad hoc strings in tests or UI call sites.
- Do not block this task on concrete profile Resource classes.

## Breaking Change Rationale

The addon is unpublished. Extending dependency kinds and adding a service is a clean API change. Existing dependency resources still save/load because fields remain the same.

## Resource / API / UI Boundary

- Resource/API: add service and dependency kind constants.
- UI: unchanged in this task.
- Tests: adapter-level CRUD/hydration/validation.

## Task-Local Decisions

- `hydrate_dependency_map()` returns a dictionary keyed by semantic ids such as `tile_catalog`, `object_database`, and `export_profile`.
- `validate_dependencies()` delegates to `HexMapDocumentValidator` and returns its validation result.
- `source_badge` is service metadata for later UI use, not visible UI in this task.
