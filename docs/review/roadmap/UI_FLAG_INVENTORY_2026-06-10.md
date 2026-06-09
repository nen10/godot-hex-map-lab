# UI Flag Inventory 2026-06-10

Roadmap: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/ROADMAP.md`
Queue task: `STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT`

## Scope

This review inventories the editor UI flags and derived state fragments that should be replaced by explicit state machines or ViewState models in the later STATE tasks. The goal is not to refactor code in this task; the goal is to make later refactors coherent and to decide which old UI tests should be kept, rewritten, or deleted.

Source review:

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_gen_state_evaluator.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd`
- `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd`
- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `addons/hex_map_kit/editor/hex_map_editor_path_selector.gd`
- `addons/hex_map_kit/editor/hex_dist_editor.gd`
- `tests/test_editor_plugin.gd`

## Priority Contract

| priority | meaning | later task use |
|---|---|---|
| `P0` | Blocks several later tasks or currently combines enough flags that visible UI can contradict itself. Build a state object before further screen work. | `STATE-10`, `STATE-20`, `STATE-30`, `STATE-60` |
| `P1` | Has visible workflow ambiguity but can be made clean after a P0 foundation exists. | `STATE-40`, `STATE-50` |
| `P2` | Already has a service/helper boundary or lower immediate UX risk; clean after primary workflow states are stable. | `STATE-50`, `STATE-60`, later cleanup |

Later state machines should expose:

- a single named state or state record for the workflow,
- events that mutate the state,
- a ViewState dictionary that screens render directly,
- a debug snapshot generated from state, not recomputed from private widget fields,
- tests that assert transitions and ViewState, not private node shape.

## Area Inventory

| area | current flag / state fragments | current derived UI | issue | priority | target task |
|---|---|---|---|---|---|
| Generate operation | `_generation_running`, `_generation_cancel_requested`, `_generation_progress`, `_generation_status`, `_generation_progress_step`, `_generation_id`, `_last_generation_cancelled`, `_generation_thread`, `_generation_progress_*_token`, `_tile_settings_apply_pending`, `_tile_settings_apply_debounce_token`, `_tile_settings_last_apply_result`, `_last_generation_validation_*`, `_last_generation_apply_order`, `_last_batch_generation_results`, `_last_output_apply_result`, `_current_data`, `_current_overlay_data`, `_output_target_mode` | `_refresh_controls()`, `_refresh_generation_block_state()`, progress controls, cancel button, output target status, batch score rows | Run/progress/cancel/apply/dirty/block state is spread across booleans, strings, counters, timers, and result dictionaries. `HexMapGenStateEvaluator` is useful but only covers partial control visibility/blocking. | `P0` | `STATE-10` |
| Workspace selection / binding | `HexMapEditorSessionState.target_layer`, `selected_hex_tile_map_layer`, `auto_link_selected_hex_tile_map`, `document`, `document_saved_path`, `workspace_asset_context`, `_last_document_dependency_hydration`, `_hydrating_document_dependencies`, `_selected_hex_tile_map_*` UI labels, missing unique resource directory/prefix fields | `selected_hex_tile_map_snapshot()`, `selected_hex_tile_map_writeback_snapshot()`, `resources_screen_snapshot()`, implicit sync from session changes | No target, selected node, auto-link off, node-owned resources, document dependencies, manual override, pending writeback, and conflict are assembled procedurally. This is the largest cross-screen state boundary. | `P0` | `STATE-30` |
| Asset slot lifecycle | `HexMapEditorAssetSlotState.slot_id`, `required_type`, `current_resource`, `current_path`, `current_source`, `is_required`, `validation_status`, `validation_messages`, `allows_create_new`, `allows_sample`, sample resource/path/label; panel `_syncing`; control action visibility | Row status text, ResourcePicker base type, Create New/sample action visibility, compact detail text, source badges | The state object exists and is valuable, but config, current selection, validation result, sample affordance, and operation result still live in one mutable object. | `P0` | `STATE-20` |
| Paint interaction | `_document`, `_document_dirty`, `_document_source`, `_target_layer`, `_target_layer_nodes`, `_target_selection_explicit`, `_edit_mode`, tile/object/label payload dictionaries, selected object/label ids, `_last_edit_hit`, `_last_edit_status`, `_target_status_detail`, `_selected_validation_issue`, `_validation_focus_status`, `_pending_viewport_trace`, `_last_highlight_hex`, `_last_applied_to_target` | `paint_workspace_snapshot()`, `paint_brush_snapshot()`, payload control visibility, target readiness, Last Edit labels, missing asset CTA | Paint state combines target resolution, document editability, brush readiness, selected cell, last edit, validation focus, and raw/debug control visibility. Needs a state machine after selection binding is explicit. | `P1` | `STATE-40` |
| Validation workflow | `_last_workspace_validation_result`, `_selected_validate_issue_index`, `_selected_validate_issue_row`, `_selected_validate_issue_navigation`, edit-tool validation dashboard state | Validate empty state, issue navigator rows, selected issue navigation, target summary, route/suggested action | Validation rows are now useful workflow state, but run/result/selection/navigation are separate fields and screen refresh recomputes from result dictionaries. | `P1` | `STATE-50` |
| Export workflow | `HexMapEditorSessionState.export_saved_path`, `recent_export_destinations`, `context.level_document`, `context.export_profile`, destination dialog callbacks, `_export_*` labels/buttons | `export_screen_snapshot()`, destination context, output modes, can-export button state, recent destination state | Export has a good snapshot surface, but destination selection, recent destination, run eligibility, output mode, and result/handoff status are not one state record. | `P1` | `STATE-50` |
| Sample learning flow | Session flags `show_bundled_samples_in_main_selectors`, `use_bundled_sample_assets_for_scratch_documents`, `auto_create_project_copy_when_applying_sample`, `sample_learning_cta_dismissed`, panel `_last_sample_action_result` | CTA visibility, Settings sample rows, duplicate-to-project dialog/action state, Generate/Paint sample-control hiding | Sample mode is less dangerous after recent cleanup, but it remains cross-cutting and must stay separate from production asset selection state. | `P1` | `STATE-50` |
| Dialog lifecycle | `HexMapEditorPathSelector.dialog_lifecycle_snapshot()`, `attach_dialog()`, `popup_dialog()`, per-flow callback state in asset rows/export/sample/dist dialogs, `HexDistEditor._recent_distribution_paths` | FileDialog config snapshots, callback-testable open/commit/cancel paths | Lifecycle helper fixed double-add/reparent behavior. Remaining risk is scattered per-dialog config/callback state, not the helper itself. | `P2` | `STATE-50` |

