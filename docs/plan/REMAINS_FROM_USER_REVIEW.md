# REMAINS_FROM_USER_REVIEW.md

ユーザーレビュー由来の残件のうち、EditorPlugin と直接関係する検討項目を置く。


## 3. EDITOR PLUGIN

### 3.1 MAP GENERATION DOCK

`addons/hex_map_kit/editor/hex_map_gen_dock.gd`

- Editor Dock上で [pointy-top, flat-top] を切り替え時に、合わせてTileSizeの二つのSpinBox value : x, yを入れ替えるようにしたいです。

- タイルセット管理機能:
  - floor, wallのSpinBoxの値を更新するたび、applyを実行します(タイル画像を即座に確認したい)

- Apply Layer の操作 flow
  - 複数 `TileMapLayer` が scene にある場合の選択 UI


### 3.2 DISTRIBUTION EDITOR

`addons/hex_map_kit/editor/hex_dist_editor.gd`

- distribution 管理の整理
  - preset と custom `.tres` の一覧管理
  - 最近使った custom distribution
  - preset から複製して保存する flow

### 3.3 ADAPT TILE_MAP_LAYER


