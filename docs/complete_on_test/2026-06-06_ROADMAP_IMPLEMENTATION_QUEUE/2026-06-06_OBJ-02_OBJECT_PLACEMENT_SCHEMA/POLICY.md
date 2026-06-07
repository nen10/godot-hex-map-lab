# OBJ-02 Object Placement Schema Policy

作成日: 2026-06-07

## Decisions

- `HexMapDocumentObjectPlacementResource` remains the typed v2 placement schema.
- `rotation_degrees` is the stored canonical rotation field because it is explicit and already exists on the resource.
- Adapter dictionary entries expose both `rotation_degrees` and `rotation` for compatibility with roadmap wording and older payloads.
- `HexMapDocumentAdapter.set_object()` is the primary mutation helper for single-cell object placement.
- Legacy `document.objects` remains synchronized as the fallback display/runtime path until later object layer tasks replace marker rendering.

## Compatibility

Legacy v1 object entries with `rotation` migrate into `rotation_degrees`. Existing entries without variant or spawn condition continue to use empty defaults.

## Non-goals

- Object brush UI is `OBJ-03`.
- Scene instancing or layer adapter behavior is `OBJ-04`.
- Object validation and runtime export policy are `OBJ-05`.
