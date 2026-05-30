# QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_IMPLEMENTATION_PLAN_2026-05-31.md

## 参照方針

- 方針: `docs/plan/QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_POLICY_2026-05-31.md`
- 採用案: `Control`派生の `HexDirectionOffsetControl` を追加する。

## 対象ファイル

- `addons/hex_map_kit/editor/hex_direction_offset_control.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## 入出力インターフェース

入力:

- `offset: HexVector`
- `direction_index: int`
- `button_size: float`
- `flat_top: bool`
- `enabled: bool`

出力:

- `offset_changed(offset)` signal
- `direction_pressed(direction_index, offset)` signal
- Query Row dictionary `offset`
- Query Row再評価結果

## 新規Control

### class

```gdscript
@tool
class_name HexDirectionOffsetControl
extends Control
```

### properties

```gdscript
signal offset_changed(offset)
signal direction_pressed(direction_index: int, offset)

@export var button_size: float = 28.0
@export var flat_top: bool = true
@export var show_basis_labels: bool = false
@export var offset = HexVector.zero()
```

### public methods

```gdscript
func set_offset(value) -> void
func get_offset()
func set_button_size(value: float) -> void
func set_flat_top(value: bool) -> void
func set_enabled(value: bool) -> void
```

### 内部構造

- `GridContainer`または絶対配置の`Control`を内部に持つ。
- 6個の`Button`を作成する。
- 中央にはoffset labelを置く。
- `flat_top` / `pointy_top`でbutton配置を切り替える。

最初の実装はGodotの標準Buttonを使う。hex形状の描画は `_draw()` で補助線として扱い、button自体の入力判定は矩形のままにする。

## Dock統合

### 置換対象

- `_build_query_direction_control()`
- `_query_direction_placeholder()`
- `_apply_query_direction_button_size()`
- `_on_query_row_direction_pressed()`

### row dictionary

既存:

```gdscript
row["direction_buttons"] = buttons
row["direction_control"] = grid
```

変更後:

```gdscript
row["offset_control"] = control
```

`offset_label` はControl中央表示へ統合する。Query Row上に別labelを残す場合も、表示はControlの値を正とする。

### signal

```gdscript
control.offset_changed.connect(_on_query_row_offset_changed.bind(row, query_kind))
```

handler:

```gdscript
func _on_query_row_offset_changed(offset, row: Dictionary, query_kind: String) -> void:
    row["offset"] = offset
    _on_query_row_edited(query_kind)
```

### size sync

`_on_query_direction_size_changed()` は各rowの `offset_control.set_button_size()` を呼ぶ。

3つのSpinBoxを残す場合は値同期だけを継続する。破壊的に共通1箇所へ移す場合は、`_build_query_row_controls()` の各sectionからsize SpinBoxを削除し、Source RegistryまたはOverlay controls先頭に移す。

## Resource schema

保存resourceのschema変更はない。

Query Row offsetはEditor Dock session内のUI stateであり、現状通りresourceへ保存しない。

## テスト計画

### Control単体

`tests/test_editor_plugin.gd` にControlを直接生成するテストを追加する。

- `_test_hex_direction_offset_control_updates_offset()`
  - initial offsetがzeroである。
  - direction 0 pressで `HexVector.directions()[0]` になる。
  - opposite direction pressでoffsetが更新される。
  - `offset_changed` が発火する。
- `_test_hex_direction_offset_control_button_size()`
  - `set_button_size(36)` でminimum sizeが変わる。

### Dock統合

既存の Query Row test を更新する。

- rowが `offset_control` を持つ。
- Mask / Reference / Deductor Floor Sourceの各rowが同じControl classを使う。
- size変更が全Controlへ同期する。
- Controlのdirection操作で `_evaluate_query_rows()` の結果が変わる。
- Mask Query Rowのoffset編集時にCrop resetまたは保持再計算方針が反映される。

## 実装手順

1. `hex_direction_offset_control.gd` を追加する。
2. `hex_map_gen_dock.gd` にpreloadを追加する。
3. `_build_query_direction_control()` をControl生成へ置き換える。
4. row dictionaryの `direction_buttons` 参照を `offset_control` へ更新する。
5. size同期処理をControl APIへ更新する。
6. 既存Query Row testsをControl前提へ更新する。
7. `docs/TEST.md` を更新する。
8. `./tools/test.sh` を実行する。

## 完了判定

- Query Rowのoffset変更がControl単体とDock統合の両方で検証される。
- 既存のtoric representative expansion / Exclude complement / Crop result testsが維持される。
- UI部品としてQuery Row以外からも生成できる。
