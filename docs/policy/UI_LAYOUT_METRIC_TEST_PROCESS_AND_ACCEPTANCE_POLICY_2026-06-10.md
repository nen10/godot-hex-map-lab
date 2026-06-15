# UI Layout Metric Test Process and Acceptance Policy 2026-06-10

対象: Hex Map Kit Godot Editor Workspace UI  
目的: スクリーンショットやユーザー目視に依存せず、Godot Control tree のサイズ・状態・情報量・操作契約を数値評価し、UI改修の regression signal として使えるテストプロセスを定義する。

PROCESS-60 update（2026-06-15）:

- UI Layout Metric Test は **回帰検知**であり、UI/graph task の合格根拠そのものではない。
- Metric P0 failure は `./tools/test.sh` 上の regression failure として修正対象にする。
- Metric pass は完了証明ではない。完了根拠は `docs/process/QUEUE_OPERATION_RULES.md` の two-layer DoD、特に experiential DoD（work surface / primary action / context chips / preview の有無）で記録する。
- 既存コードや report schema に残る `gate` wording は歴史的な実装名であり、PROCESS-60 以降の意味は regression check である。

---

## 0. 結論

UIの見た目を人間が確認する前に、かなり多くの欠陥は **Control tree の数値評価** で検出できる。

このpolicyでは、Godotの実レイアウトエンジンでWorkspace UIを構築し、各 `Control` node の `global_rect`、minimum size、text width、visibility、parent container、scroll reachability、ResourcePicker type、button signal、tooltip、debug text leakage を収集する。

評価対象はスクリーンショットではない。

```text
UI tree
  -> layout snapshot JSON
    -> metric evaluator
      -> fail / warn / info report
        -> regression report
        -> two-layer DoD review input
```

この方式を、ここでは **UI Layout Metric Test** と呼ぶ。

重要な考え方:

```text
- UIを見た感想ではなく、UI構造の破綻可能性を数値で検出する。
- headless testの都合でUIを歪めない。
- UIがユーザー主観で美しいかは判定しない。
- ただし、label切れ、scroll不能、no-op button、debug情報漏れ、state矛盾は機械的に判定する。
- metric pass は task 完了の代理にしない。UI/graph task の self-review は、ユーザーが最初に何を見るか、何を操作できるかを別途記録する。
```

---

## 1. 適用範囲

### 1.1 対象UI

対象は主に `Hex Map Workspace` dock である。

対象tab:

```text
Resources
Generate
Paint
Catalog
Layers
Validate
QA
Export
Settings
```

対象Control種別:

```text
Control
Container
VBoxContainer / HBoxContainer / GridContainer / MarginContainer
ScrollContainer
Label
Button
CheckBox
OptionButton
EditorResourcePicker
EditorFileDialog trigger buttons
ProgressBar
Tree
ItemList
TextEdit / LineEdit if present
custom controls under addons/hex_map_kit/editor
```

### 1.2 非対象

以下はこのテストでは最終判断しない。

```text
- アイコンの美しさ
- 色彩の好み
- 日本語表現の自然さ
- Godot Editor themeとの感性的な相性
- 余白の美的評価
- ユーザーが安心するかどうか
```

これらは将来の人間レビューやanalog testに任せる。

ただし、以下は数値評価対象である。

```text
- labelが割当幅を超える
- debug文字列が通常UIに露出する
- 重要actionがscrollなしでは到達できない
- ResourcePickerがgeneric Resource型
- stateとvisible textが矛盾する
- visible buttonが押しても意味ある状態変化を持たない
```

---

## 2. Source of truth

UI Layout Metric Test は、次の3層を source of truth とする。

### 2.1 UI Contract

新規文書を作る。

```text
docs/ui/WORKSPACE_UI_CONTRACT.md
```

ここに各tabの目的、表示してよい情報、禁止情報、必須component、重要action、metric閾値を書く。

例:

