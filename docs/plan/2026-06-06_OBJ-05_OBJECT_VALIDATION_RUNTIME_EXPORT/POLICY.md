# OBJ-05 Object Validation Runtime Export Policy

作成日: 2026-06-07

## Decisions

- Object scene validation is opt-in through `require_object_scenes` or an `object_database` option so legacy documents without object databases do not become noisy by default.
- Unique object detection uses placement `properties.unique`, object definition `default_properties.unique`, or the definition tag `unique`.
- Runtime export is a copied dictionary representation of object placements; it resolves scene paths but does not edit `object_placements` or legacy `objects`.
- Authoring state and runtime state stay separate until a later packaging/export task chooses a concrete file format.

## Compatibility

Existing validation calls keep passing without object database options. Object-on-wall remains a default validation rule.

## Non-goals

- Public export file format is deferred to package/example tasks.
- Runtime object instancing is provided by `OBJ-04`; this task only exports placement state.
