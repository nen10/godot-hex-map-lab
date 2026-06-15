# SCREEN-41 POLICY

## 採用方針
- DESIGN-10 Layers / LAYOUT_SKETCH_POLICY 準拠。role stack を視覚化。
- 既存 `HexLayerStackResource` / writable source 語彙（document/target/generated/readonly）を使う。
- writable source は Build(generated)/Paint(document) 共存の鍵として明示。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | なし | role 状態の真実は Layer Stack resource |
| legacy | 注意 | data 温存、UI を視覚化 |

## State / Invariant
| invariant | 内容 |
|---|---|
| 視覚 stack | 先頭が role stack tree |
| writable 明示 | 各 role の writable source が見える |

## baseline 整合
DESIGN-10 Layers、`PRODUCT_DEFINITION.md` §5/§5.1、`LAYOUT_SKETCH_POLICY.md`。
