# REPAIR-13A Implementation Plan

## Scope

node add row と Source typing UI の事前計画。

この文書は実行ログではない。

## target files

想定:

- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
- `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
- `addons/hex_map_kit/generation/`
- `tests/test_build_screen_full.gd`
- `tests/test_build_graph_canvas.gd`

## planned implementation steps

1. graph 下部に node add row を置く。
2. button group を `Anchor / Build / Select` に分ける。
3. `Source Terrain` / `Source Overlay` を追加 entry として用意する。
4. Source node の `output_type` を header / inspector に出す。
5. old palette が primary entry として残らないことを確認する。
6. visual snapshot / UI snapshot に row group と Source typing を含める。

## dependency / test matrix

| dependency / area | risk | proof / test |
|---|---|---|
| REPAIR-13 state model | output type が UI とずれる | Source typing snapshot |
| layout | row が狭く読みづらい | readable text snapshot |
| graph canvas | button click が node add に通らない | add node test |
| Source inspector | output type が見えない | inspector snapshot |

## planned completion criteria

- `Source Terrain` / `Source Overlay` を row から追加できる。
- row は graph の下にあり、group 表示される。
- `Compose` は primary row にない。
- Source output type が接続 validation と一致する。

