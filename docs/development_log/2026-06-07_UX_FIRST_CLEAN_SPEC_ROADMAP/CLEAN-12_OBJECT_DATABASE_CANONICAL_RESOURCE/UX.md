# CLEAN-12 UX Notes

## Goal

Object databases should be authoring resources, not migration containers. Designers define object ids, display labels, scene resources, tags, defaults, and preview textures through typed object definition resources.

## User-Facing Contract

- `HexObjectDatabaseResource.definitions` is the only normal definition collection.
- `HexObjectDefinitionResource.scene` is a `PackedScene` resource reference.
- `preview_texture` is a `Texture2D` resource reference.
- Runtime export returns copied runtime dictionaries with `scene` resource references.
- Missing object scenes are validation issues caused by null or wrong resource references, not missing path strings.

## Acceptance

- Object definitions save/load as typed resources without `version` or `objects`.
- Direct instance application resolves `PackedScene` from explicit prototypes, placements, or object definitions.
- Runtime object export returns `scene`, not `scene_path`.
- `./tools/test.sh` passes.
