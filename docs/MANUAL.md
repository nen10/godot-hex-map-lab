# Hex Map Kit Manual

## 目次

- [Hex Map Kit Manual](#hex-map-kit-manual)
  - [目次](#目次)
  - [1. セットアップ](#1-セットアップ)
    - [プロジェクトへの導入](#プロジェクトへの導入)
    - [アドオン構造](#アドオン構造)
    - [スクリプトからの利用](#スクリプトからの利用)
  - [2. クイックスタート](#2-クイックスタート)
  - [3. スクリプティングガイド](#3-スクリプティングガイド)
    - [3.1 座標系: HexVector と HexPoint](#31-座標系-hexvector-と-hexpoint)
      - [HexVector](#hexvector)
      - [HexPoint（軸座標・オフセット座標）](#hexpoint軸座標オフセット座標)
    - [3.2 マップデータ: HexMapData](#32-マップデータ-hexmapdata)
    - [3.3 マップ生成: HexMapGenerator](#33-マップ生成-hexmapgenerator)
      - [基本生成](#基本生成)
      - [パラメータ解説](#パラメータ解説)
      - [一様分布による壁生成](#一様分布による壁生成)
    - [3.4 連結性と回復](#34-連結性と回復)
    - [3.5 経路探索: HexGrid](#35-経路探索-hexgrid)
    - [3.6 TileMapLayer への適用](#36-tilemaplayer-への適用)
    - [3.7 リソース保存: HexMapResource](#37-リソース保存-hexmapresource)
    - [3.8 トーラスマップと対称生成](#38-トーラスマップと対称生成)
      - [トーラス座標 (HexToricCoordinate)](#トーラス座標-hextoriccoordinate)
      - [9-Split 分割ルール (HexToricMapSplitRule)](#9-split-分割ルール-hextoricmapsplitrule)
      - [対称生成](#対称生成)
    - [3.9 デバッグ出力](#39-デバッグ出力)
  - [4. EditorPlugin ガイド](#4-editorplugin-ガイド)
    - [4.1 有効化](#41-有効化)
    - [4.2 マップ生成ドック](#42-マップ生成ドック)
      - [操作方法](#操作方法)
      - [形状ごとの動き](#形状ごとの動き)
      - [Stats 表示](#stats-表示)
    - [4.3 生成結果の保存と利用](#43-生成結果の保存と利用)
    - [4.4 デバッグ実行](#44-デバッグ実行)
  - [5. API リファレンス](#5-api-リファレンス)
    - [HexVector](#hexvector-1)
    - [HexPoint](#hexpoint)
    - [HexMapData](#hexmapdata)
    - [HexMapGenerator](#hexmapgenerator)
    - [HexGrid](#hexgrid)
    - [HexToricCoordinate](#hextoriccoordinate)
    - [HexToricMapSplitRule](#hextoricmapsplitrule)
    - [HexMapTileAdapter](#hexmaptileadapter)
    - [HexMapResource](#hexmapresource)
    - [HexMapDebug](#hexmapdebug)

---

## 1. セットアップ

### プロジェクトへの導入

`addons/hex_map_kit/` ディレクトリをプロジェクトの `addons/` に配置します。
`project.godot` に以下のセクションが存在することを確認してください:

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
```

### アドオン構造

```
addons/hex_map_kit/
  plugin.cfg              # アドオン登録情報
  plugin.gd               # EditorPlugin エントリポイント
  core/
    hex_vector.gd         # 立方体座標
    hex_point.gd          # 軸座標・オフセット座標
    hex_map_data.gd       # マップデータコンテナ
    hex_map_generator.gd  # マップ生成
    hex_grid.gd           # 近傍・経路探索
    hex_randomizer.gd     # 確率分布テーブル
    hex_toric_coordinate.gd   # トーラス座標
    hex_toric_map_split_rule.gd  # 9-split 分割ルール
    hex_map_debug.gd      # デバッグ表示
  adapter/
    hex_map_tile_adapter.gd    # TileMapLayer 連携
    hex_map_resource.gd        # .tres リソース
  editor/
    hex_map_gen_dock.gd   # エディタドック
```

### スクリプトからの利用

API はすべて静的メソッドまたは RefCounted インスタンスで提供されます:

```gdscript
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
```

---

## 2. クイックスタート

```gdscript
# preload
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

# マップ生成: 8x6 長方形, 壁確率 45%, seed=42, 連結性回復あり, 原点保護
func generate() -> void:
    var data = HexMapGenerator.generate_rectangle(
        8, 6,       # width, height
        0.45,       # wall_probability
        42,         # seed
        true,       # ensure_connected
        false,      # toric
        [HexVector.zero()]  # protected_floor
    )

    # TileMapLayer に描画
    var layer = $TileMapLayer
    HexMapTileAdapter.apply_to_tile_map_layer(
        layer, data,
        0, Vector2i.ZERO,        # floor: source=0, atlas=(0,0)
        0, Vector2i(1, 0)        # wall:  source=0, atlas=(1,0)
    )
```

---

## 3. スクリプティングガイド

### 3.1 座標系: HexVector と HexPoint

#### HexVector

3次元空間を対角方向から見て平面に射影して`(q, s, r)` の 3 成分によるhex座標を2次元平面に表現します。
同一の地点に複数の3次元座標が対応するため内部で正規化処理を行ない、uniquenessを保証しています。
入力した `(q, s, r)` と実際に作成される座標には、3次元の対角線の範囲において違いが発生します。
この正規化による代表点は、距離計算をシンプルに表現する値を採用しています。

```gdscript
var origin = HexVector.zero()           # (  0,  0,  0 )
var Q      = HexVector.q_axis()         # ( +1,  0,  0 )
var R      = HexVector.r_axis()         # (  0,  0, +1 )
var S      = HexVector.s_axis()         # (  0, +1,  0 )
var east   = Q.subtract(R)              # ( +1,  0, -1 )
var south  = S.negated()                # (  0, -1,  0 )

# 任意の方向ベクトル
var v = HexVector.apply_basis(2, -1, -1)  # q=2, s=-1, r=-1 → 正規化後 (3, 0, 0): Q.scaled(3)

# 演算
var sum       = east.add(south)
var diff      = east.subtract(south)
var scaled    = east.scaled(5)
var neg       = east.negated()

# 距離
var l1_dist   = v.l1_norm()          # L1ノルム (マンハッタン距離)
var l2_dist   = v.l2_norm()          # 近似ユークリッド距離
var chebyshev = v.l_infinity_norm()  # Chebyshev 距離

# 識別キーと表示
print(east.key())          # "1,0,-1"
print(east.debug_string()) # "(Q:1, S:0, R:-1)"
print(east.axial())        # Vector2i(1,-1)  (q-s, r-s)
```

**6方向ベクトル:**

```gdscript
var directions = HexVector.directions()
# [Q, -R, S, -Q, R, -S]
```

#### HexPoint（軸座標・オフセット座標）

HexVector（立方体座標）での正規化と異なり、sを0にする点を代表点として採用した正規化を行い、3成分の座標値を`(q, r)` の2成分で表現します。
これによって、ディスプレイ上でのhex座標表現に適したオフセット座標との変換機能をサポートします。

```gdscript
# 生成
var point = HexPoint.from_cube(1, -1, 0)   # 立方体座標から
var offset_point = HexPoint.from_offset(3, 2)  # オフセット座標から

# 変換
var offset = point.to_offset()    # Vector2i オフセット座標

# point + vector -> point
var neighbor = point.add_vector(HexVector.q_axis())

# point - point -> vector
point.vector_to(neighbor) == Q
point.vector_from(neighbor) == -Q

# 2点間の距離
var dist = point.l1_distance_to(neighbor)  # 1

```

---

### 3.2 マップデータ: HexMapData

`HexMapData` はマップの全セルと壁情報を保持するコンテナです。

```gdscript
var data = HexMapData.new()

# プロパティ
print(data.cells)         # Array[HexVector] — 全セル
print(data.walls)         # Array[HexVector] — 壁セル
print(data.cyclic_size)   # int — 0 なら非トーラス、>0 ならトーラス

# クエリ
data.has_cell(some_vector)   # セルに含まれるか
data.has_wall(some_vector)   # 壁かどうか
data.floor_cells()           # 壁でないセル一覧
data.cell_set()              # {key: HexVector} 辞書
data.wall_set()              # {key: HexVector} 辞書

# 壁の設定
data.set_walls([HexVector.q_axis(), HexVector.s_axis()])
```

**形状ファクトリ:**

```gdscript
# 長方形
var rect      = HexMapData.rectangle(8, 6)              # 8x6, non-toric
var toric_rect = HexMapData.rectangle(5, 5, true)       # 5x5 toric

# トーラス正方形 (toric rectangle のショートカット)
var toric     = HexMapData.square(7, true)              # 7x7 toric

# 正六角形
var hex       = HexMapData.hexagon(3)                   # radius=3 → 37 cells

# 任意のセル集合から
var data      = HexMapData.from_cells(my_cells)
var data_w    = HexMapData.from_cells(my_cells, my_walls, 5)  # cyclic_size=5
```

**ユーティリティ:**

```gdscript
var cell_set = HexMapData.make_set(points)              # {key: HexVector}
var has      = HexMapData.has_key(points, "1,0,-1")     # bool
var unique   = HexMapData.unique_points(duplicates)      # 重複除去
var floors   = HexMapData.points_except(cells, walls)    # 差集合
var filtered = HexMapData.filter_points(candidates, cell_set)  # 絞り込み
var keys     = HexMapData.sorted_keys(points)            # キー文字列のソート済み配列
```

---

### 3.3 マップ生成: HexMapGenerator

#### 基本生成

```gdscript
# 長方形マップ
var rect = HexMapGenerator.generate_rectangle(
    8,    # width
    6,    # height
    0.45, # wall_probability
    42,   # seed
    true, # ensure_connected
    false,# toric
    [HexVector.zero()]  # protected_floor
)

# トーラス正方形マップ
var toric = HexMapGenerator.generate_toric_square(
    7,    # size (N×N)
    0.45, # wall_probability
    42,   # seed
    true, # ensure_connected
    [HexVector.zero()]
)

# 正六角形マップ
var hex = HexMapGenerator.generate_hexagon(
    3,    # radius
    0.45, # wall_probability
    42,   # seed
    true, # ensure_connected
    [HexVector.zero()]
)
```

#### パラメータ解説

| パラメータ | 型 | 説明 |
|---|---|---|
| `width / height` | `int` | 長方形の幅と高さ。`toric=true` のとき `width == height` 必須 |
| `radius` | `int` | 六角形の半径。`cells.size() = 1 + 3 * radius * (radius + 1)` |
| `size` | `int` | トーラス正方形の一辺。`odd` 推奨（対称生成で必須） |
| `wall_probability` | `float` | 0.0–1.0。壁生成確率 |
| `seed` | `int` | 乱数シード。同一シード・同一パラメータで同一マップを再現 |
| `ensure_connected` | `bool` | `true` で壁を削って全床セルを連結にする |
| `protected_floor` | `Array[HexVector]` | 壁にしない保護セル |

#### 一様分布による壁生成

```gdscript
# セル集合に対してランダム壁を生成
var walls = HexMapGenerator.generate_random_walls(
    cells,   # Array[HexVector]
    0.45,    # wall_probability
    42,      # seed
    [HexVector.zero()]  # protected_floor
)
```

---

### 3.4 連結性と回復

```gdscript
# 全床セルが連結か判定
if not HexMapGenerator.is_floor_connected(data):
    print("disconnected!")

# 連結成分を取得
var components = HexMapGenerator.connected_components(data)
print("components: %d" % components.size())
for comp in components:
    print("  size: %d" % comp.size())

# 壁を削って連結にする（回復）
var removed = HexMapGenerator.restore_connectivity(data)
print("removed %d walls to restore connectivity" % removed.size())

# 特定の terminal 間のみを連結にする
var terminal_a = HexVector.zero()
var terminal_b = HexVector.q_axis().scaled(4)
var removed_t = HexMapGenerator.restore_terminal_connectivity(
    data,
    [terminal_a, terminal_b]
)

# terminal が連結済みか確認
if HexMapGenerator.are_terminals_connected(data, [terminal_a, terminal_b]):
    print("terminals connected!")
```

---

### 3.5 経路探索: HexGrid

```gdscript
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")

# 近傍取得
var neighbors = HexGrid.neighbors(HexVector.zero())    # 入力: HexPoint or HexVector
var toric_neighbors = HexGrid.neighbors(origin, 7)     # 入力: (HexPoint, cyclic_size:トーラス周期)

# L1 リング / ディスク
var ring = HexGrid.l1_ring(2)            # L1距離がちょうど radius のセル (12 cells)
var disc = HexGrid.l1_disc(2)            # L1距離が radius 以内の全セル (19 cells)
var shifted = HexGrid.l1_disc(1, center) # 原点以外を中心に指定

# 連結領域（BFS）
var connected = HexGrid.connected_area(
    start_point,
    enterable_cells,      # 通行可能なセル一覧
    0                     # cyclic_size。0 で非トーラス
)

# 最短経路（Dijkstra）
var path = HexGrid.shortest_path(
    start,                # HexVector
    [goal],               # Array[HexVector] — 複数ゴールの中から最短のものへ
    enterable_cells,      # 通行可能なセル一覧
    0                     # cyclic_size >0 でトーラスエッジをまたぐ最短
)
# path は start から goal までの HexVector 配列。到達不能なら []

# 多点始点版
var path = HexGrid.shortest_path_to_any(
    starts,               # Array[HexVector] — 複数始点
    goals,                # Array[HexVector] — 複数ゴール
    enterable_cells,
    cyclic_size
)

# セット変換
var cell_dict = HexGrid.make_set(points)
```

---

### 3.6 TileMapLayer への適用

```gdscript
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")

# 座標変換
var map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.zero())  # Vector2i(0,0)
var local_pos = HexMapTileAdapter.hex_to_local(
    HexVector.q_axis(),  # HexVector
    24.0,                # hex_size (ピクセル)
    true                 # flat_top (false で pointy-top)
)

# TileMapLayer に直接描画
HexMapTileAdapter.apply_to_tile_map_layer(
    $TileMapLayer,           # TileMapLayer ノード
    data,                    # HexMapData
    0, Vector2i.ZERO,        # floor: source_id, atlas_coords
    0, Vector2i(1, 0)        # wall:  source_id, atlas_coords
    # clear_layer=true で既存セルをクリア
)

# エントリ一覧を取得（自前描画用）
var entries = HexMapTileAdapter.to_tile_entries(data)
# entries: Array[{ "vector": HexVector, "kind": "floor"|"wall",
#                  "map_cell": Vector2i, "sort_z": int }]
# map_cell row, column, sort_z の順でソート済み
for entry in entries:
    print("%s: %s at %s" % [
        entry["kind"],
        entry["vector"].key(),
        str(entry["map_cell"])
    ])
```

---

### 3.7 リソース保存: HexMapResource

```gdscript
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")

# HexMapData → Resource 変換
var resource = HexMapResource.from_map_data(data)

# Resource → HexMapData 復元
var restored = resource.to_map_data()

# Resource のプロパティ（@export、.tres にシリアライズ）
# resource.cells: Array[Vector3i] — (q, s, r) 形式
# resource.walls: Array[Vector3i] — (q, s, r) 形式
# resource.cyclic_size: int

# ファイルに保存
ResourceSaver.save(resource, "res://maps/level1.tres")
```

---

### 3.8 トーラスマップと対称生成

#### トーラス座標 (HexToricCoordinate)

```gdscript
const HexToricCoordinate = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")

# 座標のラップ
var wrapped = HexToricCoordinate.wrap_vector(out_of_bounds_vector, cyclic_size)

# 中心化した代表座標（hex 形状表示用）
var centered = HexToricCoordinate.centered_vector(vector, cyclic_size)
# 例: (6,0,-6) with size=7 → (-1,0,1)

# 糊代付き展開（トーラスマップを複数コピーして表示するため）
var unfolded = HexToricCoordinate.unfolded_vectors(vector, cyclic_size)
# 各コピーは L1_norm <= cyclic_size の範囲内
```

#### 9-Split 分割ルール (HexToricMapSplitRule)

```gdscript
const HexToricMapSplitRule = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")

var rule = HexToricMapSplitRule.new(3)     # map_unit_radius=3 → cyclic_size=7

# 三角形領域の生成
var triangle = HexToricMapSplitRule.triangle(
    3,                      # edge_length
    HexVector.zero(),       # origin
    true                    # flat_left
)

# 分割情報
print(rule.map_unit_radius)   # 3
print(rule.cyclic_size)       # 7
print(rule.split_canvas.size()) # 9

# セルがどの分割領域に属するか
var index = rule.split_index_for(vector)   # 0–8, または -1

# 対称生成領域のタグ情報（デバッグ用）
var tags = rule.symmetry_generation_tags()
# {key: { "vector", "kind", "phase", "source_split", ... }}
```

#### 対称生成

```gdscript
# 対称生成（正方形）
var symmetric_data = HexMapGenerator.generate_symmetric_square(
    3,    # 生成半径
    0.45, # wall_probability
    42,   # seed
    true, # ensure_connected
    [HexVector.zero()],   # protected_floor
    20,   # distribution_id (確率分布テーブル ID)
    [],   # terminal_floor (terminal 連結性回復用)
    false # toric/non-toricを指定
)

# 低レベル: 壁のみ生成
var sym_walls = HexMapGenerator.generate_symmetric_toric_walls(
    7,    # size
    0.45, # wall_probability
    42,   # seed
    20,   # distribution_id
    [HexVector.zero()]
)
```

対称生成では、外周から中心に向かって壁を生成し、9-split の各領域に対称的な壁配置を行います。
`distribution_id` は隣接セルの壁状況に応じた確率分布テーブルを選択します。
`terminal_floor` を指定すると、指定されたセル間の連結性を優先的に回復します。

---

### 3.9 デバッグ出力

```gdscript
const HexMapDebug = preload("res://addons/hex_map_kit/core/hex_map_debug.gd")

# ASCII 表示
var ascii = HexMapDebug.render_ascii(data, ".", "#", " ", true)
print(ascii)
# .#..
# #...

# サマリー
print(HexMapDebug.render_summary(data))
# cells=48 walls=12 floors=36 cyclic_size=0
```

---

## 4. EditorPlugin ガイド

### 4.1 有効化

1. `project.godot` の `[editor_plugins]` に `"res://addons/hex_map_kit/plugin.cfg"` が登録されていることを確認してください。

   ```ini
   [editor_plugins]
   enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
   ```

2. Godot エディタを起動すると、下部パネル（`DOCK_SLOT_LEFT_BL`）に **Hex Map Kit** ドックが表示されます。

   ドックが表示されない場合は、エディタの **Project > Project Settings > Plugins** タブで Hex Map Kit が有効になっているか確認してください。

### 4.2 マップ生成ドック

```
┌─ Hex Map Kit ──────────────────────────────────┐
│ Shape:  [Rectangle ▼]                           │
│ ─────────────────────────────────────────────── │
│ Width:  [8]  Height: [6]                        │
│ ─────────────────────────────────────────────── │
│ Wall Prob: 0.45  [━━━━●━━━━━━━━]                │
│ Seed:  [1201]  [Rand]                           │
│ ─────────────────────────────────────────────── │
│ ☑ Restore Connectivity                          │
│ ☐ Symmetric Gen (odd N only)                    │
│ ─────────────────────────────────────────────── │
│ Rectangle  cells=48  walls=12  floors=36  ...    │
│ ─────────────────────────────────────────────── │
│ [Generate]  [Save .tres]                        │
└─────────────────────────────────────────────────┘
```

#### 操作方法

| 操作 | 説明 |
|---|---|
| **Shape** | マップ形状を選択: Rectangle / Hexagon / Torus |
| **Width / Height** | Rectangle 選択時の幅と高さ (1–64) |
| **Radius** | Hexagon 選択時の半径 (1–20)。セル数は `1 + 3r(r+1)` |
| **Size (odd)** | Torus 選択時の一辺の長さ。`7, 9, 11, 13` から選択 |
| **Wall Prob** | 壁の生成確率 (0.00–1.00)。スライダーで調整 |
| **Seed** | 乱数シード。`Rand` ボタンでランダム化 |
| **Restore Connectivity** | ON で連結性を自動回復。OFF で壁が分断する場合あり |
| **Symmetric Gen** | Torus かつ odd N のときのみ有効。対称生成モードに切替 |
| **Generate** | 現在のパラメータでマップを再生成 |
| **Save .tres** | エディタファイルダイアログで HexMapResource として保存 |

#### 形状ごとの動き

**Rectangle**:
- Width × Height の非トーラス長方形マップを生成
- サイズは任意（1–64）

**Hexagon**:
- 指定 radius の正六角形マップを生成
- 自動的に非トーラス

**Torus**:
- N×N のトーラス正方形マップを生成
- サイズは `7, 9, 11, 13` から選択
- "Symmetric Gen" ON + odd N で対称生成モード
- Stats 表示に `sym-gen` 文字列が追加される

#### Stats 表示

```
Rectangle  seed=1201  wall_prob=0.45  cells=48  walls=12  floors=36  connected=yes
```

生成後、自動的に `connected` 状態が表示されます。対称生成時は末尾に `sym-gen` が付与されます。

### 4.3 生成結果の保存と利用

**Save .tres ボタン**:
1. 生成後、`Save .tres` をクリック
2. 保存先を選択（デフォルト: `hex_map.tres`）
3. 保存後、FileSystem ドックに `.tres` ファイルが表示される

保存された `.tres` は `HexMapResource` です。スクリプトから読み込んで利用:

```gdscript
var resource = load("res://maps/level1.tres")
var data = resource.to_map_data()

# TileMapLayer に描画
HexMapTileAdapter.apply_to_tile_map_layer($TileMapLayer, data, ...)
```

### 4.4 デバッグ実行

エディタ外で実行するデバッグシーンが用意されています:

**Hex 近傍配置確認:**
```sh
./tools/debug_hex_orientation.sh
```
flat-top/pointy-top の近傍方向を視覚的に確認。`Both` / `Flat` / `Pointy` / `Parity` / `Custom` モードを切替可能。

**生成マップ視覚確認:**
```sh
./tools/debug_generated_map.sh
```
キーボード操作:

| キー | 機能 |
|---|---|
| `Space` | シード更新 |
| `Tab` | 形状切替 (Rectangle → Hexagon → Torus) |
| `R` | 連結性回復 ON/OFF |
| `O` | flat-top / pointy-top 切替 |
| `P` | 経路表示 ON/OFF |
| `S` | 9-split オーバーレイ ON/OFF (Torus, odd N) |
| `Y` | 対称生成領域オーバーレイ ON/OFF (Torus, odd N) |
| `D` | 中心化表示 ON/OFF |
| `U` | 糊代付き展開表示 ON/OFF |
| `N` | Torus サイズ切替 (7→8→9→11→13) |
| `G` | 対称生成モード ON/OFF (Torus, odd N) |

---

## 5. API リファレンス

### HexVector

| メソッド | シグネチャ | 説明 |
|---|---|---|
| `key` | `() -> String` | `"q,s,r"` 形式の一意識別子 |
| `axial` | `() -> Vector2i` | `(q-s, r-s)` |
| `l1_norm` | `() -> int` | `|q|+|s|+|r|` |
| `l2_norm` | `() -> float` | 近似ユークリッド距離 |
| `l_infinity_norm` | `() -> int` | `max(|q|,|r|,|s|)` |
| `co_norm` | `() -> int` | `l1 - l_infinity` |
| `is_equal` | `(other) -> bool` | 等値判定 |
| `add` | `(other) -> HexVector` | 加算 |
| `subtract` | `(other) -> HexVector` | 減算 |
| `negated` | `() -> HexVector` | 符号反転 |
| `scaled` | `(int) -> HexVector` | スカラー倍 |
| `divided` | `(int) -> HexVector` | 整数除算 |
| `clone` | `() -> HexVector` | 複製 |
| `debug_string` | `() -> String` | `"(Q:q, S:s, R:r)"` |
| *(static)* `zero` | `() -> HexVector` | `(0,0,0)` |
| *(static)* `q_axis` | `() -> HexVector` | `(1,0,-1)` |
| *(static)* `s_axis` | `() -> HexVector` | `(-1,1,0)` |
| *(static)* `r_axis` | `() -> HexVector` | `(0,-1,1)` |
| *(static)* `apply_basis` | `(q,s,r) -> HexVector` | 正規化 |
| *(static)* `directions` | `() -> Array` | 6方向ベクトル |

### HexPoint

| メソッド | シグネチャ | 説明 |
|---|---|---|
| `key` | `() -> String` | `"q,r"` 形式 |
| `to_offset` | `() -> Vector2i` | オフセット座標変換 |
| `add_vector` | `(HexVector) -> HexPoint` | ベクトル加算 |
| `subtract_vector` | `(HexVector) -> HexPoint` | ベクトル減算 |
| `vector_to` | `(HexPoint) -> HexVector` | 方向ベクトル |
| `vector_from` | `(HexPoint) -> HexVector` | 逆方向ベクトル |
| `l1_distance_to` | `(HexPoint) -> int` | L1 距離 |
| `l2_distance_to` | `(HexPoint) -> float` | 近似ユークリッド距離 |
| *(static)* `from_cube` | `(q,s,r) -> HexPoint` | 立方体座標から |
| *(static)* `from_offset` | `(x,y) -> HexPoint` | オフセット座標から |

### HexMapData

| メソッド | シグネチャ | 説明 |
|---|---|---|
| `cell_set` | `() -> Dictionary` | セル辞書 |
| `wall_set` | `() -> Dictionary` | 壁辞書 |
| `floor_cells` | `() -> Array` | 壁でないセル |
| `has_cell` | `(point) -> bool` | セル存在判定 |
| `has_wall` | `(point) -> bool` | 壁判定 |
| `set_walls` | `(Array) -> void` | 壁設定 |
| *(static)* `rectangle` | `(w,h,toric=false) -> HexMapData` | 長方形 |
| *(static)* `square` | `(size,toric=false) -> HexMapData` | 正方形 |
| *(static)* `hexagon` | `(radius) -> HexMapData` | 正六角形 |
| *(static)* `from_cells` | `(cells,walls=[],cyclic=0) -> HexMapData` | 任意セル集合 |
| *(static)* `make_set` | `(Array) -> Dictionary` | 辞書化 |
| *(static)* `has_key` | `(Array,String) -> bool` | キー存在判定 |
| *(static)* `unique_points` | `(Array) -> Array` | 重複除去 |
| *(static)* `filter_points` | `(Array,Dict) -> Array` | フィルタ |
| *(static)* `points_except` | `(Array,Array) -> Array` | 差集合 |
| *(static)* `sorted_keys` | `(Array) -> Array` | ソート済みキー |

### HexMapGenerator

| メソッド | シグネチャ | 説明 |
|---|---|---|
| *(static)* `generate_rectangle` | `(w,h,prob,seed=0,connected=false,toric=false,prot=[]) -> HexMapData` | 長方形生成 |
| *(static)* `generate_toric_square` | `(size,prob,seed=0,connected=false,prot=[]) -> HexMapData` | トーラス正方形生成 |
| *(static)* `generate_symmetric_square` | `(size,prob,seed=0,connected=false,prot=[],dist_id=20,terminals=[],connect_toric=false) -> HexMapData` | 対称生成 |
| *(static)* `generate_hexagon` | `(radius,prob,seed=0,connected=false,prot=[]) -> HexMapData` | 六角形生成 |
| *(static)* `generate_random_walls` | `(cells,prob,seed=0,prot=[]) -> Array` | 壁生成 |
| *(static)* `generate_symmetric_toric_walls` | `(size,prob,seed=0,dist_id=20,prot=[]) -> Array` | 対称壁生成 |
| *(static)* `is_floor_connected` | `(HexMapData) -> bool` | 連結判定 |
| *(static)* `connected_components` | `(HexMapData) -> Array` | 連結成分 |
| *(static)* `are_terminals_connected` | `(HexMapData,Array) -> bool` | terminal 連結判定 |
| *(static)* `restore_connectivity` | `(HexMapData) -> Array` | 連結性回復 |
| *(static)* `restore_terminal_connectivity` | `(HexMapData,Array) -> Array` | terminal 連結回復 |

### HexGrid

| メソッド | シグネチャ | 説明 |
|---|---|---|
| *(static)* `neighbors` | `(HexVector,cyclic=0) -> Array` | 6隣接セル |
| *(static)* `l1_ring` | `(radius,origin=zero) -> Array` | L1リング |
| *(static)* `l1_disc` | `(radius,origin=zero) -> Array` | L1ディスク |
| *(static)* `connected_area` | `(start,enterable,cyclic=0) -> Array` | BFS 連結領域 |
| *(static)* `shortest_path` | `(start,goals,enterable,cyclic=0) -> Array` | 最短経路 |
| *(static)* `shortest_path_to_any` | `(starts,goals,enterable,cyclic=0) -> Array` | 多点始点最短経路 |
| *(static)* `make_set` | `(Array) -> Dictionary` | 辞書化 |

### HexToricCoordinate

| メソッド | シグネチャ | 説明 |
|---|---|---|
| `to_vector` | `() -> HexVector` | ベクトル変換 |
| `axial` | `() -> Vector2i` | 軸座標 |
| *(static)* `apply_cyclic` | `(HexVector,int) -> HexToricCoordinate` | ラップ |
| *(static)* `wrap_vector` | `(HexVector,int) -> HexVector` | ラップ (簡易) |
| *(static)* `centered_vector` | `(HexVector,int) -> HexVector` | 中心化 |
| *(static)* `unfolded_vectors` | `(HexVector,int,int=-1) -> Array` | 糊代展開 |

### HexToricMapSplitRule

| メソッド | シグネチャ | 説明 |
|---|---|---|
| `canvas_cells` | `() -> Array` | 全キャンバスセル |
| `split_index_for` | `(HexVector) -> int` | 分割領域インデックス (0–8) |
| `get_rough_split_tag` | `(HexVector) -> int` | 粗い分割タグ |
| `get_split_area_unit` | `(HexVector,bool=true) -> Array` | 分割領域の三角形 |
| `symmetry_generation_tags` | `() -> Dictionary` | 対称生成タグ |
| *(static)* `triangle` | `(int,HexVector,bool=true) -> Array` | 三角形領域 |

### HexMapTileAdapter

| メソッド | シグネチャ | 説明 |
|---|---|---|
| *(static)* `vector_to_map_cell` | `(HexVector) -> Vector2i` | オフセット座標変換 |
| *(static)* `to_tile_entries` | `(HexMapData,bool,bool) -> Array` | タイルエントリ一覧 |
| *(static)* `apply_to_tile_map_layer` | `(layer,data,floor_src,floor_atlas,wall_src,wall_atlas,clear=true) -> void` | TileMapLayer 描画 |
| *(static)* `hex_to_local` | `(HexVector,float,bool=true) -> Vector2` | 座標→ローカル位置 |

### HexMapResource

| メソッド | シグネチャ | 説明 |
|---|---|---|
| `to_map_data` | `() -> HexMapData` | Resource → データ |
| `set_from_map_data` | `(HexMapData) -> void` | データ → Resource |
| *(static)* `from_map_data` | `(HexMapData) -> HexMapResource` | ファクトリ |

### HexMapDebug

| メソッド | シグネチャ | 説明 |
|---|---|---|
| *(static)* `render_ascii` | `(HexMapData,floor=".",wall="#",missing=" ",indent=true) -> String` | ASCII 描画 |
| *(static)* `render_summary` | `(HexMapData) -> String` | サマリー文字列 |
