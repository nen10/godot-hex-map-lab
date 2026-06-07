# OBJ-04 Object Layer Adapter UX

作成日: 2026-06-07

## Goal

Runtime and authoring code can turn object placements into visible object layer content. Object markers remain a lightweight debug fallback, while an object role layer can now receive scene tiles and runtime code can instantiate object scene prototypes directly.

## Operation Steps

1. Load a v2 document with object placements.
2. Provide a layer stack with an object role.
3. Provide object scene-tile prototypes through a tile catalog entry keyed by object id or catalog key.
4. Apply the document to the layer stack.
5. The object role `TileMapLayer` receives scene-tile cells for object placements.
6. Runtime code may instead provide direct `PackedScene` prototypes and instantiate them under a managed object instance layer.

## Completion Signal

- Scene tile prototype placement works on the object role layer.
- Direct instance prototype placement works under a managed runtime node.
- The standard choice is documented in policy.
