# RUNTIME-50 POLICY

## 採用方針
- **editor 非依存**: runtime build は `addons/hex_map_kit/generation/` の runner のみ使用。editor を import しない。
- **境界遵守**: build は map 生成まで。gameplay（戦闘/AI 等）は含まない（製品定義 §0/§7）。
- **embed 優先**: semantics は embed snapshot を優先解決、無ければ reference path。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | semantics | embed が無い古い graph は reference path で解決（無ければ error を返す、握れる） |
| mirror | なし | |
| legacy | なし | |

## State / Invariant
| invariant | 内容 |
|---|---|
| 決定性 | 同 graph + 同 seed → 同 map |
| 自己完結 | embed graph は外部 .tres 無しで build 可 |
| 非 editor | runtime path は editor class を参照しない |

## baseline 整合
`PRODUCT_DEFINITION.md` §0（runtime Map Build API in-scope）、`GENERATION_GRAPH_MODEL.md` §7、`GRAPH-10`/`GRAPH-14`。
