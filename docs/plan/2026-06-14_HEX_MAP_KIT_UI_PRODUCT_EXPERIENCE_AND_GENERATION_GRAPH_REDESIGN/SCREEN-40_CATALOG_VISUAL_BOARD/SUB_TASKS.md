# SCREEN-40 SUB_TASKS

Complexity class: **C3**（既存 catalog screen/component を統合 visual board へ。）

## Task Resolution
Catalog を **tile/object 統合の visual asset board** にする（DESIGN-10 Catalog 仕様）。entry card grid が主役、raw source_id/atlas は通常非表示、sample は tutorial source 分離。

## 確定設計（locked: tile/object 統合）
- 主役: entry card grid（preview + name + badge）。tile と object を1 board に。
- chips: `Catalog:`
- inspector: 選択 entry の preview（tile atlas / object scene）/ tags / missing badge。
- empty: `[Create Catalog] [Choose Catalog] [Open sample]`。
- 退避: raw source_id/atlas_coords→tooltip、catalog 選択→Resources。

## Scope
含む: card grid 化、tile/object 統合、inspector preview、raw id 非表示、empty CTA。
含まない: catalog データモデル変更（既存 `HexTileCatalogResource` 等を使う）。

## Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 範囲 | A: tile+object 統合 / B: tile のみ | **A** | Build/Paint は両方を key で消費（locked）|
| raw id | A: tooltip / B: 主面 | **A** | LAYOUT_SKETCH_POLICY |

## Scheduled Task Audit: なし。
## Sub-tasks
1. entry card grid（tile/object 統合）。
2. 選択 inspector（preview/badge、既存 `hex_tile_catalog_preview_control.gd` 再利用）。
3. raw id→tooltip、empty CTA、sample 分離。
4. tests。
fallback/mirror: なし。
