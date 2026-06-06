# Multi Layer Overlay Resource / Adapter / Apply Policy 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Overlay Data の保存用 Resource、TileMapLayer への表示 adapter、Overlay Data 同士の Apply Policy を実装済みとして扱う。

## 入出力

### HexOverlayResource

入力:

- `HexOverlayData`
- orientation
  - `HexMapResource.ORIENTATION_FLAT_TOP`
  - `HexMapResource.ORIENTATION_POINTY_TOP`

出力:

- `HexOverlayResource`
  - `cells: Array[Vector3i]`
  - `item_keys: PackedStringArray`
  - `item_cells: Array`
  - `cyclic_size: int`
  - `orientation: int`
- `to_overlay_data()`

### Overlay Apply Policy

入力:

- target `HexOverlayData`
- source `HexOverlayData`
- write policy
  - `APPLY_CLEAR_AND_WRITE`
  - `APPLY_ADD_ITEM`
- existing policy
  - `EXISTING_MERGE`
  - `EXISTING_REPLACE`
  - `EXISTING_SKIP`

出力:

- 更新された target `HexOverlayData`

`TileMapLayer` は1 cellに複数 item を直接保持できないため、複数 item の merge / replace / skip は `HexOverlayData` 上で表現する。描画時は `HexOverlayTileAdapter` の item order に従って1 cellに表示する tile を決める。

### HexOverlayTileAdapter

入力:

- `HexOverlayData`
- item tile mapping
  - key: item key `String`
  - value:
    - `source_id`
    - `atlas_coords`
    - `alternative_tile`
- `clear_layer: bool`
- `flat_top: bool`
- optional item order

出力:

- `to_tile_entries()`
  - `vector`
  - `item_key`
  - `map_cell`
  - `sort_z`
  - `source_id`
  - `atlas_coords`
  - `alternative_tile`
- `TileMapLayer.set_cell()`

## 実装状況

- [x] `HexOverlayResource` で Overlay Data を保存用 Resource に変換する
- [x] `HexOverlayResource.to_overlay_data()` で Overlay Data に復元する
- [x] `HexOverlayData.apply_overlay()` が clear/add と merge/replace/skip を扱う
- [x] `HexOverlayTileAdapter` が user item key ごとに TileMapLayer の tile を割り当てる
- [x] unmapped item key は TileMapLayer へ書かない
- [x] `clear_layer=false` で既存 TileMapLayer cell を保持して overlay cell を追加できる

## テスト

- `tests/test_hex_adapter.gd`
  - `HexOverlayResource` roundtrip
  - clear/add と merge/replace/skip apply policy
  - user item key ごとの source / atlas / alternative tile 反映
  - unmapped item key の skip
  - `clear_layer=false` で既存 TileMapLayer cell を保持
