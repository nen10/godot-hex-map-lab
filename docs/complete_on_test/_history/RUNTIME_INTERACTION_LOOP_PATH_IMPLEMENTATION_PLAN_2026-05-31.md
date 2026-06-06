# RUNTIME_INTERACTION_LOOP_PATH_IMPLEMENTATION_PLAN_2026-05-31.md

## 参照方針

- 方針: `docs/complete_on_test/RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md`
- 採用案: canonical data + visual representative。

## 対象ファイル

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/core/hex_toric_coordinate.gd`
- `tests/test_hex_tile_map_layer.gd`
- `debug/generated_map_debug.gd`
- `docs/TEST.md`

## 入出力インターフェース

入力:

- `HexMapResource`
- mouse `InputEvent`
- node local position: `Vector2`
- viewport / display rect: `Rect2`
- canonical path: `Array[HexVector]`
- loop display mode
- `cyclic_size`

出力:

- click / hover signals
- hit dictionary
- canonical connected component: `Array[HexVector]`
- visual representatives: `Array[HexVector]`
- visual path: `Array[HexVector]`
- debug scene display state

## `HexTileMapLayer` API計画

### export properties

```gdscript
@export var input_enabled: bool = true
@export var emit_hovered_cell: bool = true
@export var loop_display_enabled: bool = false
@export_enum("None", "Toric", "Infinite") var loop_display_mode: int = 0
@export var loop_display_margin: int = 1
@export var loop_display_rect: Rect2 = Rect2()
```

`loop_display_rect` が空の場合、現在のviewportまたはnode-localの推定表示範囲を使う。

### signals

```gdscript
signal cell_clicked(hex, event)
signal cell_hovered(hex)
signal cell_hit_clicked(hit: Dictionary, event)
signal cell_hit_hovered(hit: Dictionary)
```

既存ユーザー向けには `cell_clicked(hex, event)` を使いやすい入口とし、loop表示の詳細が必要な場合は `cell_hit_clicked` を使う。

### input flow

1. `_unhandled_input(event)` または `_input(event)` でmouse eventを受ける。
2. `input_enabled` がfalseなら処理しない。
3. `to_local(event.position)` でlocal座標へ変換する。
4. `local_to_cell_hit(local_pos)` を呼ぶ。
5. `exists == true` の場合、clicked / hovered signalをemitする。

## hit test計画

### `local_to_cell_hit(local_pos)`

- `local_to_hex(local_pos - _tile_map.position)` でvisual hexを得る。
- `cyclic_size > 0` かつloop displayなら、`HexToricCoordinate.wrap_vector(visual_hex, cyclic_size)` をcanonical hexにする。
- non-toricならvisual hexとcanonical hexは同じ。
- `has_cell(canonical)` をexistsに使う。

戻り値:

```gdscript
{
    "hex": canonical,
    "visual_hex": visual_hex,
    "local": local_pos,
    "exists": has_cell(canonical),
}
```

## loop representative計画

### Core helper

`HexToricCoordinate.unfolded_vectors(point, cyclic_size, max_l1_norm)` は既存。表示範囲に合わせたrepresentative選択は `HexTileMapLayer` 側に置く。

### `visual_representatives_for_cell(hex, rect, margin)`

1. canonical hexをwrapする。
2. `HexToricCoordinate.unfolded_vectors(canonical, cyclic_size, limit)` で候補を作る。
3. `hex_to_local(visual)` が `rect.grow(margin * hex_size)` に入るものを返す。
4. non-toricでは `[hex]` を返す。

### redraw

初期実装ではbase TileMapLayerはcanonical mapのみを描く。loop copyは `_draw()` でtile surrogateではなくhighlight/path確認用のoutlineとして描く。

Tileそのものをloop copy表示する段階では、内部にcopy用 `TileMapLayer` を追加し、canonical cellからvisual representativeへtile entryを複製する。

## infinite表示計画

`loop_display_mode == Infinite` では `cyclic_size` によるwrapを行わない。

初期実装では、finite resourceのcellを「同一canonical cellの複製」として扱わず、canonical座標そのものを表示範囲内へ追加していく方式を採る。chunk生成やprocedural infinite map dataが必要になった場合は、`visible_cells_provider(rect)` 相当のCallableを追加して、表示範囲内の実座標cellを供給する。

hit test:

- visual hexをそのままcanonical hexとして扱う。
- `has_cell()` はfinite resource内のcellだけをtrueにする。
- infinite provider導入後はproviderが返すcell setを存在判定に使う。

path:

- non-toric pathは入力pathをそのまま表示する。
- infiniteでは異なる座標を同一cellへwrapしない。

## visual path計画

### `visual_path_for_canonical_path(path, anchor_local)`

1. pathが空なら空配列。
2. 先頭cellはanchorに最も近いrepresentativeを選ぶ。anchor未指定ならcanonical local。
3. 2cell目以降は、前representative localから最も近いrepresentativeを選ぶ。
4. 結果はvisual hex配列として返す。

toric mapでは `HexToricCoordinate.unfolded_vectors()` を使う。non-toricでは入力pathをそのまま返す。

### `draw_loop_path(path, color)`

- canonical pathを受け取り、`visual_path_for_canonical_path()` で表示代表へ変換する。
- `_display_path` にはvisual pathを保存する。
- signalやquery APIはcanonical pathを返すため、表示用配列とデータ用配列を混同しない。

## connected component helper

既存 `is_map_connected()` / `connected_component(hex)` は維持する。

追加候補:

```gdscript
func connected_component_from_local(local_pos: Vector2) -> Array
func highlight_connected_component(hex, color: Color) -> void
```

これらは `local_to_cell_hit()` のcanonical hexを使う。

## Resource schema

`HexMapResource` schemaは変更しない。

loop displayはruntime view stateであり、`.tres` には保存しない。保存が必要になる場合は、scene側のexport propertyとしてGodot sceneに保存される。

## テスト計画

### `tests/test_hex_tile_map_layer.gd`

追加テスト候補:

- `_test_cell_clicked_signal_uses_local_to_hex()`
  - layerにmapを適用する。
  - synthetic mouse eventまたはhelper直接呼び出しでhitを作る。
  - expected canonical cellがsignal payloadに入ることを検証する。
- `_test_local_to_cell_hit_wraps_toric_visual_cell()`
  - cyclic mapでvisual hexが範囲外でもcanonicalにwrapされる。
- `_test_visual_path_for_toric_path_uses_nearest_representatives()`
  - edge間pathを与え、表示local距離がcanonical polylineより短いrepresentativeになることを検証する。
- `_test_connected_component_from_local_matches_core()`
  - local座標からcomponentを取得し、`HexGrid.connected_area()` と一致する。

### `tests/test_debug_scenes.gd`

- debug sceneがloop path表示modeを持つことを検証する。
- scene scriptのtoggle stateが初期化できることを検証する。

## Debug workflow

`debug/generated_map_debug.gd` に以下のtoggleを追加する。

- `L`: loop display
- `C`: clicked / hovered cell display
- `P`: existing path displayをloop-awareに切替

`docs/TEST.md` のDebug実行にキー説明を追加する。

## 実装手順

1. `HexTileMapLayer` にsignalsとinput handlingを追加する。
2. `local_to_cell_hit()` を追加し、headless testで固定する。
3. `visual_representatives_for_cell()` と `visual_path_for_canonical_path()` を追加する。
4. `draw_loop_path()` を追加する。
5. connected component helperをlocal hit経由で追加する。
6. debug sceneにloop display / click display toggleを追加する。
7. `docs/TEST.md` を更新する。
8. `./tools/test.sh` を実行する。

## 完了判定

- runtime click signalがheadless testで検証される。
- toric wrapをまたぐpathが近接representative列になる。
- connected component helperがcanonical cellでCore結果と一致する。
- debug sceneでloop pathの手動確認方法が記録される。
