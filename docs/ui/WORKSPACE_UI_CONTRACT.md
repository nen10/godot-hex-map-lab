# Workspace UI Contract

Source roadmap: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ROADMAP.md`
Metric policy: `docs/policy/UI_LAYOUT_METRIC_TEST_PROCESS_AND_ACCEPTANCE_POLICY_2026-06-10.md`
Registry source: `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`

This document is the source of truth for Workspace UI metric contracts. It defines expected tab purpose, required components, forbidden visible text, and baseline metric thresholds before the static audit, runtime snapshot collector, and metric gates are implemented.

It is not a visual style guide and does not judge aesthetic taste.

## Global Rules

Normal Workspace UI must show user-task state, not internal implementation state.

Allowed always-visible information:

- tab purpose and current readiness
- selected user-facing resource or role name
- compact status icon or short state
- one or two real next actions
- primary workflow result

Allowed tooltip/detail information:

- resource path
- Resource type filter and source badge explanation
- validation rule id and fix detail
- blocked reason
- sample source path
- recent export destination path

Debug report only:

- raw JSON or dictionaries
- raw validation/export/generation payloads
- node paths
- internal ids, event ids, private flag names
- raw filepath-heavy diagnostics
- fallback/debug/mirror flags

Forbidden in normal UI:

- raw JSON
- filepath or node path as the primary visible label
- numeric fallback or debug fallback as feature text
- private flag names
- visible `true` / `false` text when a checkbox/toggle already communicates the state
- silent sample source as production completion proof
- visible no-op buttons

## Baseline Metric Thresholds

These are baseline thresholds for later metric tooling. A later task may tune a value only with a review note.

| metric | baseline | severity target | notes |
|---|---:|---|---|
| `has_scroll_container` | `true` for every tab root | P0 when required tab lacks scroll | Workspace tabs must remain reachable in narrow docks. |
| `max_debug_label_count_normal` | `0` | P0 | Normal mode should not show debug labels. |
| `max_forbidden_visible_text_count` | `0` | P0 | Forbidden text classes are listed globally and per tab. |
| `max_no_op_button_count` | `0` | P0 | Visible buttons must change state, open a real picker/dialog, or run a real command. |
| `max_generic_resource_picker_count_required` | `0` | P0 | Required Resource pickers need concrete base types. |
| `min_resource_picker_width` | `180` | P1 | Below this, label truncation and unusable selection risk increase. |
| `min_primary_action_width` | `96` | P1 | Primary command text/icon should remain legible. |
| `max_resource_row_lines_compact` | `2` | P1 | Narrow layout may wrap to two lines, not an unstable multi-line block. |
| `max_dead_area_ratio` | `0.55` | P1 | Large empty area is a warning unless the tab is intentionally empty-state focused. |
| `max_normal_width_label_truncation_count` | `0` | P1 | Normal width labels should not truncate core task text. |
| `disabled_action_tooltip_required` | `true` | P1 | Disabled visible actions need a blocked reason. |

## Component Id Contract

Required component ids should use the registry names below when the component already exists. Later extraction tasks may add ids, but they must update this contract.

| tab | required component ids | required asset slot ids |
|---|---|---|
| Resources | `resources_context_panel`, `document_asset_panel`, `missing_unique_resources_panel` | `level_document`, `tile_catalog`, `object_database`, `label_database`, `layer_stack`, `movement_profile` |
| Generate | `generation_panel` | none |
| Paint | `brush_palette` | none |
| Catalog | `catalog_asset_panel`, `catalog_detail_panel` | `tile_catalog` |
| Layers | `layer_stack_asset_panel`, `layer_stack_role_panel` | `layer_stack` |
| Validate | `validation_asset_panel`, `validation_issue_navigator` | `level_document`, `validation_rule_suite` |
| QA | `qa_asset_panel`, `qa_seed_lab_panel` | `generation_profile`, `validation_rule_suite`, `level_document` |
| Export | `export_asset_panel`, `export_purpose_panel`, `export_destination_panel` | `level_document`, `export_profile` |
| Settings | `settings_preferences_panel`, `sample_settings_panel` | none |

## Tab Contracts

### Resources

Purpose:
- Show the selected `HexTileMapLayer`, authoring `Level Document`, shared dependencies, optional resources, and missing unique node resources.

Required components:
- `resources_context_panel`
- `document_asset_panel`
- `missing_unique_resources_panel`

Primary actions:
- create/select Level Document
- create missing unique node resources
- select shared project resources
- copy Workspace debug report

Forbidden visible text:
- raw node path as primary label
- raw dependency snapshot
- `res://` path outside picker tooltip/detail/debug report
- sample source presented as selected production Resource without warning
- `SharedResource` creation wording for node-owned unique resources

Metric thresholds:
- `has_scroll_container: true`
- `max_debug_label_count_normal: 0`
- `max_no_op_button_count: 0`
- `min_resource_picker_width: 180`
- `max_resource_row_lines_compact: 2`
- `disabled_action_tooltip_required: true`

