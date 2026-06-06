# FALLBACK_BLOCK_IMPLEMENTATION_PLAN.md

## 概要

`docs/review/FALLBACK_CLASSIFICATION.md` のユーザー要望に従い、以下の修正を実施する。

## 工数と優先順位

全7ステップ。各ステップは順不同で着手可能だが、コード削除系 (Step 1) を最初に行うと後続が整理しやすい。

---

## Step 1: Legacy Mask/Reference Controls の削除

### 対象ファイル
`addons/hex_map_kit/editor/hex_map_gen_dock.gd`

### 削除する定数
- `OVERLAY_QUERY_OPERATIONS` (line 66-69)
- `OVERLAY_QUERY_OPERATION_NAMES` (line 70-72)

### 削除する変数宣言
- `_overlay_mask_primary_check` (line 162)
- `_overlay_mask_primary_items_edit` (line 163)
- `_overlay_mask_overlay_check` (line 164)
- `_overlay_mask_overlay_items_edit` (line 165)
- `_overlay_mask_operation_option` (line 166)
- `_overlay_reference_primary_check` (line 183)
- `_overlay_reference_primary_items_edit` (line 184)
- `_overlay_reference_overlay_check` (line 185)
- `_overlay_reference_overlay_items_edit` (line 186)
- `_overlay_reference_operation_option` (line 187)

### 削除するメソッド
- `_new_query_operation_option()` — 削除（legacy mask/reference 専用）
- `_overlay_query_operation()` — 削除（legacy mask/reference 専用）
- `_overlay_query_cells()` — 削除（legacy mask/reference 専用）
- `_parse_item_key_list()` — 削除（`_overlay_query_cells()` からのみ呼ばれる）
- `_overlay_candidate_cells_for_snapshot()` — 削除（legacy mask fallback 専用）

### 書き換えるメソッド

**`_build_overlay_mask_controls()`**:
- legacy Primary/Overlay check + text + Mask Set operation の全 UI 構築コードを削除
- 残す: セクションラベル "Placement Mask"、Query Row controls、Crop checkbox + count label
- 削除後、Crop row を Query Row container の直下に移動

**概形**:
```gdscript
func _build_overlay_mask_controls() -> Control:
    _overlay_mask_container = VBoxContainer.new()
    _overlay_mask_container.add_child(_build_section_label("Placement Mask"))
    _overlay_mask_container.add_child(_build_query_row_controls(true))
    return _overlay_mask_container
```

**`_build_overlay_adjacency_controls()`**:
- legacy Primary/Overlay check + text + Reference Set operation の全 UI 構築コードを削除
- 残す: セクションラベル "Reference Items"、Query Row controls、Neighbor Radius、Adjacency Rules

**概形**:
```gdscript
func _build_overlay_adjacency_controls() -> Control:
    var box = VBoxContainer.new()
    _overlay_adjacency_check = CheckButton.new()
    ...
    _overlay_reference_container = VBoxContainer.new()
    _overlay_reference_container.visible = false
    box.add_child(_overlay_reference_container)
    _overlay_reference_container.add_child(_build_small_label("Reference Items"))
    _overlay_reference_container.add_child(_build_query_row_controls(false))
    # Neighbor Radius, Adjacency Rules はそのまま残す
    ...
    return box
```

### `_set_generation_controls_disabled()` の更新
- 配列から legacy コントロールを削除 (`_overlay_mask_primary_check` 等)

---

## Step 2: Query Row 0行時の全通過 (Any predicate)

### 対象ファイル
`addons/hex_map_kit/editor/hex_map_gen_dock.gd`

### `_evaluate_query_rows()` の修正
rows が空の場合、Shape universe 全体を返す（Any predicate: 述語なし = 全 cell 通過）:

```gdscript
func _evaluate_query_rows(mask_query: bool) -> Array:
    var rows = _overlay_mask_query_rows if mask_query else _overlay_reference_query_rows
    var universe = _overlay_shape_universe()
    if rows.is_empty():
        return universe  # Any predicate: 全 cell 通過
    # ... 以下 5d の行評価ロジック (_query_row_contain_cells_in_universe 使用)
```

`_query_universe()` は削除し、常に `_overlay_shape_universe()`（Step 5）を使う。

### `_query_rows_enabled()` の修正
空 rows は「無効」ではなく「全通過」として扱う。呼び出し元の `_overlay_mask_cells_for_snapshot()` では、rows 空 → `_evaluate_query_rows()` が universe を返すため、結果空の warning は rows が存在して結果が空の場合のみ発行する（Step 3 参照）。

---

## Step 3: `_overlay_mask_cells_for_snapshot()` / `_overlay_reference_cells_for_snapshot()` の簡略化

### 対象ファイル
`addons/hex_map_kit/editor/hex_map_gen_dock.gd`

