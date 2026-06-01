# Tile / Object 管理方法の調査

## 目的

現状の EditorPlugin は、atlas 画像から `TileSetAtlasSource` を作成し、floor / wall の `source_id` と `atlas_coords` を `TileMapLayer.set_cell()` に渡している。

この調査では、Godot 4 の機能を使って以下を整理する。

- Editor 上で作成したノードまたは scene を `TileMapLayer` に配置できるか
- 小さな scene node 群を atlas のように管理できるか
- Hex Map Kit で採用しやすい tile / object 管理案

## 結論

Editor で作成したノードは、`.tscn` として保存し、root が `CanvasItem` を継承していれば `TileSetScenesCollectionSource` に登録して `TileMapLayer` 上へ配置できる。

`TileSetScenesCollectionSource` は `TileSet` の source の一種で、scene を tile として公開する。配置された scene tile は、`TileMapLayer` が scene tree に入った後、フレーム終端に `TileMapLayer` の子として自動 instantiate される。すでに tree 内にある `TileMapLayer` で scene tile を追加または削除した場合も、対応する scene の生成と解放は自動で行われる。

ただし scene tile は配置数ごとに scene instance を作るため、atlas よりコストが高い。床・壁・大量の地形見た目は atlas のまま扱い、少数のインタラクティブ object、装飾、パーティクル、音源、トリガーなどを scene tile として別レイヤーに置く構成が妥当である。

## Godot の関連機能

### TileSetAtlasSource

現状の方式。画像 atlas を `TileSetAtlasSource` に登録し、`source_id` と `atlas_coords` で tile を指定する。

Hex Map Kit ではすでに以下が実装されている。

- `HexMapTileAdapter.configure_atlas_tile_set(tile_set, texture, flat_top, tile_size, source_id, tile_coords)`
- `HexMapTileAdapter.apply_to_tile_map_layer(layer, data, floor_source_id, floor_atlas_coords, wall_source_id, wall_atlas_coords, clear_layer, flat_top)`

大量セル向けの描画効率が高く、floor / wall の基本表示に向いている。

### TileSetScenesCollectionSource

scene を tile として扱う source。

使い方の要点:

- scene を別 `.tscn` として保存する
- scene root は `CanvasItem` 継承である必要がある
- `TileSet` に Scenes Collection を追加する
- scene slot に `PackedScene` を割り当てる
- TileMap editor では通常 tile のように paint できる
- GDScript では `TileSetScenesCollectionSource.create_scene_tile(packed_scene, id_override)` で登録できる

`TileMapLayer.set_cell()` で配置する場合、scene tile の指定は以下になる。

```gdscript
tile_map_layer.set_cell(cell, scene_source_id, Vector2i(0, 0), scene_tile_id)
```

`TileSetScenesCollectionSource` の場合、`atlas_coords` は常に `Vector2i(0, 0)` を使い、`alternative_tile` が scene ID を表す。

配置済み cell から scene を調べる場合:

```gdscript
var source_id = tile_map_layer.get_cell_source_id(cell)
if source_id > -1:
	var source = tile_map_layer.tile_set.get_source(source_id)
	if source is TileSetScenesCollectionSource:
		var scene_id = tile_map_layer.get_cell_alternative_tile(cell)
		var packed_scene = source.get_scene_tile_scene(scene_id)
```

注意点:

- scene tile はすべて 1 つの tile slot を占有し、scene の識別は `alternative_tile` ID で行う
- `get_cell_tile_data()` は atlas source 用で、scene source の cell では `null` になる
- instantiate は遅延されるため、直後に child を見る必要があるテストや editor tool では `update_internals()` または frame 待ちが必要になる
- `update_internals()` は高コストなので一括更新後の最小回数に留める
- 大量の floor / wall 見た目を scene tile にする用途には向かない

### TileMapLayer / 複数レイヤー

Godot 4 では `TileMap` は deprecated で、複数レイヤーは複数の `TileMapLayer` node で表現する。

Hex Map Kit では、地形と object を以下のように分けると扱いやすい。

- `TerrainLayer`: atlas source の floor / wall
- `ObjectLayer`: scene collection source の object / trigger / decoration
- `OverlayLayer`: path / marker / temporary preview

同一座標に複数 tile を重ねたい場合も、layer 分離が自然である。

### Custom data layers

`TileSet` は atlas tile に custom data layer を持てる。たとえば `kind`, `movement_cost`, `blocks_path`, `spawn_tag` のような値を tile 側に持たせられる。

制約として、custom data は `TileSet` 内の tile 定義に紐づくため、配置 instance ごとの個別値には向かない。配置ごとの差分は、別 tile / alternative tile / scene instance の export property / HexMapResource 側の object data で管理する。

### Terrains

Godot 4 の terrains は、atlas tile に地形接続情報を持たせ、隣接 tile に応じた variant を選ぶ仕組みである。

Hex Map Kit では以下の用途に検討できる。

- wall edge / floor edge の自動見た目選択
- water / ground / cliff など複数 terrain の接続
- 手描き編集時の隣接補正

一方で、現在の generator は floor / wall を data として確定し、それを `set_cell()` している。生成結果から terrain connect API を使う場合、Godot 側の terrain set が必要な組み合わせを十分に持つ必要がある。

### Alternative tiles

atlas tile には alternative tile を作れる。Godot 4.2 以降は TileMap editor で配置時に rotate / flip できるが、色、material、z index、texture origin、custom data が異なる variant を管理する場合は alternative tile が使える。

Hex Map Kit では、同じ floor 画像の色違い、wall variant、marker variant を atlas 内で増やす用途に向く。

### TileMapPattern

