# UI State Transition Refactor Feedback 2026-06-10

作成日: 2026-06-10  
対象repo: `godot-hex-map-lab-20260610-025244.zip`  
関連roadmap: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`  
目的: UI制御をフラグ合成から状態遷移管理へ移行するため、現状のフラグ制御候補、state model設計、refactoring候補領域を整理する。次回roadmap作成の前段資料として使う。

---

## 0. 総合結論

UI制御は、すでに一部で state model 化が始まっている。

良い既存例:

- `HexMapEditorAssetSlotState`: Asset slot の `status` / `source` / `selected` / `sample` を snapshot 化している。
- `HexMapWorkspaceAssetContext`: Workspace 全体の asset slot を明示的に集約している。
- `HexMapWorkspaceComponentRegistry`: tab / component / responsibility / asset slot の関係を宣言的に持っている。
- `HexMapGenStateEvaluator`: Generate Dock の visibility / disabled / label / block reason を pure input から評価している。
- `HexMapEditMutationBuilder` / `HexMapEditViewportInputAdapter`: mutation と viewport hit 判定が UI から少し分離されている。

一方で、重要なUI制御はまだ boolean flag、selected index、pending token、visible/disabled代入、手続き型 `_refresh_*()` の連鎖で組まれている。特に以下は state transition 管理へ移す価値が高い。

```text
1. Generation実行 / cancel / progress / debounce
2. selected HexTileMap node と workspace asset context の同期
3. AssetSlot の config / runtime / operation の分離
4. Paint edit mode / brush readiness / viewport interaction
5. Validation run / issue selection / focus navigation
6. Export destination / output readiness / execution
7. Sample learning / duplicate / project copy flow
8. Dialog open/commit/cancel lifecycle
9. Missing unique resources create flow
10. Tabごとの readiness / empty / active operation 状態
```

推奨方針:

```text
UI Widget を直接 enable/disable/visible する設計
  -> State Reducer が ViewState を生成し、Widget は ViewState を render する設計へ移す

複数boolの組み合わせで意味を作る設計
  -> enum/const state + transition event + side effect request へ移す

_refresh_*() が相互に呼び合う設計
  -> dispatch(event) -> reduce(state,event) -> render(view_state) へ移す
