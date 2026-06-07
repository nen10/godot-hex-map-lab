# OBJ-01 Object Database v2 Policy

作成日: 2026-06-07

## Decisions

- `HexObjectDefinitionResource` is the primary v2 schema for object catalog entries.
- The public v2 id field is `id`, matching the roadmap acceptance.
- Legacy dictionaries that use `object_id` are accepted and migrated to `id`.
- `HexObjectDatabaseResource.objects` remains exported as a compatibility/fallback array.
- `HexObjectDatabaseResource.definitions` is exported as `Array[Resource]` to keep saved `.tres` subresources stable in Godot.
- The database keeps the fallback array synchronized from typed definitions when helpers mutate definitions.

## Compatibility

Old resources are not rewritten automatically on load, but `ensure_v2_defaults()`, lookup helpers, and mutation helpers populate typed definitions from old `objects` data. Dictionary output includes both `id` and `object_id` so existing consumers can continue to read the old key.

## Non-goals

- Object placement document schema is handled by `OBJ-02`.
- Editor object brush UI is handled by `OBJ-03`.
- Runtime object layer instancing is handled by `OBJ-04`.
