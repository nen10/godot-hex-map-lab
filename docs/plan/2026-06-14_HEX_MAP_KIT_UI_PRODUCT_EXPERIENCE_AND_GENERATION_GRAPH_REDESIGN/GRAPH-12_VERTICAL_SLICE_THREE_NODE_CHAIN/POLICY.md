# GRAPH-12 POLICY

## 採用方針
- **run 純粋性維持**: `GRAPH-10` runner は副作用なし。Document 書込は Promote action（別ステップ）だけが行う。
- **generated 層境界**: Promote は `writable source = generated` で書き、`document`/`target`/手動層を置換しない。
- **Document adapter 再利用**: 既存 `hex_map_document_adapter.gd` の payload 書込を使う（新規 Document 操作を作らない）。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | なし | 生成層と手動層は `writable source` で**区別**（重複保持でない） |
| legacy | なし | |

## State / Invariant
| invariant | 内容 |
|---|---|
| 手動層保持 | Promote 後、`document`/手動(Paint) 層は不変 |
| generated 上書き | 同 role の `generated` 層は再 Promote で置換される（再生成想定） |
| chain 成立 | 中間 selection が次 node 入力として実際に使われる |
| 保存可能 | Promote 後の Document は `.tres` 保存できる |

## baseline 整合
`PRODUCT_DEFINITION.md` §3/§4/§5.1、`GENERATION_GRAPH_MODEL.md` §6、`GRAPH-10`/`GRAPH-11`。
