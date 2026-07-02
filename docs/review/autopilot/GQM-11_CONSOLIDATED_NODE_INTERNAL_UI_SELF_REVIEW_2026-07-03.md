# GQM-11_CONSOLIDATED_NODE_INTERNAL_UI Self Review

Task: `GQM-11_CONSOLIDATED_NODE_INTERNAL_UI`
Queue: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: user contract + GQM-11 queue row; no separate task packet was created because this contract scoped writable docs to queue/proof/self-review.
Optional execution log: none

## Execution Summary

Replaced the consolidated inspector parameter path with `HexGenerationParamSchema.schema_for()`. The four consolidated node types now render param rows from schema entries, apply schema labels/options/ranges/defaults, and redraw dependent rows in place when method fields change. The old consolidated `_param_*` match helpers were removed; remaining branch logic is isolated to legacy-only helpers.

Added a small editor helper for criteria asset chips and canonical reference keys. The inspector and graph titlebar now expose an editable `display_name` plus criteria source chips for wall distribution, adjacency rules, and item pool assets. Chips display inline state or referenced asset display names, open the existing criteria editor windows, and use `HexMapAssetLibrary` for Load, Save as, Duplicate, and Inline operations where this task owns the UI.

The GQM-10 handoff item is also addressed: selection input passthrough adaptation no longer appears as raw `none`; the visible label is `そのまま (selection)`.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/editor/hex_generation_criteria_ui.gd` | Added shared criteria chip/key helpers for display labels, inline/reference state, and schema asset-kind lookup. |
| `addons/hex_map_kit/editor/hex_generation_criteria_ui.gd.uid` | Godot import uid for the new helper script. |
| `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd` | Replaced consolidated param UI with schema-driven rendering, added display name/titlebar controls, criteria chips, criteria asset operations, and in-place morph refresh. |
| `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd` | Added consolidated titlebar display-name editing, criteria chips, chip-open signal, chip snapshot data, and clearer selection passthrough adaptation labels. |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | Routed canvas titlebar chip clicks to the inspector criteria editor windows. |
| `tests/test_editor_generation.gd` | Added schema row parity, morph, criteria chip source, referenced item pool display, and chip editor-open coverage. |
| `tests/test_build_graph_canvas.gd` | Added selection passthrough display and titlebar criteria chip editor-open coverage. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md` | Marked only the GQM-11 row `COMPLETE`. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/PROOF_LOG.md` | Added the GQM-11 proof entry. |
| `docs/review/autopilot/GQM-11_CONSOLIDATED_NODE_INTERNAL_UI_SELF_REVIEW_2026-07-03.md` | Added this self-review. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Criteria asset reference keys | `distribution_asset_path`, `rules_asset_path`, and `item_pool_asset_path` are stored and displayed in editor params, but no generation/runtime resolution was added. | The contract assigns runtime path resolution to GQM-16 and forbids `generation/` and `adapter/` changes. | GQM-16 owns runtime resolution and any schema declaration expansion it requires. |
| Non-headless visual capture | Not produced in this task. | The user contract states merge-after visual verification is orchestrator-owned; this task is responsible through headless tests. | Orchestrator visual pass after merge. |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Consolidated inspector rows come from schema | pass | `_test_consolidated_inspector_schema_rows_and_morph()` compares terrain and item `param_fields` to `HexGenerationParamSchema.schema_for()` key order. |
| Deleted old consolidated `_param_*` match helpers | pass | Inspector no longer defines `_param_keys_for_type`, `_param_visibility_for_type`, `_param_control_type`, `_param_options`, `_param_min/max/step`, or `_param_default`; legacy paths use `_legacy_*` helpers only. |
| Method changes morph dependent rows in place | pass | `_test_consolidated_inspector_schema_rows_and_morph()` changes `wall_method`, `distribution_mode`, and `placement_method` without reselection and checks visible rows/labels update. |
| Titlebar has display-name edit and criteria chips | pass | Canvas creates `HexTitlebarDisplayName_*` and `HexTitlebarCriteriaChip_*`; `_test_consolidated_titlebar_criteria_chip_opens_editor()` verifies the titlebar chip label and click path. |
| Criteria chips show inline/reference source names | pass | `_test_consolidated_inspector_criteria_chip_sources()` checks `pool: inline` and a project asset display name as `pool: Treasure Pool [ref]`. |
| Criteria chip opens existing editor window | pass | Inspector chip opens the item pool editor; canvas chip opens the Markov Distribution Window through BuildScreen routing. |
| Asset operations use `HexMapAssetLibrary` | pass | Inspector criteria operation rows use library list/load/save/duplicate APIs for wall distribution, adjacency rules, and item pool UI operations. |
| Selection passthrough display is clear | pass | `_test_selection_adaptation_display_is_passthrough()` verifies `そのまま (selection)` in row snapshot and dropdown text. |
| `./tools/test.sh` green | pass | Final standard run exited 0 with run id `20260703-073658-80829`. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | pass | Consolidated nodes show an editable node name plus criteria chips in the titlebar; the inspector mirrors the same source chips above schema-driven param rows. |
| What user can do | pass | Users can change methods and see dependent rows morph immediately, open criteria editors from chips, and move criteria between inline/project assets through Load, Save as, Duplicate, and Inline controls. |
| (graph task) chain runs | pass | Existing consolidated graph/screen tests still run through standard verification; this task does not change generation execution or runtime reference resolution. |
| Label-heavy but metrics pass | pass | New labels are compact chips and row labels; workspace metrics report P0 `0`, P1 `0`. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | generated by standard suite | `.godot_user/ui-metrics/20260703-073658-80829/workspace_layout_metrics.md` |
| P0 failures | 0 | Metric report total_p0_failures = 0. |
| P1 issues | 0 | Metric report total_p1_issues = 0. |
| UI metric applicability | regression proof | GQM-11 changes editor inspector/canvas controls; non-headless visual verification is orchestrator-owned per contract. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| Runtime resolution for `distribution_asset_path`, `rules_asset_path`, and `item_pool_asset_path` | queued outside this task | GQM-16 per user contract; GQM-11 stores, displays, and edits the params only. |
| Merge-after editor capture | orchestrator-owned proof | User contract says visual verification is after merge; headless tests are this executor's gate. |

## Repair-now Review

No repair-now item remains. The final diff stays within editor UI, tests, queue row, proof log, and this self-review; `generation/` and `adapter/` were not changed.

## Test Review

- Focused Godot run: `res://tests/test_build_graph_canvas.gd` passed.
- Focused Godot run: `res://tests/test_editor_generation.gd` passed.
- Focused Godot run: `res://tests/test_build_screen_full.gd` passed.
- Command: `./tools/test.sh`
- Result: exit 0
- Notes: Final run id `20260703-073658-80829`; macOS CA certificate warnings and editor warning-path test warnings were non-fatal.
