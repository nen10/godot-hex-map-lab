# HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_PLAN_2026-06-03.md

## 対象

- UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_UX_2026-06-03.md`
- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_POLICY_2026-06-03.md`
- Review: `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_PERFORMANCE_REVIEW_2026-06-03.md`
- Completed review: `docs/review/_history/EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`
- Boundary review: `docs/review/_history/HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md`

## 現状反映 2026-06-05

- `HexTileMapLayer.display_tile_set_resource` とTarget TileSet resource persistenceは実装済みである。
- Editor DockのTarget path/resource selection、Target Status、mode-specific payload、Generation Dock path action labelは実装済みである。
- Manual editのOverlay Tile / Object / Label表示責務は `HexTileMapLayer` 配下へ移っている。
- `HexTileMapLayer.apply_document_cell(document, hex)` は、現在もper-clickでdocument複製 / Resource変換 / `_data` 再構築に戻る主要な残課題である。
- Object scene layerとobject asset database拡張はこのPlanから除外し、Object Asset Boundaryの別Flowへ送る。

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

既存 `HexMapResource` / `HexMapDocumentResource` schemaを維持する。`display_tile_set_resource` によるTarget TileSet scene persistenceは既存schemaとして扱う。

### 中期

sceneには `hex_map` snapshot、display tile設定、node構成を保存し、document payloadは明示的な `HexMapDocumentResource` 保存へ寄せる。`HexMapDocumentResource` 相当のsubresourceを `HexTileMapLayer` に持たせる案は、このFlowでは実装しない。

## 対象ファイル

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_map_resource.gd`
- `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_editor_path_selector.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_debug_scenes.gd`
- `docs/TEST.md`
- `docs/manual/`
- `docs/knowledge/DEV_GODOT.md`

## 実装手順

1. 現在のfull-processing境界をtestで固定する。
   - `HexTileMapLayer.apply_document_cell(document, hex)` がper-click通常経路で使われている箇所を特定する。
   - Edit Dock click編集で `HexMapDocumentAdapter.duplicate_document()` / `to_map_resource()` / `to_map_data()` / `_normalize_data()` へ戻らないことを検証できるtest seamを作る。

2. `HexTileMapLayer` 内部state command APIを設計する。
   - `load_map_resource(resource)`
   - `load_document_resource(document)`
   - `to_map_resource()`
   - `to_document_resource()`
   - `apply_edit_command(command)`
   - `inverse_edit_command(command)`
   - `set_cell_exists(hex, exists)`
   - `set_wall_state(hex, wall)`
   - `set_tile_override(hex, payload)`
   - `set_overlay_tile(hex, payload)`
   - `set_object_marker(hex, payload)`
   - `set_label_marker(hex, payload)`

3. command payloadを定義する。
   - `mode`: floor / wall / shape / overlay_tile / object / label
   - `hex`: canonical hex coordinate
   - `before`: 対象hex周辺の最小semantic state
   - `after`: 適用後の最小semantic state
   - `display`: 更新したbase / overlay / markerの差分情報
   - `snapshot_dirty`: Save / Export用snapshot cacheを無効化するflag

4. `hex_map` propertyの互換動作を整理する。
   - setterは `load_map_resource()` を呼ぶ。
   - getterは直近snapshotまたは `to_map_resource()` を返す。
   - per-click更新ではResourceを毎回再生成しない。
   - scene保存では `hex_map` snapshotと `display_tile_set_resource` を維持し、document payloadは暗黙保存しない。

5. 内部stateからbase internal `TileMapLayer` へincremental同期する。
   - floor / wall変更は対象map cellだけ `set_cell()` する。
   - shape add / removeは対象cellのset / eraseとpayload cleanupを行う。
   - loop duplicate表示はcanonical cell変更時に必要なduplicate cellだけ同期する。
   - `_data` 全量再構築はLoad / Import / explicit rebuildに限定する。

6. document payload表示を内部stateへ移す。
   - tile override cacheを内部stateへ統合する。
   - overlay tile entryを既存overlay表示層のstateへ統合する。
   - Object / Label markerは既存front overlay childのstateへ接続する。
   - document全量apply時も、内部stateを作ってから必要範囲を描く。

7. Edit Dockを `HexTileMapLayer` state APIへ接続する。
   - `_document` は保存 / debug / export用snapshot cacheとして扱う。
   - click editはTarget APIにcommandを渡し、Targetから更新後の最小diffを受け取る。
   - Undo / Redoはdocument全量before / afterではなく、command / inverse commandを使う。
   - Last EditはTarget state diffとdisplay diffを読む。

8. Generator Dock Primary applyを `HexTileMapLayer` state APIへ接続する。
   - Primary generation resultは `load_map_data()` または `load_map_resource()` で適用する。
   - `Add new layer...` は引き続き `HexTileMapLayer` を作る。
   - plain `TileMapLayer` apply helperはCore / legacy testへ移す。

9. Generator Overlay applyを既存overlay state APIへ接続する。
   - Manual overlay tile edit resultとGenerator Overlay resultを同じoverlay stateへ入れる。
   - plain `TileMapLayer` Target要求が残る場合は、legacy / migration helperとして分離する。
   - Object scene layerはこの手順に含めない。

10. Save / Exportを内部state snapshotに切り替える。
   - `to_map_resource()` / `to_document_resource()` から保存する。
   - 既存document Load / Import結果とroundtripするtestを追加する。
   - Target由来documentはunsaved snapshotとして扱い、document保存は明示操作に限定する。

11. Migration / debug helperを残す。
   - plain `TileMapLayer` から現表示cellを読むhelperは、migration / debug専用に限定する。
   - UI通常Targetには戻さない。

12. Documentationを更新する。
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
8. `apply_edit_command()` がper-click通常経路で `to_map_resource()` / `to_map_data()` / `_normalize_data()` を要求しない。
9. `inverse_edit_command()` が対象hexのsemantic stateと表示を復元する。

### `tests/test_editor_plugin.gd`

1. Edit DockがTarget state APIで編集し、document snapshotを更新する。
2. Generator Primary applyが `HexTileMapLayer` state APIを使う。
3. Save / ExportがTarget internal stateからResourceを生成する。
4. plain `TileMapLayer` は通常Primary Target候補に出ない。
5. Manual overlay tile editとGenerator Overlay applyのTarget typeがPrimaryと混ざらない。
6. Edit Dock Undo / Redoがdocument全量snapshotではなくcommand / inverse commandで動く。
7. Target由来documentがunsaved snapshotとして表示され、保存は明示操作で行われる。

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
