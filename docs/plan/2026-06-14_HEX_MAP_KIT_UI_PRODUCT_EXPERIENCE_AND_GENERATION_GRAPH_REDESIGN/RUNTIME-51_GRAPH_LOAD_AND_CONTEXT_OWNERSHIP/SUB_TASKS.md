# RUNTIME-51 SUB_TASKS

Complexity class: **C4**（context ownership という微妙な UX/architecture。既存選択追跡との整合。）

## Task Resolution

graph resource（`GRAPH-14`）を editor に読み込んだとき、dock の「現在の文脈」を **独立した文脈所有システムを作らず**、既存の「選択 node の resource 追跡」を再利用して復元する（O2-UX の最小コスト実装、`GENERATION_GRAPH_MODEL.md` §10）。

## 確定設計（縮小しない・決め切り済み）

| モード | 既定 | semantics | Document/層 |
|---|---|---|---|
| **新規 HexTileMapLayer 生成** | **default** | **embed（複製）** で自己完結 | 新 node の resource として復元、その node が選択され既存追跡が適用 |
| **既存 HexTileMapLayer へ overwrite** | opt-in（checkbox **off**） | **reference / merge** | `writable source` 準拠で **`generated` 層のみ置換**、`document`/手動(Paint)層は保持 |

- 文脈所有者は常に **node 1つ**＝二重所有が発生しない。新設は「graph→node 具現化(factory)」と load 入口のみ。
- 既存 `hex_map_workspace_asset_resource_factory.gd` / `hex_map_sample_asset_duplicator.gd`（資産複製）を再利用。

## Scope
含む: `Load Graph` 入口、新規 node 具現化（embed）、overwrite path（opt-in, writable_source 準拠）、既存追跡との接続、tests。
含まない: graph 編集 canvas（`GRAPH-11`）、runtime build（`RUNTIME-50`）。

## Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 文脈所有 | A: 新 node を作り既存追跡再利用 / B: 独立 graph セッション(context-owner) | **A** | 二重所有を消す・低コスト |
| 新規 semantics | A: embed 複製 / B: 参照 | **A** | 独立 map・runtime build と一貫 |
| overwrite 安全 | A: generated 層のみ / B: 全置換 | **A** | Paint 手編集保護 |

## Scheduled Task Audit: なし。

## Sub-tasks
1. `Load Graph` action（resource picker）。
2. 新規 HexTileMapLayer 具現化 + embed semantics 復元（factory 再利用）。
3. overwrite path（選択が HexTileMapLayer の時のみ・checkbox off・generated 層のみ置換）。
4. tests（新規生成 / overwrite で手動層保持 / 二重所有が起きない）。

fallback/mirror: なし。