State source:
- `HexMapWorkspaceBindingService`
- `HexMapWorkspaceRootState`
- `HexMapEditorAssetSlotState.view_state()`

### Generate

Purpose:
- Configure generation inputs, run/cancel generation, inspect preview/result state, and apply/promote output through explicit target actions.

Required components:
- `generation_panel`

Primary actions:
- generate
- cancel
- apply/promote through explicit output target
- save result through existing safe actions

Forbidden visible text:
- raw generation snapshot metadata
- internal run tokens or private `_generation_*` flag names
- sample catalog auto-selected as generation source
- generic "reload" action without visible state purpose

Metric thresholds:
- `has_scroll_container: true`
- `max_debug_label_count_normal: 0`
- `max_no_op_button_count: 0`
- `max_dead_area_ratio: 0.55`
- `disabled_action_tooltip_required: true`

State source:
- `HexMapGenerationRunState`
- Generate output target ViewState
- Workspace root ViewState

### Paint

Purpose:
- Show active brush, target layer, selected/hovered cell, and last edit feedback for viewport editing.

Required components:
- `brush_palette`

Primary actions:
- choose brush/mode
- paint through viewport
- route missing asset actions to owning tab

Forbidden visible text:
- Resource setup rows that belong to Resources/Catalog/Layers/Export
- raw object/label payload dictionaries
- internal tile ids
- viewport trace details outside debug report

Metric thresholds:
- `has_scroll_container: true`
- `max_debug_label_count_normal: 0`
- `max_no_op_button_count: 0`
- `max_dead_area_ratio: 0.55`
- `disabled_action_tooltip_required: true`

State source:
- `HexMapPaintInteractionState`
- Workspace root ViewState
- viewport input adapter feedback

### Catalog

Purpose:
- Manage Tile Catalog selection, entry list/detail, preview availability, and catalog validation summary.

Required components:
- `catalog_asset_panel`
- `catalog_detail_panel`

Primary actions:
- create/select Tile Catalog
- assign TileSet
- create/edit catalog entries
- validate catalog

Forbidden visible text:
- raw TileSet source ids as primary labels
- atlas coordinates as primary workflow controls unless the user is editing an entry detail
- numeric fallback wording
- Paint-owned brush controls

Metric thresholds:
- `has_scroll_container: true`
- `max_debug_label_count_normal: 0`
- `max_no_op_button_count: 0`
- `min_resource_picker_width: 180`
- `max_resource_row_lines_compact: 2`
- `disabled_action_tooltip_required: true`

State source:
- Catalog screen snapshot ViewState
- `HexTileCatalogResource`
- asset slot state for `tile_catalog`

### Layers

Purpose:
- Show Layer Stack readiness, role rows, selected target relationship, and missing layer role actions.

Required components:
- `layer_stack_asset_panel`
- `layer_stack_role_panel`

Primary actions:
- select/create Layer Stack
- create/apply role layers
- clear or repair role assignment when real action exists

Forbidden visible text:
- child node paths as primary labels
- raw writeback relationship maps
- hidden role ids without user-facing role names
- Paint brush controls

Metric thresholds:
- `has_scroll_container: true`
- `max_debug_label_count_normal: 0`
- `max_no_op_button_count: 0`
- `min_resource_picker_width: 180`
- `max_resource_row_lines_compact: 2`
- `disabled_action_tooltip_required: true`

State source:
- Layer screen snapshot ViewState
- Workspace binding state
- asset slot state for `layer_stack`

### Validate

Purpose:
- Run validation, summarize issue severity/count, present issue rows, and route selected issues to the owning screen/resource/cell.

Required components:
- `validation_asset_panel`
- `validation_issue_navigator`

Primary actions:
- run validation
- select issue
- focus owner screen/resource/cell

Forbidden visible text:
- raw validation result object
- full issue metadata dump
- rule ids as the only visible issue text
- slot-level placeholder Validate buttons that do not run real validation

Metric thresholds:
- `has_scroll_container: true`
- `max_debug_label_count_normal: 0`
- `max_no_op_button_count: 0`
- `min_resource_picker_width: 180`
- `disabled_action_tooltip_required: true`

State source:
- `HexMapValidationWorkflowState`
- validation issue navigator ViewState
- asset slot state for `validation_rule_suite`

### QA

Purpose:
- Compare generated seed results, show selected seed state, validation/score context, and promote a chosen result to the Level Document.

Required components:
- `qa_asset_panel`
- `qa_seed_lab_panel`

Primary actions:
- run seed lab
- select seed row
- promote selected seed to Level Document

Forbidden visible text:
- raw batch rows as primary UI
- generation snapshot dictionaries
- promotion path as primary label
- sample-only preview as completion proof

Metric thresholds:
- `has_scroll_container: true`
- `max_debug_label_count_normal: 0`
- `max_no_op_button_count: 0`
- `min_resource_picker_width: 180`
- `max_dead_area_ratio: 0.55`
- `disabled_action_tooltip_required: true`

