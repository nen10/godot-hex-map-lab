# CLEAN-14 Policy

## Constraints

- Remove the old `labels: Array` authoring surface from `HexLabelDatabaseResource`.
- Remove `dependency_path` from `HexMapDocumentDependencyResource`.
- Keep `resource_path` as Godot's built-in resource metadata only; do not export a custom `resource_path` property.
- Keep this task focused on schema, validators, docs, and tests. UI resource-picker redesign remains CLEAN-20 and later.

## Validation

- `required=true` with `resource == null` is `document.dependency_missing`.
- Non-null resources with the wrong `kind` are `document.dependency_type_mismatch`.
- `kind=other` accepts any non-null Resource.
- Optional null dependencies do not report missing/type mismatch.
