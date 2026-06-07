# UI Asset Selection / Workspace Refinement Implementation Queue 2026-06-07

作成日: 2026-06-08  
Roadmap: `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ROADMAP.md`  
Queue design policy: `docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md`  
Operation process: `docs/process/QUEUE_OPERATION_RULES.md`  
Autopilot process: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`

この queue は、sample preset を production workflow の完成根拠にしないため、Workspace の各 tab に任意 project asset selection を持たせる実装単位へ roadmap を分割したものである。

---

## 0. Queue operation notes

- status 更新、dependency sweep、proof 記録は `docs/process/QUEUE_OPERATION_RULES.md` に従う。
- `READY` task は plan files を作成して実装まで進める。Plan 作成は承認ゲートではない。
- Acceptance は sample preset だけで満たしてはいけない。
- 新規 analog test は作らない。UI再編後にユーザー指示がある場合だけ別 roadmap で扱う。
- UI task の test は private node 名ではなく、asset slot state、workspace context、tab component contract を確認する。

---

## 1. Phase A0: Policy reset

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `ASSET-00` | `COMPLETE` | none | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ASSET-00_ASSET_SELECTION_POLICY_RESET/` | Asset selection policy reset | `AGENTS.md`, `docs/policy/DOMAIN_POLICY.md`, `docs/policy/IMPLEMENTATION_POLICY.md`, `docs/policy/TEST_DESIGN_POLICY.md`, `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`, roadmap/queue docs | `sample-only prototype` and `No sample-only completion` are documented; headless tests cannot treat sample preset success as feature complete; analog tests remain deferred. |
| `ASSET-01` | `READY` | `ASSET-00` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ASSET-01_ASSET_SLOT_INVENTORY/` | Asset slot inventory | `docs/review/roadmap/ASSET_SLOT_INVENTORY_2026-06-07.md`, editor UI source review notes | Inventory lists slot id, screen/tab, required type, current sample dependency, arbitrary selection path, validation state, flow classification, cleanup task id. |

---

## 2. Phase A1: Asset slot model

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `ASSET-10` | `BACKLOG` | `ASSET-01` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ASSET-10_ASSET_SLOT_STATE_MODEL/` | Unified asset slot state/control model | new `addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd`, new `hex_map_editor_asset_slot_control.gd`, existing resource selector component, editor tests | Slot state represents Not selected / Selected / Invalid / Warning, type mismatch, and optional sample source without making sample the default; tests inspect state model, not private widget names. |
| `ASSET-11` | `BACKLOG` | `ASSET-10` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ASSET-11_WORKSPACE_ASSET_CONTEXT_RESOURCE/` | Workspace asset context | new `HexMapWorkspaceAssetContext`, `HexMapEditorSessionState`, `HexMapWorkspace`, editor tests | Catalog, Object DB, Label DB, Layer Stack, Movement Profile, Validation Suite, Generation Profile are held in shared context; Generate/Paint/Validate/QA use the same context and do not search sample assets independently. |
| `ASSET-12` | `BACKLOG` | `ASSET-10` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ASSET-12_CREATE_NEW_RESOURCE_ACTIONS/` | Create-new actions for asset slots | asset slot control/model, resource creation helpers, editor tests | Asset slots can create required resources through FileDialog / Save As; created resource enters asset context; sample assets are not silently mixed into new project asset creation. |

---

