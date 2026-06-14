## Adopted Decisions

- `HexTileMapLayer` stays coordinator and continues to expose public runtime entry points.
- `HexObjectLayerRenderer` owns:
  - `ObjectInstanceLayer` node lifecycle lookup/creation.
  - direct instance prototype application.
  - scene tile prototype application forwarding.
  - payload marker draw path.
- `HexTileMapLayer` no longer owns object-layer lifecycle or inline marker drawing implementation.

## Rejected Decisions

- Do not change object marker appearance, color, counts, z-ordering, or placement math.
- Do not rename existing public methods.
- Do not introduce sample-only / fallback-only behavior for direct instance rendering.
- Do not change tile-map apply or document-apply control flow.

## Resource / API / UI Boundary

| area | owner | boundary |
|---|---|---|
| Public runtime entry points (`apply_object_instances`, `apply_object_scene_tiles_to_layer`, `object_instance_layer`, `_draw_overlay`)| `HexTileMapLayer` | Keep API stable and coordinator behavior. |
| Runtime instance-layer lifecycle and marker draw operations | `HexObjectLayerRenderer` | Full ownership for direct node lifecycle and payload marker drawing. |
| Document payload storage (`_object_markers_by_key`, `_label_markers_by_key`) | `HexTileMapLayer` | Data preparation remains in coordinator; rendering reads prepared marker stores. |
| Test instrumentation | `tests/test_hex_tile_map_layer.gd` | Assertion-only seam behavior tests; no production path changes. |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Legacy inline marker draw code path | remove | task objective is boundary extraction | Not kept | `tests/test_hex_tile_map_layer.gd` now asserts seam markers are used. |
| Legacy layer lifecycle helper | remove | ownership is now explicit in renderer | Not kept | `object_instance_layer()` still returns valid layer with expected name/z-index. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Object instance parent | `ObjectInstanceLayer` exists under `HexTileMapLayer` when requested and has `z_index=60` | stale parent or wrong z-ordering | `_test_object_layer_renderer_seam_applies_instances_and_markers` |
| Object instance count/parenting | direct instance count and parent relationship remain consistent with prior runtime behavior | managed child leak or wrong parent | `_test_object_layer_renderer_seam_applies_instances_and_markers` |
| Marker rendering | object and label payload markers are drawn by renderer seam | marker path regression | `_test_object_layer_renderer_seam_applies_instances_and_markers` |
| Public entry semantics | existing methods remain callable and coordinated | API break | existing tests + new seam test |
