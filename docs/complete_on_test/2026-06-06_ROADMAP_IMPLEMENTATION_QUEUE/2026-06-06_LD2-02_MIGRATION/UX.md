# LD2-02 v1 to v2 Migration UX

作成日: 2026-06-07
Queue task: `LD2-02`

## Goal

Existing v1 `HexMapDocumentResource` files can be converted into Level Document v2 resources without losing their current map, tile override, object, label, or source version information.

## Operation Steps

1. User or adapter code supplies an existing `HexMapDocumentResource`.
2. Migration returns a document with v2 schema initialized.
3. The migrated document preserves legacy fields for compatibility.
4. The migrated document fills typed v2 terrain / overlay / object placement / label placement fields where v1 data exists.
5. Missing v1 fields produce a valid empty v2 document instead of crashing.

## Maintained UX

- Existing v1 save/load behavior remains compatible.
- Current Edit/Runtime code can still read legacy fields from migrated documents.
- Later UI tasks can switch to typed v2 fields without losing v1 fallback data.

## Non-Goals

- No editor UI changes.
- No catalog lookup or validation rules.
- No full adapter roundtrip rewrite; `LD2-04` owns v2 apply/roundtrip behavior.
