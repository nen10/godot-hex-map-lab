# Feedback Integrated Resource / State / Workspace Refactor Implementation Queue 2026-06-10

作成日: 2026-06-10
Roadmap: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/ROADMAP.md`
Queue design policy: `docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md`
Operation process: `docs/process/QUEUE_OPERATION_RULES.md`
Autopilot process: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
Commit process: `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`

この queue は、4つの feedback を採用した Resource ownership / UI state transition / first impression / task screen refactor を、Codex autopilot が実装・検証・self-review・queue update できる task slice に分割したものである。

---

## 0. Queue operation notes

- status 更新、dependency sweep、proof 記録は `docs/process/QUEUE_OPERATION_RULES.md` に従う。
- `READY` task は plan files を作成して実装まで進める。Plan 作成は承認ゲートではない。
- Resource / API cleanup は UI redesign より前に置く。ただし visible no-op control と FileDialog lifecycle の明確な UX bug は早期に修正してよい。
- UI task の completion proof は first impression と作業目的に接続する。headless API availability だけで `COMPLETE` にしない。
- Sample bundle は learning / onboarding / duplicate source であり、production completion proof にしない。
- 旧 UI shape test が roadmap の UX / API を妨げる場合は更新または削除する。
- 新規 analog test は作らない。
- `dist` freshness は通常テスト化しない。最終 task `PROC-90` でのみ `tools/package_addon.sh` による再生成と manifest 差分確認を行う。

---

## 1. Phase M0: Feedback adoption / safety repair

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `FB-00` | `COMPLETE` | none | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-00_ADOPT_ALL_FEEDBACKS/` | Feedback adoption proof and execution source-of-truth reset | `ROADMAP.md`, feedback docs, queue/proof docs | 4 feedback sources are adopted in the roadmap; priority order, analog-test deferral, and final-only dist rule are recorded; `./tools/test.sh` passed. |
| `FB-01` | `COMPLETE` | `FB-00` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-01_FIX_FILE_DIALOG_POPUP_PATHS/` | Unified FileDialog lifecycle for workspace/editor dialogs | `addons/hex_map_kit/editor/hex_map_workspace.gd`, `hex_map_editor_path_selector.gd`, `hex_map_editor_asset_slot_control.gd`, `hex_map_sample_settings_panel.gd`, `hex_dist_editor.gd`, editor tests | Dialog popup paths use one lifecycle utility; double `add_child()` / reparent paths are removed; open/commit/cancel remains callback-testable; `./tools/test.sh` passed. |
| `FB-02` | `COMPLETE` | `FB-00` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-02_VISIBLE_NO_OP_CONTROL_REPAIR/` | Visible no-op and placeholder control removal | workspace tabs, asset slot controls, sample settings, editor tests | No visible Select/Open/Validate/Details/Link/Node/Sample action remains without a real state change; disabled controls explain conditions via tooltip; `./tools/test.sh` plus targeted editor UI tests. |

---

