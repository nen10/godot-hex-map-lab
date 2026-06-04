# HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_PLAN_2026-06-03.md

## 対象

- UX: `docs/plan/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_UX_2026-06-03.md`
- Policy: `docs/plan/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_POLICY_2026-06-03.md`
- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_PERFORMANCE_REVIEW_2026-06-03.md`

## 入力

- `HexMapResource`
- `HexMapDocumentResource`
- Generator Primary result `HexMapData`
- Generator Overlay result `HexOverlayData`
- Edit Dock cell edit command
- Manual overlay tile edit command
- 内部 `TileMapLayer` cell / TileSet / map coordinate
- Save / Export command

## 出力

- `HexTileMapLayer` 内部state
- base internal `TileMapLayer` 表示
- loop duplicate internal `TileMapLayer` 表示
- overlay / marker / label表示
- `HexMapResource` snapshot
- `HexMapDocumentResource` snapshot

## 永続化されるschema

### 短期

既存 `HexMapResource` / `HexMapDocumentResource` schemaを維持する。

### 中期

`HexTileMapLayer` のexport propertyとして保存されるstateを増やす場合、Resource snapshotとscene保存の二重管理を避ける。

採用候補:

- sceneには `hex_map` とdisplay tile設定だけを保存し、document payloadは明示document保存へ寄せる。
- または `HexMapDocumentResource` 相当のsubresourceを `HexTileMapLayer` に持たせる。

この選択は、実装前に追加reviewする。

## 対象ファイル

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_map_resource.gd`
- `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_debug_scenes.gd`
- `docs/TEST.md`
- `docs/manual/`
- `docs/knowledge/DEV_GODOT.md`

## 実装手順

1. `HexTileMapLayer` 内部state APIを設計する。
   - `load_map_resource(resource)`
   - `load_document_resource(document)`
   - `to_map_resource()`
   - `to_document_resource()`
   - `edit_cell(command)`
   - `set_cell_exists(hex, exists)`
   - `set_wall_state(hex, wall)`
   - `set_tile_override(hex, payload)`
   - `set_overlay_tile(hex, payload)`
   - `set_object_marker(hex, payload)`
   - `set_label_marker(hex, payload)`

2. `hex_map` propertyの互換動作を整理する。
   - setterは `load_map_resource()` を呼ぶ。
   - getterは直近snapshotまたは `to_map_resource()` を返す。
   - per-click更新で毎回Resourceを再生成しない。

3. 内部stateからbase internal `TileMapLayer` へincremental同期する。
   - floor / wall変更は対象map cellだけ `set_cell()` する。
   - shape add / removeは対象cellのset / eraseとpayload cleanupを行う。
   - loop duplicate表示はcanonical cell変更時に代表cellだけ同期する。

4. document payload表示を内部stateへ移す。
   - tile override cacheを内部stateへ統合する。
   - overlay tile entryを内部stateへ統合する。
   - Object / Label markerをfront overlay childで描画する。
   - document全量apply時も、内部stateを作ってから必要範囲を描く。

5. Edit Dockを `HexTileMapLayer` state APIへ接続する。
   - `_document` は保存 / debug / export用snapshotとして扱う。
   - click editはTarget APIにcommandを渡し、Targetから更新後snapshotを受け取る。
   - Last EditはTarget state diffとdisplay diffを読む。

6. Generator Dock Primary applyを `HexTileMapLayer` state APIへ接続する。
   - Primary generation resultは `load_map_data()` または `load_map_resource()` で適用する。
   - `Add new layer...` は引き続き `HexTileMapLayer` を作る。
   - plain `TileMapLayer` apply helperはCore / legacy testへ移す。

7. Overlay要Tile / Overlay apply統合を設計する。
   - Manual overlay tile edit resultとGenerator Overlay resultを `HexTileMapLayer` の別internal `TileMapLayer` に置くか、overlay canvasへ描くかを比較する。
   - Item tile mappingが必要な場合はoverlay internal `TileMapLayer` を採用候補にする。
   - Marker / labelだけで足りる場合はoverlay canvasを採用候補にする。

8. Save / Exportを内部state snapshotに切り替える。
   - `to_map_resource()` / `to_document_resource()` から保存する。
   - 既存document Load / Import結果とroundtripするtestを追加する。

9. Migration / debug helperを残す。
   - plain `TileMapLayer` から現表示cellを読むhelperは、migration / debug専用に限定する。
   - UI通常Targetには戻さない。

10. Documentationを更新する。
   - Manual: `HexTileMapLayer` がPrimary map nodeであることを明記する。
   - TEST: Core adapterとEditor UX targetの違いを分ける。
   - DEV_GODOT: Resource snapshotとlive stateの分離を追記する。

## Test Plan

### `tests/test_hex_tile_map_layer.gd`

1. `load_map_resource()` が内部stateとbase `TileMapLayer` を更新する。
2. `set_wall_state()` が対象cellだけを更新する。
3. `set_cell_exists()` が対象cellの表示とpayload cleanupを行う。
4. tile override / object / label stateが保存snapshotへ出力される。
5. overlay tile stateが保存snapshotへ出力される。
6. `to_document_resource()` / `load_document_resource()` がroundtripする。
7. loop duplicate表示がincremental edit後も同期する。

### `tests/test_editor_plugin.gd`

1. Edit DockがTarget state APIで編集し、document snapshotを更新する。
2. Generator Primary applyが `HexTileMapLayer` state APIを使う。
3. Save / ExportがTarget internal stateからResourceを生成する。
4. plain `TileMapLayer` は通常Primary Target候補に出ない。
5. Manual overlay tile editとGenerator Overlay applyのTarget typeがPrimaryと混ざらない。

### `tests/test_hex_adapter.gd`

1. plain `TileMapLayer` adapter helperはCore互換として維持される。
2. `HexMapDocumentAdapter` と `HexTileMapLayer` state snapshotの変換が一致する。

### Analog Test

1. 大きいmapで連続clickして、全量redraw時より反応が軽いことを観察する。
2. Generate、Edit、Save、Reload、Exportの同一Target roundtripを確認する。
3. Overlay tile / marker / labelの表示layerが `HexTileMapLayer` 配下で一貫していることを確認する。

## 完了条件

- `HexTileMapLayer` 内部stateがGenerator / Edit / Save / Exportの共通経路になる。
- Resourceはlive edit中のper-click transportではなくsnapshotとして扱われる。
- Primary map編集でplain `TileMapLayer` Targetを必要としない。
- per-click editが対象cell中心のincremental更新になる。
- Overlay要Tileもmanual edit / generator applyの両方から扱える。
- `./tools/test.sh` とanalog testが成功する。
