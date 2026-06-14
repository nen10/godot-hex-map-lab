# User Goal

Keep `HexTileMapLayer` as the coordinator while extracting object placement rendering and runtime instancing into a dedicated seam so that map-layer ownership is explicit and easier to evolve.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Preserve public map-facing behavior while moving object rendering to renderer seam | high | low | low | adopt | No visible behavior or API changes; stronger boundary. |
| Add visible debug or marker logs for seam wiring | low | medium | high | reject | Non-UX debug output violates no-leaked debug requirement. |
| Add user-facing controls for renderer lifecycle | none | low | high | reject | Runtime internals should remain coordinator-owned and non-user-facing. |

## Adopted Experience

- Existing map edit workflow, object placement placement, and rendering output are unchanged.
- Object instance nodes are still attached under `ObjectInstanceLayer` when direct instances are applied.
- `HexTileMapLayer` remains the public runtime coordinator with same entry methods.
- Debug/marker rendering behavior remains identical: object markers and label markers are drawn in overlay step, now through renderer seam.

## Experience Steps

1. A map layer document is applied or object instances are requested.
2. `HexTileMapLayer` forwards object instance lifecycle and marker draw paths to `HexObjectLayerRenderer`.
3. The renderer ensures parent layer existence and z-index, instantiates scene objects, and draws payload markers.
4. Existing callers interact only with existing public methods (`apply_object_instances`, `apply_object_scene_tiles_to_layer`, `object_instance_layer`).
