# DESIGN-10 POLICY

## 採用方針

- `docs/policy/LAYOUT_SKETCH_POLICY.md` に全面準拠（§1 必須リージョン / §2 各タブ主役 / §3 規則 / §4 記法 / §6 チェックリスト）。
- 主役・chips・primary action・empty CTA・resource 退避先は `IMPLEMENTATION_PLAN.md` の per-tab 仕様で**確定**。wireframe はそれを描く。
- これは **design artifact（wireframe）であり実装ではない**。code 変更なし。

## Fallback / Mirror Handling

| 項目 | 有無 |
|---|---|
| fallback | なし |
| mirror | なし |
| legacy 互換 | なし（現行 UI を温存する理由を作らない。wireframe は目標形を描く） |

## State / Invariant Table

| invariant | 内容 |
|---|---|
| 2状態必須 | 各タブ wireframe は **normal + empty** を描く |
| work surface first | 主役が dominant かつ resource 詳細より前（質的） |
| 1 primary action | 各タブに頭出し action が1つ |
| label budget | 主面に内部語彙（型説明 / readiness summary / debug / queue-test 語）を出さない |
| QA/Validate 除外 | wireframe を作らない（park） |

## baseline 整合

`PRODUCT_DEFINITION.md`（§4 主導線 / §5 map semantics / Export 3形態）、`GENERATION_GRAPH_MODEL.md`（Build=graph canvas / §10 graph load）に準拠。