## P0 State Boundaries

### Generate Run State

Required states:

```text
IDLE
PARAMS_DIRTY
PREVIEW_QUEUED
GENERATING
CANCELLING
VALIDATING
APPLYING_TO_DOCUMENT
APPLYING_TILE_SETTINGS
GENERATED_PREVIEW
APPLIED_DIRTY_DOCUMENT
FAILED
BLOCKED
```

Contract:

- `_generation_running`, `_generation_cancel_requested`, `_generation_progress`, `_generation_status`, `_generation_progress_step`, hide timers, and debounce flags must become fields derived from one run state.
- `HexMapGenStateEvaluator` should be kept or expanded as the pure ViewState boundary.
- Generate tests that inspect progress/cancel should move from private fields to `generation_status()` / `generation_progress_snapshot()` / ViewState.

### Asset Slot State

Required split:

```text
SlotDefinition: slot id, display label, required type, purpose, required/optional
SlotSelection: resource, path, source, source badge
SlotValidation: selected/missing/optional/invalid/warning messages
SlotOperation: create/save/open/clear/sample result and disabled reason
```

Contract:

- `HexMapEditorAssetSlotState` remains the seed, but later work should split config from runtime/result state.
- Row rendering should consume ViewState labels/icons/tooltips instead of recomputing `OK/Missing/Optional` in controls.
- Tests should keep state snapshots and stop relying on private row controls.

### Workspace Selection / Binding State

Required states:

```text
NO_TARGET
SELECTED_NODE_NO_DOCUMENT
SELECTED_NODE_RESOURCES_LINKED
DOCUMENT_DEPENDENCIES_HYDRATED
MANUAL_OVERRIDE
PENDING_NODE_WRITEBACK
PENDING_DEPENDENCY_WRITEBACK
CONFLICT
AUTO_LINK_DISABLED
```

Contract:

- Selected HexTileMap, target layer, node-owned resources, document dependencies, manual override, and writeback relationships should be one binding state record.
- `HexMapWorkspaceBindingService.relationship_for_slot()` is the service boundary to keep.
- Workspace tests should assert state snapshots and writeback policies, not manual Link button or path text.

## P1 State Boundaries

### Paint Interaction State

Required state record:

