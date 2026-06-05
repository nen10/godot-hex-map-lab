# EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_PLAN_2026-06-05

## 対象

- UX: `docs/plan/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/UX.md`
- Policy: `docs/plan/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/POLICY.md`
- Implementation review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md`

## 入力

- Direct resource path text: `res://...`
- `EditorFileDialog` selected file / directory path
- `EditorResourcePicker` selected resource
- `HexMapDocumentResource`
- `HexMapResource`
- `HexOverlayResource`
- `TileSet`
- atlas image resource
- `HexTileMapLayer` target and internal base / overlay `TileMapLayer`
- Source Registry entries and resource paths
- Generate History directory
- Save / Export target path
- Overlay item key and tile payload

## 出力

- Browse / Save / Directory dialog付きpath selector rows
- disabled button and reason status
- Target Status detail: TileSet path、source数、tile size、floor / wall / overlay payload、overlay visibility
- Target由来documentの未保存 / 保存済み状態
- mode別Floor / Wall / Overlay tile payload
- `Select Internal TileMapLayer` wording and status
- PackedScene save / reload persistence test for Target TileSet
- updated `docs/TEST.md` and analog test steps

## 永続化されるschema

### `HexMapDocumentResource`

変更しない。asset path、TileSet reference、Object scene referenceは保存しない。

### `HexMapResource` / `HexOverlayResource`

変更しない。Import / Export / Source Registry / Generate Historyの保存先pathだけがUIで扱われる。

### `HexTileMapLayer`

Target TileSetは引き続き内部 `TileMapLayer.tile_set` を第一候補にする。`PackedScene.pack()` / reloadで維持されない場合は、`HexTileMapLayer` のexport propertyまたは明示Resource propertyへTileSet参照を持たせる。

### Editor UI state

Floor / Wall / Overlay tile payloadの最後の値はDock session stateとして保持する。永続resource schemaには追加しない。

## 対象ファイル

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_editor_path_selector.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md`
- `docs/TEST.md`
- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/knowledge/DEV_GODOT.md`

## 実装手順

1. path selector helperを追加する。
   - `addons/hex_map_kit/editor/hex_map_editor_path_selector.gd` を追加する。
   - `LineEdit`、Browse / Save / Dir button、primary action button、status / tooltip設定を持つControlにする。
   - `file_mode`、filters、placeholder、action label、required resource class、validation callbackを設定できるようにする。
   - 共有helperが過剰になる場合は、file dialog / validation factoryだけを共有し、row layoutは各Dockへ残す。

2. Edit DockのDocument / Import Map / Exportをselector化する。
   - Document Loadは `*.tres` open filterと `HexMapDocumentResource` validationを使う。
   - Document SaveはSave dialogを使い、保存成功後に `_document_path` と `document_source` 表示を更新する。
   - Import Mapは `HexMapResource` validationを使う。
   - ExportはSave dialogを使い、`HexMapResource` 出力であることをSave / Export Statusへ出す。
   - direct path setterと既存test helperは維持する。

3. Edit DockのAtlas ImageをBrowse操作へ寄せる。
   - `Atlas Image` rowにBrowse buttonを追加し、image file filterを設定する。
   - 選択後はpath textへ反映し、Target TileSetへ適用する。
   - Targetがない、TileSetがない、texture load不可、tile size不明の場合はApplyをdisabledにし、Statusへ理由を出す。
   - sample presetは選択と適用状態が分かる表示にする。

4. Generation Dock側のpath操作と状態表示を揃える。
   - Source Registry `Load .tres`、Generate History `Dir`、Save `.tres`、Select Atlas Imageの文言・filter・StatusをEdit Dockと揃える。
   - reload失敗時はpush_errorだけでなくSource Registry Statusへ理由を出す。
   - Generate Historyがoff / directory unset / directory selectedを明確に表示する。

5. Target Statusを拡張する。
   - Target class / path、document source、document saved path、TileSet resource path、TileSet source count、tile sizeを表示する。
   - floor / wall / overlay payloadの `source_id`、`atlas_coords`、`alternative_tile` を表示する。
   - overlay internal layerのvisibility / z-index相当情報を表示する。
   - `Copy Debug Report` に同じ情報を含める。

6. Target由来documentの保存状態を明確にする。
   - Target Reload由来のdocumentを `Unsaved target document` と表示する。
   - Save成功後の `document_source` 表示を保存path由来へ更新する。
   - Export成功はdocument保存ではないことをSave / Export Statusへ出す。
   - Save / Export checkpoint testの期待値を更新する。

