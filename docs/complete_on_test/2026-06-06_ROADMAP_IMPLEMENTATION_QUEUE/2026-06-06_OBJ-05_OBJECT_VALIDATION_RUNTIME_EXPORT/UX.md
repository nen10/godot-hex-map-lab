# OBJ-05 Object Validation Runtime Export UX

作成日: 2026-06-07

## Goal

Object placements can be checked before runtime use, and runtime code can export object placement state without mutating authoring data. Designers get validation feedback for missing scenes, wall placement, and duplicate unique objects.

## Operation Steps

1. Create a v2 document with object placements.
2. Provide an object database when scene or uniqueness validation is needed.
3. Run document validation.
4. Validation reports missing object scenes, objects on walls, and duplicate unique object ids.
5. Runtime sample exports copied object placement data with resolved scene paths.
6. Authoring placements remain unchanged after runtime export.

## Completion Signal

- Missing object scene detection is test-covered.
- Object-on-wall detection remains test-covered.
- Duplicate unique object detection is test-covered.
- Runtime export returns copied object state and does not mutate the document.