```md
## Resources tab

Purpose:
- selected HexTileMapLayer の authoring resources を確認・作成・関連づける。

Required components:
- selected_hex_tile_map_summary
- resource_context_panel
- missing_unique_resources_panel
- copy_workspace_debug_report_button

Forbidden visible text:
- `/root/`
- `@EditorNode`
- `res://` full paths, except inside collapsed debug section if allowed
- `true` / `false`
- raw source enum names

Metric thresholds:
- has_scroll_container: true
- max_debug_label_count: 0
- min_resource_picker_width: 180
- max_visible_status_text_width: 24 if using icon mode
```

### 2.2 State Matrix

新規文書を作る。

```text
docs/ui/WORKSPACE_STATE_MATRIX.md
```

状態ごとの期待表示を書く。

例:

```md
## State: selected_hex_tile_map_without_resources

Input state:
- selected_hex_tile_map: HexTileMapLayer
- level_document: null
- layer_stack: null
- tile_catalog: null
- sample_mode: false
- debug_mode: false

Expected visible state:
- Resources tab shows missing unique resources panel
- Create Missing Resources is enabled only after save directory selected
- Generate tab shows target not ready
- Paint tab shows no active document / no active brush state
- Settings tab does not inject sample resources into main flow

Forbidden:
- sample catalog auto-selected
- raw node path visible in normal UI
```

### 2.3 Metric Specification

この文書が metric specification である。

実装時に更新する場合は、taskごとに `docs/review/autopilot/<TASK>_UI_METRIC_CHANGE_<date>.md` に変更理由を残す。

---

## 3. Test architecture

### 3.1 Required files

推奨ファイル構成:

```text
addons/hex_map_kit/editor/testing/hex_ui_layout_snapshot_collector.gd
addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd
addons/hex_map_kit/editor/testing/hex_ui_state_scenario_builder.gd
addons/hex_map_kit/editor/testing/hex_ui_static_contract.gd

tests/test_workspace_layout_metrics.gd
tests/test_workspace_state_matrix.gd
tests/test_workspace_interaction_contract.gd

tools/ui_static_audit.py

docs/ui/WORKSPACE_UI_CONTRACT.md
docs/ui/WORKSPACE_STATE_MATRIX.md
```

`addons/hex_map_kit/editor/testing/` は addon内部に置いてよいが、package対象に含めるかは後で判断する。公開packageに不要なら `tools/` または `tests/support/` へ移す。

### 3.2 Two-pass testing

UI Layout Metric Test は2段階にする。

```text
Pass A: Godot headless layout pass
  実際のGodot Control treeを構築し、layout後のrectを読む。

Pass B: Static audit pass
  GDScript sourceを静的に読み、Button / Label / ResourcePicker / ScrollContainer の危険patternを検出する。
