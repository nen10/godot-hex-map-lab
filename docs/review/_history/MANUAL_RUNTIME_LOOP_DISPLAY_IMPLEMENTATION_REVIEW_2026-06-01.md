# MANUAL_MAP_EDIT + RUNTIME_LOOP 横断レビュー (2026-06-01)

agentによるレビュー

## 対象

`docs/complete_on_test/実施順序_2026-06-01.md` の3計画に対する commits `3069f00`..`ce92f81`:

1. **MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT** — `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_IMPLEMENTATION_PLAN_2026-06-01.md`
2. **RUNTIME_INTERACTION_LOOP_DISPLAY_TILE_COPY** — `docs/complete_on_test/RUNTIME_INTERACTION_LOOP_DISPLAY_TILE_COPY_IMPLEMENTATION_PLAN_2026-05-31.md`
3. **MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY** — `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY_IMPLEMENTATION_PLAN_2026-05-31.md`

## 総評

3計画の実装が完了し、全テストパス。Editor viewport click → document mutation → tile redraw の E2E flow、loop duplicate tile copy 表示、visual duplicate からの canonical document 編集が headless test で検証されている。変更は +1997/-153 行（38ファイル）、大部分がテスト（`test_editor_plugin.gd` +259行、`test_hex_tile_map_layer.gd` +125行）。

---

## 当初の要件より優れている実装

### 1. `HexTileMapLayer` の2層 tile map アーキテクチャ
base `_tile_map`（canonical cells）と `_loop_tile_map`（loop duplicate tiles）の二重構造。`_loop_tile_map.tile_set` は base と同じ `TileSet` を共有し、重複描画のコストが低い。`_ensure_tile_map_layers()` は既存の子 TileMapLayer を名前 (`BASE_TILE_MAP_NAME` / `LOOP_TILE_MAP_NAME`) で識別し、再帰的な子検索を避ける。

### 2. `_editor_viewport_position_to_scene_position()` の多段 fallback
`global_canvas_transform` → `canvas_transform` → `get_canvas_transform()` の3段のプロパティ/メソッド試行で Godot 4.x のバージョン間差異を吸収する。テスト用に `set_viewport_canvas_transform_for_test()` 経由で `_test_viewport_canvas_transform` を注入可能。実 Editor での動作確認前に headless test で全分岐を検証できる。

### 3. `_refresh_last_hit_display()` による canonical cell highlight
visual duplicate から編集した場合も、highlight は常に canonical cell に行われる。`last_edit_status()` が `hex`（canonical）と `visual_hex`（display representative）の両方を返すため、status label と highlight で情報が一貫する。

### 4. `apply_cell()` から `_apply_hit()` への内部委譲
旧 `apply_cell(hex)` が hit dictionary を内製して `_apply_hit(hit)` を呼ぶ方式により、HexVector 単体の直接編集（headless test helper）と viewport click の両方が同一の mutation path を通る。`exists` は document の map data から計算される。

### 5. `_refresh_payload_controls_visibility()` の row 単位の表示切替
`_set_control_row_visible()` が control の親 `HBoxContainer` の `visible` を切り替える。単に control 自身を hide するのではなく、ラベル + control の row 全体を非表示にするため、隙間ができない。

### 6. undo/redo の loop duplicate 検証
`_test_map_edit_tool_undo_redo_preserves_loop_visual_identity` が UndoRedo の undo/redo 後に `_loop_tile_map.get_cell_atlas_coords(duplicate_map_cell)` が canonical document の状態と一致することを直接検証している。

---

## 要件に対する実装の不足

### 1. VIEWPORT_INPUT: `_handles()` の headless test がソースコード文字列検査

`_test_plugin_handles_canvas_item_when_map_edit_ready` は `FileAccess.get_file_as_string()` で `plugin.gd` のソースコード中に `func _handles(object: Object) -> bool:` が存在することを文字列検索で確認している。実 EditorPlugin インスタンスを生成して `_handles(tile_layer)` を直接呼ぶテストではない。Godot の headless モードでは EditorPlugin が有効にならず、`_handles()` の実際の呼び出しをテストできない制約によるものだが、この制約はコメントで明示されていない。

### 2. LOOP_DISPLAY: `_loop_tile_map` の editor scene 永続化

`_loop_tile_map` は `add_child(_loop_tile_map, false, INTERNAL_MODE_BACK)` で内部モード追加されるが、editor scene を保存→再読み込みした場合に `_loop_tile_map` が複製されたり、`_ensure_tile_map_layers()` が二重に検出したりする可能性がある。現状のテストでは保存→再読み込みの roundtrip を検証していない。

### 3. VIEWPORT_INPUT: `_on_target_selected` が Auto (index 0) で selection sync しない

plan では「Auto 解決だけで selection を変えるとユーザーの Scene Tree 操作を奪いやすいため、実装段階では explicit target selection 時に selection sync する」と明示されている。実装は `if index != TARGET_AUTO_INDEX` でガードしており、仕様通り。

---

## UI 上の改善点

### 1. `_refresh_payload_controls_visibility()` が各モード切替で全ペイロード行を走査

6つの edit mode × 9つの control の可視性を毎回切り替える。`WALL_FLOOR` と `SHAPE` は同じ表示（全ペイロード非表示）だが、個別に処理している。mode をグループ化すると効率が上がるが、現状の規模では問題ない。

### 2. debug_viewport_input の出力先が `print()`

`@export var debug_viewport_input := false` が有効な場合、`_debug_viewport_input()` が `print()` でログを出す。Editor の Output パネルで確認する必要があり、Dock の status label には表示されない。ユーザーがログを見逃す可能性がある。