## 2. Phase M1: Resource ownership / dependency hydration

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `RES-10` | `COMPLETE` | `FB-00` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/RES-10_DOCUMENT_DEPENDENCY_SERVICE/` | Document dependency service for shared project resources | `addons/hex_map_kit/adapter/hex_map_document_dependency_resource.gd`, new `hex_map_document_dependency_service.gd`, adapter tests | Tile Catalog, Object DB, Label DB, Movement Profile, Validation Suite, Generation Profile, and Export Profile can be add/find/update/remove/hydrated from `HexMapDocumentResource.dependencies`; tests cover dependency CRUD and validation. |
| `RES-11` | `COMPLETE` | `RES-10` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/RES-11_DOCUMENT_DEPENDENCY_HYDRATION/` | Workspace context hydration from selected document dependencies | `HexMapWorkspaceAssetContext`, `HexMapWorkspace`, dependency service, editor tests | Document selection hydrates shared resources into workspace context with `Document Dependency` source badge; manual override can temporarily supersede it; missing dependencies stay missing instead of silently using samples. |
| `NODE-20` | `COMPLETE` | `RES-11` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/NODE-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE/` | Selected HexTileMap read/write binding service | new `addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd`, `HexTileMapLayer`, `HexMapWorkspace`, editor tests | Scene selection resolves `HexTileMapLayer`; node-owned Level Document / Layer Stack are read and written on node exports; shared resources are read/written through document dependencies. |
| `NODE-21` | `COMPLETE` | `NODE-20` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/NODE-21_HEX_MAP_RESOURCE_ROLE_CLARIFICATION/` | Clear role decision for `HexTileMapLayer.hex_map` | `HexMapWorkspace`, `HexMapEditTool`, workspace UI/docs/tests | `hex_map` is no longer implied as authoring source of truth; UI/docs/tests treat Level Document as canonical authoring; no ambiguous compatibility-only display remains; `./tools/test.sh` passed. |
| `NODE-22` | `COMPLETE` | `NODE-20` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/NODE-22_MISSING_NODE_RESOURCE_BULK_CREATE_REVIEW/` | Missing Resource create flow aligned with node/document/dependency ownership | `HexMapWorkspace`, binding/dependency services, editor tests | Node-owned and shared resources are not mixed in one opaque bulk create path; shared resources require create or select existing; node export, document dependency, and workspace context match after creation; `./tools/test.sh` passed. |

---

## 3. Phase M2: Concrete Resource profile classes

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `PROFILE-30` | `COMPLETE` | `RES-10` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/PROFILE-30_CONCRETE_PROFILE_RESOURCES/` | Concrete profile Resource classes and picker filters | adapter resource files, asset slot definitions, resource picker filters, tests/docs | Validation Rule Suite, Generation Profile, and Export Profile use concrete Resource classes; picker filters are typed; docs/manual explain each profile purpose; no sample-only placeholder is completion proof; `./tools/test.sh` passed. |
| `PROFILE-31` | `COMPLETE` | `PROFILE-30`, `RES-11` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/PROFILE-31_PROFILE_DEPENDENCY_INTEGRATION/` | Profile resources integrated with dependencies and workspace tabs | dependency service, `HexMapWorkspaceAssetContext`, QA/Validate/Export tabs, editor tests | Concrete profiles hydrate from document dependencies; QA/Validate/Export tabs show concrete resources instead of generic `Resource`; missing profiles have optional/missing state; `./tools/test.sh` passed. |

---

## 4. Phase M3: UI state transition foundation

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `STATE-00` | `COMPLETE` | `FB-00` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT/` | UI flag inventory and state machine priority contract | `docs/review/roadmap/UI_FLAG_INVENTORY_2026-06-10.md`, workspace/gen/edit source notes | Generate, asset slots, workspace binding, paint, validation, export, sample, and dialog flags are inventoried; P0/P1/P2 state-machine priorities and old-test disposition are recorded; `./tools/test.sh` passed. |
| `STATE-10` | `COMPLETE` | `STATE-00` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-10_GENERATION_RUN_STATE_MACHINE/` | Generation run state machine | `hex_map_gen_dock.gd`, generation state helpers, workspace Generate tab, tests | Progress/cancel/debounce/apply/dirty/error state is derived from one generation run state; Generate tab renders from ViewState; heavy orientation/global updates enter the state model. |
| `STATE-20` | `COMPLETE` | `STATE-00` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT/` | Asset slot config/runtime/result state split | `hex_map_editor_asset_slot_state.gd`, `hex_map_editor_asset_slot_control.gd`, workspace asset panel, tests | Slot definition, current selection, validation result, sample availability, and operation result are separate structures; OK/Missing/Optional labels become ViewState/icon+tooltip. |
| `STATE-30` | `COMPLETE` | `NODE-20`, `STATE-20` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-30_WORKSPACE_SELECTION_BINDING_STATE/` | Workspace selection and writeback state machine | binding service, `HexMapEditorSessionState`, `HexMapWorkspace`, editor tests | No target, selected node without document, hydrated dependencies, manual override, pending writeback, applied writeback, and conflict are explicit states; auto-link works without a manual link button. |
| `STATE-40` | `COMPLETE` | `STATE-30` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-40_PAINT_INTERACTION_STATE_MACHINE/` | Paint interaction state machine | `hex_map_edit_tool.gd`, viewport input adapter, workspace Paint tab, editor tests | Paint state covers target/document/brush/viewport hover/apply/dirty/validation focus/missing asset; selected cell, active brush, and layer target render from state. |
| `STATE-50` | `COMPLETE` | `STATE-30` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES/` | Validation, Export, Sample, and Dialog state models | workspace tabs, validation dashboard, sample settings, dist/export UI, dialog lifecycle helpers, tests | Validation, export, sample learning, and dialog lifecycle have explicit state transitions and ViewState output; tests cover transitions, not private widget shapes. |
| `STATE-60` | `COMPLETE` | `STATE-10`, `STATE-20`, `STATE-30`, `STATE-40`, `STATE-50` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-60_ROOT_DISPATCHER_AND_VIEWSTATE_INTEGRATION/` | Root dispatcher and ViewState integration | workspace root state/dispatcher helpers, tab renderers, debug report code, tests | Screens receive ViewState instead of recombining flags; root events dispatch through reducer/dispatcher boundaries; debug reports can be generated from state snapshots; `./tools/test.sh` passed. |