`TileMapPattern` は複数 cell の配置パターンを保存し、`TileMapLayer.set_pattern()` で貼り付けられる。半オフセット形状では単純な座標加算では貼り付け位置が合わないため、`TileMapLayer.map_pattern()` が用意されている。

Hex grid 上で建物、部屋、装飾群、入口周りなどの小さなまとまりを配置する場合、単一 scene tile ではなく pattern として扱う案がある。

## Hex Map Kit への採用案

### 案 A: 現状維持 + atlas source 強化

基本地形は現在の atlas flow を保つ。

追加候補:

- atlas source を複数登録できる UI
- floor / wall 以外の logical tile kind
- named tile preset
- custom data layer の読み取り
- alternative tile ID の指定

想定 interface:

```gdscript
{
	"name": "wall",
	"layer": "terrain",
	"source_id": 0,
	"atlas_coords": Vector2i(1, 0),
	"alternative_tile": 0
}
```

### 案 B: scene collection source を object layer に追加

object 用 `TileMapLayer` を作り、`TileSetScenesCollectionSource` を使って `.tscn` 群を配置する。

想定 object:

- treasure / shop / portal などの interactive object
- spawn point / trigger / area marker
- AudioStreamPlayer2D
- CPUParticles2D / GPUParticles2D
- animated decoration

想定 interface:

```gdscript
{
	"name": "shop",
	"layer": "object",
	"source_id": 1,
	"atlas_coords": Vector2i(0, 0),
	"alternative_tile": 100,
	"scene_path": "res://addons/hex_map_kit/objects/shop.tscn"
}
```

`HexMapTileAdapter` には、atlas tile と scene tile の両方を表す entry を返せる形を追加できる。

```gdscript
{
	"vector": hex,
	"layer": "object",
	"kind": "shop",
	"map_cell": Vector2i(...),
	"source_id": 1,
	"atlas_coords": Vector2i(0, 0),
	"alternative_tile": 100
}
```

### 案 C: HexTileCatalog resource

atlas と scene collection を横断して、logical name で tile / object を引ける `.tres` を作る。

目的:

- `floor_source_id` / `floor_atlas_coords` のような個別 UI を増やし続けない
- atlas tile と scene tile を同じ選択 UI で扱う
- generator が `kind` を返し、adapter が catalog から `set_cell()` 引数へ変換する

想定 resource schema:

```gdscript
class_name HexTileCatalog
extends Resource

@export var tile_set: TileSet
@export var entries: Array[HexTileCatalogEntry]
```

```gdscript
class_name HexTileCatalogEntry
extends Resource

@export var name: String
@export_enum("atlas", "scene") var source_type: String = "atlas"
@export var layer_name: String = "terrain"
@export var source_id: int = 0
@export var atlas_coords: Vector2i = Vector2i.ZERO
@export var alternative_tile: int = 0
@export_file("*.tscn") var scene_path: String
@export var tags: PackedStringArray = []
```

配置時の input:

```gdscript
{
	"hex": HexVector,
	"catalog_name": "shop"
}
```

配置時の output:

```gdscript
{
	"layer_name": "object",
	"map_cell": Vector2i,
	"source_id": int,
	"atlas_coords": Vector2i,
	"alternative_tile": int
}
```

### 案 D: scene instance を TileMapLayer 外に直接生成

`TileMapLayer` に scene tile として置く代わりに、`HexTileMapLayer` または sibling `Node2D` の下へ `PackedScene.instantiate()` して `hex_to_local()` 位置に配置する。

利点:

- instance ごとの export property を設定しやすい
- 生成順、owner、group、名前、signal 接続を制御しやすい
- `TileMapLayer` の scene tile 遅延生成に依存しない

欠点:

- TileMap editor の paint / erase とは別管理になる
- scene を atlas のように TileSet editor で選ぶ体験からは外れる

この案は、生成マップに対して runtime object を置く用途や、AI / item / enemy のように tile cell 以上の状態を持つ object に向く。

## 推奨構成

当面は以下が最も扱いやすい。

1. floor / wall は現状の atlas source を継続する
2. `TileMapLayer` を terrain / object / overlay に分ける
3. object layer に `TileSetScenesCollectionSource` を追加する
4. atlas tile と scene tile を統一して選ぶ `HexTileCatalog` を検討する
5. 多数表示される静的見た目は atlas、少数で振る舞いを持つものは scene tile、状態を強く持つものは直接 scene instance として分ける

## 検証ケース候補

headless で確認できる範囲:

- `TileSetScenesCollectionSource` を作成し、`PackedScene` を `create_scene_tile()` で登録できること
- scene tile の `set_cell(cell, source_id, Vector2i(0, 0), scene_id)` が cell identifier として保存されること
- `get_cell_source_id()` / `get_cell_alternative_tile()` から scene tile を復元できること
- `HexMapTileAdapter.vector_to_map_cell()` の hex cell 変換を object layer でも共有できること

Godot editor 上の確認が必要な範囲:

- Scenes Collection を TileSet editor から作り、TileMap editor で paint できること
- scene tile が editor / runtime で期待位置に instantiate されること
- placeholder 表示が必要な invisible scene で `set_scene_tile_display_placeholder()` が有効か
- atlas terrain layer と object scene layer を重ねたとき、z index / y sort / origin が破綻しないこと

## 参照

- Godot docs: `TileSetScenesCollectionSource`  
  https://docs.godotengine.org/en/stable/classes/class_tilesetscenescollectionsource.html
- Godot docs: `TileMapLayer`  
  https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html
- Godot docs: Using TileSets / Using a collection of scenes  
  https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html#using-a-collection-of-scenes
- Godot docs: Custom metadata, terrains, alternative tiles  
  https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html
- Godot docs: When to use scenes versus scripts  
  https://docs.godotengine.org/en/stable/tutorials/best_practices/scenes_versus_scripts.html
