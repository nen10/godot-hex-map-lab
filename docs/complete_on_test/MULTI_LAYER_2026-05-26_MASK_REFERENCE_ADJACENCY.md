# Multi Layer Mask / Reference / Adjacency 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Placement Mask / Adjacency Reference の Core 入力解決と、Adjacency Reference を使う Overlay item generation を実装済みとして扱う。

## 入出力

### Item Selector Query

入力:

- selector `Dictionary`
  - `source`
    - `HexMapData`
    - `HexOverlayData`
    - `item_cells(item_key)` を持つ data object
  - `item_key: String`
  - または `item_keys: Array[String]`
- operation
  - `HexOverlayData.ITEM_QUERY_OR`
  - `HexOverlayData.ITEM_QUERY_AND`

出力:

- `HexOverlayData.query_item_cells(selectors, operation)`
- `HexOverlayData.query_item_set(selectors, operation)`

この API は Primary Data と Overlay Data をまたぐ Placement Mask / Reference Items の集合演算に使う。

### Adjacency Overlay Generator

入力:

- `cells: Array[HexVector]`
  - 生成候補 cell
- `item_name: String`
  - 生成する Overlay item key
- `reference_cells: Array[HexVector]`
  - 近傍参照に使う cell
- `probability_rules: Dictionary`
  - `Vector2i(neighbor_count, component_count)` または `"neighbor_count,component_count"` を確率に対応させる
  - `neighbor_count` 単独 key も fallback として扱う
  - `default` は該当 rule がないときの確率
- `seed: int`
- `blocked_cells: Array[HexVector]`
- `cyclic_size: int`
- `neighbor_radius: int`
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

- [x] Primary / Overlay をまたぐ item selector の OR / AND 集合演算
- [x] selector は `item_key` と `item_keys` を扱う
- [x] `generate_toric_adjacency_items()` は対象 cell 周囲の reference cell 数を取得する
- [x] `generate_toric_adjacency_items()` は reference neighbor の connected component 数を取得する
- [x] `(neighbor_count, component_count)` rule で Overlay item の生成確率を決める
- [x] `cyclic_size > 0` の場合は候補 cell / reference cell / neighbor scope を toric wrap する
- [x] hexagon など非 toric 形状でも reference に存在する neighbor だけを使って実行できる
- [x] Adjacency item generation は seed 固定と progress / cancel に対応する

## テスト

- `tests/test_hex_map_generation.gd`
  - Primary Floor と Overlay item を OR / AND で結合できること
  - OR / AND の結果を set として参照できること
  - `generate_toric_adjacency_items()` が `(neighbor_count, component_count)` rule を使うこと
  - toric wrap した reference neighbor を参照できること