---

## 5. Phase M4: Minimal first impression repair

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `UI-00` | `COMPLETE` | `STATE-00` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/` | Workspace UI visible contracts | `WORKSPACE_SCREEN_CONTRACT.md`, `WORKSPACE_STATE_MACHINE.md`, `VISIBLE_CONTROL_INVENTORY.md`, `RESOURCE_ROW_SPEC.md`, `DEBUG_LABEL_POLICY.md` | Each tab separates always-visible information from tooltip/debug detail; debug/filepath/internal state are not normal UI; Generate tab caution is documented before changes; `./tools/test.sh` passed. |
| `UI-01` | `COMPLETE` | `STATE-20`, `UI-00` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-01_RESOURCE_ROW_REDESIGN/` | Compact/adaptive Resource row redesign | asset slot control/state, workspace asset panel, row tests | Resource rows work as compact one-line or narrow adaptive two-line controls; status text moves to icon+tooltip; filepath/node path/debug state are hidden by default; Details button is removed unless replaced by a real detail surface; `./tools/test.sh` passed. |
| `UI-02` | `READY` | `UI-00` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-02_SETTINGS_LABEL_SIMPLIFICATION/` | Settings label and debug text simplification | `HexMapWorkspace`, `HexMapSampleSettingsPanel`, settings/debug UI, editor tests | Boolean state is represented by checkbox/toggle controls, not always-on true/false text; debug payload moves to copy/debug report flow. |
| `UI-03` | `READY` | `STATE-10`, `UI-00` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-03_GENERATE_EMPTY_AREA_AND_STATUS_REPAIR/` | Generate empty-area and result-status repair | `hex_map_gen_dock.gd`, workspace Generate tab, generation state/tests | Generate screen no longer contains unexplained dead space; preview/apply/document/save result state is visible; any reload action has a clear state purpose. |

---

