# UX First Clean Spec Implementation Queue 2026-06-07

作成日: 2026-06-07  
Roadmap: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/UX_ROADMAP.md`  
Operation rules: `docs/process/QUEUE_OPERATION_RULES.md`  
Commit policy: `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`

この queue は、Autopilot 実装後に残った互換性・path text・test都合のUI設計を破棄し、未公開addonとして清潔な UX / API / test contract へ統一するための実装キューである。Plan 作成は承認ゲートではない。各 `READY` task は、plan files 作成、実装、test、self-review、queue update まで同じ Autopilot run で進める。

---

## 0. Queue operation rules

- status は `docs/process/QUEUE_OPERATION_RULES.md` に従う。
- `READY` task を進める。Roadmap 記載の UX に関して Design Flow に従い、`UX.md` / `POLICY.md` / `IMPLEMENTATION_PLAN.md` を必要に応じて作る。
- 本ファイル記載の要件は圧縮された概要にすぎない。設計に際しては必ず `UX_ROADMAP.md` 全体から該当箇所及び関連する目標を理解し、UXの機能分解を進めること。
- この roadmap では、未公開addonであることを前提に、互換性維持より clean UX / clean API / clean tests を優先する。
- Headless editor test が clean UX を妨げる場合、test を削除または新UXの state contract へ書き換える。
- 新規 analog test は作らない。analog test は UI再編後にユーザー指示で再開する。
- task 完了時は dependency sweep を実行し、依存が満たされた `BACKLOG` を `READY` にする。
- Dispatcher は table order の先頭 `READY` を選ぶ。下の table order は最初に実行するべき順序を反映している。

Completion proof template:

```text
proof:
  plan: docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/<TASK_ID>_<slug>/
  review: docs/review/autopilot/<TASK_ID>_SELF_REVIEW_<date>.md
  tests:
    - ./tools/test.sh
    - <targeted command if any>
  docs:
    - docs/TEST.md
  major files:
    - ...
  maturity:
    - CODE_COMPLETE | DOCS_COMPLETE | HEADLESS_TEST_COMPLETE | PACKAGE_READY
```

---

## 1. Phase CLEAN-0: Policy and inventory bootstrap

| id | status | priority | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---:|---|---|---|---|---|---|
| `CLEAN-00` | `COMPLETE` | P0 | none | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-00_POLICY_RESET/` | Autopilot / policy reset | `AGENTS.md`, `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`, `docs/policy/IMPLEMENTATION_POLICY.md`, `docs/policy/TEST_DESIGN_POLICY.md`, this queue | Policy docs state `UX合理性 > headless test > compatibility`; compatibility is exception; new analog tests are deferred; self-review checks whether old tests distorted UX | `DOCS_COMPLETE` |
| `CLEAN-30` | `COMPLETE` | P0 | `CLEAN-00` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-30_EDITOR_SCREEN_INVENTORY/` | Editor screen inventory by user task | `docs/review/roadmap/EDITOR_UX_COMPONENT_INVENTORY_2026-06-07.md`, editor source inventory notes | Inventory classifies UI as `keep-in-place` / `move-to-screen` / `merge-with-existing` / `advanced-only` / `delete`; path text and fallback UI deletion candidates are explicit | `DOCS_COMPLETE` |

---

## 2. Phase CLEAN-1: Resource/API canonicalization

| id | status | priority | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---:|---|---|---|---|---|---|
| `CLEAN-10` | `COMPLETE` | P0 | `CLEAN-00`, `CLEAN-30` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-10_DOCUMENT_CANONICAL_SCHEMA/` | `HexMapDocumentResource` canonical schema | `addons/hex_map_kit/adapter/hex_map_document_resource.gd`, `hex_map_document_adapter.gd`, document child resources, `tests/test_hex_adapter.gd`, docs/API/manual | `v1` / `v2` / `version` / legacy fields / `ensure_v2_defaults()` are removed from public contract; new document is canonical by construction; tests verify canonical save/load and roundtrip, not migration fixtures | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-11` | `COMPLETE` | P0 | `CLEAN-10` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-11_ADAPTER_COMPATIBILITY_REMOVAL/` | Adapter migration / compatibility removal | `hex_map_document_adapter.gd`, `hex_map_tile_adapter.gd`, `hex_overlay_tile_adapter.gd`, `hex_tile_map_layer.gd`, adapter/layer tests | Normal adapter path has no `legacy` / `v1` / `fallback`; missing catalog or assignment becomes validation issue; runtime apply succeeds for validation-clean document | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-13` | `COMPLETE` | P0 | `CLEAN-10` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-13_TILE_CATALOG_CANONICAL_RESOURCE/` | Tile catalog canonical resource | `hex_tile_catalog_resource.gd`, `hex_tile_catalog_entry.gd`, `hex_tile_catalog_validator.gd`, tile/overlay adapters, sample catalog | `tile_set_path` / `scene_path` / fallback fields are removed; TileSet / PackedScene resource references are canonical; sample catalog validator is clean | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-12` | `COMPLETE` | P0 | `CLEAN-10` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-12_OBJECT_DATABASE_CANONICAL_RESOURCE/` | Object database canonical resource | `hex_object_database_resource.gd`, `hex_object_definition_resource.gd`, `hex_object_layer_adapter.gd`, runtime sample, object tests | `definitions` is the only normal object definition field; scene uses `PackedScene`; runtime export returns resource references rather than scene path strings | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-14` | `COMPLETE` | P1 | `CLEAN-10` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-14_LABEL_DEPENDENCY_CANONICAL_RESOURCE/` | Label / dependency canonical resources | `hex_label_database_resource.gd`, new label definition resource, `hex_map_document_dependency_resource.gd`, validator/docs/tests | Label database uses typed definitions; dependency uses Resource / kind / role / required, not editable path string; validation detects null or type mismatch | `HEADLESS_TEST_COMPLETE` |

