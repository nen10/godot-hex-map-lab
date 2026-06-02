# HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY Analog Test

## Metadata

- Status: ready_for_editor_run
- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_REVIEW_2026-06-02.md`
- Implementation review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_REVIEW_2026-06-02.md`
- Source plans:
  - `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_UX_2026-06-02.md`
  - `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_POLICY_2026-06-02.md`
  - `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_PLAN_2026-06-02.md`
- Target Editor Plugin area: `Hex Map Edit` Dock, `HexTileMapLayer` viewport display
- Created date: 2026-06-02

## Use Case

- Actor: Godot Editor user
- Goal: `HexTileMapLayer` を親targetとして扱い、表示されているhex cellをクリックして編集結果、highlight、debug reportを確認できる。
- Success state: invalid click後もvalid clickが効き、highlight / markerがtile前面に表示され、`Copy Debug Report` で報告用textを一括copyでき、Godot OutputにEditorUndoRedoManager errorが出ない。

## Preconditions

- Godot project state: `res://addons/hex_map_kit/plugin.cfg` is enabled in the editor.
- Scene/resource files: 任意の2D sceneを開く。
- Required node setup: Sceneに `HexTileMapLayer` nodeを1つ作る。
- Data to prepare:
  - Generated map path: `res://.godot_user/analog_hex_layer_debug_source.tres`
  - Manual document path: `res://.godot_user/analog_hex_layer_debug_document.tres`

## Operation Steps

1. Godot Editorでprojectを開き、addonが有効であることを確認する。
2. Sceneに `HexTileMapLayer` nodeを追加し、node名を `AnalogHexLayer` にする。
3. `Hex Map Generate` Dockで小さなPrimary mapを作る。例: `Rectangle`, `Width = 5`, `Height = 4`, `Seed = 6202`, `Wall Prob = 0.25`, `Restore Connectivity = On`。
4. Targetで `AnalogHexLayer` を選び、必要なら `Use Sample Tiles` を実行する。
5. `Generate` を押し、viewport上にfloor / wall tileが表示されることを確認する。
6. `Save .tres` で `res://.godot_user/analog_hex_layer_debug_source.tres` に保存する。
7. `Hex Map Edit` Dockを開き、`Import Map` に上記pathを入力して `Import` を押す。
8. `Document` に `res://.godot_user/analog_hex_layer_debug_document.tres` を入力し、`Save` を押す。
9. Targetを `Auto` にし、Scene Treeで親 `AnalogHexLayer` を選択する。
10. `Target Status` が `HexTileMapLayer`、`tiles=ready`、floor / wall atlasを表示することを確認する。
11. Scene Treeで内部表示用 `TileMapLayer` が見えて選べる場合はそれを選択し、Targetが内部layer名ではなく親 `HexTileMapLayer` として扱われることを確認する。
12. `Edit Mode` を `Wall / Floor` にする。
13. viewport上のmap外または選択不能cellを1回clickする。
14. Dock statusが `No editable cell.` になり、Godot Editorの選択targetが意図せず別nodeへ移らないことを確認する。
15. 続けてviewport上のvisible floor cellをclickする。
16. クリックしたcellがwall tileへ変わり、同じcell上にhighlightがtile前面で見えることを確認する。
17. `Last Edit` が `document=yes`、`target=yes`、`display=yes`、atlas before / afterを表示することを確認する。
18. 別のvisible cellをclickし、highlightが最後に編集したcellだけへ移ることを確認する。
19. `Edit Mode` を `Object` にし、`Object` に `debug_marker`、`Properties` に `{"source":"analog"}` を入力する。
20. visible floor cellをclickし、object markerがtile前面で見えることを確認する。
21. `Edit Mode` を `Label` にし、`Label ID` に `debug_label`、`Text` に `A1` を入力する。
22. visible floor cellをclickし、label markerがtile前面で見えることを確認する。
23. `Copy Debug Report` を押す。
24. 任意のtext fieldへpasteし、reportに `Hex Map Edit Debug Report`、`target_status:`、`last_edit_status:`、`target_resolution_reason:`、`target_apply_reason:` が含まれることを確認する。
25. Godot Output Dockに `EditorUndoRedoManager` または `add_do_method` errorが出ていないことを確認する。

## Expected Observations

- `HexTileMapLayer` は親nodeとしてTarget解決され、内部 `TileMapLayer` をユーザーが意識せず操作できる。
- invalid click後も次のvalid clickがdocumentとtarget displayを更新する。
- Wall / Floor editは実tile表示に反映される。
- highlight、object marker、label markerはfloor / wall tileの裏に隠れない。
- Last Editはcanonical / visual cell、document mutation、target apply、display mutationを区別して表示する。
- Copy Debug ReportはDebug報告に必要なDock textとraw statusを1つのtextとしてcopyする。
- Output DockにEditorUndoRedoManager API mismatch errorが出ない。

## Failure Signals

- invalid click後、valid clickしてもLast Editや表示が更新されない。
- Target Statusが内部 `TileMapLayer` をtargetとして表示する。
- 見えているcellと編集されるcellがずれる。
- highlightやmarkerがtileに隠れて見えない。
- Copy Debug Reportのpaste結果にraw statusやLast Editが含まれない。
- Godot Outputに `Invalid call to function 'add_do_method' in base 'EditorUndoRedoManager'` が出る。

## Evidence To Attach

- `Target Status` のpaste結果。
- `Copy Debug Report` のpaste結果。
- invalid click後とvalid click後のviewport screenshot。
- Output Dockの該当エラー有無。
