# EditorPlugin 実装済み項目


## 作成済みファイル

- `addons/hex_map_kit/plugin.cfg`
- `addons/hex_map_kit/plugin.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_dist_editor.gd`
- `addons/hex_map_kit/editor/hex_map_resource_inspector.gd`
- `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
- `addons/hex_map_kit/adapter/hex_map_resource.gd`

## 1. EditorPlugin 基盤

### 入力

- Godot editor の plugin lifecycle
- `plugin.cfg`

### 出力

- `HexMapGenDock` を Dock に追加/削除する
- `HexMapResource` 用 inspector plugin を追加/削除する

### 実装状況

- [x] `plugin.cfg` 登録
- [x] `plugin.gd` の `_enter_tree()` / `_exit_tree()`
- [x] Dock 追加/削除
- [x] InspectorPlugin 追加/削除

### テスト

`EditorPlugin` の Dock 操作 lifecycle は editor 専用のため、headless では登録 metadata と script load を検証する。

- `tests/test_editor_plugin.gd`
  - `plugin.cfg` load
  - plugin script load

## 2. Map Generation Dock

### 入力

- `Generator`
  - `Simple`
  - `Hex-inward Markov mesh model`
- `Shape`
  - Simple: `Hexagon`, `Rectangle`
  - Symmetric: `Hexagon`, `Square`, `Torus`
- size
  - Simple Hexagon: `Radius`
  - Simple Rectangle: `Width`, `Height`
  - Symmetric: `Generation Radius`
- `Wall Prob`
- `Seed`
- `Restore Connectivity`
- Distribution
  - preset id
  - custom `HexDistribution` resource

### 出力

- `_current_data: HexMapData`
- Stats label
  - shape
  - seed
  - wall probability
  - cells / walls / floors
  - connected
  - generator name
- `HexMapResource` `.tres`

### 実装状況

- [x] Simple Rectangle / Hexagon
- [x] Symmetric Hexagon / Square / Torus
- [x] `Generation Radius <= 2` も larger radius と同じ対称生成フローで完了する
- [x] Seed 固定生成
- [x] Restore Connectivity
- [x] Stats 表示
- [x] Dock 内 progress UI と `generation_status()` による生成状態保持
- [x] `Generate` ボタン実行時だけ生成し、Dock 内 progress を出す
- [x] 生成入力の変更、focus exit、seed randomize、distribution 変更では生成しない
- [x] Core cancel callback へ接続した実行中 generation の cancel request 状態保持
- [x] `.tres` 保存 flow

### テスト

- `tests/test_hex_map_generation.gd`
  - minimum radius の対称生成
  - protected floor
  - connected check
- `tests/test_editor_plugin.gd`
  - Dock から Symmetric Hexagon radius 1 / 2 を生成
  - Stats に generator name が反映される
  - Dock 内 progress / running / cancel request / status が更新される
  - `Generate` ボタン実行時は短時間生成でも Dock 内 progress が表示される
  - 表示済み Dock 内 progress は成功直後に即非表示にせず、最短表示時間後に非表示にする
  - Generate flow では modal progress window を生成しない
  - 生成入力の値変更、focus exit、seed randomize、distribution 変更では生成しない
  - Core progress callback と cancel callback が Dock に接続される
  - cancel 時に partial data が current map へ反映されない

実装:

- [x] 入力 control から `_current_data` を生成する
- [x] stats label に shape / seed / wall probability / cell count / wall count / floor count / connected / generator name を表示する
- [x] `current_resource()` で orientation 付き `HexMapResource` を出力する
- [x] Dock 内 progress UI と `generation_status()` に `running` / `cancel_requested` / `progress` / `status` を保持する
- [x] Dock 内 progress は `Generate` ボタン実行時に表示し、成功後の非表示まで最低 0.8 秒待つ
- [x] SpinBox / OptionButton / Slider / CheckButton の生成入力変更では自動生成しない
- [x] `Cancel` で実行中 generation の cancel request 状態を保持し、Core cancel callback に伝える

テスト:

- `tests/test_hex_map_generation.gd`
- `tests/test_editor_plugin.gd`


### タイルセット管理機能

入力:

- `TileMapLayer`
- orientation
- tile size
- floor / wall source id
- floor / wall atlas coords
- atlas image resource path
- sample atlas image

出力:

- `TileSet`
- `TileSetAtlasSource`
- floor / wall tile 設定
- `TileMapLayer` cell

実装:

- [x] `TileSet.tile_shape = TILE_SHAPE_HEXAGON`
- [x] `TileSet.tile_layout = TILE_LAYOUT_STACKED`
- [x] flat-top は `TILE_OFFSET_AXIS_VERTICAL`
- [x] pointy-top は `TILE_OFFSET_AXIS_HORIZONTAL`
- [x] Dock の source id / atlas coords を `TileMapLayer.set_cell()` に渡す
- [x] orientation 切り替え時に Tile Size width / height を入れ替える
- [x] 複数 `TileMapLayer` を Target OptionButton で選択する
- [x] Tile Size / Floor / Wall の SpinBox 変更時に選択中 `TileMapLayer` へ即時 apply する
- [x] `Select Atlas Image` で画像 resource path から `TileSetAtlasSource` を作成する
- [x] `Use Sample Tiles` で sample atlas を設定する
- [x] atlas 画像に関する Godot 公式ドキュメントへのリンクと Dock 項目との関係を `docs/manual/MANUAL_EDITOR_PLUGIN.md` に記録する

テスト:

- `tests/test_hex_adapter.gd`
- `tests/test_editor_plugin.gd`
  - Tile Size swap
  - 複数 `TileMapLayer` の一覧化
  - 選択中 `TileMapLayer` への SpinBox 即時 apply

## 3. Distribution Editor

### 入力

- `HexRandomizer` preset
- `HexDistribution` `.tres`
- 3-neighbor / 2-neighbor / 1-neighbor SpinBox 値

### 出力

- `HexDistribution`
  - `distribution_3: Array[float]`
  - `distribution_2: Array[float]`
  - `distribution_1: Array[float]`
- pattern preview color
  - `brightness = 0.9 - value / 10.0`

### 実装状況

- [x] preset 値を SpinBox に表示
- [x] `.tres` 読み込み値を SpinBox に表示
- [x] SpinBox 更新時に pattern preview を redraw
- [x] `Recent` で custom `.tres` 一覧を表示
- [x] 保存 / 読み込みした custom `.tres` を recent list に記録
- [x] `Duplicate Preset...` で preset を custom `.tres` として保存
- [x] `Save New...`
- [x] `Apply`
- [x] `Cancel` と window close

### テスト

- `tests/test_editor_plugin.gd`
  - preset values
  - resource load values
  - duplicate preset save
  - recent custom distribution list
  - center color
  - close button cancel flow

## 4. TileMapLayer 連携

### 入力

Dock に TileMapLayer 適用用の設定を持つ。

- Orientation
  - `flat-top / Vertical Offset`
  - `pointy-top / Horizontal Offset`
- `Tile Size`
  - width
  - height
- floor tile
  - source id
  - atlas x
  - atlas y
- wall tile
  - source id
  - atlas x
  - atlas y

### TileSet 設定

対象が `TileMapLayer` の場合:

- `TileSet.tile_shape = TileSet.TILE_SHAPE_HEXAGON`
- `TileSet.tile_layout = TileSet.TILE_LAYOUT_STACKED`
- `flat-top` は `TileSet.TILE_OFFSET_AXIS_VERTICAL`
- `pointy-top` は `TileSet.TILE_OFFSET_AXIS_HORIZONTAL`
- `TileSet.tile_size = Vector2i(width, height)`

TileSet が未設定の場合は新しい `TileSet` を作る。
orientation は `HexMapResource` に保存し、Dock / Resource 側を表示レイアウトの管理主体とする。

### TileMapLayer への出力

`HexMapTileAdapter.apply_to_tile_map_layer()` へ以下を渡す。

- `layer`
- `_current_data`
- floor source id
- floor atlas coords
- wall source id
- wall atlas coords
- flat-top / pointy-top orientation

### 実装状況

- [x] Generate 後の自動 apply
- [x] Apply Layer button による手動再反映
- [x] 選択中の `TileMapLayer` を優先
- [x] scene 内の最初の `TileMapLayer` を fallback
- [x] scene 内の複数 `TileMapLayer` を Target OptionButton で選択
- [x] TileSet 設定 helper
- [x] floor/wall source / atlas 設定
- [x] floor/wall source / atlas 設定変更時の即時 apply
- [x] flat-top / pointy-top と TileOffsetAxis の対応
- [x] flat-top / pointy-top 切り替え時の Tile Size swap
- [x] `HexMapResource` への orientation 保存

### テスト

- `tests/test_hex_adapter.gd`
  - `configure_hex_tile_set()`
  - flat-top / pointy-top の TileMapLayer offset cell 変換
  - TileShape Hexagon
  - TileLayout Stacked
  - flat-top -> Vertical Offset
  - pointy-top -> Horizontal Offset
  - tile size
  - `HexMapResource` orientation roundtrip
- `tests/test_editor_plugin.gd`
  - Dock の floor/wall source / atlas 設定が apply に渡る
  - Dock の orientation が resource と apply に反映される
  - Dock の orientation 変更時に Tile Size が入れ替わる
  - Dock の Target 選択が apply 先を切り替える
  - Dock の SpinBox 変更が選択中 `TileMapLayer` に即時反映される
  - Dock が `TileMapLayer` の `TileSet` を作成・設定する
  - Generate 後に現在の control 値で再生成した map が選択中 `TileMapLayer` へ自動 apply される
  - Dock に `Apply Layer` button が残り、`Generate & Apply` button が存在しない

## 5. Atlas / Sample TileSet 管理

### 入力

- sample atlas image
  - `addons/hex_map_kit/assets/sample_hex_tiles.png`
  - 画像サイズ: `128 x 57`
  - region size: `64 x 57`
  - floor tile: atlas `Vector2i(0, 0)`
  - wall tile: atlas `Vector2i(1, 0)`
- 対象 `TileMapLayer`
- Dock の orientation
- 任意 atlas image resource path
- source id / floor atlas coords / wall atlas coords

### 出力

- 対象 `TileMapLayer.tile_set`
- sample 用 source id `0` の `TileSetAtlasSource`
- Dock の Tile Size / Floor / Wall control
- 任意 source id の `TileSetAtlasSource`

### 実装状況

- [x] sample atlas image を addon asset として作成
- [x] sample atlas 生成用 tool を `tools/create_sample_hex_tiles.gd` に作成
- [x] `HexMapTileAdapter.configure_atlas_tile_set()` で任意 texture から atlas source を作成
- [x] `HexMapTileAdapter.configure_sample_tile_set()` で sample atlas source を作成
- [x] Dock の `Select Atlas Image` で画像 resource path を `TileSetAtlasSource` として設定
- [x] Dock の `Use Sample Tiles` で選択中 `TileMapLayer` に sample TileSet を設定
- [x] sample setup 後に Dock の Tile Size / Floor / Wall control を sample 値へ同期
- [x] atlas setup 後に Dock の Tile Size / Floor / Wall control を atlas 値へ同期

### テスト

- `tests/test_hex_adapter.gd`
  - sample atlas image が存在し、`128 x 57` の PNG として読める
  - sample TileSet に source id `0` が作成される
  - floor / wall atlas tile が作成される
- `tests/test_editor_plugin.gd`
  - Dock から atlas image path / source id / atlas coords を `TileMapLayer` に設定できる
  - Dock から sample TileSet を `TileMapLayer` に設定できる
  - Dock の orientation が sample TileSet の TileOffsetAxis に反映される
  - Dock の Tile Size / Floor / Wall control が sample 値へ同期される

## 6. HexMapResource Inspector

### 入力

- `HexMapResource`

### 出力

- cells
- walls
- floors
- connected
- torus size

### 実装状況

- [x] `HexMapResource` を handle
- [x] `resource.to_map_data()` の summary を表示

### テスト

`EditorInspectorPlugin` の実体生成は editor 専用で headless test できないため、表示に使う data path をテストする。

- `tests/test_hex_adapter.gd`
  - `HexMapResource` roundtrip