---

## 3. Phase CLEAN-2: Resource reference UX

| id | status | priority | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---:|---|---|---|---|---|---|
| `CLEAN-20` | `COMPLETE` | P0 | `CLEAN-10`, `CLEAN-13` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-20_RESOURCE_SELECTION_UI_STANDARD/` | Resource selection UI standard | `hex_map_edit_tool.gd`, `hex_map_gen_dock.gd`, path selector/session state helpers, editor tests | Normal document/catalog/object/label selection uses Resource picker or FileDialog; editable path LineEdit is removed or read-only status; path-based headless tests are deleted or rewritten | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-50` | `COMPLETE` | P0 | `CLEAN-20` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-50_HEADLESS_EDITOR_TEST_DESTRUCTION_PASS/` | Headless editor test destruction pass | `tests/test_editor_plugin.gd`, editor UI tests, `docs/TEST.md` | Tests no longer require old path LineEdit or fallback/numeric controls; tests check clean UI state transitions instead of obsolete node existence | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-21` | `COMPLETE` | P0 | `CLEAN-20`, `CLEAN-50` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-21_DOCUMENT_HEADER_REDESIGN/` | Document Header redesign | editor document/session/header code, `hex_map_edit_tool.gd`, `hex_map_gen_dock.gd`, editor tests | New/Open/Save/Save As/Validate/Dirty state work without path text editing; `v2` and `migration` wording is absent from UI | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-22` | `COMPLETE` | P0 | `CLEAN-13`, `CLEAN-20` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-22_CATALOG_SCREEN_REDESIGN/` | Catalog Screen redesign | catalog editor UI, `hex_map_gen_dock.gd`, `hex_map_edit_tool.gd`, catalog tests | Catalog resource picker, TileSet picker, entry list, preview/status, PackedScene picker for scene entries; normal paint UI selects catalog key, not `source_id / atlas_coords` | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-23` | `COMPLETE` | P1 | `CLEAN-12`, `CLEAN-20` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-23_OBJECT_PALETTE_REDESIGN/` | Object Palette / Property Editor redesign | object editor UI, object resources/adapters, editor/object tests | Object database picker, definition list, PackedScene picker, object-key placement brush, and type-aware property editor exist; raw dictionary text is not normal UX | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-24` | `COMPLETE` | P1 | `CLEAN-21` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-24_LAYER_STACK_SCREEN_REDESIGN/` | Layer Stack Screen redesign | layer stack UI, `hex_tile_map_layer.gd`, editor/layer tests | Template picker, role list, visible/locked/z-index/writable source, Create Missing Layers, Apply Document, Clear Role are available; plain TileMapLayer apply is not primary UX | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-25` | `COMPLETE` | P1 | `CLEAN-21` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-25_GENERATION_QA_SCREEN_REDESIGN/` | Generation QA Screen redesign | generation QA UI, `hex_map_gen_dock.gd`, generation/editor tests | Batch seed run, score table, selected seed preview/state, Promote to Document, metadata and dirty state are visible as screen workflow | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-26` | `COMPLETE` | P1 | `CLEAN-21` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-26_VALIDATION_SCREEN_REFINEMENT/` | Validation Screen refinement | validation panel/dashboard, validator helpers, editor tests | Issues are grouped by domain and severity; issue click can focus cell/resource/catalog entry where applicable; fix suggestions exist; Copy Debug Report remains detailed | `HEADLESS_TEST_COMPLETE` |

---

## 4. Phase CLEAN-3: UX information architecture

| id | status | priority | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---:|---|---|---|---|---|---|
| `CLEAN-31` | `COMPLETE` | P1 | `CLEAN-30` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-31_WORKSPACE_TAB_MODEL_DECISION/` | Workspace / tab model decision | `docs/review/roadmap/EDITOR_WORKSPACE_MODEL_DECISION_2026-06-07.md`, editor architecture notes | Decision records 2-dock / workspace dock / main screen choice using UX criteria, not file size; chosen model gives Catalog/Layer/Validate/QA a clear home | `DOCS_COMPLETE` |
| `CLEAN-32` | `COMPLETE` | P1 | `CLEAN-31` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-32_UX_RESPONSIBILITY_COMPONENT_EXTRACTION/` | Component extraction by UX responsibility | new editor component scripts, `hex_map_gen_dock.gd`, `hex_map_edit_tool.gd`, editor tests | Components map to UX responsibilities such as DocumentHeader, CatalogPanel, LayerStackPanel, BrushPalette, ObjectPalette, SeedLabPanel, ValidationPanel; extraction is not justified by line count alone | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-33` | `COMPLETE` | P0 | `CLEAN-20`, `CLEAN-30` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-33_DELETE_HARMFUL_UI_PATHS/` | Delete redundant / harmful UI paths | editor UI code, editor tests, manual/API cleanup | Normal UI has no editable path text, numeric fallback tile controls, plain TileMapLayer primary action, or v2/migration wording; advanced/debug remnants have documented reason | `HEADLESS_TEST_COMPLETE` |

---

## 5. Phase CLEAN-4: Manual and API docs

| id | status | priority | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---:|---|---|---|---|---|---|
| `CLEAN-40` | `COMPLETE` | P1 | `CLEAN-21`, `CLEAN-22`, `CLEAN-23`, `CLEAN-24`, `CLEAN-25`, `CLEAN-26` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-40_MANUAL_CATALOG_VALIDATION_QA_UPDATE/` | Catalog / Validation / QA manual update | `docs/manual/MANUAL_EDITOR_PLUGIN.md`, `docs/manual/MANUAL_WORKFLOW.md`, `docs/manual/MANUAL_SCRIPTING.md`, `README.md` | Manual is organized by user goal; explains Resource picker workflows for Catalog, Layer Stack, Validation, Object Placement, Generation QA, Debug Report; no new analog test files are added | `DOCS_COMPLETE` |
| `CLEAN-41` | `COMPLETE` | P1 | `CLEAN-10`, `CLEAN-11`, `CLEAN-12`, `CLEAN-13`, `CLEAN-14` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-41_API_DOCS_CLEAN_VOCABULARY/` | API docs clean vocabulary pass | `docs/api/API_REFERENCE.md`, scripting manual, runtime examples | Public API docs remove `v2`, migration, legacy, path-string primary APIs; Resource object APIs are the first path; path helpers are documented only as supplemental load helpers | `DOCS_COMPLETE` |

---

## 6. Phase CLEAN-5: Clean tests

| id | status | priority | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---:|---|---|---|---|---|---|
| `CLEAN-51` | `READY` | P0 | `CLEAN-10`, `CLEAN-11`, `CLEAN-12`, `CLEAN-13`, `CLEAN-14` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-51_RESOURCE_API_CANONICAL_TESTS/` | Resource/API canonical tests | adapter/core/runtime tests, `docs/TEST.md` | Tests cover canonical document save/load, adapter roundtrip, catalog Resource references, PackedScene object definition, dependency Resource validation, no silent fallback apply, runtime query by Resource | `HEADLESS_TEST_COMPLETE` |
| `CLEAN-52` | `READY` | P0 | `CLEAN-00` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-52_ANALOG_TEST_DEFERRAL_MARKER/` | Analog test deferral marker | `docs/TEST.md`, queue/process docs if needed | `docs/TEST.md` states new analog tests are deferred during UI rework; existing analog tests are history, not clean UX acceptance; NEXT-03-style analog pack is not scheduled | `DOCS_COMPLETE` |

---

## 7. Phase CLEAN-6: Package / sample integrity

| id | status | priority | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---:|---|---|---|---|---|---|
| `CLEAN-60` | `READY` | P1 | `CLEAN-12`, `CLEAN-13` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-60_SAMPLE_ASSET_INTEGRITY/` | Sample asset integrity after clean references | `addons/hex_map_kit/assets/sample_hex_tile_catalog.tres`, sample TileSet/PackedScene/Texture resources, package tests | Sample catalog has no debug path or missing scene; package manifest includes sample dependencies; sample catalog validator is clean | `PACKAGE_READY` |
| `CLEAN-61` | `BACKLOG` | P2 | `CLEAN-40`, `CLEAN-41`, `CLEAN-51`, `CLEAN-60` | `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-61_DIST_REGENERATION_AFTER_CLEAN_SPEC/` | Dist regeneration after clean spec | `tools/package_addon.sh`, `dist/`, package docs/tests | `tools/package_addon.sh` regenerates current-tree package; manifest has no dev-only files and no legacy/migration docs; release upload is not performed | `PACKAGE_READY` |

