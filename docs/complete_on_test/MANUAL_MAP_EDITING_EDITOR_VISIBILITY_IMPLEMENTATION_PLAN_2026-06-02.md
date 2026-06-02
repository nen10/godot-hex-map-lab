# MANUAL_MAP_EDITING_EDITOR_VISIBILITY_IMPLEMENTATION_PLAN_2026-06-02.md

## 参照方針

- UX: `docs/complete_on_test/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_UX_2026-06-02.md`
- 方針: `docs/complete_on_test/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_POLICY_2026-06-02.md`
- 採用案: Dock 内の target readiness detail、last edit trace、save/export checkpoint、last-only highlight。

## 対象ファイル

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md`
- `docs/TEST.md`

## 入出力インターフェース

入力:

- `HexMapEditTool._document`
- `HexMapEditTool._target_layer`
- edit mode
- viewport `InputEventMouseButton`
- `_local_hit()` result
- before / after `HexMapDocumentResource` snapshot
- target `TileMapLayer` / `HexTileMapLayer` tile state
- save / export path

出力:

- `_target_status_detail: Dictionary`
- `_last_edit_status: Dictionary`
- `_last_persistence_status: Dictionary`
- Dock detail labels
- last-only highlight on `HexTileMapLayer`

## Trace schema

Trace は Editor Dock session state であり、`.tres` へ保存しない。

### Target readiness

```gdscript
{
    "target_path": String,
    "target_class": String,
    "is_hex_tile_map_layer": bool,
    "tile_set_present": bool,
    "floor_source_id": int,
    "floor_atlas_coords": Vector2i,
    "wall_source_id": int,
    "wall_atlas_coords": Vector2i,
    "used_cell_count": int,
    "loop_display_mode": int,
    "ready": bool,
    "message": String,
}
```

plain `TileMapLayer` の tile ids は Hex Map Edit の document adapter default を使う。`HexTileMapLayer` は target の exported floor / wall fields を読む。

### Last edit trace

```gdscript
{
    "target_path": String,
    "target_class": String,
    "mode": int,
    "viewport_position": Vector2,
    "scene_position": Vector2,
    "local_position": Vector2,
    "hex": HexVector,
    "visual_hex": HexVector,
    "exists_before": bool,
    "exists_after": bool,
    "wall_before": bool,
    "wall_after": bool,
    "document_changed": bool,
    "target_applied": bool,
    "target_used_cells_before": int,
    "target_used_cells_after": int,
    "display_atlas_before": Vector2i,
    "display_atlas_after": Vector2i,
    "display_changed": bool,
    "message": String,
}
```

`HexTileMapLayer` target の `display_atlas_*` は canonical base tile と loop copy tile のうち、hit に対応する代表を取得する。内部 layer の直接参照が必要になる場合は、`HexTileMapLayer` に read-only helper を追加する。

### Persistence checkpoint

```gdscript
{
    "operation": "save_document" | "export_map",
    "path": String,
    "ok": bool,
    "error": int,
    "resource_class": String,
    "cell_count": int,
    "wall_count": int,
    "message": String,
}
```

## UI計画

Hex Map Edit Dock に以下を追加する。

- `Target Status` label
- `Last Edit` detail label
- `Save / Export` detail label

表示例:

```text
Target: HexTileMapLayer res://Scene/MapLayer tiles=ready loop=toric used=24
Last Edit: wall/floor q0,s0,r0 floor->wall document=yes target=yes tile=(0,0)->(1,0)
Save: res://.godot_user/analog_manual_document.tres cells=24 walls=9 ok
```

compact status label は既存の `Edited ...`、`Saved document.`、`Exported HexMapResource.` を維持する。

## 実装計画

### 1. Target readiness helper

`HexMapEditTool` に追加する。

```gdscript
func target_readiness_status() -> Dictionary
func _refresh_target_status_detail() -> void
func _format_target_status_detail(status: Dictionary) -> String
```

更新タイミング:

1. `set_target_layer()`
2. `refresh_target_layer_options()`
3. `_on_target_selected()`
4. `import_map_resource()`
5. `_apply_document_to_target()`

### 2. Last edit trace helper

`_apply_hit(hit)` で before / after の document state と target state を採取する。

追加 helper:

```gdscript
func _document_cell_state(document, hex) -> Dictionary
func _target_display_state(hex, visual_hex) -> Dictionary
func _target_used_cell_count() -> int
func _build_last_edit_trace(hit: Dictionary, before, after, applied: bool) -> Dictionary
func _refresh_last_edit_detail() -> void
```

`_commit_document_change()` は target apply の bool を返す helper へ寄せる。

候補:

```gdscript
func _commit_document_change(before, after, action_name: String) -> bool
```

UndoRedo がある場合も commit 後の `_last_applied_to_target` を trace に使う。

### 3. Viewport position trace

`_editor_viewport_event_to_target_local()` で viewport / scene / local position を `_pending_viewport_trace` に保存し、`_apply_hit()` の trace に合流する。

debug print は `debug_viewport_input` 有効時の補助として残し、Dock detail を primary observation にする。

### 4. Save / Export checkpoint

`save_document()` と `export_map_resource_to_path()` の成功 / 失敗時に `_last_persistence_status` を更新する。

追加 helper:

```gdscript
func _document_summary(document) -> Dictionary
func _set_persistence_status(operation: String, path: String, ok: bool, error: int = OK) -> void
func _refresh_persistence_detail() -> void
```

### 5. Last-only highlight

`HexTileMapLayer` に helper を追加する。

```gdscript
func remove_highlight(hex: HexVector) -> void
```

`HexMapEditTool` は `_last_highlight_hex` を持ち、次の編集で前回 highlight だけを消してから新しい canonical cell を highlight する。

### 6. Analog test更新

`tests/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md` に観察点を追加する。

- Target 選択後に target class / TileSet / atlas readiness を記録する。
- Step 14 / 15 後に Last Edit detail を記録する。
- Save / Export 後に checkpoint detail を記録する。
- viewport 無変化時は Last Edit detail の `document_changed`、`target_applied`、`display_changed` を報告する。

## Resource / saved document schema

`HexMapDocumentResource` と `HexMapResource` の schema 変更はない。

追加する trace は Dock session state であり、保存対象ではない。Save / Export checkpoint は保存結果の観察情報として表示する。

## テスト計画

### `tests/test_editor_plugin.gd`

1. `_test_map_edit_tool_target_readiness_reports_plain_tile_map_layer()`
   - plain `TileMapLayer` target を設定する。
   - target class、TileSet presence、used cell count、ready message を検証する。

2. `_test_map_edit_tool_target_readiness_reports_hex_tile_map_layer_loop_state()`
   - `HexTileMapLayer` target を設定し、loop display mode と floor / wall atlas を検証する。

3. `_test_map_edit_tool_last_edit_trace_distinguishes_document_and_redraw()`
   - viewport input route から wall / floor click を行う。
   - `document_changed == true`、`target_applied == true`、`display_changed == true`、before / after wall state を検証する。

4. `_test_map_edit_tool_last_edit_trace_reports_target_apply_failure()`
   - document はあるが target が invalid になる fixture を作る。
   - mutation と apply failure の表示境界を検証する。

5. `_test_map_edit_tool_persistence_checkpoint_reports_save_and_export_counts()`
   - save document と export map を実行し、path、resource class、cell count、wall count を検証する。

### `tests/test_hex_tile_map_layer.gd`

1. `_test_remove_highlight_removes_single_cell()`
   - 2 cell を highlight し、片方だけ remove できることを検証する。

### `docs/TEST.md`

Hex Map Edit Dock の手動確認に以下を追加する。

- Target Status の target class、TileSet、atlas、loop state を確認する。
- Last Edit detail の document / target / display state を確認する。
- Save / Export detail の path と count を確認する。

## 実装手順

1. Target readiness helper と label を追加する。
2. Last edit trace schema と label を追加する。
3. `_apply_hit()` に before / after document state と target display state の採取を追加する。
4. Save / Export checkpoint trace を追加する。
5. `HexTileMapLayer.remove_highlight()` と last-only highlight を追加する。
6. `tests/test_editor_plugin.gd` に target readiness / edit trace / persistence checkpoint tests を追加する。
7. `tests/test_hex_tile_map_layer.gd` に highlight test を追加する。
8. `tests/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md` と `docs/TEST.md` を更新する。
9. `./tools/test.sh` を実行する。

## 完了判定

- viewport click 後の document mutation と target redraw が trace で分離される。
- target class と display readiness が Dock 上で確認できる。
- Save / Export の結果が path、resource class、cell count、wall count で確認できる。
- last edit highlight が最後の canonical cell だけを示す。
- `tests/test_editor_plugin.gd`、`tests/test_hex_tile_map_layer.gd`、analog test 手順が計画内容に接続される。
