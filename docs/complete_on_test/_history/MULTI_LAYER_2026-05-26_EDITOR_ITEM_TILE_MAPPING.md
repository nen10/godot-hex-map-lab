# Multi Layer Editor Item Tile Mapping 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Editor Dock の Overlay Item Pool から item key ごとの TileMapLayer 表示tileを指定する機能を実装済みとして扱う。

## 入出力

入力:

- Overlay Item Pool row
  - `Item Name`
  - tile `source_id`
  - tile `atlas_x`
  - tile `atlas_y`
- `_current_overlay_data`

出力:

- `HexOverlayTileAdapter.apply_to_tile_map_layer()` の item tile mapping
  - key: item key
  - value: `{ source_id, atlas_coords }`

Item Pool に存在しない item key は、Dock の `Wall` source / atlas coords を fallback tile として使う。

## 実装状況

- [x] Item Pool row に tile source / atlas coords を追加する
- [x] Overlay apply 時に item key ごとの tile mapping を作る
- [x] Item Pool にない item key は従来どおり `Wall` tile controls を使う
- [x] Generate 後の自動 apply / `Apply Layer` / 即時 tile settings apply が item key ごとの tile mapping を使う

## テスト

- `tests/test_editor_plugin.gd`
  - `Tree` と `Rock` に別々の atlas coords を指定し、同じ Overlay Data 内で別tileとして `TileMapLayer` に書かれること
