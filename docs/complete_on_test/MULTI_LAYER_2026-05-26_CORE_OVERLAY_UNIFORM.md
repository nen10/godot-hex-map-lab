# Multi Layer Core Overlay Uniform 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Overlay Data の土台と Uniform Distribution 系 item 生成を実装済みとして扱う。

## 入出力

### Primary Item Key

入力:

- `HexMapData`
  - `cells`
  - `walls`

出力:

- `item_keys()`
  - `Any`
  - `Floor`
  - `Wall`
- `item_cells(item_key)`
  - `Any`: 全 cell
  - `Floor`: wall を除いた floor cell
  - `Wall`: wall cell
- `item_set(item_key)`

### Overlay Data

入力:

- `cells: Array[HexVector]`
- `items: Dictionary`
  - key: user item key `String`
  - value: `Array[HexVector]`
- `cyclic_size: int`

出力:

- `HexOverlayData`
  - `item_keys()`
  - `item_cells(item_key)`
  - `item_set(item_key)`
  - `add_item_cell(item_key, point)`
  - `add_item_cells(item_key, points)`
  - `has_item(point, item_key)`
  - `items_at(point)`
  - `occupied_cells()`

Overlay の item key はユーザー定義文字列で、`Wall` など Primary と同名でも扱える。

### Uniform Overlay Generator

入力:

- `cells: Array[HexVector]`
- `blocked_cells: Array[HexVector]`
- `seed: int`
- `generate_random_items`
  - `placement_probability: float`
  - `item_pool: Array[Dictionary]`
    - `name: String`
    - `weight: float`
- `generate_limited_items`
  - `item_pool: Array[Dictionary]`
    - `name: String`
    - `limit: int`
- interrupt options
  - `chunk_size`
  - `progress_callback`
  - `cancel_callback`

出力:

- `HexOverlayData`
- interruptible API の result `Dictionary`
  - `data`
  - `cancelled`
  - `progress`
  - `steps`
  - `total_steps`

## 実装状況

- [x] Primary Data が `Any` / `Floor` / `Wall` item key を公開する
- [x] Overlay Data が任意 item key と cell 集合を保持する
- [x] Overlay item key は `Wall` などの名前も制限しない
- [x] `generate_random_items()` は Placement Probability と item weight で item を生成する
- [x] `generate_limited_items()` は残配置数 / 残走査 cell 数を使い、item ごとの limit まで生成する
- [x] `blocked_cells` を生成候補から除外する
- [x] Overlay item generation は seed 固定と progress / cancel に対応する

## テスト

- `tests/test_hex_map_generation.gd`
  - Primary Data の `Any` / `Floor` / `Wall` item key
  - Overlay Data の user item key、未知 cell filter、重複除去、同名 key 許可
  - `generate_random_items()` の weight、mask、seed、zero probability
  - `generate_limited_items()` の item limit と blocked cell 除外
  - interruptible random item generation の progress / cancel