---

## 8. Current pointer

Current recommended next task: `CLEAN-51`.

Reason:

- Dependency sweep completed on 2026-06-07 after `CLEAN-41` completion.
- No additional tasks were promoted.
- `CLEAN-51` is the first `READY` task by table order.
- `CLEAN-52` and `CLEAN-60` remain `READY`.

---

## 9. Completed task proof log

### CLEAN-41

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-41_API_DOCS_CLEAN_VOCABULARY/`
review: `docs/review/autopilot/CLEAN-41_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/api/API_REFERENCE.md`
  - `docs/manual/MANUAL_SCRIPTING.md`
  - `docs/manual/MANUAL_WORKFLOW.md`
  - `examples/basic_runtime/README.md`
  - `examples/editor_workflow/README.md`
  - `docs/review/autopilot/CLEAN-41_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-41_API_DOCS_CLEAN_VOCABULARY/`
- major files:
  - `docs/api/API_REFERENCE.md`
  - `docs/manual/MANUAL_SCRIPTING.md`
  - `docs/manual/MANUAL_WORKFLOW.md`
  - `examples/basic_runtime/runtime_query_sample.gd`
  - `examples/basic_runtime/runtime_query_example.gd`
  - `tests/test_debug_scenes.gd`
- maturity:
  - `DOCS_COMPLETE`

### CLEAN-40

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-40_MANUAL_CATALOG_VALIDATION_QA_UPDATE/`
review: `docs/review/autopilot/CLEAN-40_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/manual/MANUAL_EDITOR_PLUGIN.md`
  - `docs/manual/MANUAL_WORKFLOW.md`
  - `docs/manual/MANUAL_SCRIPTING.md`
  - `README.md`
  - `docs/review/autopilot/CLEAN-40_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-40_MANUAL_CATALOG_VALIDATION_QA_UPDATE/`