### `_overlay_mask_cells_for_snapshot()` 
legacy 分岐を削除し、常に Query Row 評価のみ行う:

```gdscript
func _overlay_mask_cells_for_snapshot(snapshot: Dictionary) -> Array:
    var query_cells = _evaluate_query_rows(true)
    if _overlay_mask_query_rows.is_empty():
        return query_cells  # 全通過: Shape/Size universe 全体
    if query_cells.is_empty():
        push_warning("Placement Mask query result is empty. Overlay generation will use no candidate cells.")
    return query_cells
```
注: `_overlay_mask_crop_enabled()` は Crop result data 生成にのみ関係し、Mask candidate cells の計算には不要（universe は常に Shape/Size）。

### `_overlay_reference_cells_for_snapshot()`
legacy 分岐を削除:

```gdscript
func _overlay_reference_cells_for_snapshot() -> Array:
    if _overlay_reference_query_rows.is_empty():
        return []  # reference query 明示なし → 空
    return _evaluate_query_rows(false)
```

---

## Step 4: `_current_data` の Overlay 非依存化

### 対象ファイル
`addons/hex_map_kit/editor/hex_map_gen_dock.gd`

### `_overlay_cyclic_size_for_snapshot()` の修正
`_current_data` への参照を削除し、現在の toric connection 設定から導出:

```gdscript
func _overlay_cyclic_size_for_snapshot() -> int:
    if _uses_symmetric_generation() \
        and _shape_option_symmetric.selected == SHAPE_RECTANGLE \
        and _torus_connectivity_check != null \
        and _torus_connectivity_check.button_pressed:
        return int(_gen_radius_spin.value) * 2 + 1
    return 0
```

### `_build_snapshot()` の修正
`snapshot["overlay_cyclic_size"]` が正しく `_overlay_cyclic_size_for_snapshot()` から導出されることを確認。既に `_build_snapshot()` が line 2674 でこれを呼んでいるため、呼び出し側の変更は不要。

### `_overlay_mask_cells_for_snapshot()` の修正
`_current_data` への参照がすでに legacy コードに閉じているため、Step 3 の簡略化で自動的に解消される。

### `_overlay_candidate_cells_for_snapshot()` 
Step 1 で削除済み。

### legacy コード削除に伴い解消される `_current_data` 参照
- `_overlay_query_cells()` (line 2885, 2887) — Step 1 で削除
- `_overlay_candidate_cells_for_snapshot()` (line 3002, 3003) — Step 1 で削除

### 確認項目
- Overlay toggle ON でも `_current_data` が null の状態で Dock が正常動作すること
- 既存の Primary Generation は影響を受けないこと（`_on_generate_pressed` は overlay mode でない場合 `_current_data` を使うため）

---

## Step 5: Query universe の Shape/Size 統一 + toric source 繰り返し展開

### 対象ファイル
`addons/hex_map_kit/editor/hex_map_gen_dock.gd`

### 5a. `_overlay_crop_universe()` → `_overlay_shape_universe()` に改名
Crop On/Off に関わらず universe は常に現在の Shape/Size。関数名を実態に合わせる:

```gdscript
func _overlay_shape_universe() -> Array:
    var symmetric = _uses_symmetric_generation()
    var shape = _shape_option_symmetric.selected if symmetric else _shape_option_simple.selected
    if symmetric:
        var radius = int(_gen_radius_spin.value)
        if shape == SHAPE_HEXAGON:
            return HexMapData.hexagon(radius).cells
        return HexMapData.square(radius * 2 + 1, false).cells
    match shape:
        SHAPE_HEXAGON:
            return HexMapData.hexagon(int(_hex_radius_spin.value)).cells
        SHAPE_RECTANGLE:
            return HexMapData.rectangle(int(_rect_width_spin.value), int(_rect_height_spin.value)).cells
        SHAPE_TORUS, _:
            var radius = int(_gen_radius_spin.value)
            return HexMapData.square(radius * 2 + 1, false).cells
```

### 5b. `_query_universe()` の削除
`_evaluate_query_rows()` 内で universe 計算に使っていた `_query_universe()` を削除し、常に `_overlay_shape_universe()` を使う。

### 5c. `_evaluate_query_rows()` の修正
`crop_enabled` パラメータを削除（常に Shape universe）。呼び出し元も修正:
- `_overlay_mask_cells_for_snapshot()`: `_evaluate_query_rows(true)` に簡略化
- `_overlay_reference_cells_for_snapshot()`: `_evaluate_query_rows(false)` に簡略化
- `_overlay_crop_result_data()`: 内部で universe を直接取得

### 5d. toric source の繰り返し展開 (新規実装) ★

toric source の Item cell は、Shape universe 内で torus として繰り返されるすべての代表を含める。

