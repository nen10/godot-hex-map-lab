# EditorPlugin Manual

Hex Map Kit の EditorPlugin は、エディタ上で `HexMapResource` を生成・保存し、シーン内の `TileMapLayer` へ反映するための Dock と Inspector 拡張を提供します。

## 1. 有効化

`project.godot` の `[editor_plugins]` に plugin が登録されていることを確認します。

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
```

Godot エディタ起動後、Dock に **Hex Map Kit** が表示されます。

## 2. Map Generation Dock

Dock は現在のパラメータを変更すると即時に `_current_data` を再生成します。`Generate` ボタンは同じ設定で明示的に再生成するときに使います。

### Generator

`Generator` で生成方式を選びます。

- `Simple`: 独立乱数で壁を置く基本生成
- `Hex-inward Markov mesh model`: 外周から中心へ進む対称生成

### Simple

`Simple` では `Shape` とサイズを指定します。

- `Hexagon`: `Radius`
- `Rectangle`: `Width`, `Height`

生成 API は `HexMapGenerator.generate_hexagon()` または `generate_rectangle()` です。

### Hex-inward Markov Mesh Model

対称生成では `Shape` と `Generation Radius` を指定します。

- `Hexagon`: 対称 toric square の外周側 split 0 / split 7 を除いた hex 領域
- `Square`: non-toric square
- `Torus`: toric square

`Generation Radius` は `map_unit_radius` です。square / torus の一辺は `2 * radius + 1` になります。`Generation Radius = 1 / 2` では安定した参照リングが存在しないため、distribution ではなく `Wall Prob` で直接壁を生成します。

### Distribution

対称生成時は `Dist` で preset を選びます。`Edit` を押すと Distribution Editor が開きます。

Preset は `HexRandomizer.get_preset_names()` の順に表示されます。preset を選んでいる場合は、生成時に preset id を `HexMapGenerator` へ渡します。`.tres` を保存・読み込みした場合は `HexDistribution` resource を custom distribution として渡します。

### 共通パラメータ

- `Wall Prob`: 壁確率。0.00 から 1.00
- `Seed`: 乱数シード
- `Rand`: seed をランダム更新
- `Restore Connectivity`: floor 全体の連結性回復

`Restore Connectivity` が有効な場合、生成後に `HexMapGenerator.restore_connectivity()` が実行されます。`HexVector.zero()` は protected floor として扱われます。

### Stats

Stats は以下を表示します。

```text
Shape  seed=1201  wall_prob=0.45  cells=48  walls=12  floors=36  connected=yes  Generator Name
```

`connected` は現在の `HexMapData` に対する `HexMapGenerator.is_floor_connected()` の結果です。

### Generation Progress

Dock は生成処理の状態を `generation_status()` と progress UI に保持します。

- `running`: 生成中かどうか
- `cancel_requested`: `Cancel` が押されたかどうか
- `progress`: 0.0 から 1.0
- `status`: `Generating` / `Preparing` / `Updating` / `Ready` / `Cancel requested` / `Cancelled`

現在の生成 API は同期処理です。`Cancel` は実行中状態に cancel request を記録しますが、重い生成をフレーム途中で中断するには、生成器を async / chunked 実行へ分割する必要があります。

### TileMapLayer Settings

`Apply Layer` で使う TileMapLayer 設定を Dock から指定できます。

| 設定 | 内容 |
|---|---|
| `Orientation` | `flat-top / Vertical Offset` または `pointy-top / Horizontal Offset` |
| `Tile Size` | `TileSet.tile_size` に設定する width / height |
| `Floor` | floor tile の `source_id`, `atlas_x`, `atlas_y` |
| `Wall` | wall tile の `source_id`, `atlas_x`, `atlas_y` |

`Orientation` は `HexMapResource` に保存されます。`Apply Layer` / `Generate & Apply` はこの orientation を正として、対象 `TileMapLayer.tile_set` と `set_cell()` 用の cell 座標を同時に設定します。

TileSet は以下に設定されます。

```text
tile_shape = TILE_SHAPE_HEXAGON
tile_layout = TILE_LAYOUT_STACKED
tile_offset_axis = TILE_OFFSET_AXIS_VERTICAL    # flat-top
tile_offset_axis = TILE_OFFSET_AXIS_HORIZONTAL  # pointy-top
```

TileSet が未設定の `TileMapLayer` へ適用した場合は、新しい `TileSet` を作成してから設定します。
Apply 後に TileMapLayer Inspector 側だけで `Horizontal Offset` / `Vertical Offset` を手動変更する経路は管理対象外です。

Godot 側の対応 API は公式ドキュメントの `TileMapLayer`、`TileSet`、`TileSetAtlasSource` を参照します。

- https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html
- https://docs.godotengine.org/en/stable/classes/class_tileset.html
- https://docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html

### Atlas Image

`Select Atlas Image` は resource path の画像を読み込み、対象 `TileMapLayer.tile_set` に `TileSetAtlasSource` を作成します。source id は Dock の `Floor` source を使い、floor / wall の atlas coords と `Tile Size` を TileSetAtlasSource に反映します。設定後は `Wall` source も同じ source id に同期されます。

`Use Sample Tiles` は addon 同梱の `addons/hex_map_kit/assets/sample_hex_tiles.png` を使うショートカットです。sample は `source_id=0`、floor `Vector2i(0, 0)`、wall `Vector2i(1, 0)`、tile size `64 x 57` に設定します。

### Buttons

- `Generate`: 現在の設定で再生成
- `Cancel`: 実行中 generation に cancel request を記録
- `Save .tres`: `HexMapResource` として保存
- `Apply Layer`: 選択中の `TileMapLayer`、または編集中 scene の最初の `TileMapLayer` に現在の map を適用
- `Generate & Apply`: 現在の設定で再生成してから `Apply Layer` と同じ設定で反映
- `Select Atlas Image`: 画像 resource を `TileSetAtlasSource` として対象 `TileMapLayer` に設定
- `Use Sample Tiles`: addon 同梱 sample atlas を対象 `TileMapLayer` に設定

`Apply Layer` は `HexMapTileAdapter.apply_to_tile_map_layer()` を使います。表示するには、対象 `TileMapLayer` の `TileSet` 側に、Dock で指定した floor / wall の source と atlas coords に対応する tile を用意します。

## 3. Distribution Editor

Distribution Editor は `HexDistribution` の 3-neighbor / 2-neighbor / 1-neighbor table を編集します。

### 表示

各 pattern は、参照セルの floor/wall 状態と、中央セルの生成値を表示します。SpinBox の値は 0.0 から 8.0 で、生成確率は `value / 8.0` です。

中央セルの色は以下です。

```text
brightness = 0.9 - value / 10.0
```

値が大きいほど暗く表示されます。

### Preset

Window 起動時は preset の値が SpinBox に入ります。`Preset` を変更すると、現在の編集 path はクリアされ、preset 値が再読み込みされます。

### Load / Save

- `Load .tres`: `HexDistribution` resource を読み込み、SpinBox に反映
- `Save New...`: 現在値を新しい `.tres` として保存
- `Apply`: 読み込み済み path へ保存し、Map Generation Dock へ適用
- `Cancel` または window close: 保存せず閉じる

保存後は FileSystem scan が実行されます。

## 4. HexMapResource Inspector

`HexMapResource` を Inspector で選択すると、先頭に以下の summary が表示されます。

```text
cells=49  walls=20  floors=29  connected=yes  orientation=flat-top  torus=7x7
```

この表示は `resource.to_map_data()` の結果をもとに算出されます。
