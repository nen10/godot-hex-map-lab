# OBJ-04 Object Layer Adapter Policy

作成日: 2026-06-07

## Decisions

- Standard authoring path: scene-tile prototypes on the object role `TileMapLayer`.
- Runtime alternate path: direct `PackedScene` instances under a managed `Node2D` layer.
- Object scene-tile prototypes resolve from a tile catalog entry keyed by placement `catalog_key` or `object_id`.
- Direct instance prototypes resolve from explicit `scene_prototypes` first, then from `HexObjectDatabaseResource` definition `scene_path`.
- The object marker overlay remains as a debug/fallback state but is no longer the only object-layer output.

## Compatibility

Existing object marker display state is preserved. Scene tile and direct instance application are additive and only run when their layer/prototype inputs are supplied.

## Non-goals

- Object validation/export policy is `OBJ-05`.
- Public example packaging waits for `PKG-01`.
