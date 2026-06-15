# SCREEN-40 POLICY

## 採用方針
- DESIGN-10 Catalog / LAYOUT_SKETCH_POLICY 準拠。raw id は tooltip。
- 既存 `HexTileCatalogResource` / preview control 再利用。
- sample catalog は tutorial source として分離（production と混ぜない）。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | なし | |
| legacy | 注意 | catalog データは温存、UI のみ board 化 |

## State / Invariant
| invariant | 内容 |
|---|---|
| card 主役 | 先頭が card grid |
| 欠損可視 | missing entry は badge |
| sample 分離 | sample は production asset と混ざらない |

## baseline 整合
DESIGN-10 Catalog、`LAYOUT_SKETCH_POLICY.md`、`PRODUCT_DEFINITION.md`（map semantics: 語彙）。