```

Godot UIのContainer layoutは複雑なので、純粋なPython再実装で完全再現しようとしない。**Godot自身を layout oracle として使う**。

Static audit は高速な補助であり、Godot headless passの代替ではない。

---

## 4. Snapshot model

### 4.1 Node snapshot fields

各 visible Control node から以下を収集する。

```gdscript
{
  "id": String,                       # stable id if available
  "name": String,
  "node_path": String,                # report only, normal UI判定には使わない
  "class": String,
  "script_class": String,
  "visible": bool,
  "disabled": bool,
  "parent_class": String,
  "tab_id": String,
  "semantic_role": String,            # title, resource_picker, status, primary_action, debug_text, etc.

  "rect": Rect2,
  "global_rect": Rect2,
  "minimum_size": Vector2,
  "combined_minimum_size": Vector2,
  "custom_minimum_size": Vector2,
  "size_flags_horizontal": int,
  "size_flags_vertical": int,

  "text": String,
  "text_width": float,
  "allocated_text_width": float,
  "text_truncation_ratio": float,

  "tooltip": String,
  "tooltip_length": int,

  "button_text": String,
  "button_pressed_connections": int,
  "button_effect_contract": String,

  "resource_picker_base_type": String,
  "resource_picker_has_resource": bool,
  "resource_picker_resource_class": String,

  "is_scroll_container": bool,
  "inside_scroll_container": bool,
  "scroll_container_path": String,

  "visible_text_kind": String,         # user, status, debug, internal, filepath, nodepath
  "state_source": String,              # node, document, dependency, manual, sample, scratch
  "sample_source": bool
}
```

### 4.2 Stable IDs

`node_path` は実行ごとに変わる場合があるため、評価IDとして使わない。

各重要Controlは `metadata` を持つ。

```gdscript
control.set_meta("ui_metric_id", "resources.level_document.slot")
control.set_meta("ui_metric_role", "resource_slot")
control.set_meta("ui_metric_tab", "Resources")
control.set_meta("ui_metric_required", true)
```

最低限のrole:

```text
screen_root
scroll_root
section
resource_slot
resource_slot_title
resource_picker
status_icon
status_text
primary_action
secondary_action
debug_action
debug_text
empty_state
summary
progress
busy_state
issue_list
score_table
```

Metadataがない場合、collectorはclass/name/textから推定するが、重要UIではmetadata必須とする。

---

## 5. Scenario matrix

### 5.1 Dock sizes

最低限、以下で評価する。

```text
width: 280, 320, 360, 420, 520, 640
height: 420, 600, 720, 900
```

Acceptanceで重視する標準幅:

```text
narrow: 320x600
normal: 420x720
wide:   640x900
```

### 5.2 UI scale

Godot Editor UI scale相当として、以下を疑似的に評価する。

```text
scale: 1.0, 1.25, 1.5
```

実装では、font size / theme override / test theme のいずれかで再現する。完全なEditor scale再現が難しい場合、font size matrixだけでもよい。

### 5.3 Locale / text variants

最低限:

```text
en_short
ja_short
ja_long
long_resource_names
long_paths_debug_only
```

Text variant例:

```text
Level Document
レベルドキュメント
選択中HexTileMapLayerが参照するLevel Document
res://very/long/project/path/maps/chapter_01/level_document.tres
/root/@EditorNode@18073/@Panel@14/...
```

通常UIに long path / node path を出すことは原則禁止だが、debug leakage検出用にscenarioへ入れる。

### 5.4 Workspace states

最低限:

```text
no_selected_hex_tile_map
selected_hex_tile_map_no_resources
selected_hex_tile_map_with_unique_resources
selected_hex_tile_map_with_shared_resources
selected_hex_tile_map_with_document_dependencies
sample_mode_off
sample_mode_on
sample_resource_selected
manual_project_resource_selected
generate_preview_only
generate_apply_to_document_dirty
generate_running_busy
paint_no_brush
paint_active_brush
validation_no_issues
validation_with_errors
qa_no_profile
qa_with_score_rows
export_no_destination
export_ready
settings_debug_off
settings_debug_on
```

---

## 6. Metric definitions

### 6.1 Text truncation risk

#### Formula

```text
text_width = font.get_string_size(text).x
allocated_text_width = control.rect.size.x - horizontal_content_padding
truncation_ratio = text_width / max(allocated_text_width, 1)
```

#### Threshold

```text
FAIL:
- required title / primary action text truncation_ratio > 1.00 at normal width
- Resource slot title truncation_ratio > 1.00 if no tooltip/short-title alternative exists

WARN:
- non-critical label truncation_ratio > 1.00
- any text truncation_ratio > 0.85 at narrow width
```

#### Policy

Resource rowのtitleは短くする。

```text
Bad:
- HexMapDocumentResource
- Selected HexTileMap Resource Context

