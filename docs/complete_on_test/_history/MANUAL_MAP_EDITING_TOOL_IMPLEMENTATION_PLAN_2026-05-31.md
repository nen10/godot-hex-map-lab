# MANUAL_MAP_EDITING_TOOL_IMPLEMENTATION_PLAN_2026-05-31.md

## 参照方針

- 方針: `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md`
- 採用案: `HexMapDocumentResource` を正とするresource-primary editor tool。

## 対象ファイル

- `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_object_database_resource.gd`
- `addons/hex_map_kit/adapter/hex_label_database_resource.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/plugin.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## 入出力インターフェース

入力:

- selected `HexMapDocumentResource`
- selected editable `TileMapLayer`
- edit mode
- cursor local position
- tile paint payload
- object payload
- label payload
- `HexObjectDatabaseResource`
- `HexLabelDatabaseResource`

出力:

- updated `HexMapDocumentResource`
- exported `HexMapResource`
- updated `TileMapLayer`
- `UndoRedo` action
- updated object / label placement entries

## Resource設計

### `HexMapDocumentResource`

```gdscript
@tool
class_name HexMapDocumentResource
extends Resource

@export var map: HexMapResource
@export var tile_overrides: Array = []
@export var objects: Array = []
@export var labels: Array = []
@export var version: int = 1
```

### `HexObjectDatabaseResource`

```gdscript
@tool
class_name HexObjectDatabaseResource
extends Resource

@export var objects: Array = []
```

object definition:

```gdscript
{
    "object_id": String,
    "display_name": String,
    "default_properties": Dictionary,
}
```

### `HexLabelDatabaseResource`

```gdscript
@tool
class_name HexLabelDatabaseResource
extends Resource

@export var labels: Array = []
```

label definition:

```gdscript
{
    "label_id": String,
    "display_name": String,
    "default_text": String,
}
```

### tile override schema

```gdscript
{
    "cell": Vector3i,
    "kind": "floor" | "wall" | "overlay",
    "item_key": String,
    "source_id": int,
    "atlas_coords": Vector2i,
    "alternative_tile": int,
}
```

`item_key` はoverlay / object tileとの接続用に空文字を許容する。

### object schema

```gdscript
{
    "cell": Vector3i,
    "object_id": String,
    "properties": Dictionary,
}
```

### label schema

```gdscript
{
    "cell": Vector3i,
    "label_id": String,
    "text": String,
}
```

### Adapter

`HexMapDocumentAdapter` に以下を置く。

```gdscript
static func from_map_resource(resource: HexMapResource) -> HexMapDocumentResource
static func to_map_resource(document: HexMapDocumentResource) -> HexMapResource
static func apply_to_tile_map_layer(document, layer: TileMapLayer, options: Dictionary = {}) -> void
static func set_wall(document, hex, wall: bool) -> void
static func set_cell_exists(document, hex, exists: bool) -> void
static func set_tile_override(document, hex, payload: Dictionary) -> void
static func set_object(document, hex, payload: Dictionary) -> void
static func set_label(document, hex, payload: Dictionary) -> void
```

## Editor tool設計

### Plugin接続

`plugin.gd` にEditorPlugin toolを追加する。

- Dock: `Hex Map Edit`
- Tool state: selected document, selected TileMapLayer, edit mode, payload
- Viewport input forwarding: `forward_canvas_gui_input(event)`

### Edit modes

```gdscript
enum EditMode {
    SHAPE,
    WALL_FLOOR,
    FLOOR_TILE,
    WALL_TILE,
    OBJECT,
    LABEL,
}
```

### Click flow

1. Editor viewportのmouse positionを取得する。
2. selected TileMapLayerまたはHexTileMapLayerからlocal座標へ変換する。
3. `HexMapTileAdapter`または`HexTileMapLayer.local_to_hex()`でHex座標へ変換する。
4. edit modeに応じてpayloadを作る。
5. `UndoRedo.create_action()` でresource更新とTileMapLayer再描画を登録する。
6. action commit後、Dock statusへ変更内容を表示する。

### UndoRedo

Actionは以下を持つ。

- do: document mutation
- do: TileMapLayer apply
- undo: previous document state restore
- undo: TileMapLayer apply

初期実装では対象entry単位のbefore / after snapshotを保存する。大規模編集ではdocument全体snapshotではなく、cell単位deltaへ移行する。

## UI計画

Dock controls:

- Document resource picker
- Target TileMapLayer picker
- Edit mode segmented buttons
- Tile payload controls: source id, atlas coords, alternative tile
- Object payload controls: object id, properties text
- Label payload controls: label id, text
- Save document button
- Export `HexMapResource` button
- Status label

## Resource保存

- `.tres` document pathはユーザーが選択する。
- Generate DockのHistory保存とは分離する。
- `HexMapDocumentResource` から `HexMapResource` をexportできる。

## テスト計画

### `tests/test_hex_adapter.gd`

追加テスト候補:

- `_test_hex_map_document_roundtrips_map_and_payloads()`
  - map、tile override、object、labelを保存復元する。
- `_test_hex_map_document_adapter_updates_wall_floor()`
  - `set_wall()` / `set_cell_exists()` がmap dataへ反映される。
- `_test_hex_map_document_adapter_applies_tile_overrides()`
  - TileMapLayerへtile overrideが反映される。

### `tests/test_editor_plugin.gd`

追加テスト候補:

- `_test_map_edit_tool_builds_dock_controls()`
  - Dockがdocument picker / target / edit modeを持つ。
- `_test_map_edit_tool_click_updates_document_with_undo_redo()`
  - click helperを直接呼び、UndoRedoでdocumentとTileMapLayerが戻る。
- `_test_map_edit_tool_imports_generated_map_resource()`
  - `HexMapResource` からdocumentを作り、再exportで同じmap dataになる。

### Editor workflow test

`docs/TEST.md` に手動確認を記録する。

- Godot EditorでHex Map Edit Dockを開く。
- Documentを選ぶ。
- TileMapLayerを選ぶ。
- Edit modeを切り替えてセルをclickする。
- Undo / Redoで表示とresourceが戻る。
- `.tres` を保存し、再読み込みで同じ編集状態が復元される。

## 実装手順

1. `HexMapDocumentResource` を追加する。
2. `HexMapDocumentAdapter` を追加し、roundtrip testを作る。
3. Editor Dock `Hex Map Edit` を追加する。
4. target selectionとdocument pickerを実装する。
5. edit modeごとのmutation helperを追加する。
6. UndoRedo actionを実装する。
7. TileMapLayer applyをdocument adapterへ接続する。
8. Editor workflow test手順を `docs/TEST.md` へ追加する。
9. `./tools/test.sh` を実行する。

## 完了判定

- Document resource roundtripがテストで固定される。
- wall / floor / tile / object / label payloadがcell単位で保存される。
- Undo / RedoがresourceとTileMapLayerの両方を戻す。
- Generate Dockで作ったmap resourceをmanual editing documentへ移せる。
