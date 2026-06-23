# REPAIR-13 Implementation Plan

## Scope

Graph-wide state model、param propagation audit、Terrain Filter / Overlay Filter 分離を実装へ進めるための事前計画。

この文書は実行ログではない。

## target files

想定:

- `addons/hex_map_kit/generation/`
- `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd`
- `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
- `tests/test_generation_graph.gd`
- `tests/test_generation_promote.gd`
- `tests/test_build_screen_full.gd`
- `tests/test_build_graph_canvas.gd`

## planned implementation steps

1. graph edit state から derived graph state を計算する evaluator の owner を決める。
2. node schema に input type / output type / required params / param validity を定義する。
3. UI param change が graph revision と dirty downstream を必ず更新するようにする。
4. `Region Filter` を `Terrain Filter` / `Overlay Filter` へ分離する。
5. Overlay Filter の item key 候補を upstream planned / actual overlay keys から導出する。
6. Generate 前に invalid / unconfigured / stale state を評価する。
7. `Generate -> Apply -> Generate` で初めて viewport が出る状態を回帰として test する。

## dependency / test matrix

| dependency / area | risk | proof / test |
|---|---|---|
| graph resource | derived state が保存 state と混ざる | derived state is recomputed |
| param propagation | UI値が runner に届かない | audit matrix test |
| dirty propagation | stale cache で成功扱い | dirty downstream test |
| Terrain Filter | overlay input を誤許可 | invalid connection test |
| Overlay Filter | item key 候補が出ない | planned/actual item key test |
| Generate preview | Apply が projection 発生源になる | Generate-only viewport test |

## planned completion criteria

- fixed FSM ではなく derived graph state として状態が計算される。
- 全 node の主要 params が UI -> graph -> runner -> output -> viewport で監査される。
- Terrain Filter と Overlay Filter の input 型が分かれる。
- Overlay Filter の item key は raw text ではなく upstream 由来候補になる。
- Generate 単体で projection が起き、Apply は pending preview の確定だけを行う。

## scheduled follow-up

| follow-up | reason |
|---|---|
| `REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING` | Source typing と node add row は UI layout task として分離する。 |
| `REPAIR-15_MARKOV_ADJACENCY_MAPPING` | old Generate の Markov / adjacency parity は state model 完了後に扱う。 |