Good:
- Document
- Catalog
- Layer Stack
```

詳細はtooltipへ移す。

### 6.2 Resource row geometry

#### Expected row structure

```text
[status icon] [short title] [EditorResourcePicker expands] [primary action if needed]
```

#### Metrics

```text
row_width = row.rect.size.x
picker_width = picker.rect.size.x
title_width = title.rect.size.x
status_width = status.rect.size.x
action_width_total = sum(action_button.width)
```

#### Threshold

```text
FAIL:
- picker_width < 160 at normal width
- picker_width < 120 at narrow width
- title_width > 140 at normal width
- visible status text width > 48 when icon mode is required
- action_width_total > 140 in resource row without explicit exception

WARN:
- more than 1 visible action button in a resource row
- title_width > 110 at narrow width
```

#### Policy

`Details` buttonはResource rowに置かない。Details相当の情報は title tooltip / status tooltip / Copy Debug Report へ移す。

### 6.3 Scroll reachability

#### Formula

```text
content_height = tab_content.get_combined_minimum_size().y
viewport_height = tab_scroll_container.rect.size.y
requires_scroll = content_height > viewport_height
has_scroll = tab_root is ScrollContainer or child scroll covers primary content
```

#### Threshold

```text
FAIL:
- requires_scroll and not has_scroll
- required primary action y > viewport_height and not inside ScrollContainer
- tab content clips vertically with no scroll parent

WARN:
- primary action is below first viewport in initial state
- more than 70% of tab content is below first viewport in initial state
```

### 6.4 Dead area / control density

#### Formula

```text
visible_area = tab_visible_rect.width * tab_visible_rect.height
occupied_area = union_area(visible_control_rects excluding containers/background)
interactive_area = union_area(buttons + pickers + inputs + lists + trees)

dead_area_ratio = 1.0 - occupied_area / max(visible_area, 1)
interactive_density = interactive_area / max(visible_area, 1)
```

#### Threshold

```text
FAIL:
- dead_area_ratio > 0.75 in a work tab without preview canvas/list/table reason

WARN:
- dead_area_ratio > 0.60 in Generate/Paint/Catalog/Layers/Validate/QA/Export
- interactive_density < 0.08 in a work tab with required work controls
```

#### Exceptions

Dead area is allowed if tab intentionally contains:

```text
- preview viewport
- map preview canvas
- large issue list waiting for results
- score table waiting for batch run
```

But exception must be declared in `WORKSPACE_UI_CONTRACT.md`.

### 6.5 Visible debug leakage

#### Debug patterns

```text
/root/
@EditorNode
@Panel
res://
user://
class_name
SOURCE_
NodePath
true
false
HexMapWorkspaceAssetContext
HexMapEditorSessionState
```

#### Formula

```text
debug_label_count = count(visible_text matching debug patterns)
debug_text_width_total = sum(width of debug-matching visible text)
debug_leakage_score = debug_label_count * 10 + debug_text_width_total / 100
```

#### Threshold

```text
FAIL:
- debug_label_count > 0 in normal mode for Resources/Generate/Paint/Catalog/Layers/Validate/QA/Export/Settings
- true/false visible as state label in Settings

WARN:
- filepath visible outside explicit compact path chip or debug section
- node path visible outside Copy Debug Report
```

#### Policy

Debug details go to one button per tab at most:

```text
Copy <Tab> Debug Report
```

Normally, `Copy Workspace Debug Report` should be enough.

### 6.6 No-op button audit

#### Required metadata

Every visible button must have:

```gdscript
button.set_meta("ui_action_id", "resources.create_missing")
button.set_meta("ui_action_effect", "creates_resources_and_assigns_selected_node")
```

#### Checks

```text
has_pressed_signal
has_action_id
has_effect_description
is_not_duplicate_of_standard_resource_picker_action
is_enabled_condition_documented_if_disabled
```

#### Threshold

```text
FAIL:
- visible enabled button has no pressed connection
- visible enabled button has no ui_action_id
- visible button effect only changes status label
- visible button duplicates ResourcePicker standard clear/load action without special reason

