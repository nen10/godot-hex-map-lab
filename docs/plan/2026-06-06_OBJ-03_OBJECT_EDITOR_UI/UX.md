# OBJ-03 Object Editor UI UX

作成日: 2026-06-07

## Goal

Object mode in Hex Map Edit writes typed object placements, not only loose marker data. The brush lets a user choose an object id and edit placement properties before clicking a cell. Saved documents keep that placement state, and Undo/Redo restores it.

## Operation Steps

1. Load or create a v2 document in Hex Map Edit.
2. Switch to Object mode.
3. Set an object id, rotation, variant, spawn condition, and property JSON.
4. Click a map cell.
5. The document contains a typed object placement with the entered state.
6. Undo removes the placement and Redo restores the same typed placement state.

## Completion Signal

- Object mode controls are visible only in Object mode.
- Object mode writes `object_placements` for v2 documents through the adapter.
- Property JSON state and placement fields are undoable and saved.
