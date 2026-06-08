# Workspace Visible UI Inventory 2026-06-08

作成日: 2026-06-08
Task: `UIR-01`
Roadmap: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`

## Summary

Current source/readback confirms the first-impression report: the workspace has the intended tab count, but most tabs still read as Resource reference panels. `Document` has not yet been renamed to `Resources`, root tab pages are plain `VBoxContainer`s, and the reusable asset slot control shows verbose labels plus `Select...`, `Create New...`, `Open`, `Clear`, and `Validate` buttons on every slot.

The main distinction:

- `Generate` and the embedded `HexMapEditTool` create their own internal `ScrollContainer`.
- The workspace tab pages themselves are not scroll roots.
- Asset panels in Document, Catalog, Layers, Validate, QA, Export, and Settings are mounted directly into plain tab pages.
- Several visible buttons emit signals that are not connected by `HexMapWorkspaceAssetPanel` or `HexMapWorkspace`.

This inventory is current-state evidence, not a UX approval.

## Source / Readback Evidence

| Evidence | Current fact |
|---|---|
| `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd:7` | Current tab names are `Document`, `Generate`, `Paint`, `Catalog`, `Layers`, `Validate`, `QA`, `Export`, `Settings`. |
| `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd:32` | Registry exposes component ids and asset slot ids per tab. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd:1172` | Workspace builds a `TabContainer` and plain `VBoxContainer` tab pages. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd:1213` | `_add_tab_page()` creates each page as `VBoxContainer`, not `ScrollContainer`. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd:1223` | Resource asset panels are mounted in Document, Catalog, Layers, Paint, Validate, QA, Export, and Settings. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd:1763` | Generate tab embeds `HexMapGenDock`. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd:1776` | Paint tab embeds `HexMapEditTool` plus object/label asset panel. |
| `addons/hex_map_kit/editor/hex_map_gen_dock.gd:333` | Generate dock owns an internal `ScrollContainer`. |
| `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1064` | Edit tool owns an internal `ScrollContainer`. |
| `addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd:127` | Asset panel adds a title label and then one asset slot control per row. |
| `addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd:151` | Asset panel wires create path, clear, and slot-state changes only. |
| `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd:126` | Slot control shows title, current, type, status, messages, resource picker, and action buttons. |
| `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd:157` | Visible slot actions include `Select...`, `Create New...`, `Open`, `Clear`, `Validate`, and optional sample. |
| `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd:109` | Settings/Samples shows checkboxes and sample rows with path text. |
| `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd:138` | Sample rows show `Open` and `Duplicate To Project`, but workspace does not connect the emitted sample signals. |

## Registry Snapshot

| Tab | Mounted components | Asset slot ids |
|---|---|---|
| Document | `document_asset_panel` | `level_document`, `tile_catalog`, `object_database`, `label_database`, `layer_stack` |
| Generate | `generation_panel` | none |
| Paint | `brush_palette`, `object_label_asset_panel` | `object_database`, `label_database` |
| Catalog | `catalog_asset_panel` | `tile_catalog` |
| Layers | `layer_stack_asset_panel` | `layer_stack` |
| Validate | `validation_asset_panel`, `validation_issue_navigator` | `level_document`, `validation_rule_suite` |
| QA | `qa_asset_panel` | `generation_profile`, `validation_rule_suite`, `level_document` |
| Export | `export_asset_panel`, `export_destination_panel` | `level_document`, `export_profile` |
| Settings | `settings_project_defaults_panel`, `sample_settings_panel` | `movement_profile` |

## Tab Inventory

