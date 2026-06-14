# Implementation Plan

## Scope

Extract runtime object-layer instancing and object-marker rendering ownership from `HexTileMapLayer` into `HexObjectLayerRenderer` while preserving all public API and rendering behavior.

## Target Files

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/adapter/hex_object_layer_renderer.gd`
- `addons/hex_map_kit/adapter/hex_object_layer_renderer.gd.uid`
- `tests/test_hex_tile_map_layer.gd`

## Planned Implementation Steps

1. Remove direct object-layer inline lifecycle helpers from `HexTileMapLayer` (`_ensure_object_instance_layer`, constant-dependent state and node creation block).
2. Keep `HexTileMapLayer` public coordinator methods and route:
   - `_object_instance_layer` access via `object_instance_layer()` to renderer.
   - `apply_object_instances()` through renderer seam.
   - `apply_object_scene_tiles_to_layer()` through renderer seam.
   - `_draw_overlay()` marker rendering through renderer seam.
3. Keep renderer null-safe and node-safe; preserve node name and z-index behavior.
4. Add seam-specific tests for:
   - seam parent creation and z-index,
   - direct instance count/parenting through seam,
   - marker draw callback through renderer seam.
5. Run `./tools/test.sh` and record test result.
6. Update queue status/proof log for `ARCH-NEXT-20` and add self-review/test-result docs.

## Fallback / Deferred Step

| step | decision | reason |
|---|---|---|
| Introduce an additional gameplay service for marker geometry queries | defer to `ARCH-NEXT-21` | out of scope for runtime rendering boundary extraction. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Runtime node lifecycle | wrong parent or ordering | `_test_object_layer_renderer_seam_applies_instances_and_markers` |
| Marker output | behavior regression (shape/appearance) | `_test_object_layer_renderer_seam_applies_instances_and_markers`, existing marker-count assertions |
| Public entry points | API break | existing `test_hex_tile_map_layer.gd` object test plus seam test |
| Standard completion gate | incomplete test proof | `./tools/test.sh` |

## Planned Completion Criteria

- `HexTileMapLayer` no longer owns object marker drawing or instance layer lifecycle internals.
- Object-instance runtime boundary is exercised through `HexObjectLayerRenderer`.
- Existing object placement behavior and marker visuals remain unchanged.
- `./tools/test.sh` passes and proof docs are updated.
