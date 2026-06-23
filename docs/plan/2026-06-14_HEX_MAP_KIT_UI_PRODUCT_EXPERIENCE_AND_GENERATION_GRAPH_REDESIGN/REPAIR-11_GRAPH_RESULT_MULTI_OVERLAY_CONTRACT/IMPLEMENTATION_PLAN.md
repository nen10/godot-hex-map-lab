# REPAIR-11 Implementation Plan

## Scope

`Result` node の multi-overlay contract を実装するための事前計画。

この文書は実行ログではない。

## target files

想定:

- `addons/hex_map_kit/generation/`
- `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd`
- `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
- `tests/test_generation_promote.gd`
- `tests/test_build_screen_full.gd`
- `tests/test_build_graph_canvas.gd`

## planned implementation steps

1. Result node schema を `terrain` required + `overlay_inputs[]` optional にする。
2. graph validation で `result -> Result` を invalid にする。
3. runner / promote path で複数 overlay を保持する。
4. projection report に overlay count / overlay layer paths を追加する。
5. Apply/Revert snapshot に overlay document state を含める。
6. inspector / snapshot に Result overlay inputs を表示する。

## dependency / test matrix

| dependency / area | risk | proof / test |
|---|---|---|
| graph resource save/load | overlay_inputs が失われる | save/load round-trip |
| runner cache | overlay output が1つに潰れる | multi-overlay cache test |
| document projection | overlay が別 layer で残らない | document layer count proof |
| viewport preview | terrain だけ表示される | viewport overlay proof |
| Apply/Revert | overlay snapshot 漏れ | revert restores overlay state |

## planned completion criteria

- Result multi-overlay graph が保存・読込後も同じ接続を持つ。
- Generate 単体で terrain + N overlay が viewport に出る。
- Apply 後に overlay が別 generated overlay として inspect できる。
- Revert 後に前状態へ戻る。
- `Compose` を primary flow に戻さない。

