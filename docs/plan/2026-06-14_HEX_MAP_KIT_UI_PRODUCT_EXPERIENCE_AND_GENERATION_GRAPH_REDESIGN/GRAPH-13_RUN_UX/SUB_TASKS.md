# GRAPH-13 SUB_TASKS

Complexity class: **C3**（run engine 拡張 + UX。dirty/cancel/batch/失敗可視。）

## Task Resolution

`GRAPH-11` canvas の run を実用化する。**Generate(N=1) を頭出し**、N 入力・seed/shape randomize を下方へ降格、dirty 伝播で再 run を最小化、cancel 可能、失敗時にどの node が悪いか分かる。

## 確定設計
| 論点 | 決定 |
|---|---|
| run engine | DAG topo + 中間 cache + **dirty 伝播**（上流変更で下流 dirty、dirty のみ再実行） |
| cancel | 既存 generator の **`interrupt_options`**（progress/cancel）を runner に通す |
| N batch | `N`(default 1) 入力 + seed/shape randomize。**下方に降格**（半オプション） |
| 失敗可視 | `validate`/run error の `node` を canvas で強調 |
| 頭出し | `[Generate]` を context strip 右で明白に |

## Scope
含む: dirty 伝播 / cancel / progress / N batch UI(降格) / 失敗 node 強調。
含まない: promote（`GRAPH-12`）/ persistence（`GRAPH-14`）。

## Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 再実行 | A: dirty のみ / B: 毎回全 run | **A** | 生成は重い・体験を軽く |
| cancel | A: interrupt_options 再利用 / B: 新規 | **A** | 既存 progress/cancel を流用 |
| N batch 位置 | A: 下方降格 / B: 頭出し | **A** | 初手の体験を重くしない（PRODUCT_DEFINITION）|

## Scheduled Task Audit: なし。

## Sub-tasks
1. runner に dirty 伝播（node 単位の cache 無効化）。
2. cancel/progress（interrupt_options 配線、busy 表示）。
3. N batch panel（N default 1、seed/shape randomize、下方）。
4. 失敗 node 強調（error.node → GraphNode ハイライト）。
5. tests。

fallback/mirror: なし。
