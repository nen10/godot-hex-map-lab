# EditorPlugin 実装計画

## 目的

Hex Map Kit を Godot 4 EditorPlugin として利用できる状態にする。


## draft plan

### 生成機能の拡張

- 大きいマップ生成時、待ち時間がながい。
  - -> 読み込み時間のプログレスバー表示/生成キャンセル機能

### タイルセット管理機能

- マップ上に配置可能なタイル等の画像アセットの管理機能
  - Godotの既存機能と連携できる範囲を活用する方針で実装したい。
  - 可能な範囲・有用な機能をリストアップし、それぞれに計画を立てて進める。

### マップのマニュアル編集機能

方針案であり、より一般的な枠組みや既存機能があれば、効率的な実装を採用する

- マップ形状編集機能
- 壁の配置(座標情報)の編集機能 (マップのペイント機能 - 壁有無)
  - -> リソースとして保存(保存したいLayerをDock上で選択?)
- 座標ごとの壁タイル画像編集機能 (ペイント機能 - タイル画像選択)
- 座標ごとの床タイル画像編集機能 (ペイント機能 - タイル画像選択)
- 座標ごとのオブジェクト編集機能 (ペイント機能 - )

  - ラベル付き座標の編集・保存機能
  - ラベルはタイルチップ画像データベースと連携する
  - マップオブジェクトデータベース作成機能 - オブジェクト番号ごとに、画像を対応させる。
    - 非表示のContainerノードシーンとして用意しオブジェクトをまとめて管理するとか？
    - Godot UIを活用したノードシーン作成を前提として、それを読み込む形でデータベースを作成するとしても良いが、効率的なものがいい。
- Undo/Redo 対応


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
- [x] `Generation Radius <= 2` は distribution 参照ではなく `Wall Prob` 直接生成として完了する
- [x] Seed 固定生成
- [x] Restore Connectivity
- [x] Stats 表示
- [x] `.tres` 保存 flow

### テスト

- `tests/test_hex_map_generation.gd`
  - minimum radius の対称生成
  - protected floor
  - connected check
- `tests/test_editor_plugin.gd`
  - Dock から Symmetric Hexagon radius 1 / 2 を生成
  - Stats に generator name が反映される

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
- [x] `Save New...`
- [x] `Apply`
- [x] `Cancel` と window close

### テスト

- `tests/test_editor_plugin.gd`
  - preset values
  - resource load values
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

- [x] Apply Layer button
- [x] Generate & Apply button
- [x] 選択中の `TileMapLayer` を優先
- [x] scene 内の最初の `TileMapLayer` を fallback
- [x] TileSet 設定 helper
- [x] floor/wall source / atlas 設定
- [x] flat-top / pointy-top と TileOffsetAxis の対応
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
  - Dock が `TileMapLayer` の `TileSet` を作成・設定する
  - Generate & Apply が現在の control 値で再生成してから apply する

## 5. HexMapResource Inspector

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

## REMAINS への移動方針

コード上で headless test しにくい視覚確認、UI ワークフロー検討、runtime gameplay 機能、公開用 documentation 整備は `docs/plan/REMAINS_FROM_USER_REVIEW.md` または `docs/plan/REMAINS_NON_EDITOR_PLUGIN.md` に置く。