- major files:
  - `docs/manual/MANUAL_EDITOR_PLUGIN.md`
  - `docs/manual/MANUAL_WORKFLOW.md`
  - `docs/manual/MANUAL_SCRIPTING.md`
  - `README.md`
- maturity:
  - `DOCS_COMPLETE`

### CLEAN-33

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-33_DELETE_HARMFUL_UI_PATHS/`
review: `docs/review/autopilot/CLEAN-33_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/manual/MANUAL_EDITOR_PLUGIN.md`
  - `docs/review/autopilot/CLEAN-33_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-33_DELETE_HARMFUL_UI_PATHS/`
- major files:
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `tests/test_editor_plugin.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

### CLEAN-32

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-32_UX_RESPONSIBILITY_COMPONENT_EXTRACTION/`
review: `docs/review/autopilot/CLEAN-32_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/review/autopilot/CLEAN-32_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-32_UX_RESPONSIBILITY_COMPONENT_EXTRACTION/`
- major files:
  - `addons/hex_map_kit/editor/hex_map_workspace.gd`
  - `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
  - `addons/hex_map_kit/plugin.gd`
  - `tests/test_editor_plugin.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

### CLEAN-31

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-31_WORKSPACE_TAB_MODEL_DECISION/`
review: `docs/review/autopilot/CLEAN-31_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/review/roadmap/EDITOR_WORKSPACE_MODEL_DECISION_2026-06-07.md`
  - `docs/review/autopilot/CLEAN-31_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-31_WORKSPACE_TAB_MODEL_DECISION/`
