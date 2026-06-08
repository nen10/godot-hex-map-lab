# UI Workspace / Resource Flow Redesign Implementation Queue 2026-06-08

作成日: 2026-06-08  
Roadmap: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`  
Queue design policy: `docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md`  
Operation process: `docs/process/QUEUE_OPERATION_RULES.md`  
Autopilot process: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`

この queue は、UI Asset Selection 実行後の first impression 課題を、Workspace / Resource flow の実装単位へ分割したものである。目的は、ゲーム開発者が dock を狭く配置しても、選択中 `HexTileMap` ノード、自分の project asset、生成・ペイント・検証・Export の関係を画面上で理解できる状態にすることである。

---

## 0. Queue operation notes

- status 更新、dependency sweep、proof 記録は `docs/process/QUEUE_OPERATION_RULES.md` に従う。
- `READY` task は plan files を作成して実装まで進める。Plan 作成は承認ゲートではない。
- UI first impression を完了根拠に含める。headless API availability だけで UI task を `COMPLETE` にしない。
- Sample bundle は learning / duplicate source であり、production execution fallback にしない。
- 新規 analog test は作らない。manual / first impression checklist / UI smoke checklist は作ってよい。
- Dist freshness は通常テスト化しない。final process step として再生成する。

---

## 1. Phase U0: Roadmap adoption / policy reset

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `UIR-00` | `COMPLETE` | none | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/UIR-00_ADOPT_FIRST_IMPRESSION_FEEDBACK/` | First impression feedback adoption | `AGENTS.md`, `docs/policy/IMPLEMENTATION_POLICY.md`, `docs/policy/TEST_DESIGN_POLICY.md`, `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md` | Sample is learning / duplicate source, not execution fallback; committed dist freshness is final process step, not normal test; UI first impression outranks headless API availability. |
| `UIR-01` | `COMPLETE` | `UIR-00` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/UIR-01_CURRENT_VISIBLE_UI_INVENTORY/` | Current visible UI inventory | `docs/review/roadmap/WORKSPACE_VISIBLE_UI_INVENTORY_2026-06-08.md`, current editor UI source/readback notes | Inventory reproduces Document/Paint/Catalog/Layers/Validate/QA/Export/Settings first impression and separates display bugs from missing design. |

---

## 2. Phase U1: Layout / Scroll / Dock resilience

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `LAYOUT-10` | `COMPLETE` | `UIR-01` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/LAYOUT-10_SCROLL_CONTAINER_FOR_ALL_TABS/` | Scrollable content for all workspace tabs | `HexMapWorkspace`, per-tab content containers, `HexMapWorkspaceAssetPanel`, `HexMapSampleSettingsPanel`, editor tests | Each tab root has ScrollContainer or equivalent; primary actions remain reachable in narrow/short docks; tab switching does not break scroll/focus. |
| `LAYOUT-11` | `COMPLETE` | `LAYOUT-10` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/LAYOUT-11_COMPACT_RESOURCE_ROW_LAYOUT/` | Compact resource row layout | asset slot controls, workspace asset panel, sample settings panel, editor tests | Resource rows use `[Title] [ResourcePicker] [status icon]`; long purpose/type/path/validation details move to tooltip or expander; missing state remains short and visible. |

---

## 3. Phase U2: HexTileMap node binding / Resource lifecycle

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `NODE-20` | `COMPLETE` | `UIR-00` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE-20_HEX_TILE_MAP_RESOURCE_OWNERSHIP_POLICY/` | HexTileMap resource ownership policy | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE_RESOURCE_OWNERSHIP_POLICY.md`, relevant resource/editor source notes | UniqueResource / SharedResource / OptionalResource are classified; noisy always-on resources are documented; Resources tab display classification can follow the policy. |
| `NODE-21` | `COMPLETE` | `NODE-20` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE-21_SELECTED_HEX_TILE_MAP_AUTO_BINDING/` | Selected HexTileMap auto-binding | `HexMapWorkspace`, `HexMapEditorSessionState`, selected node integration, editor tests | Scene Tree selection changes update Workspace context; no selected node shows `No HexTileMap selected`; auto-link is default ON; manual Link button is removed or becomes status indicator. |
| `NODE-22` | `COMPLETE` | `NODE-21` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE-22_CREATE_MISSING_UNIQUE_RESOURCES_FLOW/` | Create missing unique resources flow | Resources tab, resource factory helpers, FileDialog/Save As helpers, editor tests | User chooses save directory and prefix; missing UniqueResources are created with default names and auto-referenced by selected HexTileMap; SharedResource is not silently created. |
| `NODE-23` | `READY` | `NODE-21` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE-23_DOCK_SELECTION_WRITES_BACK_TO_NODE/` | Dock resource selection writes back to selected node | Workspace asset context, asset slot handlers, HexTileMap exported references, editor tests | Selecting/creating Document/Catalog/Layer Stack/Object DB/Label DB writes to node or context according to policy; node/workspace diff is visible; auto-link failures explain why. |
| `NODE-24` | `READY` | `NODE-22` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE-24_GENERATE_RESULT_RESOURCE_RELATIONSHIP/` | Generate result resource relationship | Generate tab, QA tab, document metadata/generation snapshot helpers, editor/generation tests | Generate has explicit output target; Preview only and Apply to selected Document are distinct; apply updates Resources tab relationship; no selected node blocks apply with clear reason. |