7. Target TileSet scene persistenceを検証する。
   - `tests/test_hex_tile_map_layer.gd` または `tests/test_editor_plugin.gd` に `PackedScene.pack()` / instantiate testを追加する。
   - Target TileSet、atlas source、tile size、floor / wall source idがreload後も維持されることを確認する。
   - 失敗する場合は、`HexTileMapLayer` 側に保存用TileSet propertyを追加し、internal childへ同期する。

8. `Select Display Layer` を改名し、statusを追加する。
   - Button labelを `Select Internal TileMapLayer` へ変更する。
   - 押下後、Editor selectionを内部layerへ移したことをStatusへ出す。
   - Auto targetは親 `HexTileMapLayer` へ解決されることをdebug reportで確認できるようにする。

9. Overlay Tile payloadをmode別に保持する。
   - `_floor_tile_payload`、`_wall_tile_payload`、`_overlay_tile_payload` 相当のstateに分ける。
   - mode変更時に該当payloadをUIへ反映する。
   - `Read Target Tiles` / `Apply Target Tiles` が現在modeのpayloadへ作用するようにする。
   - Overlay item keyはdocument内既存key候補をOptionButtonに出し、free textも維持する。

10. Docs / analog testを更新する。
   - `docs/TEST.md` のTest pathへpath selector、disabled state、Target Status、PackedScene persistence、Overlay payload分離を追加する。
   - analog testへDocument Browse / Save As、Atlas Browse、Source Registry Load、Generate History Dir、Select Internal TileMapLayer、Target由来document保存を追加する。
   - `docs/manual/MANUAL_EDITOR_PLUGIN.md` のpath操作説明を更新する。
   - Godot editor file dialog / internal child persistenceで得た知見を `docs/knowledge/DEV_GODOT.md` へ記録する。

## Test Plan

### `tests/test_editor_plugin.gd`

1. Document path selectorでfile selected handlerから `HexMapDocumentResource` をLoadできる。
2. Target由来documentをSave dialog handler経由で保存し、path / document source / statusが更新される。
3. Import Map selectorで `HexMapResource` をImportできる。
4. Export selectorで `HexMapResource` を保存でき、document保存と区別される。
5. Atlas Image selectorでimage pathをTarget TileSetへ適用できる。
6. invalid path / missing target / missing TileSet時に該当buttonがdisabledまたはreason statusを出す。
7. Target StatusにTileSet path、source数、tile size、floor / wall / overlay payloadが含まれる。
8. `Select Internal TileMapLayer` 押下後のstatusとAuto target resolution reasonが期待通りになる。
9. Overlay Tile modeのpayloadがFloor / Wall Tile modeと独立して保持される。
10. Source Registry reload失敗時にSource Registry Statusへ理由が出る。
11. Generate History directory選択後のlabelと保存pathが期待通りになる。

### `tests/test_hex_tile_map_layer.gd`

1. Target TileSetを持つ `HexTileMapLayer` を `PackedScene.pack()` / instantiateして、TileSetとatlas sourceが維持される。
2. internal base `TileMapLayer` とoverlay `TileMapLayer` のvisibility / z-index相当情報をStatus取得helperから読める。

### Analog Test

`tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md` を更新する。

確認項目:

1. Edit DockでDocument Browse / Loadを実行する。
2. Target Reload由来documentをSave Asで保存し、Statusが未保存から保存済みへ変わる。
3. Import Map Browse / Export Save Asを実行する。
4. Atlas Image Browseでcustom atlasをTarget TileSetへ適用する。
5. `Select Internal TileMapLayer` を押し、標準TileMap panel表示の有無とStatusを観察する。
6. Overlay Tile / Floor Tile / Wall Tileを切り替え、payloadが混ざらないことを確認する。
7. Source Registry Load、Generate History Dir、Generation Saveのpath操作が一貫していることを確認する。
8. scene保存 / reload後にTarget TileSet / atlas表示が維持されることを確認する。

## 完了条件

- `./tools/test.sh` が成功する。
- Edit DockとGeneration Dockの主要path操作がBrowse / Save / Dir dialogまたはResourcePickerで完結する。
- direct path入力はadvanced操作として維持される。
- invalid stateでbuttonがdisabledになるか、押下前に原因Statusが見える。
- Target由来documentの未保存 / 保存済み状態がStatusとdebug reportで分かる。
- Target TileSet / atlas sourceのPackedScene保存 / reload永続性が確認される。
- Overlay Tile payloadがFloor / Wall Tile payloadと独立する。
- analog testにpath selector UX、Target Status、scene persistence、Overlay payload分離の確認手順がある。
