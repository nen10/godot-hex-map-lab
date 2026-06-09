# CLEAN-23 Object Palette / Property Editor Redesign UX

## Goal

Object placement should feel like choosing a game object definition and setting placement properties, not typing raw object ids or JSON dictionaries.

Primary controls:

```text
Object Database: [ResourcePicker]

Definitions:
id                  scene       tags        defaults
object.spawn        [scene]     spawn       ok
object.door         [scene]     door        ok

Scene: [PackedScene ResourcePicker]
Object Key: [definition id]

Properties:
locked       [x]
health       [ 10 ]
variant      [LineEdit]
state        [closed v]
```

## User Contract

- Object database selection uses `HexObjectDatabaseResource`.
- Object definitions are visible in a list.
- Scene references are selected as `PackedScene` resources.
- Placement brush object key comes from object definitions.
- Placement properties use typed controls for common value types.
- Raw `object_id` text and JSON dictionary property editing are not normal placement UX.

## Non-Goals

- CLEAN-26 owns broader validation issue grouping and fix suggestions.
- CLEAN-33 owns deleting any remaining debug-only object/property editing remnants outside the normal workflow.