## 6. Phase M5: Resource-centric Workspace and task screens

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `SCREEN-10` | `READY` | `RES-11`, `STATE-30`, `UI-01` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/SCREEN-10_RESOURCES_TAB_AS_CONTEXT_CENTER/` | Resources tab as selected node/document/dependency center | Resources tab/workspace screen, asset context, binding/dependency services, editor tests | Resources tab shows selected HexTileMap summary, required resource status, missing-resource actions, source badges, and clear next actions beyond resource rows. |
| `SCREEN-20` | `BACKLOG` | `SCREEN-10`, `UI-01` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/SCREEN-20_CATALOG_CONTROLS_OUT_OF_PAINT/` | Catalog editing controls moved out of Paint | Catalog tab/screen, Paint tab, catalog resource UI/tests | Catalog tab owns entry list, tile/scene preview, tags/status, create/edit entry, and catalog validation; Paint consumes catalog key and does not expose raw source_id/atlas coords as primary UI. |
| `SCREEN-21` | `BACKLOG` | `SCREEN-10` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/SCREEN-21_LAYER_DOCUMENT_EXPORT_CONTROLS_OUT_OF_PAINT/` | Layer, Document, and Export controls moved to responsible tabs | Paint tab, Layers tab, Resources tab, Export tab, editor tests | Layer roles live in Layers; document save/dependency/dirty state lives in Resources; export destination/type lives in Export; Paint has no non-paint responsibility controls. |
| `SCREEN-22` | `BACKLOG` | `STATE-40`, `SCREEN-20`, `SCREEN-21` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/SCREEN-22_PAINT_TAB_BRUSH_SURFACE/` | Paint tab as real brush editing surface | Paint screen, edit tool, viewport input adapter, editor tests | Paint tab has empty state, active brush, target layer, selected cell, and last edit; viewport editing updates Paint state; tab does not regress to resource references only. |
| `SCREEN-23` | `BACKLOG` | `STATE-50`, `SCREEN-10` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/SCREEN-23_VALIDATE_ISSUE_NAVIGATOR_REFINEMENT/` | Validate tab issue navigator refinement | validation dashboard, workspace Validate tab, document validator, tests | Validate works as workflow-level issue navigator with list/severity/scope/focus action; slot-level Validate buttons are unnecessary. |
| `SCREEN-24` | `READY` | `PROFILE-30`, `STATE-10` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/SCREEN-24_QA_SEED_LAB_AND_PROFILE_SCREEN/` | QA Seed Lab and Generation Profile screen | QA tab, generation profile resource, generation results/state, tests | QA uses Generation Profile; score table, selected seed, and promote target are visible; Document source of truth and draft context boundary are clear. |
| `SCREEN-25` | `READY` | `PROFILE-30`, `STATE-50` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/SCREEN-25_EXPORT_PURPOSE_SCREEN/` | Export tab purpose screen | Export tab, export profile resource, dist/export helpers, tests/docs | Export type, output destination, runtime handoff/debug/package purpose, and result state are clear. |

---

## 7. Phase M6: Component extraction by UX role

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `ARCH-40` | `READY` | `NODE-20`, `STATE-30` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/ARCH-40_WORKSPACE_CONTEXT_HYDRATOR_WRITER_EXTRACTION/` | Workspace context hydrator/writer extraction | `HexMapWorkspace`, binding/dependency services, asset context, tests | `hex_map_workspace.gd` no longer directly assembles node/document/dependency context; hydration/writeback service is testable; UI only renders resulting state. |
| `ARCH-41` | `BACKLOG` | `SCREEN-20`, `SCREEN-21`, `SCREEN-22` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/ARCH-41_SCREEN_COMPONENT_EXTRACTION_BY_UX_ROLE/` | Workspace/EditTool/GenDock component extraction by UX role | new per-screen scripts, `HexMapWorkspace`, `hex_map_edit_tool.gd`, `hex_map_gen_dock.gd`, tests | Extraction is justified by user task ownership, not line count; each screen script maps to a tab/workflow; Paint no longer carries Catalog/Layer/Export/Document responsibility. |
| `ARCH-50` | `READY` | `NODE-20`, `NODE-21` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/ARCH-50_HEX_TILE_MAP_LAYER_RESPONSIBILITY_SPLIT/` | HexTileMapLayer responsibility split | `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`, new adapter helpers, runtime/editor tests | `HexTileMapLayer` moves toward coordinator role; resource binding, document apply, layer stack apply, object display, gameplay query, and debug overlay responsibilities are separated without losing runtime helper value. |

---

## 8. Phase M7: Generate performance / pipeline concept

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `PERF-60` | `READY` | `STATE-10` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/PERF-60_GENERATE_PERFORMANCE_BUDGET_AND_CHUNKED_APPLY_REVIEW/` | Generate performance budget and chunked apply review | `docs/review/roadmap/GENERATE_PERFORMANCE_BUDGET_2026-06-10.md`, generation/apply paths, profiling notes | Map-size budgets classify redraw/generation/apply/validation costs; global update costs such as orientation switch are identified; progress/busy/cancel/chunked-apply policy is recorded. |
| `GENPIPE-80` | `BACKLOG` | `PERF-60` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/GENPIPE-80_GENERATION_PIPELINE_STATE_CONCEPT/` | Generation pipeline state concept backlog | `docs/review/roadmap/GENERATION_PIPELINE_STATE_CONCEPT_2026-06-10.md`, generation/resource notes | Final Level Document and intermediate map data are distinguished; primary/overlay/filter/candidate map handling is compared across Resource pass, linear pipeline, and node graph options. |