| tab_name | visible_sections | scroll_container_present | resource_rows | primary_actions | buttons_without_effect | resource_picker_filters | main_feature_controls | empty_state_text | tooltip_presence | suspected_hidden_functionality | next_task |
|---|---|---|---:|---|---|---|---|---|---|---|---|
| Document | `Document Assets` | No root tab scroll | 5 | Resource slot create/clear through slot controls | `Select...`, `Open`, `Validate` are emitted by slot controls but not connected by the asset panel | Exact for document/catalog/object/label/layer stack | None beyond Resource rows | Slot text shows `Current: Not selected` and status | No purpose tooltip surfaced | This tab is actually the future Resources context, but selected HexTileMap and ownership grouping are absent | `TAB-50`, after `NODE-20`/`NODE-23`; `LAYOUT-10` for scroll |
| Generate | `Hex Map Kit` generation dock | Internal Generate scroll yes; root page no | 0 | Shape/seed/generate/apply/QA controls inside `HexMapGenDock` | Not inventoried as no-op here; Generate is already a distinct work surface | Uses its own controls and workspace context | Strongest functional tab today | Generate control states exist, but output-resource relationship is still unclear | Existing tooltips not reviewed; not a row-level purpose model | Output target, preview/apply distinction, and performance freeze causes remain unclear | `NODE-24`, `PERF-60`, `PERF-61` |
| Paint | `Hex Map Edit`, `Object / Label Assets` | Internal Edit scroll yes; object/label asset panel root no | 2 | Brush/edit controls inside `HexMapEditTool`; object/label resources in separate asset panel | Asset panel `Select...`, `Open`, `Validate` not connected | Exact for object and label database | Brush surface exists, but first impression is mixed with Resource rows | Missing object/label resources show slot missing state | No concise purpose tooltip for asset rows | Paint has real brush APIs, but active cell/layer/catalog key summary is not prominent as tab-level context | `TAB-51`, `LAYOUT-10`, `ASSET-31` |
| Catalog | `Catalog Assets` | No root tab scroll | 1 | Resource slot create/clear only | `Select...`, `Open`, `Validate` not connected | Exact `HexTileCatalogResource` | No entry list/detail/preview visible in this tab | Slot missing state only | No purpose tooltip surfaced | Catalog editing APIs exist through workspace methods, but tab display is just a resource selector | `TAB-52`, `ASSET-31` |
| Layers | `Layer Assets` | No root tab scroll | 1 | Resource slot create/clear only | `Select...`, `Open`, `Validate` not connected | Exact `HexLayerStackResource` | No role rows, target HexTileMap summary, create/apply/visibility controls visible at tab level | Slot missing state only | No purpose tooltip surfaced | Layer stack helper APIs and edit-tool rows exist, but visible tab is resource-only | `TAB-53`, `NODE-20`, `LAYOUT-10` |
| Validate | `Validation Assets`, `Validation Issues` | No root tab scroll | 2 | Resource slot create/clear; issue navigator placeholder | `Select...`, `Open`, `Validate` on asset rows not connected; navigator has no visible run/focus action in initial state | `level_document` exact; validation suite is generic `Resource` | Issue navigator is mounted but starts as placeholder | `No validation run selected.` plus slot missing state | No purpose tooltip surfaced | Workspace validation issue routing exists in snapshot methods, but visible tab does not yet operate like an issue navigator | `TAB-54`, `ASSET-30`, `ASSET-31` |
| QA | `QA Assets` | No root tab scroll | 3 | Resource slot create/clear only | `Select...`, `Open`, `Validate` not connected | Generation/validation profiles are generic `Resource`; document exact | No visible seed comparison/adoption surface in QA tab | Slot missing state only | No purpose tooltip surfaced | Seed Lab / score table APIs remain in Generate, not visibly owned by QA | `TAB-55`, `ASSET-30`, `INFO-71` |
| Export | `Export Assets`, `Export Destination` | No root tab scroll | 2 | Choose destination, use recent, export; resource slot create/clear | Asset row `Select...`, `Open`, `Validate` not connected | Export profile is generic `Resource`; document exact | Destination UI exists, but export purpose/type classification is unclear | `Destination: Not selected`, recent count, disabled export | No purpose tooltip surfaced | Runtime/package/debug export meanings are not separated; sample destination unavailable is hidden state | `TAB-56`, `INFO-72`, `ASSET-30` |
| Settings | `Project Defaults`, sample settings | No root tab scroll | 1 | Checkboxes for sample/debug settings; sample row buttons | Movement profile asset row `Select...`, `Open`, `Validate` not connected; sample `Open`/`Duplicate To Project` emit signals but workspace does not connect them | Movement profile exact | Settings mixes project defaults with sample/debug controls | Checkbox state, sample paths; no production asset CTA | No purpose tooltip surfaced | Duplicate sample helper exists, but visible button path is not connected to workspace update | `SAMPLE-40`, `TAB-57`, `ASSET-31` |

## Classification

### Display Bugs / Wiring Gaps

- Asset slot `Select...`, `Open`, and `Validate` buttons are visible on every asset slot but the workspace asset panel does not connect those emitted signals. This is a visible button-to-state gap for `ASSET-31` / `ASSET-32`.
- Settings sample `Open` and `Duplicate To Project` buttons emit panel signals, but `HexMapWorkspace` does not connect them. This is the core visible gap for `SAMPLE-40`.
- Root workspace tabs are not `ScrollContainer`s. Generate/Edit have internal scroll, but the workspace-owned asset panels and placeholder panels do not. This is `LAYOUT-10`.

### Missing Design / Missing Visible Context

- `Document` is still the tab name, while the roadmap now wants `Resources`.
- No selected `HexTileMap` summary is visible in the current workspace tab structure.
- No UniqueResource / SharedResource grouping is visible.
- Catalog, Layers, QA, and Validate have backend/snapshot behavior but the visible first screen is still dominated by asset rows.
- Export has destination controls but does not explain what kind of export is being performed.

### Existing Functional Screens

- Generate is a real functional screen today.
- Paint contains the embedded edit tool and real brush/edit behavior, but it competes with object/label resource rows and lacks the compact current-edit summary requested by the roadmap.
- Export destination selection has a real visible control path, but needs purpose redesign.

### Test Contract Notes

- Existing headless tests already assert the current tab/component registry. They are useful readback evidence.
- Those tests should not block the roadmap rename from `Document` to `Resources` or the move from resource-list tabs to work-specific screens.
- No new analog test was created for this inventory.

## Next Task Inputs

| Queue task | Inventory handoff |
|---|---|
| `LAYOUT-10` | Add tab-level scroll or equivalent to all workspace pages, not only embedded Generate/Edit tools. |
| `NODE-20` | Define ownership before the future Resources tab groups Unique/Shared/Optional resources. |
| `ASSET-30` | Replace generic profile slots where feasible, or document why generic `Resource` remains. |
| `ASSET-31` | Remove or wire `Select...`, `Open`, `Validate`, and redundant row buttons. |
| `SAMPLE-40` | Connect or remove Settings sample `Open` / `Duplicate To Project`. |
| `TAB-50` | Rename `Document` to `Resources` and show selected HexTileMap plus resource grouping. |
| `TAB-51` | Make Paint's first screen a brush workspace rather than an object/label asset selector. |
| `TAB-52` | Add Catalog entry/detail/preview UI. |
| `TAB-53` | Add Layers role editor UI. |
| `TAB-54` | Turn Validate into an issue navigator. |
| `TAB-55` | Move Seed Lab responsibility into QA. |
| `TAB-56` | Clarify export purpose and output kind. |
| `TAB-57` | Reduce Settings to sample/debug/preferences after Resources owns production assets. |

## Acceptance Check

- Document / Paint / Catalog / Layers / Validate / QA / Export / Settings first impression is reproduced.
- Display bugs and missing design are separated.
- Source/readback notes are included.
- The inventory does not claim sample-only or API-only success as UI completion.
