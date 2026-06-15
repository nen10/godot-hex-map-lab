# SCREEN-30 POLICY

## 採用方針
- **Simple は preset graph**（別 model を作らない）。同じ `GRAPH-10` graph 上に乗る。
- **canvas が主役**（LAYOUT_SKETCH_POLICY §2 Build）。Simple 帯は入口で、canvas を覆わない。
- 既存 `GRAPH-11..13` を再利用、再実装しない。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | 注意 | Simple param と graph node param の真実は **graph**（Simple は preset を生成するだけ。二重保持しない） |
| legacy | なし | 既存 gen_dock の単発生成は変更しない（並存） |

## State / Invariant
| invariant | 内容 |
|---|---|
| 単一 graph | Simple 生成も Graph 編集も同一 graph を指す |
| canvas dominant | Build 先頭の主役は canvas |

## baseline 整合
`PRODUCT_DEFINITION.md` §3（simple は入口/graph 本体）、`LAYOUT_SKETCH_POLICY.md`、DESIGN-10 Build wireframe、`GRAPH-11..13`。