---

## 9. Phase M8: Tests / manual / process

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `TEST-80` | `BACKLOG` | `STATE-60`, `ARCH-41` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/TEST-80_EDITOR_TEST_FILE_SPLIT_AND_STATE_CONTRACTS/` | Editor test split around state/screen contracts | `tests/test_editor_plugin.gd`, new workspace/state/screen tests, `docs/TEST.md` | Old UI shape tests are removed or replaced; tests cover state transitions, hydration/writeback, and screen contracts; no analog test is added; `./tools/test.sh` passes if Godot is available. |
| `DOC-90` | `BACKLOG` | `SCREEN-10`, `SCREEN-22`, `SCREEN-25` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/DOC-90_WORKSPACE_WORKFLOW_MANUAL_UPDATE/` | Manual update for current Workspace workflow | `docs/manual/MANUAL_EDITOR_PLUGIN.md`, `docs/manual/MANUAL_WORKFLOW.md`, `docs/TEST.md`, `README.md` if needed | Manual explains selected HexTileMap -> Resources -> Generate -> Paint -> Catalog -> Validate -> QA -> Export flow, source badges, and sample learning as a separate chapter; no analog test is added. |
| `PROC-90` | `BACKLOG` | `DOC-90`, `TEST-80` | `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/PROC-90_FINAL_DIST_REGENERATION/` | Final dist regeneration and manifest proof | `tools/package_addon.sh`, `dist/`, self-review/test-result docs | `tools/package_addon.sh` runs; committed manifest/zip match the current addon tree; diff result is recorded in self-review; dist freshness remains outside normal `tools/test.sh` gate. |

---

## 10. Dynamic follow-up area

Codex appends `follow-up-ready` work here when self-review finds nonblocking work.

Template:

```md
### <TASK-ID> <title>

status: READY | BACKLOG
dependencies: ...
source_review: docs/review/autopilot/<...>.md
plan_dir: docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/<TASK-ID>_<slug>/

deliverable:
- ...

acceptance / test path:
- ...
```

---

## 11. Current pointer

Current recommended next task: `UI-02`.

Reason:

- `FB-00` is complete.
- `FB-01` is complete.
- `FB-02` is complete.
- `RES-10` is complete.
- `RES-11` is complete.
- `NODE-20` is complete.
- `NODE-21` is complete.
- `NODE-22` is complete.
- `PROFILE-30` is complete.
- `PROFILE-31` is complete.
- `STATE-00` is complete.
- `STATE-10` is complete.
- `STATE-20` is complete.
- `STATE-30` is complete.
- `STATE-40` is complete.
- `STATE-50` is complete.
- `STATE-60` is complete.
- `UI-00` is complete.
- `UI-01` is complete.
- `UI-02` and `UI-03` are READY because `UI-00` is complete.
- `SCREEN-10` is READY because `RES-11`, `STATE-30`, and `UI-01` are complete.
- `SCREEN-24`, `SCREEN-25`, `ARCH-40`, `ARCH-50`, and `PERF-60` remain READY.
- `SCREEN-22` remains BACKLOG because `SCREEN-20` and `SCREEN-21` are not complete.
- `SCREEN-23` remains BACKLOG because `SCREEN-10` is not complete.
- `TEST-80` remains BACKLOG because `ARCH-41` is not complete.
- `UI-02` is the first READY task in queue order after completed `UI-01`.

---

## 12. Completed task proof log

### FB-00 Adopt all feedbacks

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-00_ADOPT_ALL_FEEDBACKS/`
  review: `docs/review/autopilot/FB-00_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/ROADMAP.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`
  major files:
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-00_ADOPT_ALL_FEEDBACKS/SUB_TASKS.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-00_ADOPT_ALL_FEEDBACKS/UX.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-00_ADOPT_ALL_FEEDBACKS/POLICY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-00_ADOPT_ALL_FEEDBACKS/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/FB-00_TEST_RESULT_2026-06-10.md`

### FB-01 Fix FileDialog popup paths

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-01_FIX_FILE_DIALOG_POPUP_PATHS/`
  review: `docs/review/autopilot/FB-01_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_editor_path_selector.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
    - `addons/hex_map_kit/editor/hex_dist_editor.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/FB-01_TEST_RESULT_2026-06-10.md`