```

重要: すべての bool をなくす必要はない。`is_required`、`allows_create_new`、`flat_top` のような **設定値 / 構成値** は bool のままでよい。状態遷移管理に移すべきなのは、時間とイベントで変化する **workflow state / operation state / readiness state** である。

---

## 1. フラグ制御候補の洗い出し

### 1.1 高優先候補一覧

| 優先度 | 領域 | 主なファイル | 現状の兆候 | State化すべき理由 |
|---|---|---|---|---|
| P0 | Generate operation | `hex_map_gen_dock.gd` | `_generation_running`, `_generation_cancel_requested`, `_last_generation_cancelled`, `_generation_progress_step`, hide token, debounce pending | 実行・cancel・progress・apply・validationが一つの非同期状態機械であるため。 |
| P0 | Workspace selection / binding | `hex_map_workspace.gd`, `hex_map_editor_session_state.gd` | `selected_hex_tile_map_layer`, `target_layer`, `auto_link_selected_hex_tile_map`, writeback snapshot | 選択node、target、asset context、writebackが分岐し、同期バグが起きやすい。 |
| P0 | Asset slot lifecycle | `hex_map_editor_asset_slot_state.gd`, `hex_map_editor_asset_slot_control.gd`, `hex_map_workspace_asset_panel.gd` | `STATUS_*`, `SOURCE_*`, `allows_*`, `_syncing`, visible action buttons | 状態モデルはあるが config/runtime/operation が混在している。 |
| P0 | Paint interaction | `hex_map_edit_tool.gd` | `EditMode`, `_document_dirty`, `_target_selection_explicit`, `_last_applied_to_target`, `_last_edit_hit`, `_last_edit_status`, `_pending_viewport_trace` | paint tab の意味は mode + target + document + brush + viewport hit の合成で決まる。 |
| P1 | Validation workflow | `hex_map_workspace.gd`, `hex_map_validation_dashboard.gd`, `hex_map_edit_tool.gd` | `_last_workspace_validation_result`, `_selected_validate_issue_index`, `_selected_validate_issue_row`, `_validation_focus_status` | 未実行/実行中/clean/warning/error/issue selected/focus applied の状態が必要。 |
| P1 | Export workflow | `hex_map_workspace.gd` | `_export_destination_label`, recent destinations, output mode visibility, can export reason | Exportの目的が runtime handoff へ整理されたので、readiness / destination / run result を一つの状態にする。 |
| P1 | Sample learning flow | `hex_map_sample_settings_panel.gd`, `hex_map_editor_session_state.gd` | `show_bundled_samples...`, `use_bundled_sample...`, `auto_create_project_copy...`, `sample_learning_cta_dismissed` | sampleはproduction flowと分離すべき学習導線なので状態を明示する。 |
| P1 | Dialog lifecycle | `hex_map_workspace.gd`, `hex_map_editor_asset_slot_control.gd`, `hex_map_sample_settings_panel.gd`, `hex_dist_editor.gd` | popup / selected callback が各所に分散 | open/commit/cancel の状態が散ると二重add_childやno-opボタンを見逃す。 |
| P2 | Workspace tab readiness | `hex_map_workspace.gd`, `hex_map_workspace_component_registry.gd` | tabごとの snapshot / empty state / purpose text | tabが「表示される」だけでなく「作業可能か」をstateで示すべき。 |
| P2 | Layer stack operation | `hex_map_workspace.gd`, `hex_map_edit_tool.gd` | target root / role selected / apply result / relationship label | role選択、target、document apply、missing role の状態遷移がある。 |
| P2 | QA / Seed Lab | `hex_map_workspace.gd`, `hex_map_gen_dock.gd` | selected seed row / promoted document / dirty state | batch result selection -> promote -> dirty document の状態がある。 |

---

## 2. 現状フラグの具体例

### 2.1 `HexMapEditorSessionState`: preferences と workflow state が混在

現状:

```gdscript
var target_layer: Node = null
var selected_hex_tile_map_layer: Node = null
var auto_link_selected_hex_tile_map := true
var document: Resource = null
var document_source: String = ""
var document_saved_path: String = ""
var workspace_asset_context: HexMapWorkspaceAssetContext = HexMapWorkspaceAssetContext.new()
var show_bundled_samples_in_main_selectors := false
var use_bundled_sample_assets_for_scratch_documents := false
var auto_create_project_copy_when_applying_sample := false
var sample_learning_cta_dismissed := false
var debug_numeric_tile_fallback_enabled := false
```

評価:

- `show_bundled_samples...` や `debug_numeric...` は preference として bool のままでもよい。
- `selected_hex_tile_map_layer` / `target_layer` / `document` / `workspace_asset_context` は workflow state であり、状態遷移管理の対象。
- `auto_link_selected_hex_tile_map` は単なるUIトグルではなく、選択node変更時の副作用方針を決める policy state。

推奨:

```text
HexMapEditorSessionState
  -> Settings / Preferences を保持

HexMapWorkspaceState
  -> selected node / active target / asset context / active tab / operation state を保持

HexMapWorkspaceReducer
  -> event を受け取り、WorkspaceState と side effect request を返す
```

### 2.2 `HexMapGenDock`: Generation実行状態が複数フラグに分散

現状の代表フラグ:

```gdscript
var _generation_running := false
var _generation_cancel_requested := false
var _generation_progress := 0.0
var _generation_status := "Ready"
var _last_generation_cancelled := false
var _generation_thread: Thread
var _generation_id := 0
var _generation_progress_hide_token := 0
var _generation_progress_scheduled_hide_token := 0
var _generation_progress_hide_after_msec := 0
var _generation_progress_step := PROGRESS_STEP_IDLE
var _tile_settings_apply_pending := false
var _tile_settings_last_apply_result := false
var _suppress_tile_settings_apply := false
```

関連処理:

- `_begin_generation()`
- `_finish_generation()`
- `_set_generation_cancel_requested()`
- `_show_generation_progress_controls()`
- `_finish_generation_progress_controls_success()`
- `_process_generation_progress_hide_timer()`
- `_refresh_generation_block_state()`
- tile settings debounce / apply 周辺

評価:

ここは最優先でFSM化するべきである。現在は `running=false` でも `progress_step=complete`、`hide_token pending`、`last_generation_cancelled=true` のような組み合わせがあり得る。状態の意味が複数フラグの組み合わせに分散しているため、progressbarやbutton状態の正しさを局所的に判断できない。

推奨状態:

```text
GenerationRunState
  IDLE
  CONFIG_DIRTY
  BLOCKED
  QUEUED_DEBOUNCE
  PREPARING
  GENERATING
  VALIDATING_RESULT
  APPLYING_RESULT
  APPLYING_TILE_SETTINGS
  CANCEL_REQUESTED
  CANCELLED
  COMPLETED
  FAILED
```

補助状態:

```text
GenerationProgressViewState
  HIDDEN
  VISIBLE_CAN_CANCEL
  VISIBLE_LOCKED
  SUCCESS_HOLD
  ERROR_HOLD
  SCHEDULED_HIDE
