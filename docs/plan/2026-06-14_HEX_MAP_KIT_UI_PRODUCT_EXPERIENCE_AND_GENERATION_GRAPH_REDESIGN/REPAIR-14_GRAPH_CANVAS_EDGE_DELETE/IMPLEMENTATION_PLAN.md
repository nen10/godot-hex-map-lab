# REPAIR-14 Implementation Plan

## Scope

Graph canvas edge deletion interaction の事前計画。

この文書は実行ログではない。

## target files

想定:

- `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
- `tests/test_build_graph_canvas.gd`
- `tests/test_build_screen_full.gd`

## planned implementation steps

1. edge hit testing / selection state を追加する。
2. selected edge highlight を描画または snapshot に出す。
3. Delete key action を edge selection に対応させる。
4. `Delete Edge` visible action を追加する。
5. edge delete 後に graph revision / dirty downstream / validation を更新する。
6. node delete と edge delete の action を分離して test する。

## dependency / test matrix

| dependency / area | risk | proof / test |
|---|---|---|
| edge hit test | edge が選べない | select edge test |
| keyboard action | node が誤削除される | selected edge delete only |
| toolbar action | button が常時有効 | enabled/disabled test |
| dirty propagation | stale output のまま | downstream dirty test |

## planned completion criteria

- edge を選択し、Delete key で削除できる。
- visible button でも削除できる。
- node selection / deletion と混同しない。
- edge delete 後の graph snapshot に connection removal と dirty state が出る。

