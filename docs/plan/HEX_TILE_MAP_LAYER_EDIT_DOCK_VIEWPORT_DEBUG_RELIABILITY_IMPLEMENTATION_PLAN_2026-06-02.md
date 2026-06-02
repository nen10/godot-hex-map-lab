# HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_PLAN_2026-06-02.md

## 対象

- UX: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_UX_2026-06-02.md`
- Policy: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_POLICY_2026-06-02.md`
- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_REVIEW_2026-06-02.md`

## 入力

- `HexMapDocumentResource`
- `HexMapResource`
- Edit Mode
- Editor viewport click event
- Target option: Auto / explicit `HexTileMapLayer` / explicit plain `TileMapLayer`
- `HexTileMapLayer` internal display `TileMapLayer`
- TileSet tile size and orientation
- Dock debug status text

## 出力

- Copyable Dock debug text
- Stable target after invalid click
- Frontmost highlight / object marker / label marker
- Consistent click hit cell and displayed tile cell
- Error-free edit apply path
- Manual edit debug fixture / analog test

## 永続化されるschema

### `HexMapDocumentResource`

変更しない。

### `HexMapResource`

変更しない。

### Scene node

`HexTileMapLayer` に前面overlay childを追加する場合、internal childとして扱う。Scene保存時の重複防止をtestする。

## 対象ファイル

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/plugin.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_debug_scenes.gd`
- `tests/analog_test/`
- `tools/` または `debug/` 配下のdebug fixture
- `docs/TEST.md`
- `docs/knowledge/DEV_GODOT.md`

## 実装手順

1. Dock debug表示をcopy可能にする。
   - `_new_detail_label()` を置換または拡張する。
   - `Target Status`、`Last Edit`、`Save / Export`、必要ならmain statusをcopy可能にする。
   - selectable Labelが機能しない場合、read-only `TextEdit` / `LineEdit` へ置き換える。

2. UndoRedo errorを除去する。
   - 短期安定策としてEditor UndoRedoManager連携を廃止する、または `_commit_document_change()` がEditorUndoRedoManagerを検出した時は直接applyにfallbackする。
   - UndoRedoを維持する場合、`EditorUndoRedoManager.add_do_method(object, method, ...)` 用adapterを実装する。
   - Output errorが出ないtest / analog observationを追加する。

3. 無効clickでtargetを壊さない。
   - `forward_canvas_gui_input()` はtarget/documentが有効なmanual edit状態では、選択不能cellでもevent consumedにする。
   - `No editable cell` statusを出し、Last EditまたはDebug statusにno-hit reasonを残す。
   - invalid click後も次のvalid clickが反応するtestを追加する。

4. 内部 `TileMapLayer` をtarget候補から除外する。
   - `_collect_target_layers_recursive()` で `HexTileMapLayer` 配下のinternal childを探索しない、またはinternal display layerを明示除外する。
   - `_find_editor_selected_target_layer()` でもinternal `TileMapLayer` を除外する。
   - Auto targetが内部表示layerへ切り替わらないtestを追加する。

5. `HexTileMapLayer` 座標系をdisplay tileと一致させる。
   - `configure_display_tiles_from_texture()` / `ensure_display_tiles()` でtile sizeから `hex_size` を同期する。
   - 可能なら `hex_to_local()` / highlight center / marker centerを `_tile_map.map_to_local(vector_to_map_cell())` と一致させるhelperを追加する。
   - `local_to_cell_hit()` が表示tile中心をroundtripするtestを追加する。

6. Highlight / marker / labelを前面に表示する。
   - 前面overlay childを追加する。
   - highlight、object marker、label marker、path表示をoverlayへ移す。
   - tileが存在する通常状態でもhighlightが見えるtestまたはanalog observationを追加する。

7. `HexMapEditTool` apply pathを可視化結果と接続する。
   - Click後のtarget display stateを、実際のdisplay layerまたはoverlay stateから読む。
   - `wall -> floor` などのdocument traceとdisplay mutationが一致するtestを追加する。

8. Debug fixture / analog testを整備する。
   - `HexTileMapLayer` targetのmanual edit専用sceneまたはfixture resourceを作成する。
   - 既存 `tests/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md` のfollow-upとして、copyable debug、invalid click、foreground highlight、coordinate一致を含むanalog testを作る。
   - 必要なら `tools/debug_manual_edit.sh` を追加する。

9. Documentationを更新する。
   - `docs/TEST.md`
   - `docs/knowledge/DEV_GODOT.md`
   - 実装後review

## Test Plan

### `tests/test_editor_plugin.gd`

1. Detail/status controlsがcopy可能なcontrolで構築される。
2. invalid click後にvalid clickが継続してdocument / target displayを変更する。
3. Auto targetがinternal `TileMapLayer` を採用しない。
4. EditorUndoRedoManager error pathを直接applyまたはadapter pathへ流すsource検査。
5. `HexTileMapLayer` targetでclickしたdisplay cellとLast Edit hexが一致する。

### `tests/test_hex_tile_map_layer.gd`

1. display tile centerと `hex_to_local()` または新helperが一致する。
2. `local_to_cell_hit(display_center)` が同じhexを返す。
3. tile size変更時に `hex_size` またはdisplay coordinate helperが更新される。
4. overlay childがtile childより前面に存在する。
5. highlight / object marker / label marker stateがoverlayへ反映される。

### `tests/test_debug_scenes.gd`

1. manual edit debug fixtureがloadできる。
2. fixtureのtarget map、tile size、known floor/wall cells、expected click positionsが取得できる。

### Analog Test

`tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md`

確認項目:

1. Dock detail textをcopyできる。
2. invalid click後もvalid clickが反応する。
3. highlightがtile前面に見える。
4. 見えているcellと編集cellが一致する。
5. Output DockにEditorUndoRedoManager errorが出ない。

## 完了条件

- `./tools/test.sh` が成功する。
- analog testが作成され、ユーザーが実Editor確認できる。
- Dock debug表示がcopy可能になる。
- invalid click後の反応停止が解消される。
- `HexTileMapLayer` targetでtile表示、hit判定、highlight/marker座標が一致する。
- Godot Outputに `EditorUndoRedoManager.add_do_method` errorが出ない。
