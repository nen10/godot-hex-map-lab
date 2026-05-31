# MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_IMPLEMENTATION_PLAN_2026-06-01.md

## 参照

- Policy: `docs/plan/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md`
- Analog test: `.test/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md`
- Analog result: `docs/review/GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md`
- Failure analysis: `docs/review/GENERATED_MAP_MANUAL_EDIT_FAILURE_ANALYSIS_2026-06-01.md`
- Plan review: `docs/review/MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_PLAN_REVIEW_2026-06-01.md`
- Godot EditorPlugin API: https://docs.godotengine.org/en/stable/classes/class_editorplugin.html#class-editorplugin-private-method-forward-canvas-gui-input

## 目的

`GENERATED_MAP_MANUAL_EDIT` の Operation Steps 14-15 を実現する。ユーザーが Godot Editor 2D viewport 上の visible generated floor cell を click したとき、Hex Map Edit が target layer 上の cell を解決し、`HexMapDocumentResource` の wall / floor を更新し、target `TileMapLayer` を再描画する。

Operation Steps は変更しない。

## 対象範囲

1. EditorPlugin が 2D viewport input を受け取れる条件を満たす。
2. Hex Map Edit の Target 選択と Editor selection / handled object を同期し、ユーザーが hidden selection state を意識しなくてよい状態にする。
3. Editor viewport position を target layer local position へ変換する。
4. クリック失敗時に status label と optional debug log で失敗箇所を判別できるようにする。
5. headless test で直接 helper 経由だけでなく、viewport input bridge の主要分岐を固定する。

## 対象ファイル

- `addons/hex_map_kit/plugin.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `.test/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md`
- `docs/review/GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md`

## 入出力インターフェース

入力:

- Godot Editor 2D viewport `InputEventMouseButton`
- editor viewport transform / canvas transform
- selected or Target-bound `TileMapLayer` / `HexTileMapLayer`
- selected `HexMapDocumentResource`
- edit mode
- target layer orientation / tile settings

出力:

- target-local click position
- hit dictionary
  - `hex`
  - `visual_hex`
  - `exists`
  - `local`
- updated `HexMapDocumentResource`
- redrawn target layer
- UndoRedo action
- status message
- optional debug log

## 原因

### 1. `_handles()` 不足

Godot EditorPlugin の 2D viewport forwarding は `_handles()` が実装されていることを前提に呼び出される。現行 `plugin.gd` は `_forward_canvas_gui_input()` を持つが `_handles()` を持たないため、Dock は表示されても viewport click が Hex Map Edit へ届かない可能性が高い。

### 2. 座標変換不足

現行 `HexMapEditTool.forward_canvas_gui_input()` は以下の変換を行う。

```gdscript
var local_pos = (_target_layer as CanvasItem).to_local(mouse_event.position)
```

`mouse_event.position` は editor viewport space の座標であり、target `CanvasItem` の親キャンバス上の座標として扱うには不十分である。editor viewport transform を通して scene canvas/global coordinate に戻してから `target.to_local()` へ渡す必要がある。

## 実装計画

### 1. EditorPlugin input eligibility

`plugin.gd` に `_handles(object)` を追加する。

候補 API:

```gdscript
func _handles(object: Object) -> bool:
    if _edit_tool == null:
        return false
    if not _edit_tool.has_method("viewport_input_enabled"):
        return false
    if not _edit_tool.viewport_input_enabled():
        return false
    return object is CanvasItem
```

意図:

- Hex Map Edit に document と target がある場合だけ viewport input を受け取る。
- 2D scene selection が `CanvasItem` であれば input forwarding の対象にする。
- `TileMapLayer` だけに限定すると、Scene root や親 `Node2D` 選択時に Step 14 が失敗しやすいため、CanvasItem を対象にする。

### 2. Target selection sync

`HexMapEditTool.set_target_layer(layer)` または target option selected handler で、Editor selection を target layer へ同期する。

候補 API:

```gdscript
func _select_target_in_editor_if_possible() -> void:
    if not Engine.is_editor_hint():
        return
    if _target_layer == null or not is_instance_valid(_target_layer):
        return
    var selection = EditorInterface.get_selection()
    if selection == null:
        return
    selection.clear()
    selection.add_node(_target_layer)
```

適用タイミング:

1. Target option で explicit layer を選んだ直後。
2. `Refresh` 後に previous target が維持された直後。
3. `Import Map` 後、target が既にある場合。

Auto target の扱い:

- Auto が最初の editable layer を解決した場合、`Target` label に実 target path を出す。
- Auto 解決だけで selection を変えるとユーザーの Scene Tree 操作を奪いやすいため、実装段階では explicit target selection 時に selection sync する。
- Operation Step 11 は Target を設定またはRefreshして選択するため、この仕様で成立する。

### 3. Viewport-to-target-local coordinate conversion

`HexMapEditTool.forward_canvas_gui_input()` を直接変換から helper 経由へ変更する。

候補 API:

```gdscript
func forward_canvas_gui_input(event: InputEvent) -> bool:
    if not event is InputEventMouseButton:
        return false
    var mouse_event := event as InputEventMouseButton
    if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
        return false
    var local_pos = _editor_viewport_event_to_target_local(mouse_event)
    if local_pos == null:
        return false
    return apply_local_position(local_pos)
