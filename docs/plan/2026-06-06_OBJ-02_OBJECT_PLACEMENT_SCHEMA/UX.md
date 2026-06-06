# OBJ-02 Object Placement Schema UX

作成日: 2026-06-07

## Goal

Level documents store object placement as typed placement data, not only legacy marker dictionaries. A runtime or editor workflow can ask for placements and receive enough information to choose an object definition, locate it on the map, rotate or variant-select it, apply author properties, and evaluate spawn conditions.

## Operation Steps

1. Create or load a v2 `HexMapDocumentResource`.
2. Add an object placement with object id, cell, rotation, variant, custom properties, and spawn condition.
3. Save and load the document.
4. Query object entries through `HexMapDocumentAdapter.document_object_entries()`.
5. Delete the placement cell from the shape.
6. The placement and its legacy fallback entry are removed with the deleted cell.

## Completion Signal

- Object placement data has `object_id`, `cell`, `rotation`, `variant`, `properties`, and `spawn_condition`.
- Adapter mutation preserves the same schema.
- Deleted-cell cleanup removes v2 placements and legacy fallback entries.