---

## 4. Phase U3: Asset Slot UI simplification / button semantics

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `ASSET-30` | `READY` | `NODE-20` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ASSET-30_STRICT_RESOURCE_TYPE_FILTERS/` | Strict ResourcePicker type filters | asset slot state/control, workspace asset panel, resource picker filters, editor tests | Typed slots no longer request generic `Resource`; tooltip says what to pick; type mismatch is prevented at picker stage where feasible; generic slots document why flexibility is needed. |
| `ASSET-31` | `BACKLOG` | `LAYOUT-11`, `ASSET-30` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ASSET-31_REMOVE_REDUNDANT_RESOURCE_ACTION_BUTTONS/` | Remove redundant resource action buttons | asset slot controls, resource rows, workspace/sample panels, editor tests | Clear/Select/Open/Validate/Link/Node buttons are removed, delegated to ResourcePicker, or kept only when the use case is necessary and implemented; no no-op buttons remain. |
| `ASSET-32` | `BACKLOG` | `ASSET-31` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ASSET-32_WIRE_REMAINING_ACTIONS_OR_DELETE/` | Wire remaining actions or delete them | asset slot controls, workspace asset panel, sample settings panel, action handlers, editor tests | Every remaining action has observable result from button press to workspace state change; undefined actions are deleted; tests cover signal/button path, not direct API only. |

---

## 5. Phase U4: Sample learning flow repair

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `SAMPLE-40` | `BACKLOG` | `ASSET-32` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/SAMPLE-40_SETTINGS_SAMPLE_BUTTONS_FUNCTIONAL/` | Functional Settings / Samples buttons | `HexMapSampleSettingsPanel`, `HexMapWorkspace`, sample duplicator, editor tests | Open focuses/previews sample resource or is removed; Duplicate To Project chooses path, creates project copy, sets asset slot as `SOURCE_PROJECT`, and shows what changed. |
| `SAMPLE-41` | `BACKLOG` | `SAMPLE-40` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/SAMPLE-41_REMOVE_SAMPLE_FROM_MAIN_EXECUTION_FALLBACK/` | Remove sample from main execution fallback | sample settings/session state, Generate/Paint resource lookup, validation/tests | Sample mode ON does not auto-use bundled catalog for Generate/Paint execution; sample remains candidate/preview/duplicate source; direct sample selection is classified as sample with warning. |

---

## 6. Phase U5: Tab-specific functional screens

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `TAB-50` | `BACKLOG` | `NODE-23`, `LAYOUT-10` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/TAB-50_RESOURCES_TAB_RENAME_AND_CONTEXT_SCREEN/` | Resources tab rename and context screen | Workspace tab labels, Resources tab/component, node/resource context UI, editor tests | Document tab becomes Resources; selected HexTileMap is visible; Unique/Shared/Optional resources are grouped; Create Missing Resources is available; tooltips explain purpose. |
| `TAB-51` | `BACKLOG` | `TAB-50` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/TAB-51_PAINT_TAB_REAL_BRUSH_WORKSPACE/` | Paint tab as real brush workspace | Paint tab/component, brush palette, viewport edit integration, editor tests | Viewport edit switches to Paint tab; active document/layer/brush/cell/last edit are visible; tab is not just resource references; missing Object/Label resources show concise CTA. |
| `TAB-52` | `BACKLOG` | `TAB-50` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/TAB-52_CATALOG_TAB_DETAIL_EDITOR/` | Catalog tab detail editor | Catalog tab/component, entry list/detail, tile/scene preview, catalog tests | Catalog entry meaning is visible; source id / atlas coords are not primary inputs; preview absence explains why; missing assets produce warnings. |
| `TAB-53` | `BACKLOG` | `TAB-50` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/TAB-53_LAYERS_TAB_ROLE_EDITOR/` | Layers tab role editor | Layers tab/component, layer stack UI, HexTileMap child layer integration, tests | Layer Stack resource, target HexTileMap, roles, create/apply/visibility/locked/writable status are visible in Layers tab, not only resource references. |
| `TAB-54` | `BACKLOG` | `TAB-50` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/TAB-54_VALIDATE_TAB_ISSUE_NAVIGATOR/` | Validate tab issue navigator | Validate tab/component, validation issue navigator, focus/link actions, editor tests | Validate target and purpose are clear; resource-row Validate buttons become unnecessary; clicking issues can move to cell/resource/target tab with suggested action. |
| `TAB-55` | `BACKLOG` | `NODE-24` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/TAB-55_QA_TAB_SEED_LAB_SCREEN/` | QA tab Seed Lab screen | QA tab/component, generation profile, validation suite, score table, promotion target, tests | QA tab supports seed comparison and adoption; Generate and QA roles are distinct; promotion updates Resources tab Document relationship. |
| `TAB-56` | `BACKLOG` | `TAB-50` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/TAB-56_EXPORT_TAB_PURPOSE_REDESIGN/` | Export tab purpose redesign | Export tab/component, export profile/destination UI, runtime handoff/debug report/package support docs/tests | Export tab states what is exported and why; output target/type are clear; unusable buttons are absent; experimental exports are hidden or backlog. |
| `TAB-57` | `BACKLOG` | `SAMPLE-41` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/TAB-57_SETTINGS_TAB_SIMPLIFICATION/` | Settings tab simplification | Settings tab/component, sample controls, debug fallback controls, preferences UI, tests | Settings contains sample learning controls and debug/preferences only; production asset selection lives in Resources; sample actions work or are removed. |

---

## 7. Phase U6: Generate performance / progress

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `PERF-60` | `READY` | `UIR-01` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/PERF-60_GENERATE_GLOBAL_UPDATE_PROFILE/` | Generate/global update performance profile | `docs/review/roadmap/GENERATE_UPDATE_PERFORMANCE_PROFILE_2026-06-08.md`, Generate/apply/validation profiling notes | Heavy operations are classified as redraw/generation/apply/validation; UI freeze causes are identified; improvement candidates are prioritized. |
| `PERF-61` | `BACKLOG` | `PERF-60` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/PERF-61_PROGRESS_AND_BUSY_UI/` | Progress and busy UI | Generate/apply/validation UI, busy overlay/progress helpers, tests | Long operations show start/progress/completion through ProgressBar/busy overlay/current step text; UX is not distorted for progress reporting. |
| `PERF-62` | `BACKLOG` | `PERF-60` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/PERF-62_INCREMENTAL_UPDATE_AND_DEBOUNCE/` | Incremental update and debounce | Generate/apply/redraw update paths, debounce/cache helpers, performance tests | Continuous changes avoid repeated heavy full updates; visible wait time drops; behavior stays consistent with progress UI. |