WARN:
- disabled button has no tooltip explaining condition
- more than one secondary button in compact resource row
```

### 6.7 ResourcePicker type specificity

#### Checks

```text
base_type = picker.base_type
slot_required_type = slot.required_type
```

#### Threshold

```text
FAIL:
- production required slot has base_type == "" or "Resource"
- slot required_type and picker.base_type mismatch

WARN:
- optional slot has generic Resource without a backlog note explaining why
```

#### Allowed generic slots

Only allowed when `WORKSPACE_UI_CONTRACT.md` lists reason.

Example:

```text
Export Profile is temporarily generic Resource until HexExportProfileResource is implemented.
Backlog: PROFILE-10_CONCRETE_EXPORT_PROFILE_RESOURCE
```

### 6.8 State contradiction

#### Examples

```text
context.tile_catalog != null
but visible text contains "No tile catalog selected"

sample_mode == false
but generate default catalog source == sample

selected_hex_tile_map != null
but Resources tab says "No HexTileMap selected"

document_dirty == true
but visible saved status says "Saved"

export_destination == ""
but Export button enabled
```

#### Threshold

```text
FAIL:
- any state contradiction in normal mode
```

State contradiction tests are more important than screenshots.

### 6.9 Sample separation

#### Checks

```text
sample_mode_off:
  main selectors do not include sample candidates
  generate/paint do not silently use sample resources

sample_mode_on:
  sample candidates are marked SOURCE_SAMPLE or learning-only
  production path remains project resource first
```

#### Threshold

```text
FAIL:
- sample_mode_off uses sample fallback in Generate/Paint/Catalog
- sample resource satisfies production required asset without explicit user action
- sample mode UI lacks Duplicate To Project path
```

### 6.10 Generated result / document persistence clarity

Generate UI state must expose semantic state through model, not labels.

Checks:

```text
output_target in [preview_only, apply_to_document]
document_dirty_state in [clean, dirty, unsaved]
viewport_state_source in [preview, document, node_layer]
apply_button_enabled condition
save_required condition
```

Threshold:

```text
FAIL:
- output_target == preview_only and UI enables Save Document as if document changed
- output_target == apply_to_document and document_dirty_state not updated
- viewport_state_source unknown after generation

WARN:
- user-facing state lacks status icon / tooltip for preview vs document
```

---

## 7. Regression severity

### 7.1 Severity levels

```text
P0_FAIL:
  Standard regression test fails. Repair before completing the task, but P0=0 alone is not acceptance proof.

P1_FAIL:
  Report-only unless the active roadmap explicitly promotes it to repair-now.

WARN:
  Diagnostic warning. Record if it affects the active task's experiential DoD.

INFO:
  Diagnostic only.