State source:
- QA screen snapshot ViewState
- `HexMapGenerationRunState`
- asset slot state for `generation_profile`, `validation_rule_suite`, and `level_document`

### Export

Purpose:
- Show runtime handoff purpose, Level Document readiness, Export Profile readiness, destination state, and last export result.

Required components:
- `export_asset_panel`
- `export_purpose_panel`
- `export_destination_panel`

Primary actions:
- choose destination
- use recent destination when valid
- export runtime handoff

Forbidden visible text:
- raw export action result as normal UI
- full destination path as primary label
- unsupported export buttons
- package build upload wording unless a later product decision adds it

Metric thresholds:
- `has_scroll_container: true`
- `max_debug_label_count_normal: 0`
- `max_no_op_button_count: 0`
- `min_resource_picker_width: 180`
- `disabled_action_tooltip_required: true`

State source:
- `HexMapExportWorkflowState`
- Export screen snapshot ViewState
- asset slot state for `level_document` and `export_profile`

### Settings

Purpose:
- Show sample learning state, explicit debug/sample/preferences controls, and duplicate sample actions without injecting samples into production flow.

Required components:
- `settings_preferences_panel`
- `sample_settings_panel`

Primary actions:
- toggle explicit preferences
- duplicate bundled samples to project
- dismiss or route learning CTA

Forbidden visible text:
- debug payload as status label
- redundant boolean `true` / `false` text beside a checkbox/toggle
- sample path as primary visible label
- sample mode implying production asset readiness

Metric thresholds:
- `has_scroll_container: true`
- `max_debug_label_count_normal: 0`
- `max_no_op_button_count: 0`
- `max_normal_width_label_truncation_count: 0`
- `disabled_action_tooltip_required: true`

State source:
- `HexMapSampleLearningState`
- Settings preferences ViewState
- sample settings panel state

## Resource Row Contract

Resource rows select, create, validate, or explicitly learn from project Resources. They must not make filepath/debug state the first impression.

Required visible pieces:

- role label
- concrete Resource picker or selector
- compact status icon or short state
- real action button only when it changes state, opens a real picker/dialog, or runs a real command

Preferred layout:

```text
wide dock:
  [Role label] [Resource picker expands] [Status icon/short state] [Actions]

narrow dock:
  line 1: [Role label] [Status icon/short state]
  line 2: [Resource picker expands] [Actions]
```

Required status kinds:

- `ok`
- `missing`
- `optional`
- `invalid`
- `warning`
- `sample`

Resource row metrics:

| metric | baseline |
|---|---:|
| `min_resource_picker_width` | `180` |
| `max_resource_row_lines_compact` | `2` |
| `max_visible_status_text_width` | `24` when icon mode is available |
| `disabled_action_tooltip_required` | `true` |
| `generic_resource_picker_allowed` | `false` for required slots |

## Button / Action Contract

Allowed visible actions:

- create a project Resource
- open a real picker/dialog
- apply an explicitly visible bundled sample learning source
- clear a selected Resource when the row owns that action
- run a real workflow command such as validation, generation, export, or promotion
- focus a concrete owner screen/resource/cell

Disallowed visible actions:

- placeholder Details/Open/Select/Validate/Link/Node/Sample buttons
- buttons that only write temporary labels
- disabled actions without tooltip/block reason
- reload-like actions whose state effect is not visible
- package/upload actions unless a product decision adds them to Export

Metric:

- `max_no_op_button_count: 0`

## Debug / Report Contract

Normal UI should describe user tasks and state. Debug report surfaces preserve internal detail for diagnosis.

Normal UI may show:

- readiness summary
- selected role/resource name
- validation severity/count
- generation/export result summary
- short blocked reason

Tooltip/detail may show:

- filepath
- source badge explanation
- Resource type filter reason
- longer blocked reason
- validation rule id/fix detail

Debug report may show:

- root/screen ViewStates
- raw validation/export/generation payloads
- node paths
- resource paths
- private/internal ids
- raw fallback/debug/mirror flags

Metrics:

- `max_debug_label_count_normal: 0`
- `max_forbidden_visible_text_count: 0`

## Sample Contract

Bundled samples are learning/onboarding assets. They are never silent production fallbacks.

Allowed:

- first-run learning CTA
- Settings sample rows
- explicit duplicate-to-project action
- warning state when a direct bundled sample is selected
- sample paths in tooltip/detail/debug report

Forbidden:

- sample catalog auto-selected in Generate/Paint/Catalog production flow
- sample source satisfying required production asset selection
- sample-only preview counted as feature completion
- sample path as primary visible label

Metrics:

- `sample_mode_off_main_flow_sample_source_count: 0`
- `sample_source_warning_required: true`
- `duplicate_to_project_action_required_when_sample_learning_visible: true`

## Update Rule

When a future task changes required components, forbidden visible text, or threshold values, it must update this document and explain the change in that task's self-review.
