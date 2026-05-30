# HEX_CELL_BUTTON_EDITOR_UI_IMPLEMENTATION_PLAN_2026-05-31.md

## 参照方針

- 方針: `docs/plan/HEX_CELL_BUTTON_EDITOR_UI_POLICY_2026-05-31.md`
- 採用案: 単一custom `Control` が複数のhex cell buttonを描画・hit testする。

## 対象ファイル

- `addons/hex_map_kit/editor/hex_cell_button_layout.gd`
- `addons/hex_map_kit/editor/hex_cell_button_panel.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_dist_editor.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

既存の `QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_*` は参照元として残し、本計画では新規部品名で作る。

## 入出力インターフェース

入力:

- `flat_top: bool`
- `cell_radius: float`
- `cell_gap: float`
- `padding: Vector2`
- `shape_kind: String`
- `shape_cells: Array[HexVector]`
- `pressable_cells: Dictionary`
- `disabled_cells: Dictionary`
- `label_by_cell: Dictionary`
- `tooltip_by_cell: Dictionary`
- `metadata_by_cell: Dictionary`

出力:

- layout entries: `Array[Dictionary]`
- panel minimum size: `Vector2`
- `cell_pressed(entry: Dictionary)` signal
- `cell_hovered(entry: Dictionary)` signal
- Query Row offset更新
- Distribution Editor pattern描画

## `HexCellButtonLayout`

### 役割

UI nodeを持たないlayout builderとして、hex cellのcenter、polygon、bounds、minimum sizeを作る。

### class

```gdscript
@tool
class_name HexCellButtonLayout
extends RefCounted
```

### public API

```gdscript
static func build_entries(spec: Dictionary) -> Array[Dictionary]
static func minimum_size(entries: Array[Dictionary], padding: Vector2) -> Vector2
static func hex_polygon(center: Vector2, radius: float, flat_top: bool) -> PackedVector2Array
static func hit_entry(entries: Array[Dictionary], local_pos: Vector2) -> Dictionary
static func direction_cells() -> Array
static func shape_cells(shape_kind: String, options: Dictionary = {}) -> Array
```

### placement計算

1. `shape_cells` を取得する。
2. 各cellのlocal centerを計算する。
   - `HexMapTileAdapter.hex_to_local(cell, cell_radius + cell_gap, flat_top)` を使う。
   - polygon radiusは `cell_radius` を使う。
3. 全center / polygon boundsのmin/maxを計算する。
4. 左上が `padding` に収まるようにorigin offsetを加える。
5. layout entryを返す。

### polygon計算

`hex_dist_editor.gd` の `_draw_hex()` と同様に6頂点を作る。

```gdscript
var rotation = 0.0 if flat_top else 30.0
for index in range(6):
    var angle = deg_to_rad(rotation + 60.0 * float(index))
    points.append(center + Vector2(cos(angle), sin(angle)) * cell_radius)
```

### hit test

1. boundsに入らないentryを除外する。
2. `Geometry2D.is_point_in_polygon(local_pos, entry["polygon"])` で判定する。
3. 複数hitした場合はentriesの後ろを優先する。
4. `pressable == false` または `disabled == true` のentryはpressed対象にしない。

## `HexCellButtonPanel`

### class

```gdscript
@tool
class_name HexCellButtonPanel
extends Control
```

### signals

```gdscript
signal cell_pressed(entry: Dictionary)
signal cell_hovered(entry: Dictionary)
signal cell_focus_changed(entry: Dictionary)
```

### properties

```gdscript
@export var flat_top: bool = true
@export var cell_radius: float = 14.0
@export var cell_gap: float = 2.0
@export var padding: Vector2 = Vector2(4, 4)
@export var shape_kind: String = "directions"
@export var show_labels: bool = true
@export var enabled: bool = true
```

### methods

```gdscript
func configure(spec: Dictionary) -> void
func set_cells(cells: Array) -> void
func set_pressable_cells(cells: Dictionary) -> void
func set_cell_labels(labels: Dictionary) -> void
func set_cell_tooltips(tooltips: Dictionary) -> void
func set_cell_metadata(metadata: Dictionary) -> void
func get_entries() -> Array
func entry_at(local_pos: Vector2) -> Dictionary
```

### drawing

`_draw()` はlayout entriesを走査して描画する。

- fill color: normal / hover / pressed / disabled / center
- outline color
- focus outline
- label text

drawは `draw_colored_polygon()` と `draw_polyline()` を使う。labelはPanel自身が `draw_string()` で短いtextだけを描く。長いtextはtooltipへ逃がす。

### size

`_get_minimum_size()` は `HexCellButtonLayout.minimum_size(entries, padding)` を返す。

設定変更時は以下を呼ぶ。

```gdscript
update_minimum_size()
queue_redraw()
```

### input

`_gui_input(event)` で処理する。

- mouse motion: hover entry更新、`cell_hovered` emit
- left mouse button press: hit entryをpressed entryとして記録
- left mouse button release: 同じentry上でreleaseされたら `cell_pressed` emit
- keyboard: focus entryがある場合、Enter / Spaceでpressed emit、方向キーで近傍entryへfocus移動

`Geometry2D.is_point_in_polygon()` をhit判定に使い、矩形bounds内でもhex外なら押せない。

## Query Row offset統合

### Dock側入力

Query Row生成時に以下のspecを作る。

```gdscript
{
    "shape_kind": "directions",
    "flat_top": _current_resource_flat_top_or_dock_orientation(),
    "cell_radius": _query_hex_button_radius,
    "cell_gap": _query_hex_button_gap,
    "center_cell": HexVector.zero(),
    "pressable_cells": _direction_cell_map(),
    "label_by_cell": _direction_label_map(),
    "metadata_by_cell": _direction_metadata_map(),
}
```

### direction mapping

- center: current offset label、pressable=false
- direction cells:
  - `HexVector.directions()[0]` -> `+Q`
  - `HexVector.directions()[1]` -> `-R`
  - `HexVector.directions()[2]` -> `+S`
  - `HexVector.directions()[3]` -> `-Q`
  - `HexVector.directions()[4]` -> `+R`
  - `HexVector.directions()[5]` -> `-S`

pressed handler:

```gdscript
func _on_query_offset_cell_pressed(entry: Dictionary, row: Dictionary, query_kind: String) -> void:
    var direction = entry["metadata"]["direction"]
    row["offset"] = row.get("offset", HexVector.zero()).add(direction)
    row["offset_panel"].set_cell_labels(_offset_center_label(row["offset"]))
    _on_query_row_edited(query_kind)
