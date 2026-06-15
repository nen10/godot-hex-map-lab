# GRAPH-12 SUB_TASKS

Complexity class: **C4**（背骨の vertical slice。canvas + run + Promote + Document 書込の結線。複数フロー横断。★）

## Task Resolution

editor 上で `Shape→Wall→Connectivity →Region Filter→ Item Generator →[Promote]` の **6-node chain が1本通り**、中間 selection が次 node 入力になり、最終出力が **Document の層として実在**するまでを成立させる。**これが動くまで Graph を COMPLETE にしない**。

## 核心の設計判断（縮小しない・決め切る）

| 論点 | 決定 | 理由 |
|---|---|---|
| Promote の形 | **editor action**（選択 node 出力 → 役割選択 → Document 書込）。graph node にしない | `GRAPH-10` の run 純粋性を保つ。DESIGN-10 inspector の `[Promote output to Layer]` と一致 |
| writable source | Promote は **`generated`** 層として書く | Paint の `document`/手動層を潰さない（Build/Paint 共存 = PRODUCT_DEFINITION §5.1） |
| 中間 feed | Region Filter の `selection` を Item Generator の `scope` に接続（`GRAPH-10` 既存） | 背骨要件 |
| in-graph Promote node | MVP では作らない（将来拡張） | 純粋 run を崩さない |

## Promote の role→Document 対応

| target role | node 出力 | Document 書込 |
|---|---|---|
| terrain | terrain(`HexMapData`) | map cells/walls（document adapter） |
| overlay | overlay(`HexOverlayData`) | tile_overrides kind=overlay |
| object | overlay(`HexOverlayData`) | objects |

## Scope
含む: Promote action（出力+role→Document, writable_source=generated）、6-node chain の editor 結線、中間 selection preview、`GRAPH-11` inspector の Promote 活性化、tests。
含まない: dirty/cancel/N batch（`GRAPH-13`）、graph resource 永続化（`GRAPH-14`）。

## Scheduled Task Audit: なし。

## Sub-tasks
1. promote logic（`output + role + writable_source → Document`、`generated` 層のみ書込）。
2. inspector の `[Promote output to Layer]` 活性化（role 選択 + 実行）。
3. 6-node chain を editor で組める導線確認（Filter→ItemGen の中間 feed）。
4. tests（chain 通し / promote 後 Document 層実在 / 手動層保持）。

fallback/mirror: なし（生成層と手動層は `writable source` で分離。mirror でない）。
