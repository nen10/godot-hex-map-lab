# DESIGN-11 POLICY

## 採用方針

- **分類 ≠ 導線**: tab bar の分類（Primary/Support/Utility/Parked）は重要度、導線（Build→Paint→Export）は作業順序。混同しない。導線は global top strip が見せる。
- **strip の二層分界**:
  - **global top strip（本 task が定義）**: `Map` / 状態 / 進行(`Build ▸ Paint ▸ Export`) / `Missing` CTA / Diagnostics。tab を跨いで常在。
  - **per-tab context strip（`DESIGN-10`）**: そのタブ固有 chips（Catalog/Target/Layer/Brush 等）。`Map` は global のみで持ち**重複させない**。
- **QA/Validate は tab bar 外**（Diagnostics drawer・park）。

## Fallback / Mirror Handling

| 項目 | 有無 |
|---|---|
| fallback | なし |
| mirror | なし（Map を global/per-tab に二重表示しない） |
| legacy 互換 | なし（現状の9同列 tab を温存しない） |

## State / Invariant

| invariant | 内容 |
|---|---|
| tab bar 集合 | Build, Paint, Catalog, Layers, Resources, Export, Settings の7。QA/Validate は含まない |
| 改名 | `Generate`→`Build` |
| 進行表示 | top strip は常に current step を強調 |
| 未設定 | Missing があれば top strip に CTA |

## baseline 整合

`PRODUCT_DEFINITION.md`（§4 主導線・map semantics・QA park）、`GENERATION_GRAPH_MODEL.md`、`LAYOUT_SKETCH_POLICY.md`（context strip 記法）に準拠。