## 3. Phase A2: Settings / Samples separation

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `SAMPLE-10` | `BACKLOG` | `ASSET-10` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SAMPLE-10_SAMPLE_MODE_SETTINGS_TAB/` | Settings / Samples tab | `HexMapWorkspace`, new `HexMapSampleSettingsPanel`, bundled sample asset references, editor tests | Sample controls move out of Generate/Paint main UI; sample mode OFF hides bundled samples from main selectors; sample mode ON still keeps user-selected project assets primary. |
| `SAMPLE-11` | `BACKLOG` | `SAMPLE-10` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SAMPLE-11_DUPLICATE_SAMPLE_TO_PROJECT/` | Duplicate sample to project workflow | sample settings panel, duplication helpers, sample resources, package tests | Sample catalog/scene/tile dependencies can be duplicated to a project path; duplicate enters asset context as a project asset; no sample is silently assigned as project default. |
| `SAMPLE-12` | `BACKLOG` | `SAMPLE-10` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SAMPLE-12_FIRST_RUN_LEARNING_CTA/` | First-run learning CTA | workspace/settings UI, editor setting state, tests | First-run `Learn with bundled samples` CTA opens Settings / Samples; dismissing it shows normal project asset selection; CTA does not replace the production flow. |

---

## 4. Phase A3: Workspace tab content migration

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `WORKSPACE-10` | `BACKLOG` | `ASSET-11` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION/` | Real workspace tab content migration | `HexMapWorkspace`, editor tab components, Generate/Paint/Catalog/Layers/Validate/QA/Export UI code, editor tests | Document / Catalog / Layers / Validate / QA / Export / Settings tabs are non-empty and own relevant asset slots; Paint loses non-paint responsibilities; tests check `tab_has_component()` and `asset_slot_count()`. |
| `WORKSPACE-11` | `BACKLOG` | `WORKSPACE-10` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/WORKSPACE-11_TAB_COMPONENT_REGISTRY_CONTRACT/` | Workspace component registry contract | `HexMapWorkspace`, tab registry/query helpers, editor tests | Public-ish query methods expose component ids and asset slot ids, e.g. Catalog includes `catalog_asset_panel` and `tile_catalog`; tests avoid private child node names. |

---

## 5. Phase A4: Screen-by-screen asset selection

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `SCREEN-20` | `BACKLOG` | `WORKSPACE-10`, `ASSET-12` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SCREEN-20_DOCUMENT_ASSET_SCREEN/` | Document asset screen | Document tab/component, workspace context, document resource helpers, editor tests | Level Document can be selected, created, cleared, opened, saved as, and validated without sample; dependencies are visible as asset slots. |
| `SCREEN-21` | `BACKLOG` | `WORKSPACE-10`, `ASSET-12` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SCREEN-21_CATALOG_ASSET_SCREEN/` | Catalog asset screen | Catalog tab/component, catalog resources, TileSet/entry UI, editor/catalog tests | Arbitrary catalog and TileSet can be selected or created; sample catalog is only available through sample mode; entry authoring starts from TileSet / PackedScene selection. |
| `SCREEN-22` | `BACKLOG` | `WORKSPACE-10`, `ASSET-12` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SCREEN-22_LAYER_STACK_ASSET_SCREEN/` | Layer stack asset screen | Layers tab/component, layer stack resources, target root picker, editor/layer tests | Layer Stack can be selected or created without sample template; target root is picked from scene; templates are presets that can be duplicated to project assets. |
| `SCREEN-23` | `BACKLOG` | `WORKSPACE-10`, `ASSET-12` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SCREEN-23_OBJECT_LABEL_ASSET_SCREEN/` | Object / Label asset screen | Object/Label tab or panels, object database, label database, PackedScene/preview selectors, editor/object/label tests | Object placement uses Object Definition picker, not raw object id text; label placement uses Label Definition picker; sample object scene is isolated in Settings / Samples. |
| `SCREEN-24` | `BACKLOG` | `SCREEN-21`, `SCREEN-23` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SCREEN-24_PAINT_BRUSH_ASSET_SCREEN/` | Paint brush asset screen | Paint tab/component, brush palette, catalog/object/label selection state, editor tests | Paint focuses on Terrain/Overlay/Object/Label/Zone mode and current brush asset; source id, atlas coords, raw object id, and raw label id are absent from normal Paint UI; missing asset state points to owning tab. |
| `SCREEN-25` | `BACKLOG` | `WORKSPACE-10` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SCREEN-25_VALIDATE_ASSET_SCREEN/` | Validate asset screen | Validate tab/component, validation rule suite selection, issue navigator, editor tests | Missing user assets are validation issues, not sample fallback; issues point to the Document/Catalog/Object/Layer/QA place the user should fix. |
| `SCREEN-26` | `BACKLOG` | `WORKSPACE-10`, `ASSET-12` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SCREEN-26_QA_ASSET_SCREEN/` | QA / Seed Lab asset screen | QA tab/component, generation profile resources, validation suite, score table, promotion target, editor/generation tests | Custom Generation Profile and Validation Suite can be selected or created; built-in presets can be duplicated; score table displays selected profile and validation suite. |
| `SCREEN-27` | `BACKLOG` | `WORKSPACE-10`, `ASSET-12` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/SCREEN-27_EXPORT_ASSET_SCREEN/` | Export asset screen | Export tab/component, export profile, destination FileDialog/recent destinations, package/runtime handoff, package tests | Export destination uses FileDialog/recent destination, not text input; user-selected destination is required; no sample export destination exists. |

---

## 6. Phase A5: Raw text / fallback cleanup

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `CLEANUP-30` | `BACKLOG` | `SCREEN-21`, `SCREEN-24` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/CLEANUP-30_DEBUG_NUMERIC_FALLBACK_QUARANTINE/` | Debug numeric fallback quarantine | catalog/paint UI, adapters, validation helpers, tests | Normal apply path does not silently fill missing catalog through numeric fallback; debug fallback requires explicit Settings / Debug opt-in; tests assert missing catalog is validation issue. |
| `CLEANUP-31` | `BACKLOG` | `SCREEN-23`, `SCREEN-24` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/CLEANUP-31_RAW_TEXT_AUTHORING_FIELD_REPLACEMENT/` | Raw text authoring field replacement | overlay/object/label UI, property schema editors, tests | Overlay item key, Label ID, Object variant, Spawn condition, and Object property key/value have asset/definition/enum/schema selection sources; raw text is advanced/debug only or removed. |

---

## 7. Phase A6: Test contract rebuild

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `TEST-40` | `BACKLOG` | `ASSET-10` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/TEST-40_NO_SAMPLE_ONLY_COMPLETION_TESTS/` | No sample-only completion tests | editor tests, package/sample tests, `docs/TEST.md` | Feature screen tests run sample mode OFF and verify arbitrary project asset selection state; sample mode ON/OFF is tested separately; package integrity tests own sample asset validity. |
| `TEST-41` | `BACKLOG` | `WORKSPACE-11` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/TEST-41_WORKSPACE_TAB_CONTENT_CONTRACT_TESTS/` | Workspace tab content contract tests | workspace query methods, editor tests, `docs/TEST.md` | Each tab exposes expected component ids and asset slot ids through query methods; tests avoid private child node names. |
| `TEST-42` | `BACKLOG` | `ASSET-10`, `SAMPLE-11` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/TEST-42_ASSET_SLOT_STATE_MODEL_TESTS/` | Asset slot state model tests | asset slot state/control tests, sample duplication tests, `docs/TEST.md` | Required asset missing, invalid type, selected project asset, sample mode OFF hiding samples, sample mode ON showing learning candidates, and duplicate sample project state are covered. |

