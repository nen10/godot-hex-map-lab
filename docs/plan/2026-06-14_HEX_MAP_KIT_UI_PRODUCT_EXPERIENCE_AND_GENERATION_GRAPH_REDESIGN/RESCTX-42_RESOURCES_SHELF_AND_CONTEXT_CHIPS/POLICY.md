# RESCTX-42 POLICY

## 採用方針
- Resources は **resource が主役で良い唯一のタブ**（PRODUCT_DEFINITION §5.1 / LAYOUT_SKETCH_POLICY §2）。資産棚化。
- 他 work tab は context chip のみ、詳細は Resources へ（map semantics=束縛）。
- global top strip（DESIGN-11）の Map と重複させない（per-tab chip は tab 固有のみ）。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | 注意 | Map は global strip が持つ。Resources chip は `Selected HexTileMap`（重複回避） |
| legacy | なし | readiness/next-actions ラベル列は撤去（温存しない） |

## State / Invariant
| invariant | 内容 |
|---|---|
| 資産棚 | Resources 先頭が Unique/Shared/Optional card |
| chip 化 | work tab 先頭は詳細 row でなく chip |
| 不足提示 | missing は CTA（ラベル列でない） |

## baseline 整合
DESIGN-10 Resources、DESIGN-11 strip 分界、`PRODUCT_DEFINITION.md` §5/§5.1、U1/U6 是正。