```

### 7.2 P0_FAIL rules

The following fail the standard regression check:

```text
- visible enabled no-op button
- required tab content needs scroll but no ScrollContainer
- state contradiction in normal mode
- sample_mode_off uses sample fallback in main production flow
- production required ResourcePicker has generic Resource base_type
- debug node path / raw path / true/false leaks into normal visible UI
- required primary action unreachable with no scroll
- Resource selected but UI reports missing/no selected
- dialog action button opens no dialog or uses unsafe dialog parent path
```

### 7.3 P1 issue rules

```text
- label truncation for non-primary text at normal width
- more than one secondary action in compact resource row
- generic optional Resource slot without explicit backlog note
- large dead area in work tab without declared preview/list/table exception
- disabled action lacks tooltip condition
- tab is summary-only while roadmap says editor surface complete
```

### 7.4 WARN rules

```text
- label truncation risk at narrow width only
- primary action below first viewport but reachable by scroll
- high text density
- debug copy button missing for a complex tab
- tooltip too long
- inconsistent title wording across tabs
```

---

## 8. Concrete procedures

### 8.1 Procedure: add or modify a UI component

Every UI task must follow this order.

```text
1. Update WORKSPACE_UI_CONTRACT.md if component changes visible UI.
2. Update WORKSPACE_STATE_MATRIX.md if component visibility depends on state.
3. Add stable ui_metric_id / role metadata to new controls.
4. Implement UI.
5. Add or update layout metric tests.
6. Add or update interaction contract tests.
7. Run tools/ui_static_audit.py.
8. Run ./tools/test.sh if Godot is available.
9. Include UI metric report summary in self-review.
```

### 8.2 Procedure: create a new tab or screen

```text
1. Define tab purpose.
2. Define forbidden visible debug information.
3. Define required states.
4. Define required components.
5. Define scroll policy.
6. Define primary action.
7. Define empty state.
8. Define Copy Debug Report boundary.
9. Add scenario to snapshot matrix.
10. Add regression thresholds.
```

A tab is not complete if it merely mirrors resource rows and roadmap calls it a work tab; metric pass cannot override that experiential DoD failure.

### 8.3 Procedure: change Resource row

```text
1. Confirm required Resource type.
2. Set EditorResourcePicker.base_type to concrete type.
3. Shorten visible title.
4. Move explanation to tooltip.
5. Remove Clear / Select / Open / Validate unless use case is explicit.
6. Ensure picker width threshold passes.
7. Ensure status is icon/badge, not long text.
8. Add state contradiction tests.
```

### 8.4 Procedure: add a button

Before adding a button, classify it.

```text
primary_action
secondary_action
context_menu_action
debug_action
remove
```

Acceptance checklist:

```text
- ui_action_id exists
- effect description exists
- pressed signal exists
- state mutation exists
- failure condition tooltip exists
- action is not duplicate of ResourcePicker standard behavior
- button is included in interaction contract test
```

### 8.5 Procedure: expose debug information

```text
1. Do not add visible debug Label.
2. Add field to debug report model.
3. Ensure Copy Workspace Debug Report contains it.
4. Ensure normal UI debug leakage test still passes.
5. If a compact state indicator is needed, use icon + tooltip.
```

### 8.6 Procedure: modify Generate output behavior

```text
1. Update Generate state model.
2. Define output_target: preview_only / apply_to_document.
3. Define viewport_state_source: preview / document / node_layer.
4. Define document_dirty_state.
5. Define save requirement.
6. Add state contradiction tests.
7. Add metric test that status does not use long explanatory labels.
```

---

## 9. Test implementation outline

### 9.1 Snapshot collector pseudo-code

```gdscript
class_name HexUILayoutSnapshotCollector
extends RefCounted

static func collect(root: Control, scenario: Dictionary) -> Dictionary:
    var out := {
        "scenario": scenario,
        "root_size": root.size,
        "nodes": [],
        "metrics": {}
    }
    _walk(root, out["nodes"], "")
    out["metrics"] = HexUILayoutMetricEvaluator.evaluate(out)
    return out

static func _walk(node: Node, nodes: Array, tab_id: String) -> void:
    if node is Control:
        var c: Control = node
        var item := _snapshot_control(c, tab_id)
        nodes.append(item)
        if c.has_meta("ui_metric_tab"):
            tab_id = String(c.get_meta("ui_metric_tab"))
    for child in node.get_children():
        _walk(child, nodes, tab_id)