---

## 8. Phase U7: Tooltip / terminology / unknown item cleanup

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `INFO-70` | `READY` | `LAYOUT-11` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/INFO-70_RESOURCE_PURPOSE_TOOLTIPS/` | Resource purpose tooltips | resource rows, asset slot controls, docs/tests | Level Document, TileSet, Catalog, Layer Stack, Object DB, Label DB, Movement Profile, Generation Profile, Validation Suite, Export Profile have concise purpose/type tooltips. |
| `INFO-71` | `BACKLOG` | `TAB-50` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/INFO-71_TAB_PURPOSE_EMPTY_STATES/` | Tab purpose and empty states | workspace tabs/components, empty-state copy, tests | Empty states do not use sample to fill gaps; next action is one or two clear choices; detailed help moves to tooltip/help link. |
| `INFO-72` | `BACKLOG` | `TAB-56` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/INFO-72_EXPORT_TERMINOLOGY_DECISION/` | Export terminology decision | `docs/review/roadmap/EXPORT_TERMINOLOGY_DECISION_2026-06-08.md`, Export tab/manual docs | Save Document, Runtime Handoff, Data Export, Package Build, Debug Report are classified; Export tab contents and manual terms are unified. |

---

## 9. Phase U8: Generation pipeline graph research

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `GEN-80` | `BACKLOG` | `NODE-24` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/GEN-80_GENERATION_INTERMEDIATE_DATA_USE_CASE_REVIEW/` | Generation intermediate data use-case review | `docs/review/roadmap/GENERATION_PIPELINE_GRAPH_REVIEW_2026-06-08.md`, generation/resource notes | Intermediate data use cases are separated into immediate UI, backlog, and research; Generate tab is not expanded into graph editor prematurely. |
| `GEN-81` | `BACKLOG` | `GEN-80` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/GEN-81_GENERATION_PROFILE_AND_RESULT_MODEL/` | Generation Profile / Result / Document model | generation profile/result docs, resource/API notes, tests if schema changes | Generate preview, intermediate, and committed document states are defined and aligned with QA, Seed Lab, and Document metadata; graph editor remains out of scope. |

---

## 10. Phase U9: Manual / process / final packaging

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `DOC-90` | `BACKLOG` | `TAB-57`, `INFO-72` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/DOC-90_WORKSPACE_UI_MANUAL_UPDATE/` | Workspace UI manual update | `docs/manual/MANUAL_EDITOR_PLUGIN.md`, `docs/manual/MANUAL_WORKFLOW.md`, `docs/TEST.md`, `README.md` | Manual explains Resources tab, sample learning flow, HexTileMap selection auto resource sync, Generate output target / Apply to Document; no analog test is added. |
| `PROCESS-91` | `BACKLOG` | `DOC-90` | `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/PROCESS-91_FINAL_DIST_REGENERATION_STEP/` | Final dist regeneration process step | `tools/package_addon.sh`, `dist/`, process/review log | `tools/package_addon.sh` regenerates `dist`; manifest reflects current addon tree; work log records dist update; this is not added to `tools/test.sh` mandatory tests. |

