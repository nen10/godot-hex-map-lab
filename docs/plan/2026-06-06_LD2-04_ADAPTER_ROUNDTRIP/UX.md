# LD2-04 Adapter Roundtrip UX

作成日: 2026-06-07
Queue task: `LD2-04`

## Goal

Level Document v2 resources can roundtrip through adapter and runtime layer helpers without dropping typed payloads. Users keep current v1 compatibility while v2 documents can carry tile assignments, overlay assignments, object placements, label placements, and zones.

## Operation Steps

1. Adapter code reads map data from either v1 `map` or v2 terrain layers.
2. Adapter code exposes normalized tile/object/label payload entries from v1 or v2 fields.
3. Deleting a cell removes v1 and v2 payloads attached to that cell.
4. `HexTileMapLayer.apply_document()` displays v2 tile assignments and markers.
5. Tests prove roundtrip and cleanup behavior.

## Maintained UX

- v1 document apply/edit behavior remains compatible.
- Plain `TileMapLayer` direct apply remains compatibility behavior.
- `HexTileMapLayer` remains the primary richer target.

## Non-Goals

- No catalog lookup.
- No layer stack child-role application.
- No editor load/save UI changes.
