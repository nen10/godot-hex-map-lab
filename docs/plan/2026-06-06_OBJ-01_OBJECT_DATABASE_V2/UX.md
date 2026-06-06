# OBJ-01 Object Database v2 UX

作成日: 2026-06-07

## Goal

Object authoring uses named object definitions instead of loose marker dictionaries. A designer can keep using an existing `HexObjectDatabaseResource`, while new data has a clear definition schema for scene placement, filtering, default placement properties, and preview assets.

## Operation Steps

1. Create or load a `HexObjectDatabaseResource`.
2. Add object definitions with:
   - `id`
   - `display_name`
   - `scene_path`
   - `tags`
   - `default_properties`
   - `preview`
3. Load old resources that only contain `objects: Array`.
4. The database migrates old dictionary entries into typed definitions without losing the old array fallback.
5. Later editor and runtime tasks can query by object id and receive typed schema data.

## Completion Signal

- Existing legacy object arrays still load and expose the original object ids.
- Typed object definitions roundtrip through `ResourceSaver`.
- The test path documents object database v2 coverage.
