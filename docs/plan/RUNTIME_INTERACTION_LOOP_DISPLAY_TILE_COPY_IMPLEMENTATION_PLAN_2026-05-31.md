# RUNTIME_INTERACTION_LOOP_DISPLAY_TILE_COPY_IMPLEMENTATION_PLAN_2026-05-31.md

## 参照方針

- 方針: `docs/plan/RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md`
- 採用案: canonical data + visual representative を維持し、runtime-owned loop copy `TileMapLayer` を追加する。

## 対象範囲

本計画では、manual edit 用表示へ渡せる loop duplicate の tile 表示だけを対象にする。

## 対象ファイル

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_debug_scenes.gd`
- `docs/TEST.md`

## 入出力インターフェース

入力:

- `HexMapResource`
- loop display mode
- loop display rect
- loop display margin
- cyclic_size
- canonical cell state
- floor / wall tile settings

出力:

- canonical `_tile_map`
- loop copy `TileMapLayer`
- visual cell entries
- loop duplicate tile cells
- debug scene display state

## API計画

### visual cell entry

`HexTileMapLayer` に表示用 entry を返す API を追加する。

```gdscript
func visual_cell_entries_for_rect(rect: Rect2, margin: int = 1) -> Array:
```

entry:

```gdscript
{
    "hex": HexVector,          # canonical
    "visual_hex": HexVector,   # unfolded / displayed
    "map_cell": Vector2i,
    "is_canonical": bool,
}
```

`map_cell` は `HexMapTileAdapter.vector_to_map_cell(visual_hex, flat_top)` によって作る。canonical cell と同じ位置にある representative は base `_tile_map` が表示するため、copy layer へ入れるかどうかを `is_canonical` で判定できる。

### loop copy layer

`HexTileMapLayer` 内部に `_loop_tile_map` を追加する。

- base `_tile_map`: canonical map だけを表示する。
- `_loop_tile_map`: loop duplicate の visual representatives だけを表示する。
- `_loop_tile_map.tile_set` は base と同じ `TileSet` を参照する。
- copy cell は view state として扱い、保存対象は canonical data に限定する。

更新タイミング:

- `apply_map()`
- `set_wall()`
- `set_floor()`
- loop display setting 変更
- `loop_display_rect` 変更
- `flat_top` / `hex_size` 変更

public method:

```gdscript
func refresh_loop_display() -> void:
```

`refresh_loop_display()` は copy layer を clear し、`visual_cell_entries_for_rect()` から duplicate entry を再構成する。

## 描画仕様

1. canonical cell は従来通り base `_tile_map` に描く。
2. toric loop mode では、表示範囲内に入る visual representatives を列挙する。
3. `entry["is_canonical"] == false` のものだけ `_loop_tile_map` に tile を置く。
4. floor / wall の tile source / atlas / alternative は canonical cell の状態から決める。
5. outline は補助表示として維持できるが、loop duplicate の主表示は tile copy 表示にする。

## infinite mode

`LOOP_DISPLAY_INFINITE` では visual hex を canonical hex として扱う。copy layer は toric duplicate 用に限定し、infinite mode は finite resource 内の cell identity をそのまま維持する。

visible cell provider が導入されるまでは、finite resource 内の cell だけを base `_tile_map` に描く。infinite mode の hit identity は現行 test を維持する。

## 破壊的変更候補

- `_tile_map` の単一子 node 前提をやめ、base / loop copy / overlay を内部管理する。
- `_draw_loop_cell_outlines()` を debug 補助へ降格する。
- floor / wall tile 設定の更新 path を base と copy layer で共通化する。

## テスト計画

### `tests/test_hex_tile_map_layer.gd`

- `_test_visual_cell_entries_for_rect_marks_canonical_and_duplicates()`
  - toric map で表示範囲内の canonical / duplicate entry を取得する。
  - `hex` は wrap 済み canonical、`visual_hex` は表示代表であることを検証する。
- `_test_loop_copy_layer_draws_duplicate_tiles()`
  - loop display enabled の `HexTileMapLayer` に map を適用する。
  - duplicate `visual_hex` の `map_cell` に floor / wall tile が置かれることを検証する。
- `_test_loop_copy_layer_updates_after_wall_floor_edit()`
  - `set_wall()` / `set_floor()` 後に canonical と duplicate の tile が同期することを検証する。
- `_test_visual_path_anchor_selects_first_representative()`
  - `anchor_local` を指定したとき、先頭 cell の representative が anchor に最も近いものになることを検証する。

### `tests/test_debug_scenes.gd`

- loop display toggle 後、debug scene の loop duplicate 表示状態が更新されることを検証する。

### `docs/TEST.md`

- runtime loop copy display の headless test 概要を追加する。
- debug workflow に tile duplicate 表示の確認観点を追加する。

## 実装手順

1. `visual_cell_entries_for_rect()` を追加し、entry schema を headless test で固定する。
2. `_loop_tile_map` を内部 node として追加する。
3. `refresh_loop_display()` を追加し、apply / edit / setting change から呼ぶ。
4. floor / wall tile の copy 更新を base `_tile_map` と一致させる。
5. outline 表示を debug 補助へ整理する。
6. debug scene と `docs/TEST.md` を更新する。
7. `./tools/test.sh` を実行する。

## 完了判定

- loop duplicate が outline ではなく TileMapLayer tile として表示される。
- duplicate tile は canonical cell の floor / wall 更新に同期する。
- `local_to_cell_hit()` の canonical / visual identity は既存 test と互換である。
- manual edit tool が利用できる visual cell entry API が test で固定される。
