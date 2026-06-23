# REPAIR-15 Implementation Plan

## Scope

Markov / adjacency mapping の事前計画。

この文書は実行ログではない。

## target files

想定:

- `addons/hex_map_kit/generation/`
- `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
- `tests/test_editor_generation.gd`
- `tests/test_editor_distribution.gd`
- `tests/test_generation_graph.gd`
- `tests/test_generation_promote.gd`

## planned implementation steps

1. 旧 Generate の Markov / adjacency 関連 state と params を列挙する。
2. 各項目を `Wall Field` / `Connectivity` / `Item Generator` / `Overlay Filter` に対応付ける。
3. UI control key、graph param key、runner read key の一致を監査する。
4. adjacency rule の invalid / valid 表示を graph inspector に移す。
5. seed / topology / rule 変更が output 差分を生む test を作る。

## dependency / test matrix

| dependency / area | risk | proof / test |
|---|---|---|
| REPAIR-13 filter split | overlay reference が曖昧 | typed filter connection test |
| Wall Field runner | Markov params が効かない | wall output delta test |
| Item Generator runner | adjacency rules が効かない | item placement delta test |
| state evaluator | old mode constraints が消える | invalid state warning test |
| seed handling | reproducibility が壊れる | same seed / different seed tests |

## planned completion criteria

- Markov / adjacency mapping matrix が実装と一致する。
- UI で設定した params が runner に伝達される。
- invalid adjacency rule が Generate 前に分かる。
- adjacency rule 変更が生成結果に反映される。

