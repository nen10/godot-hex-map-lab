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
- [x] `Target` OptionButton は `Auto: Selected / first scene layer`、scene root 以下の短い `TileMapLayer` 名、`Add new layer...` を常に表示する。
- [x] `Target` の `Refresh` 後も `Auto: Selected / first scene layer` を保持する。
- [x] `Orientation` / `Tile Size` / `Floor` / `Wall` / atlas setup の即時 apply は Godot Editor の Scene Tree で選択中の `TileMapLayer` だけを対象にする。
- [x] `Add new layer...` は scene root 直下に新しい `TileMapLayer` を作成し、そのレイヤーを Target と Scene Tree 選択にする。
- [x] 共有 `TileSet` を持つ複数レイヤーで、Dock から選択中レイヤーの TileSet 設定を変更する前に対象レイヤー側の `TileSet` を複製する。

テスト:

- `tests/test_editor_plugin.gd`
  - orientation 変更時の Tile Size swap
  - `Target` の Auto / 短い layer 名 / `Add new layer...` 一覧化
  - `Refresh` 後の Auto 項目保持と選択中 Target 維持
  - Scene Tree 選択中 `TileMapLayer` だけへ SpinBox / sample atlas 変更が即時 apply されること
  - 共有 `TileSet` が選択中レイヤー側で複製されること
  - `Add new layer...` が scene root 直下に `TileMapLayer` を作ること

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