### FB-02 Visible no-op control repair

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-02_VISIBLE_NO_OP_CONTROL_REPAIR/`
  review: `docs/review/autopilot/FB-02_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/FB-02_TEST_RESULT_2026-06-10.md`

### RES-10 Document dependency service

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/RES-10_DOCUMENT_DEPENDENCY_SERVICE/`
  review: `docs/review/autopilot/RES-10_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_map_document_dependency_resource.gd`
    - `addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd`
    - `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
    - `tests/test_hex_adapter.gd`
    - `docs/review/autopilot/RES-10_TEST_RESULT_2026-06-10.md`

### RES-11 Document dependency hydration

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/RES-11_DOCUMENT_DEPENDENCY_HYDRATION/`
  review: `docs/review/autopilot/RES-11_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/RES-11_TEST_RESULT_2026-06-10.md`

### NODE-20 HexTileMap resource binding service

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/NODE-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE/`
  review: `docs/review/autopilot/NODE-20_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/NODE-20_TEST_RESULT_2026-06-10.md`

### NODE-21 Hex map resource role clarification

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/NODE-21_HEX_MAP_RESOURCE_ROLE_CLARIFICATION/`
  review: `docs/review/autopilot/NODE-21_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
    - `docs/manual/MANUAL_WORKFLOW.md`
    - `docs/knowledge/DEV_GODOT.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/NODE-21_TEST_RESULT_2026-06-10.md`

### NODE-22 Missing node resource bulk create review

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/NODE-22_MISSING_NODE_RESOURCE_BULK_CREATE_REVIEW/`
  review: `docs/review/autopilot/NODE-22_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/NODE-22_TEST_RESULT_2026-06-10.md`

### PROFILE-30 Concrete profile resources

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/PROFILE-30_CONCRETE_PROFILE_RESOURCES/`
  review: `docs/review/autopilot/PROFILE-30_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
    - `docs/manual/MANUAL_WORKFLOW.md`
    - `docs/manual/MANUAL_EDITOR_PLUGIN.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_validation_rule_suite_resource.gd`
    - `addons/hex_map_kit/adapter/hex_generation_profile_resource.gd`
    - `addons/hex_map_kit/adapter/hex_export_profile_resource.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd`
    - `tests/test_editor_plugin.gd`
    - `tests/test_hex_adapter.gd`
    - `docs/review/autopilot/PROFILE-30_TEST_RESULT_2026-06-10.md`

### PROFILE-31 Profile dependency integration

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/PROFILE-31_PROFILE_DEPENDENCY_INTEGRATION/`
  review: `docs/review/autopilot/PROFILE-31_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd`
    - `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `tests/test_hex_adapter.gd`
    - `docs/review/autopilot/PROFILE-31_TEST_RESULT_2026-06-10.md`

### STATE-00 UI flag inventory and contract

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT/`
  review: `docs/review/autopilot/STATE-00_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/review/roadmap/UI_FLAG_INVENTORY_2026-06-10.md`
    - `docs/TEST.md`
  major files:
    - `docs/review/roadmap/UI_FLAG_INVENTORY_2026-06-10.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT/SUB_TASKS.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT/UX.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT/POLICY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/STATE-00_TEST_RESULT_2026-06-10.md`

### STATE-10 Generation run state machine

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-10_GENERATION_RUN_STATE_MACHINE/`
  review: `docs/review/autopilot/STATE-10_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_generation_run_state.gd`
    - `addons/hex_map_kit/editor/hex_map_generation_run_state.gd.uid`
    - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-10_GENERATION_RUN_STATE_MACHINE/SUB_TASKS.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-10_GENERATION_RUN_STATE_MACHINE/UX.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-10_GENERATION_RUN_STATE_MACHINE/POLICY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-10_GENERATION_RUN_STATE_MACHINE/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/STATE-10_TEST_RESULT_2026-06-10.md`

### STATE-20 Asset slot config/runtime/result state split

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT/`
  review: `docs/review/autopilot/STATE-20_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd`
    - `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT/SUB_TASKS.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT/UX.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT/POLICY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/STATE-20_TEST_RESULT_2026-06-10.md`

