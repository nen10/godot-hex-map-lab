# LD2-01 Level Document v2 Resource Schema UX

作成日: 2026-06-07
Queue task: `LD2-01`

## Goal

`HexMapDocumentResource` を v1 の loose payload 保存から、Level Document v2 の typed resource schema へ拡張する。既存 `.tres` と adapter tests は維持し、後続 migration / validation / catalog / layer stack task が参照できる v2 フィールドを追加する。

## Operation Steps

1. Existing v1 documents still load and save with `map`, `tile_overrides`, `objects`, `labels`, and `version`.
2. New v2 documents can store terrain layers, overlay layers, object placements, label placements, zones, metadata, and dependencies as Resource-based schema.
3. Tests can create a v2 document, save/load it, and inspect typed subresources.
4. Later tasks can migrate v1 payloads into these v2 fields without changing the field names.

## UX Classification

| Step | Evaluation | Target |
| --- | --- | --- |
| Add v2 fields | 有用 + 追加 | Level Document v2 implementation has concrete storage targets. |
| Keep v1 fields | 有用 + 維持 | Existing saved resources and current editor/runtime code remain compatible. |
| Full migration helper | 有用 + 残置 | Implemented by `LD2-02`, not `LD2-01`. |
| Validation summary | 有用 + 残置 | Implemented by `LD2-03`, but schema dependency fields are added here. |

## Maintained UX

- Existing Generate/Edit/Runtime behavior is unchanged.
- Existing object/label marker payloads remain compatibility data.
- Plain `TileMapLayer` compatibility is untouched.

## Non-Goals

- No v1 to v2 migration logic beyond compatibility fields.
- No editor UI changes.
- No catalog validation implementation.