- major files:
  - `docs/review/roadmap/EDITOR_WORKSPACE_MODEL_DECISION_2026-06-07.md`
- maturity:
  - `DOCS_COMPLETE`

### CLEAN-26

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-26_VALIDATION_SCREEN_REFINEMENT/`
review: `docs/review/autopilot/CLEAN-26_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/manual/MANUAL_EDITOR_PLUGIN.md`
  - `docs/review/autopilot/CLEAN-26_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-26_VALIDATION_SCREEN_REFINEMENT/`
- major files:
  - `addons/hex_map_kit/editor/hex_map_validation_dashboard.gd`
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `tests/test_editor_plugin.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

### CLEAN-25

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-25_GENERATION_QA_SCREEN_REDESIGN/`
review: `docs/review/autopilot/CLEAN-25_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/manual/MANUAL_EDITOR_PLUGIN.md`
  - `docs/review/autopilot/CLEAN-25_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-25_GENERATION_QA_SCREEN_REDESIGN/`
- major files:
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `tests/test_editor_plugin.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

### CLEAN-24

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-24_LAYER_STACK_SCREEN_REDESIGN/`
review: `docs/review/autopilot/CLEAN-24_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/manual/MANUAL_EDITOR_PLUGIN.md`
  - `docs/review/autopilot/CLEAN-24_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-24_LAYER_STACK_SCREEN_REDESIGN/`
- major files:
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `tests/test_editor_plugin.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

### CLEAN-23

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-23_OBJECT_PALETTE_REDESIGN/`
review: `docs/review/autopilot/CLEAN-23_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/manual/MANUAL_EDITOR_PLUGIN.md`
  - `docs/review/autopilot/CLEAN-23_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-23_OBJECT_PALETTE_REDESIGN/`
- major files:
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `tests/test_editor_plugin.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

### CLEAN-22

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-22_CATALOG_SCREEN_REDESIGN/`
review: `docs/review/autopilot/CLEAN-22_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/manual/MANUAL_EDITOR_PLUGIN.md`
  - `docs/review/autopilot/CLEAN-22_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-22_CATALOG_SCREEN_REDESIGN/`
- major files:
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `tests/test_editor_plugin.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