---

## 8. Phase A7: Manual update

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `DOC-50` | `BACKLOG` | `SCREEN-20`, `SCREEN-21`, `SCREEN-23`, `SCREEN-26` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/DOC-50_ASSET_SELECTION_WORKFLOW_MANUAL/` | Project asset selection workflow manual | `docs/manual/MANUAL_EDITOR_PLUGIN.md`, `docs/manual/MANUAL_WORKFLOW.md`, `docs/manual/MANUAL_PACKAGE.md`, `README.md` | Manual uses project asset selection as main workflow; sample is isolated to learning/onboarding; `Use Sample Tiles` is not normal setup; no analog test files are added. |
| `DOC-51` | `BACKLOG` | `SAMPLE-10`, `SAMPLE-11` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/DOC-51_SAMPLE_MODE_ONBOARDING_DOCS/` | Sample mode onboarding docs | manual docs, README, sample settings references | Sample mode is learning/onboarding; production workflow is project asset selection; duplicate sample to project is explained. |

---

## 9. Phase A8: Package / sample integrity

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `PKG-70` | `BACKLOG` | `SAMPLE-10`, `SAMPLE-11` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/PKG-70_SAMPLE_AS_LEARNING_PACKAGE_CHECK/` | Sample-as-learning package check | sample assets, package script/tests, `docs/TEST.md` | Sample catalog, sample tiles, and sample scene are packaged and accessible with sample mode ON; sample mode OFF does not silently inject them into main selectors. |
| `PKG-71` | `BACKLOG` | `DOC-50`, `TEST-40` | `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/PKG-71_PROJECT_ASSET_CLEAN_PACKAGE_CHECK/` | Project asset clean package check | package checks, editor/package tests, manual/package docs | Clean project flow covers plugin load, new document, new catalog, user TileSet, user object scene, missing asset validation before selection, and package check PASS. |

---

## 10. Dynamic follow-up area

Codex appends `follow-up-ready` work here when self-review finds nonblocking work.

Template:

```md
### <TASK-ID> <title>

status: READY | BACKLOG  
dependencies: ...  
source_review: docs/review/autopilot/<...>.md  
plan_dir: docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/<TASK-ID>_<slug>/

deliverable:
- ...

acceptance / test path:
- ...
```

---

## 11. Current pointer

Current recommended next task: `ASSET-01`.

Reason:

- `ASSET-00` is complete and defines the completion rule needed by all later tasks.
- `ASSET-01` is the first dependency-satisfied READY task.

---

## 12. Completed task proof log

### ASSET-00 Asset selection policy reset

proof:
  plan: `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ASSET-00_ASSET_SELECTION_POLICY_RESET/`
  review: `docs/review/autopilot/ASSET-00_SELF_REVIEW_2026-06-08.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `AGENTS.md`
    - `docs/policy/DOMAIN_POLICY.md`
    - `docs/policy/IMPLEMENTATION_POLICY.md`
    - `docs/policy/TEST_DESIGN_POLICY.md`
    - `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
    - `docs/TEST.md`
  major files:
    - `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`
    - `docs/review/autopilot/ASSET-00_TEST_RESULT_2026-06-08.md`
