# SCREEN-31 POLICY

## 採用方針
- DESIGN-10 Paint wireframe / LAYOUT_SKETCH_POLICY 準拠。
- Paint は **`document`/手動 writable source** へ書く（Build の `generated` 層と共存、PRODUCT_DEFINITION §5.1）。
- layer/catalog の**詳細編集は委譲**（Paint は active を参照のみ）。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | なし | active layer/brush の真実は edit state（重複保持しない） |
| legacy | 注意 | 既存 edit_tool の機能を壊さず UI 構造のみ寄せる |

## State / Invariant
| invariant | 内容 |
|---|---|
| 手動層 | Paint は手動層へ書き、再生成(Build)で潰れない |
| viewport 同期 | dock の active layer/cell/last edit が viewport と一致 |

## baseline 整合
DESIGN-10 Paint、`LAYOUT_SKETCH_POLICY.md`、`PRODUCT_DEFINITION.md` §4/§5.1。