static func _snapshot_control(c: Control, tab_id: String) -> Dictionary:
    var font := c.get_theme_default_font()
    var font_size := c.get_theme_default_font_size()
    var text := _control_text(c)
    var text_width := 0.0
    if text != "" and font != null:
        text_width = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

    return {
        "name": c.name,
        "class": c.get_class(),
        "script_class": _script_class(c),
        "visible": c.is_visible_in_tree(),
        "disabled": _is_disabled(c),
        "tab_id": tab_id,
        "semantic_role": String(c.get_meta("ui_metric_role", "")),
        "id": String(c.get_meta("ui_metric_id", "")),
        "rect": c.get_rect(),
        "global_rect": c.get_global_rect(),
        "minimum_size": c.get_minimum_size(),
        "combined_minimum_size": c.get_combined_minimum_size(),
        "custom_minimum_size": c.custom_minimum_size,
        "size_flags_horizontal": c.size_flags_horizontal,
        "size_flags_vertical": c.size_flags_vertical,
        "text": text,
        "text_width": text_width,
        "allocated_text_width": c.size.x,
        "tooltip": c.tooltip_text,
        "button_pressed_connections": _pressed_connection_count(c),
        "resource_picker_base_type": _resource_picker_base_type(c),
        "inside_scroll_container": _has_scroll_parent(c),
        "visible_text_kind": _classify_visible_text(text)
    }
```

### 9.2 Metric evaluator pseudo-code

```gdscript
class_name HexUILayoutMetricEvaluator
extends RefCounted

static func evaluate(snapshot: Dictionary) -> Dictionary:
    var result := {
        "failures": [],
        "warnings": [],
        "infos": []
    }
    _check_scroll(snapshot, result)
    _check_text_truncation(snapshot, result)
    _check_resource_rows(snapshot, result)
    _check_noop_buttons(snapshot, result)
    _check_debug_leakage(snapshot, result)
    _check_resource_picker_types(snapshot, result)
    _check_dead_area(snapshot, result)
    _check_state_contradictions(snapshot, result)
    return result
```

### 9.3 Test pseudo-code

```gdscript
func test_workspace_layout_metrics() -> void:
    for scenario in HexUIStateScenarioBuilder.scenarios():
        for size in [Vector2(320, 600), Vector2(420, 720), Vector2(640, 900)]:
            var workspace := HexMapWorkspace.new()
            add_child(workspace)
            workspace.size = size
            HexUIStateScenarioBuilder.apply(workspace, scenario)
            await get_tree().process_frame
            await get_tree().process_frame

            var snapshot := HexUILayoutSnapshotCollector.collect(workspace, scenario)
            var failures: Array = snapshot.metrics.failures
            assert_true(failures.is_empty(), JSON.stringify(failures, "  "))
            workspace.queue_free()
```

### 9.4 Static audit pseudo-code

```python
# tools/ui_static_audit.py

checks = [
    find_button_without_pressed_connect,
    find_visible_debug_label_patterns,
    find_resource_picker_generic_base_type,
    find_tab_without_scroll_container,
    find_details_clear_open_select_buttons,
    find_true_false_label_text,
]

for check in checks:
    findings.extend(check(repo_root))

if any(f.severity == "FAIL" for f in findings):
    sys.exit(1)
```

---

## 10. Report format

Every UI metric run outputs:

```text
.godot_user/ui-metrics/<run-id>/workspace_ui_metrics.json
.godot_user/ui-metrics/<run-id>/workspace_ui_metrics.md
```

Markdown report format:

```md
# Workspace UI Metrics Report

Run: <id>
Godot: <version>
Date: <date>

## Summary

- P0 failures: 0
- P1 failures: 1
- Warnings: 14

## P0 failures

None.

## P1 failures

### Resources / selected_node_with_resources / 320x600

Resource row `resources.level_document` has picker_width=112 < 160.

Suggested fix:
- Shorten title to `Document`
- Move class name to tooltip
- Remove secondary action button

