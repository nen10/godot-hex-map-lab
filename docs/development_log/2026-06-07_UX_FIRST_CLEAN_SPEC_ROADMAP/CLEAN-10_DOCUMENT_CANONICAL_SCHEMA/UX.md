# CLEAN-10 UX

Task: `CLEAN-10_DOCUMENT_CANONICAL_SCHEMA`
Status: RUNNING

## 目的

Level Document を versioned migration product ではなく、現在の clean authoring / runtime handoff resource として提示する。

User は新規 document を作るときに `v1` / `v2` / `version` / `ensure_v2_defaults()` / migration を考えない。Document は作成直後から terrain layers, overlay layers, object placements, label placements, zones, metadata, dependencies を持つ canonical resource である。

## Operation Steps

1. `HexMapDocumentResource.new()` を作る。
2. 必要に応じて `metadata` を直接編集する。
3. Terrain layer に `HexMapResource` を入れる。
4. Overlay / object / label / zone / dependency resources を追加する。
5. Save / load / adapter roundtrip で同じ canonical fields が残る。

## UX 評価

| point | 判断 |
|---|---|
| Version choice | UI/API から消す。未公開 addon なので互換性保持を理由に残さない。 |
| Migration guide | Current manual から削除する。history docs は記録として残す。 |
| Map owner | Document 直下ではなく terrain layer が map owner。 |
| Payload owner | Object / label / overlay は typed placement/layer resources が owner。 |
| Test basis | Old fixture/migration tests は削除し、canonical save/load and roundtrip を検証する。 |

## 不変条件

- `HexMapDocumentResource.new()` は metadata を持つ。
- Canonical resource fields are exported and save/load through `.tres`.
- Adapter mutation helpers update canonical fields only.
- `HexTileMapLayer` and editor/generator workflows still load, edit, save, and apply canonical documents.

## 出力

- Clean `HexMapDocumentResource` public schema.
- Adapter/editor/generator callers that no longer call migration/default upgrade APIs.
- Tests and current docs that describe canonical documents without v1/v2 wording.
