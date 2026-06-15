# RESCTX-42 SUB_TASKS

Complexity class: **C3**（Resources 資産棚化 + 全 work tab の context chip 化。U1/U6 是正の本丸。）

## Task Resolution
Resources を「選択中 map の資産棚」(Unique/Shared/Optional) にし、各 work tab の先頭を**詳細 row でなく context chip** にする。現状 Resources 先頭の `Readiness Summary`/`Next actions` ラベル列（U1/U6）を撤去。

## 確定設計（DESIGN-10 Resources + DESIGN-11 strip 分界）
- Resources 主役: 3群 card（`Unique to this map` / `Shared project assets` / `Optional`）。
- chips: `Selected HexTileMap:`
- primary: `[Create Missing Resources]`（大 CTA）+ `[Save All]`。
- empty: `[Select a HexTileMap node]` / Start a map CTA。
- 各 work tab: per-tab context chip（DESIGN-10 各タブ仕様）。詳細は Resources/drawer へリンク。

## Scope
含む: Resources 資産棚化、readiness/next-actions ラベル列撤去、各 work tab の context chip 化。
含まない: global top strip（DESIGN-11/別実装）。

## Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| Resources 先頭 | A: 資産 card 棚 / B: readiness ラベル列 | **A** | U1/U6 是正 |
| work tab 先頭 | A: context chip / B: 詳細 row | **A** | LAYOUT_SKETCH_POLICY §3-3 |

## Scheduled Task Audit: なし。
## Sub-tasks
1. Resources を Unique/Shared/Optional の card 棚に。
2. `Readiness Summary`/`Next actions` ラベル列撤去、`[Create Missing Resources]` 大 CTA。
3. 各 work tab 先頭を context chip 化（詳細は Resources へ）。
4. empty CTA。
5. tests。
fallback/mirror: なし。