## Warnings
...
```

Self-review must cite this report path.

---

## 11. Regression proof by task type

The following items are regression proof requirements. They do not replace the queue's two-layer DoD.

### 11.1 Docs-only UI policy task

Required:

```text
- UI contract updated
- State matrix updated if relevant
- Regression thresholds defined if relevant
```

No Godot metric run required.

### 11.2 UI layout task

Required:

```text
- Layout metric run passes with P0 failures = 0 as regression proof
- P1 issues are recorded as report-only unless active task policy promotes them
- Scroll reachability pass
- Text truncation pass for normal width
- Debug leakage pass
- Experiential DoD recorded separately in self-review
```

### 11.3 Resource selection task

Required:

```text
- ResourcePicker type specificity pass
- resource row geometry pass
- redundant button pass
- sample separation pass if sample can appear
- state contradiction pass
```

### 11.4 Interaction task

Required:

```text
- no-op button pass
- action metadata present
- visible enabled buttons have effect contract
- disabled buttons have tooltip condition
```

### 11.5 Generate / Paint / Validate / Export task

Required:

```text
- state matrix updated
- generated/result state contradiction pass
- debug leakage pass
- primary action reachability pass
- task-specific semantic metrics pass
```

### 11.6 Package/dist task

This policy does not require committed dist freshness as a normal UI test gate.

Dist regeneration remains a final process step when roadmap says so.

---

## 12. Incremental adoption plan

### Phase M0: Contract only

```text
UI-METRIC-00_WORKSPACE_UI_CONTRACT
UI-METRIC-01_WORKSPACE_STATE_MATRIX
```

### Phase M1: Static audit

```text
UI-METRIC-02_STATIC_UI_AUDIT
```

Initial checks:

```text
- visible forbidden button text
- debug label patterns
- generic ResourcePicker pattern
- tab constructor without ScrollContainer
```

### Phase M2: Snapshot collector

```text
UI-METRIC-03_LAYOUT_SNAPSHOT_COLLECTOR
```

Collect JSON, no fail gate yet.

### Phase M3: Warning report

```text
UI-METRIC-04_LAYOUT_METRIC_WARNING_REPORT
```

All metrics are WARN only.

### Phase M4: P0 regression check

```text
UI-METRIC-05_P0_ACCEPTANCE_GATE
```

Enable P0 regression failures:

```text
- no-op visible button
- no scroll when required
- state contradiction
- debug leakage
- sample fallback in production
```

### Phase M5: P1 report

```text
UI-METRIC-06_P1_ACCEPTANCE_GATE
```

Report strict row geometry, label truncation, picker width unless the active roadmap promotes them to a hard regression failure.

---

## 13. Current recommended thresholds

These are initial values. Update with evidence.

```text
min_picker_width_normal = 180
min_picker_width_narrow = 120
max_resource_title_width_normal = 140
max_resource_title_width_narrow = 110
max_resource_row_action_buttons = 1
max_debug_label_count_normal = 0
max_dead_area_ratio_work_tab = 0.65 warn, 0.75 fail
max_visible_status_text_width_icon_mode = 48
max_primary_action_y_without_scroll = viewport_height
```

---

## 14. What this process prevents

This process is designed to catch:

```text
- Resource labels being truncated
- Resource rows becoming too wide
- Details / Clear / Open / Select buttons reappearing
- Settings showing true/false text labels
- Generate tab containing huge dead area
- Paint tab having no effective work controls
- Catalog selected while UI says no catalog selected
- sample mode off but sample fallback active
- normal UI leaking node paths and file paths
- tabs with content but no scroll
- generic Resource picker for concrete asset slots
```

It does not decide whether the UI is beautiful. It decides whether the UI is structurally acceptable.

---

## 15. Final policy

From this point on, a UI task is not complete merely because:

```text
- controls were added
- tests can find the node
- button exists
- label explains the internal state
- sample asset path works
```

A UI task is complete only when regression proof and experiential DoD are both satisfied:

```text
- UI contract is satisfied
- state matrix is satisfied
- metric P0 failures are zero as regression proof
- visible actions have real effects
- normal UI does not leak debug information
- required ResourcePicker slots are concrete
- narrow dock layout remains usable
- sample does not replace production asset selection
- self-review records what the user sees first and what primary action they can take
```

This preserves independent, structural feedback without letting metric pass replace product UX proof.
