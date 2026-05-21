# REMAINS_FROM_USER_REVIEW.md

ユーザーレビュー由来の残件のうち、EditorPlugin と直接関係する検討項目を置く。


## 3. EDITOR PLUGIN

### 3.1 MAP GENERATION DOCK

対象:

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`

実装済み:

- [x] Editor Dock 上で `pointy-top` / `flat-top` を切り替えたとき、`Tile Size` の width / height SpinBox 値を入れ替える。
- [x] `Tile Size` / `Floor` / `Wall` の SpinBox 値を更新したとき、選択中の `TileMapLayer` へ現在の map data を即時 apply する。
- [x] 複数 `TileMapLayer` が scene にある場合、Dock の `Target` OptionButton で apply 先を選択する。
- [x] `Refresh` で scene root 以下の `TileMapLayer` 一覧を再読み込みする。

テスト:

- `tests/test_editor_plugin.gd`
  - orientation 変更時の Tile Size swap
  - 複数 `TileMapLayer` の一覧化
  - 選択中 `TileMapLayer` だけへ SpinBox 変更が即時 apply されること

### 3.2 DISTRIBUTION EDITOR

対象:

- `addons/hex_map_kit/editor/hex_dist_editor.gd`

実装済み:

- [x] preset は `Preset` OptionButton で一覧管理する。
- [x] custom `.tres` は `Load .tres` と `Recent` OptionButton で一覧管理する。
- [x] custom `.tres` を保存または読み込んだとき、最近使った custom distribution として記録する。
- [x] `Duplicate Preset...` から現在の preset 値を custom `.tres` として保存する。

テスト:

- `tests/test_editor_plugin.gd`
  - preset 値を custom `.tres` として保存できること
  - 保存した custom `.tres` が recent list に入ること
  - recent list から custom distribution を再読み込みできること

### 3.3 ADAPT TILE_MAP_LAYER

対象:

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`

実装済み:

- [x] Dock の `Target` 選択と SpinBox 即時 apply により、TileMapLayer 側の atlas 表示確認フローを EditorPlugin から扱う。
