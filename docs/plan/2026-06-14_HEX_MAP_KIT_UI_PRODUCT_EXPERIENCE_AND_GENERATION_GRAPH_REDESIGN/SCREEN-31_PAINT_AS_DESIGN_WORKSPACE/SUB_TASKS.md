# SCREEN-31 SUB_TASKS

Complexity class: **C3**（既存 `hex_map_edit_tool.gd`(5364行) を DESIGN-10 Paint wireframe へ寄せる rework。）

## Task Resolution
Paint tab を「純ランダムを補うデザイン管理面」にする。DESIGN-10 Paint 仕様（主役=brush palette+編集ステータス、描画は Godot main 2D viewport、先頭に Resource row 無し）に従う。

## 確定設計（DESIGN-10 拘束）
- chips: `Map:` `Layer:(active role)` `Brush:(catalog key)`
- 主役: brush palette + 形状(single/line/disc/flood) + status（`Cell: q,r` / `Last edit: painted N cells on <layer>`）
- 描画: viewport（dock は palette/status に専念）
- empty: `[Create/Choose Level Document]`
- 退避: layer 詳細→Layers、catalog→Catalog

## Scope
含む: Paint dock の再構成（brush/active layer/cell/last edit/viewport 同期）、先頭 Resource row 撤去。
含まない: layer 編集自体（Layers）、catalog 編集（Catalog）。

## Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 編集面 | A: viewport 主 / B: dock 内ミニ | **A** | hex 編集は viewport が自然（locked） |
| 先頭 | A: brush 作業面 / B: resource row | **A** | LAYOUT_SKETCH_POLICY |

## Scheduled Task Audit: なし。
## Sub-tasks
1. 先頭 Resource row 撤去 + chips 化。
2. brush palette + 形状 + status の作業面。
3. viewport↔dock 同期（active layer/cell/last edit）。
4. empty CTA。
5. tests。
fallback/mirror: なし。