### CLEAN-21

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-21_DOCUMENT_HEADER_REDESIGN/`
review: `docs/review/autopilot/CLEAN-21_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/manual/MANUAL_EDITOR_PLUGIN.md`
  - `docs/review/autopilot/CLEAN-21_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-21_DOCUMENT_HEADER_REDESIGN/`
- major files:
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `tests/test_editor_plugin.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

### CLEAN-50

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-50_HEADLESS_EDITOR_TEST_DESTRUCTION_PASS/`
review: `docs/review/autopilot/CLEAN-50_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/TEST.md`
  - `docs/review/autopilot/CLEAN-50_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-50_HEADLESS_EDITOR_TEST_DESTRUCTION_PASS/`
- major files:
  - `tests/test_editor_plugin.gd`
  - `docs/TEST.md`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

### CLEAN-20

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-20_RESOURCE_SELECTION_UI_STANDARD/`
review: `docs/review/autopilot/CLEAN-20_SELF_REVIEW_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
  - `git diff --check` PASS
- docs:
  - `docs/knowledge/DEV_GODOT.md`
  - `docs/review/autopilot/CLEAN-20_SELF_REVIEW_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-20_RESOURCE_SELECTION_UI_STANDARD/`
- major files:
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
  - `tests/test_editor_plugin.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

### CLEAN-14

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-14_LABEL_DEPENDENCY_CANONICAL_RESOURCE/`
review: `docs/review/autopilot/CLEAN-14_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CLEAN-14_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
  - `docs/api/API_REFERENCE.md`
  - `docs/manual/MANUAL_WORKFLOW.md`
  - `docs/knowledge/DEV_GODOT.md`
  - `docs/review/autopilot/CLEAN-14_SELF_REVIEW_2026-06-07.md`
  - `docs/review/autopilot/CLEAN-14_TEST_RESULT_2026-06-07.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_label_definition_resource.gd`
  - `addons/hex_map_kit/adapter/hex_label_database_resource.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_dependency_resource.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
  - `addons/hex_map_kit/adapter/hex_map_validation_result.gd`
  - `examples/editor_workflow/editor_workflow_example.gd`
  - `tests/test_hex_adapter.gd`
  - `tests/test_debug_scenes.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

Notes:

- `HexLabelDatabaseResource` now owns typed `HexLabelDefinitionResource` entries through `definitions`.
- `HexMapDocumentDependencyResource` now stores `resource: Resource` instead of `dependency_path`.
- Dependency validation reports missing required resources and kind/type mismatches.
- Debug resource paths are read from the referenced resource's built-in `resource_path`.
- Dependency sweep promoted `CLEAN-41` and `CLEAN-51` to `READY`; `CLEAN-20` is the next task by table order.
- `repair-now`: complete.

### CLEAN-12

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-12_OBJECT_DATABASE_CANONICAL_RESOURCE/`
review: `docs/review/autopilot/CLEAN-12_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CLEAN-12_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
  - `docs/api/API_REFERENCE.md`
  - `docs/manual/MANUAL_WORKFLOW.md`
  - `examples/basic_runtime/README.md`
  - `docs/review/autopilot/CLEAN-12_SELF_REVIEW_2026-06-07.md`
  - `docs/review/autopilot/CLEAN-12_TEST_RESULT_2026-06-07.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_object_database_resource.gd`
  - `addons/hex_map_kit/adapter/hex_object_definition_resource.gd`
  - `addons/hex_map_kit/adapter/hex_object_layer_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
  - `examples/basic_runtime/runtime_query_sample.gd`
  - `tests/test_hex_adapter.gd`
  - `tests/test_hex_tile_map_layer.gd`
  - `tests/test_debug_scenes.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

Notes:

- `HexObjectDatabaseResource` no longer exports `version` or legacy `objects`; typed `definitions` are the canonical object definition collection.
- `HexObjectDefinitionResource` now uses `scene: PackedScene` and `preview_texture: Texture2D`.
- Object scene validation and direct instance resolution use resource references, not path strings.
- Runtime object export returns `scene` `PackedScene` references.
- Dependency sweep promoted `CLEAN-60` to `READY`; `CLEAN-14` is the next task by table order.
- `repair-now`: complete.

