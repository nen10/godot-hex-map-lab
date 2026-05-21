# EditorPlugin 実装計画

## 目的

Hex Map Kit を Godot 4 EditorPlugin として利用できる状態にする。
EditorPlugin は map data resource、TileMapLayer 表示、distribution 編集、atlas TileSet セットアップをエディタ上で接続する。


### ユーザーレビュー残件

`docs/plan/REMAINS_FROM_USER_REVIEW.md` の EditorPlugin 関連項目は実装済みとして整理する。

- [x] orientation 変更時の Tile Size swap
- [x] Tile Size / Floor / Wall SpinBox 変更時の即時 apply
- [x] 複数 `TileMapLayer` の Target 選択 UI
- [x] Distribution Editor の recent custom `.tres`
- [x] Distribution Editor の preset 複製保存 flow

テスト:

- `tests/test_editor_plugin.gd`


## 完了条件

- `docs/complete_on_test/EDITOR_PLUGIN.md` の実装済み項目が `tools/test.sh` で通る
- headless test できない editor lifecycle は UI workflow と検証観点を manual / plan に記録する