**計算原理**: source の Item cell（offset 適用後）について、toric 正準代表 `wrap_vector(cell, cyclic_size)` が同じになる universe 内の全 cell を結果に含める。

**実装: universe → toric 逆引きマップ方式**

```gdscript
func _query_row_contain_cells_in_universe(row: Dictionary, universe: Array) -> Array:
    var entry = _source_entry_by_id(int(row.get("source_id", -1)))
    if entry.is_empty():
        return []
    var data = entry.get("data", null)
    if data == null:
        return []
    var item_cells = data.item_cells(String(row.get("item_key", "")))
    var offset = row.get("offset", HexVector.zero())
    var cyclic_size = int(data.cyclic_size)

    if cyclic_size <= 0:
        # 非 toric: offset → universe filter（従来通り）
        var offset_cells = _offset_points(item_cells, offset, 0)
        return HexMapData.filter_points(offset_cells, HexMapData.make_set(universe))

    # toric: universe → toric 逆引きマップ
    # 計算量: O(|universe| + |items|)
    var wrapped_map := {}
    for u_cell in universe:
        var wk = HexToricCoordinate.wrap_vector(u_cell, cyclic_size).key()
        if not wrapped_map.has(wk):
            wrapped_map[wk] = []
        wrapped_map[wk].append(u_cell)

    var result: Array = []
    var seen := {}
    for item_cell in item_cells:
        var offset_cell = item_cell.add(offset)
        var wk = HexToricCoordinate.wrap_vector(offset_cell, cyclic_size).key()
        if wrapped_map.has(wk):
            for u_cell in wrapped_map[wk]:
                if not seen.has(u_cell.key()):
                    seen[u_cell.key()] = true
                    result.append(u_cell)
    return result
```

**`_evaluate_query_rows()` 内での呼び出し変更**:
```gdscript
func _evaluate_query_rows(mask_query: bool) -> Array:
    var rows = _overlay_mask_query_rows if mask_query else _overlay_reference_query_rows
    var universe = _overlay_shape_universe()
    if rows.is_empty():
        return universe  # Any predicate: 全 cell 通過

    var result: Array = []
    for index in range(rows.size()):
        var row = rows[index]
        var row_cells = _query_row_contain_cells_in_universe(row, universe)  # ★ 変更
        var match_value = _query_row_match(row)
        if match_value == QUERY_ROW_MATCH_EXCLUDE:
            row_cells = HexMapData.points_except(universe, row_cells)
        var operation_value = _query_row_operation(row)
        if index == 0:
            result = row_cells
        elif operation_value == QUERY_ROW_OPERATION_AND:
            result = _intersect_points(result, row_cells)
        else:
            result = HexMapData.unique_points(result + row_cells)
    return result
```

**影響範囲**: `_evaluate_query_rows()` は Mask / Reference / Deductor Floor の全 query から呼ばれるため、1 箇所の修正で toric source の繰り返し展開が全適用される。

### 5e. テスト追加

`tests/test_editor_plugin.gd` の `_test_generation_dock_mapdata_query_rows_evaluate_offset_and_toric` に以下を追加:

```
# Case A: toric item が universe 内で繰り返される
source: toric 3x3 (cyclic_size=3), Item at (2,0,0) → wrapped canonical (-1,0,0)
universe: rect 5x1, cells (0,0,0) to (4,0,0)
offset: +Q → offset_cell = (3,0,0) → wrapped = (0,0,0)
expect: (0,0,0) と (3,0,0) の両方が結果に含まれる
  # universe cell (0,0,0) → wrap → (0,0,0) = offset_cell wrapped ✓
  # universe cell (3,0,0) → wrap → (0,0,0) = offset_cell wrapped ✓

# Case B: toric item が universe 外
source: toric 3x3, Item at (0,0,0)
universe: rect 1x1 at (5,0,0) [source から遠い、どの代表も universe 外]
expect: 空

# Case C: 非 toric source は繰り返されない（現状維持の確認）
source: non-toric, Item at (0,0,0), offset: +Q
universe: rect 4x1
expect: (1,0,0) のみ、重複なし
```

---

## Step 6: Adjacency Rules fallback probability の削除

### 対象ファイル
`addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd`

### `parse_rules_text()` / `parse_rules_text_report()` の修正
`fallback_probability` パラメータを削除。空/全無効 rules → `{"default": 0.0}`:

```gdscript
static func parse_rules_text(text: String) -> Dictionary:
    var rules := {}
    for raw_entry in text.split(";", false):
        # ... (既存の parse ロジック、invalid は skip)
    if rules.is_empty():
        rules["default"] = 0.0
    return rules
```

`to_probability_rules()` も同様に `fallback_probability` 引数を削除。

### 対象ファイル
`addons/hex_map_kit/editor/hex_map_gen_dock.gd`