```

### 2.3 `HexMapEditTool`: Paint/target/document state が混在

現状:

```gdscript
enum EditMode { SHAPE, WALL_FLOOR, FLOOR_TILE, WALL_TILE, OBJECT, LABEL, OVERLAY_TILE }

var _document_dirty := false
var _target_selection_explicit := false
var _default_target_tile_settings_explicit := false
var _last_applied_to_target := false
var _last_edit_hit: Dictionary = {}
var _last_edit_status: Dictionary = {}
var _target_status_detail: Dictionary = {}
var _last_persistence_status: Dictionary = {}
var _last_validation_result = null
var _selected_validation_issue: Dictionary = {}
var _validation_focus_status: Dictionary = {}
var _pending_viewport_trace: Dictionary = {}
var _refreshing_object_definition_tree := false
var _refreshing_label_definition_tree := false
```

評価:

`EditMode` は良い出発点だが、paint tab の実状態は `mode` だけではない。

実際には以下の合成で決まる。

```text
Target readiness
Document readiness
Catalog/Object/Label readiness
Brush readiness
Viewport hit state
Undo/Redo edit transaction state
Validation focus state
Persistence / dirty state
```

これらを個別boolで持つと、Paint tab の見え方・action enabled・viewport入力可否・自動tab切替が分散する。

推奨状態:

```text
PaintWorkspaceState
  NO_TARGET
  TARGET_SELECTED_NO_DOCUMENT
  DOCUMENT_READY_NO_BRUSH
  BRUSH_READY
  VIEWPORT_HOVER
  EDIT_APPLYING
  EDIT_APPLIED_DIRTY
  VALIDATION_FOCUS
  BLOCKED_BY_MISSING_ASSET
```

Brush は別状態にする。

```text
BrushState
  mode: Terrain/Object/Label/Overlay/Shape
  selected_key: String
  source_asset_slot: String
  readiness: MissingAsset / Ready / Invalid / SampleWarning
```

### 2.4 `HexMapEditorAssetSlotState`: 既にstate化されているが分解余地あり

現状:

```gdscript
const STATUS_NOT_SELECTED := "not_selected"
const STATUS_SELECTED := "selected"
const STATUS_INVALID := "invalid"
const STATUS_WARNING := "warning"

const SOURCE_NONE := "none"
const SOURCE_PROJECT := "project"
const SOURCE_SAMPLE := "sample"

var is_required := true
var allows_create_new := false
var allows_sample := false
var validation_status := STATUS_NOT_SELECTED
var current_source := SOURCE_NONE
```

評価:

これは良い。ただし、1つのclassが以下を同時に持っている。

- slot config: required type, purpose, required, allows create/sample
- runtime selection: selected resource/path/source
- validation result: status/messages
- UI action availability: allows create/sample

推奨分割:

```text
HexMapAssetSlotConfig
  slot_id
  display_name
  required_type
  purpose
  is_required
  allowed_actions
  sample_policy

HexMapAssetSlotRuntimeState
  lifecycle_state
  current_resource
  current_source
  validation_messages
  operation_state

HexMapAssetSlotViewState
  compact_label
  picker_base_type
  status_text
  tooltip
  visible_actions
```

状態案:

```text
AssetSlotLifecycle
  EMPTY_REQUIRED
  EMPTY_OPTIONAL
  PROJECT_SELECTED
  SAMPLE_SELECTED_WARNING
  TYPE_INVALID
  MISSING_RESOURCE
  CREATE_DIALOG_OPEN
  CREATING
  SAVING
  SYNCING_FROM_CONTEXT
  ERROR
```

### 2.5 `HexMapWorkspaceAssetPanel`: `_syncing` guard

現状:

```gdscript
var _syncing := false
```

これは signal loop 回避としてよくあるが、状態遷移管理に移すと削減できる。

推奨:

```text
AssetContextTransaction
  USER_SELECTED_RESOURCE
  CONTEXT_SYNC_STARTED
  CONTEXT_SYNC_APPLIED
  RESOURCE_CREATED
  RESOURCE_CLEARED