### CLEAN-13

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-13_TILE_CATALOG_CANONICAL_RESOURCE/`
review: `docs/review/autopilot/CLEAN-13_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CLEAN-13_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
  - `docs/api/API_REFERENCE.md`
  - `docs/manual/MANUAL_WORKFLOW.md`
  - `docs/review/autopilot/CLEAN-13_SELF_REVIEW_2026-06-07.md`
  - `docs/review/autopilot/CLEAN-13_TEST_RESULT_2026-06-07.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd`
  - `addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd`
  - `addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd`
  - `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
  - `addons/hex_map_kit/assets/sample_hex_tile_catalog.tres`
  - `addons/hex_map_kit/assets/sample_spawn_marker.tscn`
  - `tests/test_hex_adapter.gd`
  - `tests/test_hex_tile_map_layer.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

Notes:

- `HexTileCatalogResource` now owns `tile_set: TileSet` instead of `tile_set_path`.
- `HexTileCatalogEntry` now uses `scene: PackedScene`, supports `placeholder`, and no longer has tile fallback fields.
- `HexTileCatalogValidator` and document validation prefer the catalog-owned TileSet when an explicit active TileSet is not supplied.
- The sample catalog references package-contained atlas and scene resources and validates clean.
- Dependency sweep promoted `CLEAN-20` to `READY`; `CLEAN-12` is the next task by table order.
- `repair-now`: complete.

### CLEAN-11

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-11_ADAPTER_COMPATIBILITY_REMOVAL/`
review: `docs/review/autopilot/CLEAN-11_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CLEAN-11_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
  - `docs/manual/MANUAL_WORKFLOW.md`
  - `docs/review/autopilot/CLEAN-11_SELF_REVIEW_2026-06-07.md`
  - `docs/review/autopilot/CLEAN-11_TEST_RESULT_2026-06-07.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
  - `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_overlay_tile_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_object_layer_adapter.gd`
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `tests/test_hex_adapter.gd`
  - `tests/test_hex_tile_map_layer.gd`
  - `tests/test_editor_plugin.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

Notes:

- `HexMapDocumentAdapter.catalog_compatibility_warnings()` and warning helper API were removed.
- Catalog-aware tile resolution no longer accepts fallback config data; unresolved keys produce no tile on normal adapter apply.
- `HexMapDocumentValidator` now reports `document.tile_assignment_missing` for missing terrain defaults or tile assignment keys.
- Editor generation snapshots now attach catalog defaults before validation.
- The old plain `TileMapLayer` numeric editor path is isolated behind `debug_numeric_fallback_enabled`; deleting that UI remains scheduled under `CLEAN-20` / `CLEAN-33`.
- Dependency sweep did not promote new tasks; `CLEAN-13`, `CLEAN-12`, `CLEAN-14`, `CLEAN-31`, and `CLEAN-52` remain `READY`.
- `repair-now`: complete.

### CLEAN-10

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-10_DOCUMENT_CANONICAL_SCHEMA/`
review: `docs/review/autopilot/CLEAN-10_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CLEAN-10_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
  - `docs/api/API_REFERENCE.md`
  - `docs/manual/MANUAL_WORKFLOW.md`
  - `docs/manual/MANUAL_SCRIPTING.md`
  - `docs/review/autopilot/CLEAN-10_SELF_REVIEW_2026-06-07.md`
  - `docs/review/autopilot/CLEAN-10_TEST_RESULT_2026-06-07.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `tests/test_hex_adapter.gd`
  - `tests/test_hex_tile_map_layer.gd`
  - `tests/test_editor_plugin.gd`
  - `tests/test_debug_scenes.gd`
- maturity:
  - `HEADLESS_TEST_COMPLETE`

Notes:

- `HexMapDocumentResource` now exposes only canonical fields and creates metadata by default.
- Document `version`, `map`, `tile_overrides`, `objects`, `labels`, `ensure_v2_defaults()`, `is_v2()`, `v2_schema_fields()`, and `migrate_v1_to_v2()` were removed from current document contract.
- Current API/manual/examples now describe canonical documents; the public v0.2 -> v0.3 migration guide was deleted.
- Intermediate stale test assertions were repaired before the final passing run.
- Dependency sweep promoted `CLEAN-11`, `CLEAN-13`, `CLEAN-12`, and `CLEAN-14` to `READY`; `CLEAN-31` and `CLEAN-52` remain `READY`.
- `repair-now`: complete.

### CLEAN-30

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-30_EDITOR_SCREEN_INVENTORY/`
review: `docs/review/autopilot/CLEAN-30_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CLEAN-30_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md` unchanged; standard Test path used for completion proof
  - `docs/review/roadmap/EDITOR_UX_COMPONENT_INVENTORY_2026-06-07.md`
  - `docs/review/autopilot/CLEAN-30_SELF_REVIEW_2026-06-07.md`
  - `docs/review/autopilot/CLEAN-30_TEST_RESULT_2026-06-07.md`