```

helper:

```gdscript
func _editor_viewport_event_to_target_local(event: InputEventMouseButton):
    if _target_layer == null or not (_target_layer is CanvasItem):
        _set_status("No editable target layer.")
        return null
    var scene_pos = _editor_viewport_position_to_scene_position(event.position)
    if scene_pos == null:
        _set_status("Cannot resolve editor viewport position.")
        return null
    return (_target_layer as CanvasItem).to_local(scene_pos)
```

`_editor_viewport_position_to_scene_position()` は Godot Editor 2D viewport の canvas transform を使う。

実装候補:

```gdscript
func _editor_viewport_position_to_scene_position(viewport_pos: Vector2):
    if Engine.is_editor_hint() and EditorInterface.has_method("get_editor_viewport_2d"):
        var viewport = EditorInterface.get_editor_viewport_2d()
        if viewport != null:
            return viewport.get_canvas_transform().affine_inverse() * viewport_pos
    return viewport_pos
```

検証時に Godot 4.6 の実際の Editor viewport transform API と合わない場合は、同じ helper の内部だけを差し替える。public flow と test は helper の契約に固定する。

### 4. Status and diagnostics

Step 14 failure時にユーザーが原因を報告できるよう、次の status を出す。

- target missing: `No editable target layer.`
- document missing: `No document selected.`
- outside cell: `No editable cell.`
- resolved cell: `Edited q,s,r`
- optional debug flag enabled時:
  - target path
  - edit mode
  - viewport position
  - scene position
  - local position
  - hit hex
  - exists

debug flag:

```gdscript
@export var debug_viewport_input := false
```

通常は `false`。アナログテスト失敗時だけ Inspector か test helper で有効化する。

### 5. Redraw and UndoRedo guard

`_commit_document_change()` 後、`_apply_document_to_target()` が呼ばれたことを status / test で確認できるようにする。

追加 helper:

```gdscript
func last_edit_status() -> Dictionary
```

返す値:

```gdscript
{
    "target_path": String,
    "mode": int,
    "hex": Vector3i,
    "exists": bool,
    "applied": bool,
}
```

この helper は debug / test 用であり、document schemaには保存しない。

## テスト計画

### `tests/test_editor_plugin.gd`

1. `_test_plugin_handles_canvas_item_when_map_edit_ready()`
   - plugin instance を作る。
   - edit tool に document と target layer を設定する。
   - `_handles(tile_layer)` が `true` になることを検証する。
   - document または target がない場合は `false` になることを検証する。

2. `_test_map_edit_tool_forward_canvas_gui_input_uses_viewport_transform()`
   - target `TileMapLayer` と document を作る。
   - editor viewport transform helper を test double で差し替える。
   - viewport position -> scene position -> target local position の結果が origin cell を指すようにする。
   - `forward_canvas_gui_input()` で wall/floor がtoggleされることを検証する。

3. `_test_map_edit_tool_target_selection_sync_for_explicit_target()`
   - scene root に複数 `TileMapLayer` を置く。
   - target option で明示選択した layer が `_target_layer` になり、editor selection sync helper が呼ばれることを test double で検証する。

4. `_test_map_edit_tool_forward_canvas_gui_input_reports_no_editable_cell()`
   - document外の cell をclickする viewport event を渡す。
   - `No editable cell.` が status に入ることを検証する。

5. `_test_map_edit_tool_forward_canvas_gui_input_redraws_target_layer()`
   - viewport input route から click する。
   - document wall state と target `TileMapLayer` atlas coords が同時に変わることを検証する。

### `docs/TEST.md`

Hex Map Edit Dock の手動確認に以下を追加する。

- Target を明示選択した後、Scene Tree selection が target layer へ同期される。
- `Wall / Floor` mode で viewport click すると status が `Edited ...` になる。
- クリックが外れた場合、status に原因が表示される。

## 実装手順

1. `HexMapEditTool.viewport_input_enabled()` を追加する。
2. `plugin.gd` に `_handles(object)` を追加する。
3. `HexMapEditTool` に explicit target selection sync helper を追加する。
4. `forward_canvas_gui_input()` の座標変換を helper 化する。
5. editor viewport transform を使う変換 helper を追加する。
6. click failure / success status と optional debug log を追加する。
7. headless tests を追加する。
8. `docs/TEST.md` の手動確認を更新する。
9. `./tools/test.sh` を実行する。
10. アナログテスト `GENERATED_MAP_MANUAL_EDIT` を Step 13 から再実施し、Step 14/15 を確認する。

## 完了判定

- Operation Step 14 の viewport click が `HexMapEditTool.apply_local_position()` に到達する。
- Operation Step 15 で clicked cell が floor から wall へ変わる。
- クリックが無効な場合、status から target / document / coordinate / outside-cell のどれが原因か判別できる。
- Undo / Redo は viewport input route でも document と target display を戻す。
- headless test が viewport input bridge を直接検証する。
- `docs/TEST.md` に Editor workflow test が記録される。