```

`_syncing` bool でイベントを握りつぶすのではなく、event source を明示して reducer で ignore / apply を判断する。

### 2.6 `HexMapWorkspace`: tab, validation, QA, export, missing resource が一箇所に集約されすぎ

現状の状態保持例:

```gdscript
var _selected_validate_issue_index := -1
var _selected_validate_issue_row: Dictionary = {}
var _selected_validate_issue_navigation: Dictionary = {}
var _qa_selected_seed_row: Dictionary = {}
var _qa_promoted_document: HexMapDocumentResource = null
var _missing_unique_resources_save_directory := ""
var _last_workspace_validation_result: HexMapValidationResult = null
```

評価:

Workspace は全体調停役として自然だが、各tabの状態が変数として増え続けると、再び巨大dock問題に戻る。ここは `TabState` 群へ分けるべきである。

推奨:

```text
ResourcesTabState
CatalogTabState
LayersTabState
PaintTabState
ValidateTabState
QATabState
ExportTabState
SettingsTabState
```

各tabは `snapshot()` と `view_state()` を返すが、Widget 自体ではなく state object / reducer をsource of truthにする。

---

## 3. 提案する UI State Model

### 3.1 Root state

```gdscript
class_name HexMapWorkspaceState
extends RefCounted

var active_tab := "Resources"
var selection_state: HexMapSelectionState
var asset_context_state: HexMapAssetContextState
var sample_policy_state: HexMapSamplePolicyState
var operation_state: HexMapWorkspaceOperationState
var resources_tab_state: HexMapResourcesTabState
var generate_state: HexMapGenerationRunState
var paint_state: HexMapPaintWorkspaceState
var catalog_state: HexMapCatalogTabState
var layers_state: HexMapLayersTabState
var validate_state: HexMapValidationWorkflowState
var qa_state: HexMapSeedLabState
var export_state: HexMapExportWorkflowState
var settings_state: HexMapSettingsState
```

役割:

- `HexMapWorkspaceState` は保存Resourceではなく editor session state。
- `HexMapWorkspaceAssetContext` は asset参照の値を持つ。`WorkspaceState` はその readiness / origin / writeback / dirty を持つ。
- UI Widget は `WorkspaceState` を直接変更しない。`dispatch(event)` を呼ぶ。

### 3.2 Event / Reducer

```gdscript
class_name HexMapWorkspaceEvent
extends RefCounted

const SELECTED_NODE_CHANGED := "selected_node_changed"
const ASSET_SELECTED := "asset_selected"
const ASSET_CREATE_REQUESTED := "asset_create_requested"
const ASSET_CREATED := "asset_created"
const ASSET_CLEARED := "asset_cleared"
const TAB_SELECTED := "tab_selected"
const VIEWPORT_EDIT_STARTED := "viewport_edit_started"
const VIEWPORT_EDIT_APPLIED := "viewport_edit_applied"
const GENERATE_REQUESTED := "generate_requested"
const GENERATE_PROGRESS := "generate_progress"
const GENERATE_CANCEL_REQUESTED := "generate_cancel_requested"
const GENERATE_COMPLETED := "generate_completed"
const VALIDATE_REQUESTED := "validate_requested"
const VALIDATION_COMPLETED := "validation_completed"
const VALIDATION_ISSUE_SELECTED := "validation_issue_selected"
const EXPORT_DESTINATION_SELECTED := "export_destination_selected"
const EXPORT_REQUESTED := "export_requested"
const SAMPLE_SETTING_CHANGED := "sample_setting_changed"
const DIALOG_OPENED := "dialog_opened"
const DIALOG_COMMITTED := "dialog_committed"
const DIALOG_CANCELLED := "dialog_cancelled"
```

Reducerの出力:

```gdscript
{
  "state": next_state,
  "view_state": next_view_state,
  "side_effects": [
    {"type": "open_file_dialog", "dialog_id": "export_destination"},
    {"type": "save_resource", "slot_id": "level_document", "path": "..."},
    {"type": "run_generation", "snapshot": {...}},
    {"type": "apply_document_to_target", "target": target},
  ],
}
```

重要:

- Reducer は Godot scene tree を直接触らない。
- side effect handler が FileDialog / ResourceSaver / Thread / EditorInterface を扱う。
- side effect 完了後に `*_COMPLETED` event を dispatch する。

### 3.3 ViewState

UIは以下のようなview stateをrenderするだけにする。

```gdscript
class_name HexMapWorkspaceViewState
extends RefCounted

var active_tab := "Resources"
var tabs: Dictionary = {}
var asset_rows: Dictionary = {}
var primary_status := ""
var busy_overlay_visible := false
var blocking_reason := ""
var focus_request := {}
```

Asset row例:

```gdscript
{
  "slot_id": "tile_catalog",
  "label": "Tile Catalog",
  "picker_base_type": "HexTileCatalogResource",
  "status": "project_selected",
  "status_text": "OK",
  "tooltip": "Used by Generate, Paint, Validate, QA, and Export.",
  "actions": ["create_new"],
  "action_enabled": {"create_new": true},
}
```

Widgetの責務:

```text
receive view_state
  -> set text / tooltip / visible / disabled
  -> user interaction emits event