---

## 11. Dynamic follow-up area

Codex appends `follow-up-ready` work here when self-review finds nonblocking work.

Template:

```md
### <TASK-ID> <title>

status: READY | BACKLOG  
dependencies: ...  
source_review: docs/review/autopilot/<...>.md  
plan_dir: docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/<TASK-ID>_<slug>/

deliverable:
- ...

acceptance / test path:
- ...
```

---

## 12. Current pointer

Current recommended next task: `NODE-23`.

Reason:

- Phase U1 has no remaining READY task.
- `NODE-20` is complete.
- `NODE-21` is complete.
- `NODE-22` is complete.
- `NODE-23` is the first READY task in queue order.
- `NODE-24`, `ASSET-30`, `PERF-60`, and `INFO-70` are also READY, but they appear later in the queue.

---

## 13. Completed task proof log

### UIR-00 First impression feedback adoption

proof:
  plan: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/UIR-00_ADOPT_FIRST_IMPRESSION_FEEDBACK/`
  review: `docs/review/autopilot/UIR-00_SELF_REVIEW_2026-06-08.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `AGENTS.md`
    - `docs/policy/IMPLEMENTATION_POLICY.md`
    - `docs/policy/TEST_DESIGN_POLICY.md`
    - `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`
  major files:
    - `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
    - `docs/review/autopilot/UIR-00_TEST_RESULT_2026-06-08.md`

### UIR-01 Current visible UI inventory

proof:
  plan: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/UIR-01_CURRENT_VISIBLE_UI_INVENTORY/`
  review: `docs/review/autopilot/UIR-01_SELF_REVIEW_2026-06-08.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/review/roadmap/WORKSPACE_VISIBLE_UI_INVENTORY_2026-06-08.md`
  major files:
    - `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
    - `docs/review/autopilot/UIR-01_TEST_RESULT_2026-06-08.md`

### LAYOUT-10 Scroll container for all tabs

proof:
  plan: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/LAYOUT-10_SCROLL_CONTAINER_FOR_ALL_TABS/`
  review: `docs/review/autopilot/LAYOUT-10_SELF_REVIEW_2026-06-08.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
    - `docs/review/autopilot/LAYOUT-10_TEST_RESULT_2026-06-08.md`

### LAYOUT-11 Compact resource row layout

proof:
  plan: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/LAYOUT-11_COMPACT_RESOURCE_ROW_LAYOUT/`
  review: `docs/review/autopilot/LAYOUT-11_SELF_REVIEW_2026-06-08.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
    - `docs/review/autopilot/LAYOUT-11_TEST_RESULT_2026-06-08.md`

### NODE-20 HexTileMap resource ownership policy

proof:
  plan: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE-20_HEX_TILE_MAP_RESOURCE_OWNERSHIP_POLICY/`
  review: `docs/review/autopilot/NODE-20_SELF_REVIEW_2026-06-08.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE_RESOURCE_OWNERSHIP_POLICY.md`
  major files:
    - `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
    - `docs/review/autopilot/NODE-20_TEST_RESULT_2026-06-08.md`

### NODE-21 Selected HexTileMap auto-binding

proof:
  plan: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE-21_SELECTED_HEX_TILE_MAP_AUTO_BINDING/`
  review: `docs/review/autopilot/NODE-21_SELF_REVIEW_2026-06-08.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/plugin.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/NODE-21_TEST_RESULT_2026-06-08.md`

### NODE-22 Create missing unique resources flow

proof:
  plan: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE-22_CREATE_MISSING_UNIQUE_RESOURCES_FLOW/`
  review: `docs/review/autopilot/NODE-22_SELF_REVIEW_2026-06-08.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/NODE-22_TEST_RESULT_2026-06-08.md`
