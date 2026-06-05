# HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY Analog Test

## Metadata

- Status: ready_for_editor_run
- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_REVIEW_2026-06-02.md`
- Implementation review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_REVIEW_2026-06-02.md`
- Source plans:
  - `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_UX_2026-06-02.md`
  - `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_POLICY_2026-06-02.md`
  - `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_PLAN_2026-06-02.md`
  - `docs/plan/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_UX_2026-06-03.md`
  - `docs/plan/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_POLICY_2026-06-03.md`
  - `docs/plan/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_PLAN_2026-06-03.md`
- Target Editor Plugin area: `Hex Map Edit` Dock, `HexTileMapLayer` viewport display
- Created date: 2026-06-02

## Use Case

- Actor: Godot Editor user
- Goal: `HexTileMapLayer` を親targetとして扱い、表示されているhex cellをクリックして編集結果、highlight、debug reportを確認できる。
- Success state: Target Reloadだけでtarget由来documentが作られ、invalid click後もvalid clickが効き、highlight / marker / Overlay Tileがtile前面に表示され、`Copy Debug Report` で報告用textを一括copyでき、Godot OutputにEditorUndoRedoManager errorが出ない。

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
6. `Hex Map Edit` Dockを開き、Targetを `Auto` にし、Scene Treeで親 `AnalogHexLayer` を選択して `Refresh` を押す。
7. `Document` 表示または `Copy Debug Report` で `document_source: target` が確認でき、`Import Map` / `Load` を行わなくても `viewport_input_enabled` 相当の編集状態になっていることを確認する。
8. `Target Status` が `HexTileMapLayer`、`tiles=ready`、floor / wall atlasを表示することを確認する。
9. Scene Treeで内部表示用 `TileMapLayer` が見えて選べる場合はそれを選択し、Targetが内部layer名ではなく親 `HexTileMapLayer` として扱われることを確認する。
10. Target候補の通常listにplain `TileMapLayer` が出ず、`HexTileMapLayer` が中心に表示されることを確認する。
11. `Target TileSet / Atlas` で `Tactics Flat 64x57` または `Tactics Pointy 57x64` を明示選択して `Apply Sample` を押し、固定defaultではなくユーザー操作でsample / preset assetが反映されることを確認する。
12. `Edit Mode` を `Wall / Floor` にする。
13. viewport上のmap外または選択不能cellを1回clickする。
14. Dock statusが `No editable cell.` になり、Godot Editorの選択targetが意図せず別nodeへ移らないことを確認する。
15. 続けてviewport上のvisible floor cellをclickする。
16. クリックしたcellがwall tileへ変わり、同じcell上にhighlightがtile前面で見えることを確認する。
17. `Last Edit` が `document=yes`、`target=yes`、`display=yes`、atlas before / after、`reason=Applied cell to HexTileMapLayer.` を表示することを確認する。
18. 別のvisible cellをclickし、highlightが最後に編集したcellだけへ移ることを確認する。
19. `Edit Mode` を `Object` にし、`Object` に `debug_marker`、`Properties` に `{"source":"analog"}` を入力する。
20. visible floor cellをclickし、object markerがtile前面で見え、`reason=Applied marker to HexTileMapLayer.` が表示されることを確認する。
21. `Edit Mode` を `Label` にし、`Label ID` に `debug_label`、`Text` に `A1` を入力する。
22. visible floor cellをclickし、label markerがtile前面で見えることを確認する。
23. `Edit Mode` を `Overlay Tile` にし、`Overlay Item` に `Treasure`、Tile Source / Atlas / AltにTarget TileSet上の有効tile payloadを入力してvisible floor cellをclickする。
24. Overlay tileが対象cellに表示され、`Last Edit` に `reason=Applied overlay tile to HexTileMapLayer.` とoverlay count変化が出ることを確認する。
25. viewportの端または遠端に近いvisible cellをclickし、見えているcell、highlight中心、`Last Edit` のhexが一致することを確認する。
26. `Copy Debug Report` を押す。
27. 任意のtext fieldへpasteし、reportに `Hex Map Edit Debug Report`、`document_source: target`、`target_status:`、`last_edit_status:`、`target_resolution_reason:`、`target_apply_reason:` が含まれることを確認する。
28. 必要なら `Document` に `res://.godot_user/analog_hex_layer_debug_document.tres` を入力し、`Save` でtarget由来documentを保存できることを確認する。
29. Godot Output Dockに `EditorUndoRedoManager` または `add_do_method` errorが出ていないことを確認する。

## Expected Observations

- `HexTileMapLayer` は親nodeとしてTarget解決され、内部 `TileMapLayer` をユーザーが意識せず操作できる。
- Target Reloadだけで `HexTileMapLayer.hex_map` 由来の未保存documentが作られ、Import / Loadなしで編集できる。
- invalid click後も次のvalid clickがdocumentとtarget displayを更新する。
- Wall / Floor editは実tile表示に反映される。
- highlight、object marker、label marker、Overlay Tileはfloor / wall tileの裏に隠れない。
- Last Editのtarget apply reasonがcell / marker / overlay tile単位の反映を示す。
- 遠端cellでも内部 `TileMapLayer` 基準のhit / highlight / marker中心が一致する。
- Last Editはcanonical / visual cell、document mutation、target apply、display mutationを区別して表示する。
- Copy Debug ReportはDebug報告に必要なDock textとraw statusを1つのtextとしてcopyする。
- Output DockにEditorUndoRedoManager API mismatch errorが出ない。

## Failure Signals

- invalid click後、valid clickしてもLast Editや表示が更新されない。
- Target Statusが内部 `TileMapLayer` をtargetとして表示する。
- Target Reload後にImport / Loadを要求される、またはdebug reportのdocument sourceがtargetにならない。
- 見えているcellと編集されるcellがずれる。
- highlight、marker、Overlay Tileがtileに隠れて見えない。
- Last Editが全量apply reasonだけを示し、cell / marker / overlay単位のreasonが出ない。
- Copy Debug Reportのpaste結果にraw statusやLast Editが含まれない。
- Godot Outputに `Invalid call to function 'add_do_method' in base 'EditorUndoRedoManager'` が出る。

## Evidence To Attach

- `Target Status` のpaste結果。
- `Copy Debug Report` のpaste結果。
- invalid click後とvalid click後のviewport screenshot。
- Output Dockの該当エラー有無。