```

Widgetが business state を決めてはいけない。

---

## 4. 個別 State Machine 設計

### 4.1 Workspace Selection State

対象:

- selected HexTileMap node
- target layer
- node-owned unique Resource
- shared Resource hydration
- writeback

状態:

```text
NO_SCENE_CONTEXT
NO_HEX_TILE_MAP_SELECTED
HEX_TILE_MAP_SELECTED_UNBOUND
HEX_TILE_MAP_BOUND_SYNCED
HEX_TILE_MAP_BOUND_MISSING_UNIQUE_RESOURCES
HEX_TILE_MAP_BOUND_CONTEXT_DIRTY
HEX_TILE_MAP_WRITEBACK_BLOCKED
```

主要イベント:

```text
SELECTED_NODE_CHANGED
TARGET_LAYER_CHANGED
AUTO_LINK_ENABLED
AUTO_LINK_DISABLED
NODE_RESOURCE_HYDRATED
WORKSPACE_ASSET_CHANGED
WRITEBACK_REQUESTED
WRITEBACK_COMPLETED
CREATE_MISSING_UNIQUE_REQUESTED
CREATE_MISSING_UNIQUE_COMPLETED
```

移行例:

```text
NO_HEX_TILE_MAP_SELECTED
  -- SELECTED_NODE_CHANGED(HexTileMapLayer) --> HEX_TILE_MAP_SELECTED_UNBOUND

HEX_TILE_MAP_SELECTED_UNBOUND
  -- AUTO_LINK_ENABLED / hydrate --> HEX_TILE_MAP_BOUND_SYNCED

HEX_TILE_MAP_BOUND_SYNCED
  -- missing unique detected --> HEX_TILE_MAP_BOUND_MISSING_UNIQUE_RESOURCES

HEX_TILE_MAP_BOUND_SYNCED
  -- workspace asset selected --> HEX_TILE_MAP_BOUND_CONTEXT_DIRTY

HEX_TILE_MAP_BOUND_CONTEXT_DIRTY
  -- WRITEBACK_COMPLETED --> HEX_TILE_MAP_BOUND_SYNCED