```

## `hex_dist_editor.gd` 統合

### 移行方針

`_draw_pattern()` の固定 `ref0` / `ref1` / `ref2` を、`HexCellButtonLayout` のcustom shapeへ置き換える。

初期移行ではbutton入力を使わず、描画layoutだけを使う。

spec:

```gdscript
{
    "shape_kind": "custom",
    "shape_cells": _distribution_pattern_cells(n_neighbor),
    "flat_top": true,
    "cell_radius": HEX_SIZE,
    "cell_gap": 0.0,
    "pressable_cells": {},
}
```

`_distribution_pattern_cells(3)` は、既存の上側3近傍に対応するHexVectorを返す。既存表示と同等になることをtestで固定する。

direction index:

- `n_neighbor == 3`: `[3, 2, 1]`
- `n_neighbor == 2`: `[2, 1]`
- `n_neighbor == 1`: `[2]`

これは既存の `ref0`, `ref1`, `ref2` がflat-topで上側3近傍を左から右へ並べる表示に対応する。

### 将来拡張

distribution editorでcellをclickして壁 / 床状態をtoggleする場合、同じPanelの `cell_pressed` を使う。

## Editor UI size設定

既存のdirection button size SpinBoxを以下に置き換える。

- `Cell Radius`
- `Gap`
- `Padding`

Query Rowではcompactな初期値を使う。

```text
cell_radius = 12
cell_gap = 1
padding = Vector2(2, 2)
```

Distribution Editorでは既存見た目維持のため、`cell_radius = HEX_SIZE`、`cell_gap = 0` を使う。

## Resource schema

保存resourceのschema変更はない。

`HexCellButtonLayout` / `HexCellButtonPanel` はEditor UI stateであり、`HexMapResource` / `HexOverlayResource` へ保存しない。

## テスト計画

### layout builder

`tests/test_editor_plugin.gd` に以下を追加する。

- `_test_hex_cell_button_layout_direction_cells_flat_top()`
  - `shape_kind="directions"` でcenter + six entriesができる。
  - direction centersが `HexMapTileAdapter.hex_to_local(direction, radius + gap, true)` に対応する。
- `_test_hex_cell_button_layout_direction_cells_pointy_top()`
  - flat-topとpointy-topでcentersが異なる。
- `_test_hex_cell_button_layout_minimum_size_uses_padding()`
  - padding変更でminimum sizeが変わる。
- `_test_hex_cell_button_layout_polygon_hit_rejects_rect_corner()`
  - entry bounds内だがhex polygon外のpointを拒否する。

### panel

- `_test_hex_cell_button_panel_emits_pressed_for_hex_hit()`
  - `_gui_input()` または `entry_at()` 経由でhex内pointを押し、`cell_pressed` を確認する。
- `_test_hex_cell_button_panel_does_not_press_disabled_cell()`
  - disabled entryはemitされない。
- `_test_hex_cell_button_panel_focus_navigation()`
  - keyboard操作を入れる場合、direction focus移動を検証する。

### Query Row

既存Query Row offset testを更新する。

- rowが `HexCellButtonPanel` を持つ。
- direction cell pressでoffsetが更新される。
- compact layoutにより従来よりrow表示が簡潔になる。
- Mask / Reference / Deductor Floor Sourceで同じpanelを使う。

### Distribution Editor

- `_test_distribution_editor_uses_hex_cell_layout_for_patterns()`
  - 3-neighbor patternのentry数と中心 / 参照cell配置が既存表示と同等。
- `_test_distribution_editor_pattern_redraw_uses_layout_entries()`
  - SpinBox変更でlayout entryを使った描画がredrawされる。

## 実装手順

1. `HexCellButtonLayout` を追加する。
2. layout builderのunit testを追加する。
3. `HexCellButtonPanel` を追加する。
4. polygon hit testとpressed signalのtestを追加する。
5. Query Row offset controlを `HexCellButtonPanel` 利用へ置き換える。
6. Query Row既存testを更新する。
7. `hex_dist_editor.gd` のpattern描画をlayout entries利用へ移行する。
8. Distribution Editor testを追加する。
9. `docs/TEST.md` にhex cell button UI管理とQuery Row利用を追記する。
10. `./tools/test.sh` を実行する。

## 完了判定

- 六角形polygonの描画とhit testが同じlayout entryを使う。
- flat-top / pointy-top、shape、cell radius、gap、paddingを入力にlayoutを生成できる。
- Query Row offsetがhex cell button panelを使って更新される。
- `hex_dist_editor.gd` の六角形配置が共通layoutに移行できる。
- 公式docs確認に基づくControl sizing / input / drawing方針が文書に残る。
