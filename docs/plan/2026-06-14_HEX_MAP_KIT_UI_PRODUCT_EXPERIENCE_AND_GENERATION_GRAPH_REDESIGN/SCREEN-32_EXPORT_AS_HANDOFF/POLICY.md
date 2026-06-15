# SCREEN-32 POLICY

## 採用方針
- handoff は **map 生成の出力まで**。gameplay framework 化しない（PRODUCT_DEFINITION §0/§7）。
- 3形態（data/scene/graph）を purpose card 化。graph card は `RUNTIME-50` の runtime build と整合。
- package build は **process-only**（EXPORT-NEXT-10 決定）。editor では disabled card + tooltip。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | なし | |
| legacy | 注意 | 既存 export workflow state を壊さず card 化 |

## State / Invariant
| invariant | 内容 |
|---|---|
| 境界 | 出力は load/build 可能まで。gameplay を含まない |
| graph card | `RUNTIME-50` の build 対象 graph resource を出力 |

## baseline 整合
DESIGN-10 Export、`PRODUCT_DEFINITION.md`（Export 3形態 / runtime 境界）、`RUNTIME-50`。
