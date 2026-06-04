# HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_PLAN_2026-06-03.md

## 対象

- UX: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_UX_2026-06-03.md`
- Policy: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_POLICY_2026-06-03.md`
- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_PERFORMANCE_REVIEW_2026-06-03.md`

## 入力

- Scene Treeで選択中の `HexTileMapLayer`
- `HexTileMapLayer.hex_map`
- `HexMapDocumentResource`
- Target option: Auto / explicit `HexTileMapLayer`
- Editor viewport click event
- 内部 `TileMapLayer.local_to_map()` / `map_to_local()`
- Edit Mode: `Shape` / `Wall / Floor` / `Floor Tile` / `Wall Tile` / `Object` / `Label` / Overlay要Tile
- Overlay item key、source id、atlas coords、alternative tile
- Generation Dock Primary / Overlay target

## 出力

- Target Reloadだけで作成される未保存 `HexMapDocumentResource`
- `HexTileMapLayer` 中心のTarget候補
- plain `TileMapLayer` を通常TargetにしないAuto解決
- 内部 `TileMapLayer` 基準のhit / highlight / marker座標
- 全Edit Modeのcell / marker / overlay単位target apply
- Overlay要Tileのmanual edit結果
- tactics tile / object atlas asset
- 更新されたdebug report / readiness trace

## 永続化されるschema

### `HexMapDocumentResource`

変更しない。Target由来documentは未保存resourceとして扱う。

Overlay要Tileは短期では `tile_overrides` entryの `kind=overlay` と `item_key` を利用する。複数overlay layerやitem stackingが必要になった場合のみschema拡張を別途検討する。

### `HexMapResource`

変更しない。

### Scene node

`HexTileMapLayer` のexport propertyは維持する。新規helperや内部cacheを追加する場合、保存対象にする必要があるpropertyとruntime cacheを分ける。

### Image assets

- `addons/hex_map_kit/assets/tactics_flat_top_hex_tiles_64x57_10.png`
- `addons/hex_map_kit/assets/tactics_pointy_top_hex_tiles_57x64_10.png`
- `addons/hex_map_kit/assets/tactics_objects_64x64_10.png`

## 対象ファイル

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
- `addons/hex_map_kit/adapter/hex_overlay_tile_adapter.gd`
- `addons/hex_map_kit/adapter/hex_object_database_resource.gd`
- `addons/hex_map_kit/adapter/hex_label_database_resource.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_hex_adapter.gd`
- `tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md`
- `tools/process_generated_tactics_assets.gd`
- `docs/TEST.md`
- `docs/knowledge/DEV_GODOT.md`

## 実装手順

1. Target由来document初期化を追加する。
   - `HexMapEditTool` に `_ensure_document_from_target_if_needed()` を追加する。
   - Targetが `HexTileMapLayer` かつ `_document == null` かつ `target.hex_map != null` の時、`HexMapDocumentAdapter.from_map_resource(target.hex_map)` を設定する。
   - `set_target_layer()`、`refresh_target_layer_options()`、`set_editor_selected_target_layer_for_test()`、Target Reload handlerで呼ぶ。
   - Debug reportにdocument sourceを追加する。

2. `viewport_input_enabled()` の原因を明確にする。
   - documentなしTargetありの場合、statusに `No document. Reload can read target map.` ではなく、自動初期化後にreadyを出す。
   - Targetに `hex_map` がない場合だけ `No document selected.` を維持する。

3. Manual Edit Target候補を `HexTileMapLayer` 中心にする。
   - `_collect_target_layers_recursive()` は `HexTileMapLayer` をappendしたら子を走査しない。
   - plain `TileMapLayer` は通常候補から除外する。
   - `_editable_target_from_node()` は `HexTileMapLayer` と、その内部 `TileMapLayer` から親 `HexTileMapLayer` へのmappingだけを返す。
   - legacy plain targetが必要ならtest-only setterまたは明示flagに分離する。

4. Generator Primary Targetを調査し、段階適用する。
   - `_collect_tile_map_layers_recursive()` のPrimary target候補を `HexTileMapLayer` 優先にする。
   - Overlay modeではplain `TileMapLayer` targetが必要な現状を維持するか、別UI labelで明示する。
   - 既存testのplain `TileMapLayer` 前提をPrimary / Overlay / Core helperに分類して更新する。

5. `HexTileMapLayer` の表示座標helperを追加する。
   - `hex_to_display_local(hex)` を追加し、内部 `_tile_map.map_to_local(HexMapTileAdapter.vector_to_map_cell(hex, flat_top))` を返す。
   - `display_local_to_cell_hit(local_pos)` を追加し、内部 `_tile_map.local_to_map(local_pos - _tile_map.position)` から `HexMapTileAdapter.map_cell_to_vector()` へ変換する。
   - 既存 `local_to_cell_hit()` は新helperを使う。
   - highlight / marker / path / loop outlineの中心計算を新helperへ寄せる。

6. 座標roundtrip testを追加する。
   - 近傍cellと遠端cell `(30,0,0)`、`(0,-30,0)`、`(0,0,30)` を含める。
   - `hex_to_display_local(hex)` と `_tile_map.map_to_local(vector_to_map_cell(hex))` が一致することを検証する。
   - `local_to_cell_hit(_tile_map.position + hex_to_display_local(hex))` が同じhexを返すことを検証する。

7. `HexTileMapLayer` のcell単位apply helperを追加する。
   - `apply_document_cell(document, hex)` または `refresh_display_cell_from_document(document, hex)` を追加する。
   - `Shape` は対象cellのset / eraseとpayload cleanupだけを行う。
   - `Wall / Floor` は対象cellのbase tileを更新する。
   - `Floor Tile` / `Wall Tile` はtile override cacheを対象cellだけ更新する。
   - `Object` / `Label` はmarker cacheとfront overlay childを対象cellだけ更新する。
   - Overlay要Tileはoverlay display cacheとoverlay用internal `TileMapLayer` の対象cellだけ更新する。
   - `_update_tile(hex)` とloop duplicate refreshを対象cell中心に使う。
   - toric duplicateがある場合はcanonical / visual representativeの同期をtestする。

8. Edit Dockのcommit pathを軽量化する。
   - `_apply_hit()` で変更modeと対象Targetが `HexTileMapLayer` の場合、`_commit_document_change()` 後に全量 `_apply_document_to_target()` ではなくcell / marker / overlay単位applyを使う。
   - Last Editのtarget apply reasonに `Applied cell to HexTileMapLayer.`、`Applied marker to HexTileMapLayer.`、`Applied overlay tile to HexTileMapLayer.` を追加する。

9. Overlay要Tile edit modeを追加する。
   - Edit DockにOverlay item keyとtile payload設定を追加する。
   - `HexMapDocumentAdapter.KIND_OVERLAY` を使って `tile_overrides` entryを保存 / 更新する。
   - `HexTileMapLayer` にoverlay用internal `TileMapLayer` を追加するか、既存front overlay childでtile-like marker表示を行う。
   - Generator Overlay applyとのTarget type混在を避けるため、manual overlay editは `HexTileMapLayer` target限定にする。

10. Tactics sample assetsを利用可能にする。
   - 生成済みPNGをaddon assetsへ配置する。
   - atlas source設定で10 tileを参照できることをmanual debugまたはtest fixtureで確認する。
   - Object atlasはObject marker / database fixtureの候補として扱う。

11. Debug / analog手順を更新する。
   - Target Reloadだけで編集できる確認をanalog testに追加する。
   - Debug reportにdocument source、target class、display local / map cell差分を含める。
   - 遠端cellでずれが蓄積しない目視手順を追加する。
   - 全Edit ModeとOverlay要Tileで、全量redrawではなく対象範囲apply reasonが出ることを確認する。

12. Documentationを更新する。
   - `docs/TEST.md`
   - `docs/knowledge/DEV_GODOT.md`
   - 実装後review

## Test Plan

### `tests/test_editor_plugin.gd`

1. `HexTileMapLayer.hex_map` がある状態で、document未設定のEdit DockがTarget Reload後にdocumentを自動作成する。
2. 自動作成後、`viewport_input_enabled()` がtrueになる。
3. Auto targetは選択中 `HexTileMapLayer` を選び、plain `TileMapLayer` を通常候補にしない。
4. 内部 `TileMapLayer` を選択した場合、親 `HexTileMapLayer` として解決される。
5. `Shape`、`Wall / Floor`、`Floor Tile`、`Wall Tile` は `HexTileMapLayer` targetでcell単位apply reasonを記録する。
6. `Object`、`Label` はmarker単位apply reasonを記録する。
7. Overlay要Tileはoverlay tile単位apply reasonを記録する。
8. Generator Primary target候補が `HexTileMapLayer` 中心であることを確認する。
9. Overlay modeがplain targetを必要とする場合、その扱いがPrimary targetと混ざらないことを確認する。

### `tests/test_hex_tile_map_layer.gd`

1. `hex_to_display_local()` が内部 `_tile_map.map_to_local()` と一致する。
2. `local_to_cell_hit()` が内部 `_tile_map.local_to_map()` 基準でroundtripする。
3. 遠端cellでdisplay center / hit / highlight centerが一致する。
4. `apply_document_cell()` が対象cellだけのtile atlas / marker / overlay状態を更新する。
5. `Shape` のadd / removeが対象cellのbase / overlay / marker stateだけを更新する。
6. loop display時、canonical cell edit後にduplicate tileが同期される。

### `tests/test_hex_adapter.gd`

1. `HexMapTileAdapter.vector_to_map_cell()` / `map_cell_to_vector()` のroundtripを維持する。
2. plain `TileMapLayer` apply helperはCore adapter互換として維持される。
3. `HexOverlayTileAdapter` のtile configをmanual overlay edit表示へ再利用できる。

### Analog Test

`tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md` を更新する。

確認項目:

1. `HexTileMapLayer` 選択後、Target ReloadだけでDocumentがTarget由来になりviewport編集できる。
2. Import / Loadを行わずに `Wall / Floor` が表示反映される。
3. `Shape`、`Floor Tile`、`Wall Tile`、`Object`、`Label`、Overlay要Tileが対象cell / marker / overlayだけを更新する。
4. 遠端cellをclickして、見えているcellとLast Edit hexが一致する。
5. plain `TileMapLayer` がscene先頭にあってもAuto targetが選択中 `HexTileMapLayer` を選ぶ。
6. 編集反応が全量redraw時より軽く感じられるかを観察する。
7. tactics tile / object atlasを使った表示確認を行う。

## 完了条件

- `./tools/test.sh` が成功する。
- Target Reloadだけで `HexTileMapLayer.hex_map` 由来documentが作成され、viewport編集できる。
- Manual Editの通常Target候補が `HexTileMapLayer` 中心になる。
- `HexTileMapLayer` のdisplay center / hit / highlight / markerが内部 `TileMapLayer` 基準で一致する。
- 全Edit Modeのper-click applyがcell / marker / overlay単位になる。
- Overlay要Tileをmanual editで配置・変更できる。
- tactics tile / object atlasが指定寸法のRGBA PNGとして存在する。
- analog testで初期化、Auto、遠端cell座標、反応速度を確認できる。
