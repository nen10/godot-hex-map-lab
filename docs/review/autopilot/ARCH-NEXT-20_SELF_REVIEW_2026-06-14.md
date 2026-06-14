# ARCH-NEXT-20 Self Review 2026-06-14

Task: `ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION`
Status: COMPLETE

## Summary

`HexTileMapLayer` remains the coordinator/runtime entrypoint while object-layer lifecycle, runtime instancing entrypoints, and payload marker drawing are delegated to `HexObjectLayerRenderer`. The tilemap layer now forwards `object_instance_layer()`, `apply_object_instances()`, and `_draw_overlay()` marker drawing to the renderer seam and no longer owns the object instance node lifecycle. Behavior is validated with updated seam-focused tests and existing object/tilemap paths.

## Changed Files

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `tests/test_hex_tile_map_layer.gd`
- `addons/hex_map_kit/adapter/hex_object_layer_renderer.gd`
- `addons/hex_map_kit/adapter/hex_object_layer_renderer.gd.uid`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION/SUB_TASKS.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION/UX.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION/POLICY.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION/IMPLEMENTATION_PLAN.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Acceptance

| requirement | result | evidence |
|---|---|---|
| Object placement rendering/runtime instancing boundary is separated | pass | `HexTileMapLayer` delegates instance-layer creation to `_object_layer_renderer.ensure_object_instance_layer()`, `apply_object_instances()` to `apply_direct_instance_prototypes()`, and marker rendering through renderer `draw_document_payload_markers()`. |
| `HexTileMapLayer` remains coordinator/public entry | pass | Public methods `apply_object_instances`, `apply_object_scene_tiles_to_layer`, and `object_instance_layer` still live on `HexTileMapLayer` and retain existing call semantics. |
| Null-safe and no debug leaks | pass | Renderer returns null safely in lookup and `draw_document_payload_markers()` guards `canvas`/callables and data presence. Existing tests remain green with no new debug path outputs introduced. |
| Existing behavior is preserved | pass | Regression is maintained in existing tests including `tests/test_hex_tile_map_layer.gd` object/tilemap coverage and no changes to object counts/parent semantics in seam test. |

## Plan Deviation

None.

## Repair-Now Audit

None.

## Sample-Only Completion Audit

No sample-only completion path is used. Behavior is validated with existing and seam-focused unit-style assertions independent of sample presets.

## Tests

- `./tools/test.sh`

Known non-blocking output:
- macOS CA certificate warning from Godot (`get_system_ca_certificates`).
- existing generation/editor negative-path warnings (already present in this suite).