### STATE-30 Workspace selection binding state

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-30_WORKSPACE_SELECTION_BINDING_STATE/`
  review: `docs/review/autopilot/STATE-30_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-30_WORKSPACE_SELECTION_BINDING_STATE/SUB_TASKS.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-30_WORKSPACE_SELECTION_BINDING_STATE/UX.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-30_WORKSPACE_SELECTION_BINDING_STATE/POLICY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-30_WORKSPACE_SELECTION_BINDING_STATE/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/STATE-30_TEST_RESULT_2026-06-10.md`

### STATE-40 Paint interaction state machine

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-40_PAINT_INTERACTION_STATE_MACHINE/`
  review: `docs/review/autopilot/STATE-40_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_paint_interaction_state.gd`
    - `addons/hex_map_kit/editor/hex_map_paint_interaction_state.gd.uid`
    - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-40_PAINT_INTERACTION_STATE_MACHINE/SUB_TASKS.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-40_PAINT_INTERACTION_STATE_MACHINE/UX.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-40_PAINT_INTERACTION_STATE_MACHINE/POLICY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-40_PAINT_INTERACTION_STATE_MACHINE/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/STATE-40_TEST_RESULT_2026-06-10.md`

### STATE-50 Validation Export Sample Dialog states

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES/`
  review: `docs/review/autopilot/STATE-50_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_validation_workflow_state.gd`
    - `addons/hex_map_kit/editor/hex_map_validation_workflow_state.gd.uid`
    - `addons/hex_map_kit/editor/hex_map_export_workflow_state.gd`
    - `addons/hex_map_kit/editor/hex_map_export_workflow_state.gd.uid`
    - `addons/hex_map_kit/editor/hex_map_sample_learning_state.gd`
    - `addons/hex_map_kit/editor/hex_map_sample_learning_state.gd.uid`
    - `addons/hex_map_kit/editor/hex_map_dialog_lifecycle_state.gd`
    - `addons/hex_map_kit/editor/hex_map_dialog_lifecycle_state.gd.uid`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
    - `addons/hex_map_kit/editor/hex_map_editor_path_selector.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES/SUB_TASKS.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES/UX.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES/POLICY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/STATE-50_TEST_RESULT_2026-06-10.md`

### STATE-60 Root dispatcher and ViewState integration

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-60_ROOT_DISPATCHER_AND_VIEWSTATE_INTEGRATION/`
  review: `docs/review/autopilot/STATE-60_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_workspace_root_state.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_root_state.gd.uid`
    - `addons/hex_map_kit/editor/hex_map_workspace_dispatcher.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_dispatcher.gd.uid`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-60_ROOT_DISPATCHER_AND_VIEWSTATE_INTEGRATION/SUB_TASKS.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-60_ROOT_DISPATCHER_AND_VIEWSTATE_INTEGRATION/UX.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-60_ROOT_DISPATCHER_AND_VIEWSTATE_INTEGRATION/POLICY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/STATE-60_ROOT_DISPATCHER_AND_VIEWSTATE_INTEGRATION/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/STATE-60_TEST_RESULT_2026-06-10.md`

### UI-00 Create workspace UI contracts

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/`
  review: `docs/review/autopilot/UI-00_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/SUB_TASKS.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/UX.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/POLICY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/IMPLEMENTATION_PLAN.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/WORKSPACE_SCREEN_CONTRACT.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/WORKSPACE_STATE_MACHINE.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/VISIBLE_CONTROL_INVENTORY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/RESOURCE_ROW_SPEC.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/DEBUG_LABEL_POLICY.md`
    - `docs/review/autopilot/UI-00_TEST_RESULT_2026-06-10.md`

### UI-01 Resource row redesign

proof:
  plan: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-01_RESOURCE_ROW_REDESIGN/`
  review: `docs/review/autopilot/UI-01_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-01_RESOURCE_ROW_REDESIGN/SUB_TASKS.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-01_RESOURCE_ROW_REDESIGN/UX.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-01_RESOURCE_ROW_REDESIGN/POLICY.md`
    - `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-01_RESOURCE_ROW_REDESIGN/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/UI-01_TEST_RESULT_2026-06-10.md`