```text
target: none / selected / invalid / ready
document: none / loaded / dirty / blocked
brush: mode, key, ready, missing_asset_cta
viewport: hover cell, selected cell, editable, blocked reason
last_edit: command, target apply result, undo hint
validation_focus: none / issue selected / cell focus
```

Contract:

- Paint should render from `paint_workspace_snapshot()` and `paint_brush_snapshot()` successors.
- Raw payload fields and hidden numeric/source controls are not state-machine API.
- Tests that currently inspect hidden raw controls should be rewritten to brush readiness and missing CTA state.

### Validation / Export / Sample / Dialog States

Required state records:

```text
Validation: not_run / running / complete / issue_selected
Export: no_document / no_destination / ready / running / complete / failed
Sample: hidden / learning_cta / settings_visible / duplicate_pending / duplicated
Dialog: closed / opening / open / committed / cancelled / invalid_environment
```

Contract:

- Validate issue rows and navigation are valid ViewState, but result/selection/navigation should be grouped.
- Export should group destination, recent destinations, output mode, can-run reason, and last result.
- Sample state must never be a fallback input to production Generate/Paint execution.
- Dialog config and lifecycle helper tests should stay; per-dialog tests should assert config and commit/cancel outcomes.

## Existing UI Test Disposition

| test surface | disposition | reason |
|---|---|---|
| `HexMapGenStateEvaluator` tests | keep and expand | Pure evaluator is already a good ViewState boundary. |
| Generate progress/cancel tests | rewrite later | Keep behavior coverage, but migrate private `_generation_*` assertions to run-state/ViewState snapshots during `STATE-10`. |
| Workspace selected HexTileMap / dependency hydration / writeback tests | keep, then rewrite around binding state | Current tests cover real user outcomes; later `STATE-30` should keep outcomes but assert explicit binding states. |
| Asset slot state snapshot tests | keep, then split | They already test state contracts; `STATE-20` should split config/runtime/result expectations. |
| Asset row private button/label tests | rewrite/delete | Keep only visible command availability and disabled reason through row ViewState. Delete tests preserving placeholder buttons. |
| Paint brush and missing asset CTA tests | keep, then rewrite around Paint state | Current assertions are user-goal oriented; later tests should avoid raw control visibility as primary proof. |
| Hidden raw path/numeric fallback/raw JSON tests | delete or quarantine as debug-only | These are not normal CLEAN UI acceptance. |
| Validate issue navigator tests | keep, then group result/selection/navigation | Rows are workflow state; later `STATE-50` should assert state transitions. |
| Export destination/run tests | keep, then rewrite around Export state | Current project destination and no-sample checks are valid; button disabled checks should become ViewState checks. |
| Sample settings and sample package tests | keep | They protect no silent sample fallback. Later sample state can replace direct widget assertions. |
| FileDialog lifecycle tests | keep | They protect the shared lifecycle helper and should remain callback/config based. |
| Component registry/private node shape tests | rewrite | Keep tab responsibility and slot ownership, but do not freeze private container names beyond registry contract. |

## Task Priority Mapping

| later task | priority | required output |
|---|---|---|
| `STATE-10_GENERATION_RUN_STATE_MACHINE` | `P0` | Generate run state, progress/cancel/debounce/apply ViewState, rewritten generation tests. |
| `STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT` | `P0` | SlotDefinition / SlotSelection / SlotValidation / SlotOperation split, row ViewState, row tests updated. |
| `STATE-30_WORKSPACE_SELECTION_BINDING_STATE` | `P0` | Binding state model for target/document/dependency/writeback/conflict and auto-link behavior. |
| `STATE-40_PAINT_INTERACTION_STATE_MACHINE` | `P1` | Paint target/document/brush/viewport/last-edit state model. |
| `STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES` | `P1` | Validation, Export, Sample, and Dialog state models and ViewState outputs. |
| `STATE-60_ROOT_DISPATCHER_AND_VIEWSTATE_INTEGRATION` | `P0 integration` | Root dispatch and ViewState delivery after P0/P1 state models exist. |

## Acceptance Checklist

- Generate, Workspace selection/binding, Asset slot lifecycle, Paint interaction, Validation workflow, Export workflow, Sample learning flow, and Dialog lifecycle are inventoried.
- State-machine priority is classified as P0 / P1 / P2.
- Existing UI test disposition is recorded as keep / rewrite / delete.
- No analog test or direct behavior refactor is introduced by this review task.