```

### 4.2 Asset Slot State

対象:

- ResourcePicker row
- Create New
- Learn With Sample
- type validation
- sample warning

状態:

```text
EMPTY_REQUIRED
EMPTY_OPTIONAL
PROJECT_SELECTED
SAMPLE_AVAILABLE_NOT_SELECTED
SAMPLE_SELECTED_WARNING
TYPE_INVALID
CREATE_DIALOG_OPEN
CREATING
SAVE_PENDING
SYNCING_FROM_CONTEXT
ERROR
```

主要イベント:

```text
RESOURCE_PICKED
RESOURCE_CLEARED
CREATE_NEW_PRESSED
CREATE_PATH_SELECTED
RESOURCE_CREATED
SAMPLE_AVAILABLE
LEARN_WITH_SAMPLE_PRESSED
CONTEXT_SYNC_STARTED
CONTEXT_SYNC_APPLIED
VALIDATION_UPDATED
```

ポイント:

- `allows_create_new` / `allows_sample` は `AssetSlotConfig`。
- `SAMPLE_SELECTED_WARNING` は runtime lifecycle。
- `_actions_container.visible` は view state から導出。

### 4.3 Generation Run State

対象:

- primary generation
- overlay generation
- tile settings apply debounce
- progressbar
- cancel
- validation/apply

状態:

```text
IDLE
CONFIG_DIRTY
BLOCKED
QUEUED_DEBOUNCE
PREPARING
GENERATING
VALIDATING_RESULT
APPLYING_RESULT
APPLYING_TILE_SETTINGS
CANCEL_REQUESTED
CANCELLED
COMPLETED
FAILED
```

主要イベント:

```text
CONFIG_CHANGED
TILE_SETTINGS_CHANGED
DEBOUNCE_TIMER_FIRED
GENERATE_PRESSED
GENERATION_THREAD_STARTED
GENERATION_PROGRESS
CANCEL_PRESSED
GENERATION_THREAD_COMPLETED
VALIDATION_COMPLETED
APPLY_COMPLETED
FAILED
PROGRESS_HOLD_EXPIRED
```

ViewState:

```text
Generate button enabled/text
Cancel button enabled
Progressbar visible/value/text
Controls disabled
Block reason
Dirty/queued status
```

### 4.4 Paint Workspace State

対象:

- active brush
- active target
- document readiness
- viewport input
- selected cell
- last edit

状態:

```text
NO_TARGET
TARGET_SELECTED_NO_DOCUMENT
DOCUMENT_READY_NO_BRUSH
BRUSH_MISSING_ASSET
BRUSH_READY
VIEWPORT_HOVER
EDIT_APPLYING
EDIT_APPLIED_DIRTY
VALIDATION_FOCUS
```

主要イベント:

```text
PAINT_TAB_SELECTED
VIEWPORT_EDIT_STARTED
VIEWPORT_HIT_UPDATED
BRUSH_MODE_CHANGED
BRUSH_ASSET_CHANGED
EDIT_APPLIED
UNDO_REDO_APPLIED
VALIDATION_ISSUE_FOCUS_REQUESTED
TARGET_CHANGED
DOCUMENT_CHANGED
```

### 4.5 Validation Workflow State

状態:

```text
NOT_RUN
STALE
RUNNING
CLEAN
HAS_WARNINGS
HAS_ERRORS
ISSUE_SELECTED
FOCUS_APPLIED
FAILED
```

移行例:

```text
NOT_RUN -- VALIDATE_REQUESTED --> RUNNING
RUNNING -- VALIDATION_COMPLETED(no issues) --> CLEAN
RUNNING -- VALIDATION_COMPLETED(warnings) --> HAS_WARNINGS
RUNNING -- VALIDATION_COMPLETED(errors) --> HAS_ERRORS
HAS_ERRORS -- ISSUE_SELECTED --> ISSUE_SELECTED
ISSUE_SELECTED -- FOCUS_APPLIED --> FOCUS_APPLIED
any asset/document change --> STALE
```

### 4.6 Export Workflow State

状態:

```text
NO_DOCUMENT
NO_DESTINATION
READY
RUNNING
SUCCEEDED
FAILED
```

主要イベント:

```text
DOCUMENT_SELECTED
DESTINATION_SELECTED
EXPORT_REQUESTED
EXPORT_COMPLETED
EXPORT_FAILED
DESTINATION_CLEARED
```

### 4.7 Sample Learning State

状態:

```text
OFF
CTA_VISIBLE
SETTINGS_OPEN
SAMPLE_VISIBLE_FOR_LEARNING
DUPLICATE_DIALOG_OPEN
DUPLICATING
DUPLICATED_TO_PROJECT
ERROR
DISMISSED
```

注意:

- `show_bundled_samples_in_main_selectors` は最終的に消す候補。sampleはSettings経由の学習導線に限定する方針と合わない場合がある。
- `use_bundled_sample_assets_for_scratch_documents` は scratch 作成 flow の中だけに閉じる。
- `debug_numeric_tile_fallback_enabled` は Sample state ではなく DebugPreference state。

---

## 5. Refactoring 候補領域

### `STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT`

目的:

- flag / visibility / disabled / pending / selected index を棚卸しし、state移行対象と残すboolを分類する。

対象:

- `addons/hex_map_kit/editor/*.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

Acceptance:

- workflow state / preference flag / config flag / view-only flag が分類される。
- state移行対象は roadmap queue 化される。

### `STATE-10_WORKSPACE_ROOT_STATE_AND_EVENT_DISPATCH`

目的:

- `HexMapWorkspaceState` と `dispatch(event)` の足場を作る。

対象:

- new `hex_map_workspace_state.gd`
- new `hex_map_workspace_state_reducer.gd`
- `hex_map_workspace.gd`
- tests

Acceptance:

- active tab / selected node / asset context / sample policy / operation state を snapshot できる。
- 既存Workspaceの主要操作が `dispatch` 経由でも行える。
- Widget側が直接複数stateを変更する経路を減らす。

### `STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT`

目的:

- `HexMapEditorAssetSlotState` を config / runtime / view state に分ける。

対象:

- `hex_map_editor_asset_slot_state.gd`
- `hex_map_editor_asset_slot_control.gd`
- `hex_map_workspace_asset_panel.gd`

Acceptance:

- `is_required`, `allows_create_new`, `allows_sample`, `required_type` は config へ。
- selected/project/sample/invalid/create_pending は runtime state へ。
- visibility/action labels は view state へ。

### `STATE-30_GENERATION_RUN_STATE_MACHINE`

目的:

- Generate実行・progress・cancel・debounceをFSM化する。

対象:

- new `hex_map_generation_run_state.gd`
- `hex_map_gen_dock.gd`
- `hex_map_gen_state_evaluator.gd`

Acceptance:

- `_generation_running`, `_generation_cancel_requested`, `_last_generation_cancelled`, `_tile_settings_apply_pending` を直接UI判断に使わない。
- state transition table が test される。
- progressbar visibility は `GenerationProgressViewState` から導出される。

### `STATE-40_WORKSPACE_SELECTION_BINDING_STATE`

目的:

- selected HexTileMap / target layer / asset context hydration / writeback をFSM化する。

対象:

- `hex_map_workspace.gd`
- `hex_map_editor_session_state.gd`
- `hex_tile_map_layer.gd`

Acceptance:

- selected node変更時のhydrate/auto-link/writebackが状態遷移として説明できる。
- `auto_link` がON/OFFの単純ボタンではなく policy state として扱われる。
- `No HexTileMap selected` / `Missing unique resources` / `Bound synced` / `Context dirty` が明示状態になる。

### `STATE-50_PAINT_INTERACTION_STATE_MACHINE`

目的:

- Paint tab の target/document/brush/viewport/edit result を状態管理する。

対象:

- new `hex_map_paint_workspace_state.gd`
- `hex_map_edit_tool.gd`
- `hex_map_edit_mutation_builder.gd`
- `hex_map_edit_viewport_input_adapter.gd`

Acceptance:

- Paint tab の summary / action enabled / viewport input可否が `PaintWorkspaceState` から導出される。
- `EditMode` は保持しつつ、brush readiness と missing asset state を追加する。
- `_target_selection_explicit`, `_last_applied_to_target`, `_pending_viewport_trace` の役割を状態へ移す。

### `STATE-60_VALIDATION_EXPORT_SAMPLE_STATE_MACHINES`

目的:

- Validation / Export / Sample を小さなFSMに分離する。

対象:

- `hex_map_workspace.gd`
- `hex_map_validation_dashboard.gd`
- `hex_map_sample_settings_panel.gd`

Acceptance:

- Validation: NOT_RUN/RUNNING/CLEAN/HAS_ERRORS/ISSUE_SELECTED/STALE。
- Export: NO_DOCUMENT/NO_DESTINATION/READY/RUNNING/SUCCEEDED/FAILED。
- Sample: OFF/CTA_VISIBLE/SETTINGS_OPEN/DUPLICATING/DUPLICATED_TO_PROJECT。

### `STATE-70_DIALOG_LIFECYCLE_STATE`

目的:

- FileDialog / modal dialog の open/commit/cancel を一元化する。

対象:

- `hex_map_editor_path_selector.gd`
- `hex_map_workspace.gd`
- `hex_map_editor_asset_slot_control.gd`
- `hex_map_sample_settings_panel.gd`
- `hex_dist_editor.gd`

Acceptance:

- 同じdialog nodeの二重add_childやno-op popupを防ぐ。
- dialog目的が `DialogState` で分かる。
- callback は `DIALOG_COMMITTED` event に正規化される。

### `STATE-80_TEST_CONTRACT_REBUILD_FOR_STATE_MODEL`

目的:

- private widget / bool / visible 直接検査から state snapshot / transition contract 検査へ移す。

Acceptance:

- test は `dispatch(event)` と `snapshot()` を中心に確認する。
- Widget は `ViewState render` の smoke test に留める。
- UX改善を妨げる旧UI shape test は削除する。

---

## 6. 状態遷移管理すべき追加領域

### 6.1 Generation Pipeline Graph / Intermediate Generation

今後検討中の中間生成データ / ノードグラフ的管理は、最初から state machine 前提にするべきである。

候補状態:

```text
PipelineGraphState
  EMPTY
  DIRTY
  NODE_SELECTED
  RUNNING_PASS
  PASS_COMPLETED
  VALIDATION_FAILED
  PROMOTABLE_RESULT
  PROMOTED_TO_DOCUMENT
```

理由:

- partial generation / locked cells / generated vs manual compare は、明確な state と transition がないと破綻しやすい。

### 6.2 Runtime / Authoring delta

将来 runtime delta resource を導入する場合、authoring map と runtime state を分けるため state transition が必要。

候補状態:

```text
RuntimeDeltaState
  BASELINE
  MODIFIED
  DIRTY
  SAVED
  CONFLICT_WITH_AUTHORING_UPDATE
```

### 6.3 Undo/Redo transaction

今の Undo/Redo は document と target display の同期を扱う。状態として明示するとよい。

候補状態:

```text
EditTransactionState
  IDLE
  CAPTURING_BEFORE
  APPLYING_DOCUMENT
  APPLYING_TARGET
  REGISTERED_UNDO_REDO
  FAILED_ROLLBACK_REQUIRED
```

### 6.4 Package / dist final step

dist再生成は通常test化しない方針だが、final process state としては明示できる。

候補状態:

```text
PackageProcessState
  NOT_STARTED
  MANIFEST_GENERATED
  ZIP_GENERATED
  DIST_UPDATED
  RELEASE_READY
```

---

## 7. 実装順序の提案

状態遷移管理は一度に全体を置き換えると危険なので、次の順で進める。

```text
1. STATE-00 UI flag inventory and contract
2. STATE-30 Generation run state machine
3. STATE-20 Asset slot config/runtime split
4. STATE-40 Workspace selection/binding state
5. STATE-50 Paint interaction state machine
6. STATE-60 Validation / Export / Sample state machines
7. STATE-70 Dialog lifecycle state
8. STATE-10 Root workspace dispatch/reducer integration
9. STATE-80 Test contract rebuild
```

理由:

- `GenerationRunState` は独立性が高く、効果が大きい。
- `AssetSlotState` は既に足場があるため分割しやすい。
- `WorkspaceSelectionState` は selection / asset context / node writeback の中核。
- `PaintInteractionState` は大きいので、先に周辺stateを固める。
- Root reducer は最初に巨大化させず、各小FSMができてから統合する。

---

## 8. テスト方針

### 8.1 維持するもの

- Core / Adapter / Runtime tests。
- AssetSlot snapshot contract。
- Generate state evaluator の pure state tests。
- Workspace tab / responsibility map tests。

### 8.2 置き換えるもの

以下は旧UIを固定しやすいため、state移行と同時に置き換える。

- private widget名に依存する button visible / disabled test。
- `_generation_running` など private flag を直接見る test。
- `_details_container.visible` など view内部を直接見る test。
- `_syncing` guard の存在を前提にする test。

置換先:

```text
dispatch(event) -> state snapshot -> view_state snapshot
```

### 8.3 新規テスト例

```text
GenerationRunState:
  IDLE -> GENERATE_REQUESTED -> PREPARING -> GENERATING -> COMPLETED
  GENERATING -> CANCEL_REQUESTED -> CANCELLED
  CONFIG_CHANGED -> QUEUED_DEBOUNCE -> APPLYING_TILE_SETTINGS -> COMPLETED

AssetSlot:
  EMPTY_REQUIRED -> RESOURCE_PICKED(project) -> PROJECT_SELECTED
  EMPTY_REQUIRED -> LEARN_WITH_SAMPLE -> SAMPLE_SELECTED_WARNING
  RESOURCE_PICKED(wrong_type) -> TYPE_INVALID

WorkspaceSelection:
  NO_HEX_TILE_MAP_SELECTED -> SELECTED_NODE_CHANGED -> BOUND_SYNCED
  BOUND_SYNCED -> WORKSPACE_ASSET_CHANGED -> CONTEXT_DIRTY
  CONTEXT_DIRTY -> WRITEBACK_COMPLETED -> BOUND_SYNCED

Paint:
  NO_TARGET -> TARGET_CHANGED -> TARGET_SELECTED_NO_DOCUMENT
  TARGET_SELECTED_NO_DOCUMENT -> DOCUMENT_CHANGED -> DOCUMENT_READY_NO_BRUSH
  DOCUMENT_READY_NO_BRUSH -> BRUSH_ASSET_CHANGED -> BRUSH_READY
  BRUSH_READY -> VIEWPORT_EDIT_STARTED -> EDIT_APPLYING -> EDIT_APPLIED_DIRTY
```

---

## 9. Roadmap作成時の注意

次のroadmapでは、state model を **UI見た目の内部実装** ではなく、UXの安定化装置として扱う。

採用すべき表現:

```text
User action produces event.
State transition decides readiness and next action.
View renders state.
Side effect runs outside reducer.
```

避ける表現:

```text
Buttonをdisabledにする。
Labelを更新する。
visible flagを切り替える。
_refresh_*を呼ぶ。
```

理由:

- button/label/visible は結果であり、設計の主語ではない。
- UXの主語は「ユーザーがどの状態で、何を次にできるか」である。

---

## 10. 最終提案

次回 roadmap の主軸は以下がよい。

```text
UI_STATE_MODEL_REFACTOR
  Phase 0: flag inventory and state boundary
  Phase 1: GenerationRunState
  Phase 2: AssetSlotState split
  Phase 3: WorkspaceSelectionState
  Phase 4: PaintInteractionState
  Phase 5: Validation/Export/Sample/Dialog states
  Phase 6: Root dispatch/reducer integration
  Phase 7: Test contract rebuild
```

最初に切るべき実装taskは `STATE-30_GENERATION_RUN_STATE_MACHINE` である。理由は、現状のフラグ密度が高く、非同期・progress・cancel・debounce・view更新が絡み、state machine 化の効果が最も大きいからである。

次に `STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT` を行うと、Resource row UIの見通しが上がり、Workspace selection state へつなげやすい。

この順序なら、既存UXを無理に止めず、局所的なstate machineを増やしながら、最終的に `HexMapWorkspace` 全体を event-driven UI制御へ移行できる。
