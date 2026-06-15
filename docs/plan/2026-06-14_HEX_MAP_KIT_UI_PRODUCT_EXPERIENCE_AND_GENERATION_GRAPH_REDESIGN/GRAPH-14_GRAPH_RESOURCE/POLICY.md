# GRAPH-14 POLICY

## 採用方針
- `GRAPH-10` Dictionary model を真実とし、Resource はその永続形。`to_dict`/`from_dict` で対称変換。
- embed snapshot は任意（`RUNTIME-50/51` 自己完結用）。reference 経路は path を保持。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | 注意 | embed snapshot は意図的な複製。元 .tres を破壊的に同期しない |
| legacy | なし | |

## State / Invariant
| invariant | 内容 |
|---|---|
| 無損失 | save→load で node/edge/param 一致 |
| 対称 | `from_dict(to_dict(g)) == g` |

## baseline 整合
`GENERATION_GRAPH_MODEL.md` §7、`GRAPH-10`。
