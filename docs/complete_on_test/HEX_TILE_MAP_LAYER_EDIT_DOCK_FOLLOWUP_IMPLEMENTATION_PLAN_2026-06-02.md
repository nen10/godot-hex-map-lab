# HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_IMPLEMENTATION_PLAN_2026-06-02.md

## 対象

- UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_UX_2026-06-02.md`
- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_POLICY_2026-06-02.md`
- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_REVIEW_2026-06-02.md`

## 入力

- `HexMapDocumentResource`
- Edit Mode
- Tile payload: source id / atlas coords / alternative tile
- Default Floor / Wall display tile settings
- Editor selection
- Scene root target scan result
- Target: `HexTileMapLayer` または plain `TileMapLayer`

## 出力

- Updated `HexMapDocumentResource`
- Updated target display state
- Updated `HexTileMapLayer` payload display state
- Last Edit trace with target / display reason
- Scrollable Hex Map Edit Dock
- Named generation dock tab

## Resource / Scene Schema

### `HexMapDocumentResource`

既存 schema を維持する。

- `map`
- `tile_overrides`
- `objects`
- `labels`

### `HexTileMapLayer`

既存 export fields を維持し、document payload display用の内部状態を追加する。

- default floor / wall tile: existing export fields
- tile override display: `HexMapDocumentResource.tile_overrides` から反映
- object marker display: `HexMapDocumentResource.objects` から反映
- label display: `HexMapDocumentResource.labels` から反映

永続化する schema を増やす場合は `HexMapDocumentResource` 側に限定し、内部表示cacheは scene保存対象にしない。

## 実装手順

1. edit dock layout を scroll化する。
   - `HexMapEditTool._build_ui()` の root を `ScrollContainer` + inner `VBoxContainer` に変更する。
   - 既存 control 参照を維持する。

2. generation dock title を設定する。
   - `plugin.gd` で `_dock.name = "Hex Map Generate"` を設定する。
   - 必要なら `HexMapGenDock._ready()` でも name default を設定する。

3. edit dock Auto target resolution を修正する。
   - `_resolve_target_layer()` を Auto / explicit で分ける。
   - Auto時に `_find_editor_selected_target_layer()` を追加して live selection を読む。
   - selectionに target がなければ `_target_layer_nodes` の先頭を返す。
   - explicit target時だけ `_select_target_in_editor_if_possible()` を呼ぶ。

4. edit dock に Default Floor / Wall tile settings を追加する。
   - Floor source / atlas x / atlas y / alt
   - Wall source / atlas x / atlas y / alt
   - `Read Target Tiles`
   - `Apply Target Tiles`
   - settings は plain target apply options と `HexTileMapLayer` fields の両方に接続する。

5. `HexTileMapLayer` に document payload apply helper を追加する。
   - `apply_document(document: HexMapDocumentResource)` または同等 helper。
   - map resource apply後に tile overrides を内部 display layerへ反映する。
   - object / label は `_draw()` または別 overlay helperで marker / label表示する。
   - loop display が有効な場合、visual representative側にも payload markerを出す。

6. Hex Map Edit の target apply を document helperへ寄せる。
   - `HexTileMapLayer` target では `apply_document(_document)` を呼ぶ。
   - plain `TileMapLayer` target では既存 `HexMapDocumentAdapter.apply_to_tile_map_layer()` を維持する。

7. Last Edit trace を拡張する。
   - target resolution reason
   - apply failure reason
   - display renderer kind: base tile / tile override / object marker / label / none
   - display unavailable reason: no target / no TileSet / unsupported mode / atlas missing
   - payload summary

8. tests を追加・更新する。
   - `tests/test_editor_plugin.gd`
   - `tests/test_hex_tile_map_layer.gd`
   - `docs/TEST.md`

9. documentation を更新する。
   - `docs/knowledge/DEV_GODOT.md`
   - 必要に応じて follow-up review に結果を追記する。

## Test Plan

### `tests/test_editor_plugin.gd`

1. edit dock root が `ScrollContainer` を持つ。
2. plugin が generation dock name を `Hex Map Generate` に設定する。
3. Target Auto が editor-selected `HexTileMapLayer` を返す。
4. Target Auto が selectionなしで first scene target を返す。
5. Explicit target は selection変更後も固定される。
6. Default Floor / Wall settings を変更し、`HexTileMapLayer` target に反映できる。
7. Default Floor / Wall settings を変更し、plain `TileMapLayer` redraw options に反映できる。
8. Floor Tile / Wall Tile mode の click が `HexTileMapLayer` display atlas を変える。
9. Object / Label mode の click が marker / label display state または trace renderer を変える。
10. Last Edit が `target=no` / `display=no` の reason を持つ。

### `tests/test_hex_tile_map_layer.gd`

1. `apply_document()` が default floor / wall と tile overrides を表示する。
2. `apply_document()` が object marker state を持つ。
3. `apply_document()` が label display state を持つ。
4. loop display 有効時に payload marker / label が canonical / visual representative と矛盾しない。

## Analog Test 候補

`tests/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md` の follow-up として、`HexTileMapLayer` target で次を観察する。

1. generation dock tab title が `Hex Map Generate` と表示される。
2. edit dock が縦scrollできる。
3. Target `Auto` が Scene Tree 選択中 `HexTileMapLayer` を拾う。
4. Default Floor / Wall tile settings を変更して `Wall / Floor` click の見た目が変わる。
5. Floor Tile / Wall Tile / Object / Label の各 mode で Last Edit が target / display reason を示す。

## 完了条件

- `./tools/test.sh` が成功する。
- `docs/TEST.md` に追加 Test path が記録される。
- Reviewで示された6項目が、実装済みまたは明確な別計画へ分類される。