### 3. last hit highlight が前回の highlight を消さない

`_refresh_last_hit_display()` は `highlight_cell(hex, Color.YELLOW)` を呼ぶが、前回の highlight をクリアしない。編集を繰り返すと全編集済み cell が黄色でハイライトされたままになる。`highlight_cell` は上書きされるが、編集対象外の cell の highlight は残る。

---

## 機能・コード上の改善点

### 1. `_apply_hit()` が `_last_applied_to_target` を `_commit_document_change()` → `_replace_document_state()` → `_apply_document_to_target()` の非同期チェーンで設定

`_commit_document_change()` は `_last_applied_to_target = false` にリセットし、`_replace_document_state()` が内部で `_apply_document_to_target()` を呼ぶ。`_last_edit_status["applied"]` はこのフラグの最終値を読む。しかし `_undo_redo == null` の場合は `_replace_document_state(after)` が直接呼ばれる。両方の経路で一貫しているが、`_last_applied_to_target` が UndoRedo の非同期 commit で更新されるかどうかは呼び出し順序に依存する（headless test では同期的に呼ばれるため問題ない）。

### 2. `_select_target_in_editor_if_possible()` の呼び出し箇所が5箇所

- `set_target_layer()`
- `import_map_resource_from_path()` 
- `refresh_target_layer_options()` (preserved target時)
- `_on_target_selected()` (explicit index時)
- `_on_target_refresh_pressed()` → `refresh_target_layer_options()` 経由

今後 target selection sync のタイミングを変更する場合、すべての呼び出し箇所を把握する必要がある。専用の setter に集約する方が安全。

### 3. `_editor_viewport_position_to_scene_position()` の `viewport.get("canvas_transform")` が文字列ベースのプロパティアクセス

`viewport.get("global_canvas_transform")` と `viewport.get("canvas_transform")` が文字列キーでのプロパティ読み取りになっている。Godot 4.x のバージョン間でこれらが存在しない場合に `return viewport_pos` の fallback に到達するが、その場合でも座標変換が行われず、誤った位置へのクリックが発生する。plan の「同じ helper の内部だけを差し替える」方針により、実 Editor で検証後に修正可能。

---

## テストの充足度

### 計画1 (VIEWPORT_INPUT)

| 計画のテスト | 実装 |
|-------------|------|
| `_handles(canvas_item)` 検証 | ✅ `_test_plugin_handles_canvas_item_when_map_edit_ready`（文字列検査 + helper 経由の挙動確認） |
| forward_canvas_gui_input 座標変換 | ✅ `_test_map_edit_tool_forward_canvas_gui_input_uses_viewport_transform`（test double transform 注入） |
| target selection sync | ✅ `_test_map_edit_tool_target_selection_sync_for_explicit_target`（sync_request_count による間接検証） |
| no editable cell 報告 | ✅ `_test_map_edit_tool_forward_canvas_gui_input_reports_no_editable_cell` |
| redraws target layer | ✅ 同上テスト内で `get_cell_atlas_coords` 確認 |

### 計画2 (TILE_COPY)

| 計画のテスト | 実装 |
|-------------|------|
| visual_cell_entries_for_rect | ✅ `_test_visual_cell_entries_for_rect_marks_canonical_and_duplicates` |
| loop copy layer の tile 描画 | ✅ `_test_loop_copy_layer_draws_duplicate_tiles` |
| set_wall/set_floor 後の copy 同期 | ✅ `_test_loop_copy_layer_updates_after_wall_floor_edit` |
| anchor_local 選択 | ✅ `_test_visual_path_anchor_selects_first_representative` |

### 計画3 (LOOP_DISPLAY)

| 計画のテスト | 実装 |
|-------------|------|
| visual duplicate click → canonical edit | ✅ `_test_map_edit_tool_forward_canvas_gui_input_edits_loop_visual_duplicate` |
| edit 後の loop display refresh | ✅ 同上テスト内で `_loop_tile_map.get_cell_atlas_coords` 確認 |
| undo/redo 後 canonical + duplicate 同期 | ✅ `_test_map_edit_tool_undo_redo_preserves_loop_visual_identity` |
| mode 別 payload controls | ✅ `_test_map_edit_tool_mode_specific_payload_controls` |

全14テスト充足。

---

## 不明点

### 1. `_editor_viewport_position_to_scene_position` の実 Editor での動作確認

`global_canvas_transform` / `canvas_transform` / `get_canvas_transform()` の3段試行のうち、Godot 4.6 で実際に有効なのはどれか。plan の analog test `GENERATED_MAP_MANUAL_EDIT` Step 14/15 が実 Editor で成功することで確認される想定。

### 2. `_select_target_in_editor_if_possible()` の test double 不在

headless test では `Engine.is_editor_hint() == false` のため `EditorInterface.get_selection()` に到達しない。`_target_selection_sync_request_count` がインクリメントされることだけを検証している。実 Editor での selection sync の動作確認は analog test に委ねられている。

### 3. `_test_plugin_handles_canvas_item_when_map_edit_ready` の文字列検査の意図

「plugin.gd に `_handles` が定義されていること」を確認する意図は理解できるが、`viewport_input_enabled` や `is CanvasItem` の文字列検査はリファクタリングに弱い。コメントで headless test の制約を説明する価値がある。

## ユーザーのアナログテスト報告

14に関して、選択した座標に応じて"Edited <clicked-coordinate>" がdockに表示されるようになったが、editor viewport上では変化が反映されない。実際に編集されたのか・内部的に保存ができているのかどうかよくわからない。
使用するTileMapLayerノードはGodot共通のノードで問題ないか？applyの方法がリソースのクラスに対応しているか？

