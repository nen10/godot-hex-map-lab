# HEX_TILE_MAP_LAYER_COMMON_TARGET_IMPLEMENTATION_PLAN_2026-06-02.md

## 対象

- UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_COMMON_TARGET_UX_2026-06-02.md`
- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_COMMON_TARGET_POLICY_2026-06-02.md`

## 入力

- `HexMapResource`
- `HexMapData`
- 生成 Dock の orientation / tile size / floor source / floor atlas / wall source / wall atlas
- scene root 以下の `HexTileMapLayer` / plain `TileMapLayer`
- Hex Map Edit の `HexMapDocumentResource`

## 出力

- `HexTileMapLayer.hex_map`
- `HexTileMapLayer` 内部 base `TileMapLayer` の TileSet と used cells
- `HexTileMapLayer` 内部 loop copy `TileMapLayer` の duplicate tiles
- plain `TileMapLayer` 互換経路の used cells
- Dock Target list の option item
- `docs/TEST.md` の Test path 追記
- `docs/knowledge/DEV_GODOT.md` の Godot 開発ノウハウ

## Resource / Scene Schema

### `HexTileMapLayer`

- 外部 scene node: `HexTileMapLayer`
- export:
  - `hex_map: HexMapResource`
  - `floor_source_id: int`
  - `floor_atlas_coords: Vector2i`
  - `wall_source_id: int`
  - `wall_atlas_coords: Vector2i`
  - loop display fields
- internal children:
  - `TileMapLayer`
  - `LoopTileMapLayer`

internal children は表示実装として扱い、Target scan の対象にしない。

### TileSet

`HexTileMapLayer` の display TileSet が必要 tile を持たない場合、sample atlas を次の設定で作る。

- atlas texture: `res://addons/hex_map_kit/assets/sample_hex_tiles.png`
- tile size: `HexMapTileAdapter.SAMPLE_TILE_SIZE`
- default floor: source `0`, atlas `(0, 0)`
- default wall: source `0`, atlas `(1, 0)`

生成 Dock から source id / atlas coords が指定された場合、その値で display tile を作る。

## 実装手順

1. `HexTileMapLayer` display helper を追加する。
   - `display_tile_set()`
   - `ensure_display_tiles(...)`
   - `configure_atlas_display_tiles(...)`
   - resource apply / redraw 時に TileSet 未設定または必要 tile 不足なら sample atlas を設定する。

2. `HexTileMapLayer.hex_map` apply の lifecycle を整理する。
   - setter は resource を保持する。
   - node ready 後または `_ready()` で内部 `TileMapLayer` を作り、resource を redraw する。
   - `apply_map()` は表示更新を担当する。

3. 生成 Dock の Target model を Node target として拡張する。
   - `HexTileMapLayer` と plain `TileMapLayer` を収集する。
   - `Add new layer...` は `HexTileMapLayer` を追加する。
   - editor selection helper は `HexTileMapLayer` と plain `TileMapLayer` を返す。
   - Option label は `HexTileMapLayer` を区別できる文字列にする。

4. 生成 Dock primary apply を分岐する。
   - `HexTileMapLayer`: display tile 設定を同期し、`HexMapResource.from_map_data()` を `hex_map` に設定する。
   - plain `TileMapLayer`: 既存 `HexMapTileAdapter.apply_to_tile_map_layer()` 経路を維持する。

5. Hex Map Edit の `HexTileMapLayer` apply を property 更新に寄せる。
   - `HexMapDocumentAdapter.to_map_resource(_document)` を `hex_layer.hex_map` に設定する。
   - loop display を refresh する。

6. tests を追加・更新する。
   - `tests/test_hex_tile_map_layer.gd`
   - `tests/test_editor_plugin.gd`
   - `docs/TEST.md`

7. Godot 開発ノウハウを documentation する。
   - `docs/knowledge/DEV_GODOT.md`

8. `./tools/test.sh` を実行し、失敗があれば修正と再実行を行う。

## Test Plan

### `tests/test_hex_tile_map_layer.gd`

1. `HexTileMapLayer.hex_map` を ready 前に設定しても、ready 後に used cells と visible sample TileSet が作られる。
2. `apply_map()` が resource orientation に従い、display TileSet の offset axis と atlas tile source を維持する。
3. `ensure_display_tiles()` が floor / wall source id と atlas coords を display TileSet に作る。

### `tests/test_editor_plugin.gd`

1. 生成 Dock の Target list が plain `TileMapLayer` と `HexTileMapLayer` を表示し、`HexTileMapLayer` を選択できる。
2. `Add new layer...` が `HexTileMapLayer` を作る。
3. `Use Sample Tiles` が editor-selected `HexTileMapLayer` に sample display tiles を設定する。
4. Primary apply が `HexTileMapLayer.hex_map` と display cells を更新する。
5. Generate 後 auto apply が selected `HexTileMapLayer` に反映される。
6. Hex Map Edit が target `HexTileMapLayer` の `hex_map` property と表示を更新する。

## Analog Test 候補

`GENERATED_MAP_MANUAL_EDIT` の再実行時に、Target を `HexTileMapLayer` とし、次を観察する。

- resource load 直後の viewport tile 表示
- Generate 後の `HexTileMapLayer` 表示
- Hex Map Edit Last Edit の document / target / display trace
- Scene Tree で plain `TileMapLayer` ではなく `HexTileMapLayer` を選択した時の viewport click

この analog test は実装完了要件ではなく、Editor 上の視覚確認と操作競合の観察材料として扱う。

## 完了整理

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd` に display TileSet helper と visible sample TileSet 自動作成を追加した。
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd` で primary target として `HexTileMapLayer` を収集・追加・apply できるようにした。
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd` で `HexTileMapLayer` apply 時に `hex_map` property も更新するようにした。
- `tests/test_hex_tile_map_layer.gd` と `tests/test_editor_plugin.gd` に `HexTileMapLayer` resource load / target list / primary apply / sample setup / auto apply を追加した。
- `./tools/test.sh` は成功した。Godot 起動時に macOS の `get_system_ca_certificates` error log が出るが、TileSet作成 errorやtest failureはない。