### `_overlay_adjacency_rules()` の修正
Wall Probability fallback を削除:

```gdscript
func _overlay_adjacency_rules() -> Dictionary:
    var text = ""
    if _overlay_adjacency_rules_edit != null:
        text = _overlay_adjacency_rules_edit.text
    return HexAdjacencyRuleSet.parse_rules_text(text)
```

### 影響確認
- `HexAdjacencyRuleEditor` への影響: `_refresh_rules_status()` が `parse_rules_text_report()` を呼ぶ場合、引数変更が必要
- 既存テスト: `_test_adjacency_rule_set_parses_probability_rules()` の修正が必要（fallback probability を使わない形に変更）

---

## Step 7: 小修正

### 7a. `OVERLAY_DEFAULT_ITEM_NAME` → `"Item1"`
`addons/hex_map_kit/editor/hex_map_gen_dock.gd` line 47:
```gdscript
const OVERLAY_DEFAULT_ITEM_NAME := "Item1"
```

### 7b. Deductor Floor Source 未指定時 complement
`addons/hex_map_kit/editor/hex_map_gen_dock.gd`

`_generate_overlay_data_from_snapshot()` 内の Deductor floor cells 解決ロジック（line 3159 周辺）:

現状: `candidates`（Placement Mask candidates）を Deductor floor 集合として使う
変更後: Deductor Floor Source query rows が空の場合、Shape universe ∖ generated item cells を floor 集合として使う

```gdscript
# Deductor floor cells の決定
var deductor_floor_cells = snapshot.get("overlay_deductor_floor_cells", [])
if deductor_floor_cells.is_empty() and data != null:
    # 未指定時は universe 内で item が生成されなかった cell を floor 集合とする
    var universe = _overlay_shape_universe()
    deductor_floor_cells = HexMapData.points_except(universe, data.occupied_cells())
```

この変更は Markov Mesh + Adjacency Reference Off 時にのみ影響する。

### 7c. `_item_pool_entry_float()` / `_item_pool_entry_int()` に assert 追加
`addons/hex_map_kit/core/hex_map_generator.gd`:

```gdscript
static func _item_pool_entry_float(item, key: String, default_value: float) -> float:
    assert(item is Dictionary, "item_pool entry must be a Dictionary")
    return float(item.get(key, default_value))

static func _item_pool_entry_int(item, key: String, default_value: int) -> int:
    assert(item is Dictionary, "item_pool entry must be a Dictionary")
    return int(item.get(key, default_value))
```

### 7d. SPECIFY-4, SPECIFY-5 — 調整不要（ユーザー指示）

---

## テスト更新計画

### 変更が必要なテスト (`tests/test_editor_plugin.gd`)

**`_test_generation_dock_overlay_placement_mask_filters_candidates()`** (line 914-934):
- legacy `_overlay_mask_primary_items_edit.text = "Wall"` を削除
- 代わりに: Source Registry に `_current_data` を登録し、Query Row で `Wall` をフィルタ
- `_current_data` 設定は Primary Data として Source Registry に登録する方式に変更

**`_test_generation_dock_overlay_adjacency_reference_generation()`** (line 937-960):
- legacy `_overlay_mask_primary_items_edit.text = "Floor"` と `_overlay_reference_primary_items_edit.text = "Wall"` を削除
- 代わりに: Source Registry に `_current_data` を登録し、Mask Query Row で `Floor`, Reference Query Row で `Wall` を指定

### 影響を受ける可能性があるテスト (`tests/test_hex_adapter.gd`)

**`_test_adjacency_rule_set_parses_probability_rules()`** (line 355 周辺):
- `parse_rules_text()` の `fallback_probability` 引数が削除されるため、呼び出しを修正
- fallback のテストケースを削除し、空 rules → `{"default": 0.0}` のテストに変更

### 新規テスト

- Query Row 0 行の Mask → Shape/Size universe が candidate になることのテスト
- Query Row 1 行以上で結果空 → candidate 空、Generate が実行されないことのテスト
- `_current_data == null` で Overlay Generate が正常動作することのテスト
- Deductor Floor Source 未指定時 → complement 使用のテスト
- Adjacency Rules 空 → fallback なしで default 0.0 のテスト

---

## 見積もり

| Step | 作業内容 | 想定変更量 |
|------|----------|-----------|
| 1 | Legacy コントロール削除 | ~150行削除 |
| 2 | Query Row 0行全通過 | ~15行修正 |
| 3 | mask/reference 簡略化 | ~20行修正 |
| 4 | `_current_data` 非依存化 | ~10行修正 |
| 5 | universe 統一 | ~20行修正 |
| 6 | Adjacency fallback 削除 | ~15行修正 |
| 7 | 小修正・テスト | ~80行修正 |

合計: 約 -150 +180 = +30 行（削除が主、増加分はテストと新規ロジック）
