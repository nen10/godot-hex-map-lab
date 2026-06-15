# RUNTIME-50 SUB_TASKS

Complexity class: **C3**（runtime API。`GRAPH-10` runner を editor 非依存で使う。embed semantics 自己完結。）

## Task Resolution

保存した `HexGenerationGraphResource`（`GRAPH-14`）を **実行時に読み込み map を build する API** を提供する。完全ランダム生成ユース（runtime variety）で、ゲーム実行中に graph から map を生成して `HexTileMapLayer` に適用できる。製品定義 §0 runtime 境界の「graph からの実行時生成」拡張（依然 map 生成・gameplay ではない）。

## 確定設計
| 論点 | 決定 |
|---|---|
| build 実装 | `GRAPH-10` runner を **editor 非依存**で呼ぶ（headless path 再利用） |
| 自己完結 | graph に **embed された semantics**（snapshot）で外部 .tres 無しに build 可（reference 経路はプロジェクト .tres 同梱） |
| 適用先 | 生成結果を `HexTileMapLayer` に適用（runtime map）。editor Document 認証は通らない |
| API 形 | `HexMapGraphBuilder.build(graph_res, options)->result` + `HexTileMapLayer.build_from_graph(graph_res, seed)` |

## Scope
含む: runtime build API、embed semantics 解決、`HexTileMapLayer` への適用、example、tests。
含まない: editor 読込/編集（`RUNTIME-51`）、graph 著作（`GRAPH-11/12`）。

## Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| build 入口 | A: builder + layer method 両方 / B: layer method のみ | **A** | data だけ欲しい用途と node 適用用途の両対応 |
| semantics 解決 | A: embed 優先・無ければ reference / B: reference のみ | **A** | runtime 自己完結を既定に |
| seed | A: 引数で上書き可 / B: graph 固定 | **A** | runtime variety |

## Scheduled Task Audit: なし。

## Sub-tasks
1. `HexMapGraphBuilder.build(graph_res, options)`（runner を headless 実行 → result）。
2. embed semantics 解決（snapshot → catalog/layer 適用）。
3. `HexTileMapLayer.build_from_graph(graph_res, seed)`。
4. `examples/basic_runtime/` に runtime 生成サンプル。
5. tests（同 seed 再現 / 別 seed で別 map / 外部依存なし）。

fallback/mirror: なし。
