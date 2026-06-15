# SCREEN-41 IMPLEMENTATION_PLAN（pre-execution）

## Scope
Layers を role stack 視覚化へ。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/editor/hex_map_layers_screen.gd
tests/test_editor_layer.gd
```

## 構成（DESIGN-10）
- role stack tree: terrain/overlay/object/debug 等の role 行。
- 各行 chip/toggle: visible / lock / writable-source / z-index。並べ替え可。
- inspector: 選択 role 編集（writable source option / z spin / visible・lock check）。
- empty: `[Create Layer Stack] [Choose Layer Stack]`。

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| 視覚 stack | テキスト要約のまま | 先頭が role 行の視覚 stack |
| 属性 | chip 化せず | visible/lock/writable/z が chip/toggle |
| 編集反映 | 反映されない | role 編集が Layer Stack / selected node に反映 |
| empty | ラベル | 未設定で CTA |

## Planned steps
stack tree → chip/toggle → inspector → empty → tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task SCREEN-41 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: role stack 視覚 / visible・lock・writable・z を chip/toggle。
- E: role stack が視覚的に並び、writable source が分かる。
- `./tools/test.sh` green。