- major files:
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-30_EDITOR_SCREEN_INVENTORY/`
  - `docs/review/roadmap/EDITOR_UX_COMPONENT_INVENTORY_2026-06-07.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/IMPLEMENTATION_QUEUE.md`
- maturity:
  - `DOCS_COMPLETE`

Notes:

- Inventory classifies current editor UI by user task, not file size.
- Explicit deletion candidates include editable path text, numeric fallback controls, migration hooks, compatibility warning UI, and plain TileMapLayer primary apply.
- Missing or misplaced screen homes are identified for Catalog, Layer Stack, Validation, Object Palette, Seed Lab / QA, and Document Header.
- Dependency sweep promoted `CLEAN-10` and `CLEAN-31` to `READY`; `CLEAN-52` remains `READY`.
- `repair-now`: none.

### CLEAN-00

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot / `autopilot/roadmap-main`
plan: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-00_POLICY_RESET/`
review: `docs/review/autopilot/CLEAN-00_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CLEAN-00_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md` unchanged; standard Test path used for completion proof
  - `docs/review/autopilot/CLEAN-00_SELF_REVIEW_2026-06-07.md`
  - `docs/review/autopilot/CLEAN-00_TEST_RESULT_2026-06-07.md`
- major files:
  - `AGENTS.md`
  - `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
  - `docs/policy/IMPLEMENTATION_POLICY.md`
  - `docs/policy/TEST_DESIGN_POLICY.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/IMPLEMENTATION_QUEUE.md`
  - `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-00_POLICY_RESET/`
- maturity:
  - `DOCS_COMPLETE`

Notes:

- Policy now states `UX合理性 > headless test > compatibility`.
- Compatibility is an exception only when the current CLEAN task explicitly requires it.
- New analog tests are deferred during UI rework.
- Self-review now checks whether old tests distorted UX.
- Dependency sweep promoted `CLEAN-30` and `CLEAN-52` to `READY`.
- `repair-now`: none.

---

## 10. Standard prompt

```md
Goal:
Implement the next CLEAN roadmap task from docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/IMPLEMENTATION_QUEUE.md.

Highest design policy:
- The addon is unpublished. Do not preserve v1/v2 compatibility unless the current CLEAN task explicitly says so.
- Prefer clean UX/API/spec/tests over compatibility.
- UI and API decisions must be based on game-development UX rationality, not headless-test convenience.
- If old headless editor tests preserve bad UI, delete or rewrite those tests.
- Do not create new analog tests. Analog tests are deferred by user instruction.

Process:
1. Read AGENTS.md, the CLEAN roadmap, the queue, and current implementation.
2. Pick the first READY task whose dependencies are complete.
3. Mark it RUNNING.
4. Create or update plan files if needed, but do not stop for approval.
5. Implement clean spec directly.
6. Remove obsolete compatibility code/tests/docs touched by the task.
7. Run relevant tests; if old tests fail because they assert obsolete UI/compatibility, rewrite or delete them.
8. Update docs/TEST.md only for the new clean test contract.
9. Write self-review and update the queue.
```
