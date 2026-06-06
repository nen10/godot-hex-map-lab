# Roadmap Implementation Queue 2026-06-06

作成日: 2026-06-06  
Source roadmap: `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`  
Orchestration: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
Commit policy: `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`

この queue は、人間 validate 済みロードマップを Codex が連続実装するための task 分割である。Plan 作成は承認ゲートではない。各 task は、必要な plan files を作ったら同じ Autopilot run で実装・テスト・self-review・queue 更新まで進める。

---

## 0. Queue operation rules

### status

- `READY`: 依存が満たされた。Codex が次に実装してよい。
- `BACKLOG`: 依存未完了。
- `RUNNING`: 現在の Autopilot run 対象。
- `REPAIR_NOW`: acceptance 未達。次 task へ進まず修正する。
- `BLOCKED_BY_TEST_ENV`: Godot / CI など環境不足で completion proof を作れない。
- `COMPLETE`: acceptance と test proof を満たす。
- `COMPLETE_WITH_BACKLOG`: acceptance は満たし、非blocking follow-up を queue へ追加済み。
- `SUPERSEDED`: 他 task に吸収済み。

### required proof

各 task の完了時、該当行の `proof` に以下を書く。

```text
proof:
  plan: docs/plan/<date>_<TASK_ID>_<slug>/
  review: docs/review/autopilot/<TASK_ID>_SELF_REVIEW_<date>.md
  tests:
    - ./tools/test.sh
  docs:
    - docs/TEST.md
  major files:
    - ...
```

### dependency rule

`dependencies` がすべて `COMPLETE` または `COMPLETE_WITH_BACKLOG` になったら、Codex は `BACKLOG` を `READY` に更新してよい。

---

## 1. Phase 0: Autopilot foundation and baseline

Phase 0 は人間承認ゲートではない。後続実装を迷わせないための実行足場である。

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `AUTO-00` | `COMPLETE` | none | `docs/process/` | Autopilot orchestration docs, queue, repository skill | `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`, `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`, `.agents/skills/hex-map-codex-autopilot/SKILL.md`, `AGENTS.md` | docs-only. Confirm files exist and AGENTS references Autopilot. |
| `P0-01` | `COMPLETE` | `AUTO-00` | `docs/plan/2026-06-06_P0-01_CAPABILITY_MATRIX/` | Current capability matrix and risk register | `docs/review/roadmap/CURRENT_CAPABILITY_MATRIX_2026-06-06.md`, `docs/review/roadmap/RISK_REGISTER_2026-06-06.md` | Docs classify Generate/Edit/Runtime/Document/Test, plain TileMapLayer vs HexTileMapLayer, object/label/overlay schema. No code required. |
| `P0-02` | `COMPLETE` | `P0-01` | `docs/plan/2026-06-06_P0-02_SCHEMA_BOUNDARY_DECISIONS/` | Non-blocking schema boundary decision record | `docs/review/roadmap/SCHEMA_BOUNDARY_DECISIONS_2026-06-06.md` | Decide maintain/migrate/remove for object labels overlays, TileSet/scene/custom data boundaries. No human approval. |
| `P0-03` | `COMPLETE` | `AUTO-00` | `docs/plan/2026-06-06_P0-03_TEST_BASELINE/` | Test baseline and environment report | `docs/review/autopilot/P0-03_TEST_BASELINE_2026-06-06.md` | Run `./tools/test.sh`. If Godot missing, mark `BLOCKED_BY_TEST_ENV`; do not mark implementation phases complete. |

---

## 2. Phase 1: Level Document v2

Goal: `HexMapDocumentResource` をゲーム制作で保存・検査・実行ロードできる level document へ育てる。

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `LD2-01` | `COMPLETE` | `P0-02`, `P0-03` | `docs/plan/2026-06-06_LD2-01_RESOURCE_SCHEMA/` | Level Document v2 typed resource schema | `addons/hex_map_kit/adapter/hex_map_document_resource.gd`, new v2 resource classes if needed, `tests/test_hex_adapter.gd` | v2 fields cover `terrain_layers`, `overlay_layers`, `object_placements`, `labels`, `zones`, `metadata`, `dependencies`; v1 fixtures still load. |
| `LD2-02` | `COMPLETE` | `LD2-01` | `docs/plan/2026-06-06_LD2-02_MIGRATION/` | v1 -> v2 migration helper and compatibility policy | `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`, migration helper file if needed, `tests/test_hex_adapter.gd` | Migration preserves map/tile_overrides/objects/labels/version; has roundtrip tests and missing-field tests. |
| `LD2-03` | `COMPLETE` | `LD2-01` | `docs/plan/2026-06-06_LD2-03_SUMMARY_VALIDATION_SCHEMA/` | Document summary and validation result schema | new `HexMapValidationResult` resource/script, adapter helpers, `tests/test_hex_adapter.gd` | Summary reports cells/walls/floors/objects/labels/zones/warnings/dependencies; validation result serializable and testable. |
| `LD2-04` | `COMPLETE` | `LD2-02`, `LD2-03` | `docs/plan/2026-06-06_LD2-04_ADAPTER_ROUNDTRIP/` | Adapter roundtrip for v2 document | `hex_map_document_adapter.gd`, `hex_tile_map_layer.gd`, `tests/test_hex_adapter.gd`, `tests/test_hex_tile_map_layer.gd` | Roundtrip, payload cleanup, deleted cell cleanup, tile overrides, labels, objects, zones pass. |
| `LD2-05` | `COMPLETE` | `LD2-04` | `docs/plan/2026-06-06_LD2-05_EDITOR_LOAD_SAVE/` | Edit Dock / Generate Dock document v2 load/save integration | `hex_map_edit_tool.gd`, `hex_map_gen_dock.gd`, `tests/test_editor_plugin.gd`, `docs/TEST.md` | Browse/Load/Save/Export/import flows work with v2 while v1 remains compatible. |
| `LD2-06` | `COMPLETE` | `LD2-04` | `docs/plan/2026-06-06_LD2-06_RUNTIME_LOAD_SAMPLE/` | Runtime load helper/sample for level document | `hex_tile_map_layer.gd`, `examples/basic_runtime` later or debug scene, `tests/test_debug_scenes.gd` | Runtime can load v2 document into `HexTileMapLayer`; no editor-only dependency in runtime path. |

---

## 3. Phase 2: Tile Catalog + Layer Stack MVP

Goal: `source_id / atlas_coords` の数値入力を、logical key と layer stack に置き換える。

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `CAT-01` | `COMPLETE` | `LD2-01` | `docs/plan/2026-06-06_CAT-01_CATALOG_RESOURCE/` | `HexTileCatalogResource` and `HexTileCatalogEntry` | new adapter/resource files, sample catalog resource, `tests/test_hex_adapter.gd` | Logical key maps to atlas tile, scene tile, tags, fallback fields. Sample catalog loads. |
| `CAT-02` | `COMPLETE` | `CAT-01` | `docs/plan/2026-06-06_CAT-02_CATALOG_VALIDATION/` | Catalog validation and custom data reader | catalog validation helper, `tests/test_hex_adapter.gd` | Detect missing source, invalid atlas coords, missing scene, missing TileSet, tag/custom data extraction. |
| `CAT-03` | `COMPLETE` | `CAT-01`, `LD2-04` | `docs/plan/2026-06-06_CAT-03_CATALOG_BACKED_ADAPTERS/` | Catalog-backed map/overlay tile adapters | `hex_map_tile_adapter.gd`, `hex_overlay_tile_adapter.gd`, `hex_map_document_adapter.gd`, tests | Floor/wall/overlay item key resolves by catalog key; numeric fallback remains advanced/debug path. |
| `LST-01` | `COMPLETE` | `LD2-01` | `docs/plan/2026-06-06_LST-01_LAYER_STACK_RESOURCE/` | `HexLayerStackResource` and templates | new resource/helper files, `tests/test_hex_tile_map_layer.gd` | Terrain/decoration/object/collision/navigation/overlay/debug roles defined; templates create expected role names. |
| `LST-02` | `COMPLETE` | `LST-01`, `CAT-03` | `docs/plan/2026-06-06_LST-02_APPLY_DOCUMENT_TO_LAYER_STACK/` | `apply_document_to_layer_stack()` primary path | `hex_tile_map_layer.gd`, adapter helpers, `tests/test_hex_tile_map_layer.gd` | v2 document applies to child layers by role; single plain TileMapLayer path remains compatibility path. |
| `CATUI-01` | `COMPLETE` | `CAT-03`, `LST-02`, `LD2-05` | `docs/plan/2026-06-06_CATUI-01_CATALOG_SELECTOR_UI/` | Generate/Edit catalog key selectors and advanced fallback UI | `hex_map_gen_dock.gd`, `hex_map_edit_tool.gd`, `tests/test_editor_plugin.gd` | Floor/Wall/Overlay/Object default assignment uses catalog selector; old spin boxes are advanced fallback. |
| `CAT-04` | `READY` | `CATUI-01` | `docs/plan/2026-06-06_CAT-04_EXISTING_DOCUMENT_COMPATIBILITY/` | Existing document apply compatibility through catalog/layer stack | adapter + editor tests | Existing v1/v2 docs without catalog still display via fallback with warnings, not silent wrong tiles. |

---

## 4. Phase 3: Validation Dashboard

Goal: document / catalog / object / cell の不整合を UI と debug report で検出できるようにする。

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `VAL-01` | `READY` | `LD2-03`, `CAT-02` | `docs/plan/2026-06-06_VAL-01_VALIDATION_ENGINE/` | Validation engine core rules | validation helper, `tests/test_hex_adapter.gd` | Detect outside map, orphan payload, missing catalog, missing tile, missing dependency, object on wall. |
| `VAL-02` | `BACKLOG` | `VAL-01`, `LD2-05` | `docs/plan/2026-06-06_VAL-02_DASHBOARD_UI/` | Validate tab/panel and error list | `hex_map_edit_tool.gd`, maybe shared dashboard script, `tests/test_editor_plugin.gd` | Validate button produces grouped errors/warnings; clicking cell-scoped error updates selected/focus state in headless-testable way. |
| `VAL-03` | `BACKLOG` | `VAL-02` | `docs/plan/2026-06-06_VAL-03_DEBUG_REPORT_INTEGRATION/` | Validation summary in Copy Debug Report | `hex_map_edit_tool.gd`, `hex_map_gen_dock.gd`, `tests/test_editor_plugin.gd` | Debug report includes validation summary without bloating normal status. |
| `VAL-04` | `BACKLOG` | `VAL-01` | `docs/plan/2026-06-06_VAL-04_VALIDATION_RULE_MATRIX/` | Rule matrix fixtures and docs | `tests/test_hex_adapter.gd`, `tests/test_editor_plugin.gd`, `docs/TEST.md` | Each validation rule has at least one failing and passing fixture. |

---

## 5. Phase 4: Gameplay Query Layer MVP

Goal: movement cost / blocker / reachability / range preview を game-facing API として提供する。

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `GAME-01` | `BACKLOG` | `LD2-04`, `VAL-01` | `docs/plan/2026-06-06_GAME-01_MOVEMENT_PROFILE_RESOURCE/` | `HexMovementProfileResource` and gameplay layer data | new resource/core files, `tests/test_hex_core.gd`, `tests/test_hex_adapter.gd` | Movement profile defines passability, costs, blocker keys, default behavior. |
| `GAME-02` | `BACKLOG` | `GAME-01` | `docs/plan/2026-06-06_GAME-02_WEIGHTED_PATH_AND_RANGE/` | Weighted pathfinding and movement range API | `hex_grid.gd` or helper, `hex_tile_map_layer.gd`, tests | Weighted path, blocked cells, profile-specific range, existing unweighted path compatibility. |
| `GAME-03` | `BACKLOG` | `GAME-02`, `VAL-02` | `docs/plan/2026-06-06_GAME-03_DEBUG_OVERLAY/` | Movement/range/debug overlay | `hex_tile_map_layer.gd`, editor/debug scene files, `tests/test_hex_tile_map_layer.gd`, `tests/test_debug_scenes.gd` | Debug overlay can show reachable cells/cost heat data in headless-checkable state. |
| `GAME-04` | `BACKLOG` | `GAME-02`, `VAL-01` | `docs/plan/2026-06-06_GAME-04_PROFILE_REACHABILITY_VALIDATION/` | Profile-specific reachability validation | validation helpers/tests | Important points mutually reachable per movement profile; validation reports profile id. |
| `GAME-05` | `BACKLOG` | `GAME-02`, `LD2-06` | `docs/plan/2026-06-06_GAME-05_RUNTIME_QUERY_SAMPLE/` | Runtime query API sample | `examples/basic_runtime` or debug scene, docs/manual | Runtime script can load document and ask movement/path/range queries. |

---

## 6. Phase 5: Object / Scene Placement MVP

Goal: object mode を marker から object placement / scene placement へ上げる。

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `OBJ-01` | `READY` | `LD2-01`, `CAT-01` | `docs/plan/2026-06-06_OBJ-01_OBJECT_DATABASE_V2/` | `HexObjectDatabaseResource v2` definitions | `hex_object_database_resource.gd`, new definition script if needed, `tests/test_hex_adapter.gd` | Definition has id/display_name/scene_path/tags/default_properties/preview. Existing Array loads through migration/fallback. |
| `OBJ-02` | `BACKLOG` | `OBJ-01`, `LD2-04` | `docs/plan/2026-06-06_OBJ-02_OBJECT_PLACEMENT_SCHEMA/` | Object placement schema in document | document resource/adapter/tests | Placement has object_id/cell/rotation/variant/properties/spawn_condition; cleanup on deleted cell. |
| `OBJ-03` | `BACKLOG` | `OBJ-02`, `LD2-05` | `docs/plan/2026-06-06_OBJ-03_OBJECT_EDITOR_UI/` | Object brush and property editor UI | `hex_map_edit_tool.gd`, tests | Object mode edits typed placements; property table state is saved and undoable. |
| `OBJ-04` | `BACKLOG` | `OBJ-02`, `LST-02` | `docs/plan/2026-06-06_OBJ-04_OBJECT_LAYER_ADAPTER/` | Object layer adapter using scene tile or direct instance prototypes | `hex_tile_map_layer.gd`, object adapter helper, tests | Scene tile prototype and direct instance prototype both work; standard choice documented in policy. |
| `OBJ-05` | `BACKLOG` | `OBJ-03`, `OBJ-04`, `VAL-01` | `docs/plan/2026-06-06_OBJ-05_OBJECT_VALIDATION_RUNTIME_EXPORT/` | Object validation and runtime export policy | validation helper, runtime sample, docs | Detect missing scene, object on wall, duplicate unique object; runtime export keeps authoring/runtime state separate. |

---

## 7. Phase 6: Generation QA / Seed Lab

Goal: 生成結果を validation / score / seed promotion に接続する。

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `QA-01` | `BACKLOG` | `VAL-01`, `LD2-04` | `docs/plan/2026-06-06_QA-01_VALIDATION_SUITE_ON_GENERATION/` | Apply validation suite to generation result | generator/editor helpers, tests | Generated map can be validated before promotion; pass/fail result captured. |
| `QA-02` | `BACKLOG` | `QA-01` | `docs/plan/2026-06-06_QA-02_BATCH_RUNNER_SCORE_TABLE/` | Batch generation runner and score table | `hex_map_gen_dock.gd`, generator helpers, tests | N seeds generate, validation summary and scores sortable/headless-testable. |
| `QA-03` | `BACKLOG` | `QA-02`, `LD2-05` | `docs/plan/2026-06-06_QA-03_SEED_PROMOTION/` | Promote chosen seed to Level Document | generator/editor adapter/tests | Chosen seed creates v2 document with generation snapshot metadata. |
| `QA-04` | `BACKLOG` | `QA-03` | `docs/plan/2026-06-06_QA-04_GOLDEN_SEED_FIXTURES/` | Golden seed tests and preview artifacts | `tests/test_hex_map_generation.gd`, docs/test fixtures | Deterministic scores/fixtures guard important seeds; preview data exists without requiring visual assertion. |

---

## 8. Phase 7: Public Package / Examples

Goal: v2 API に合わせた package、examples、manual、migration guide を作る。

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `PKG-01` | `BACKLOG` | `LD2-06`, `GAME-05`, `OBJ-05` | `docs/plan/2026-06-06_PKG-01_EXAMPLES/` | `examples/basic_runtime` and `examples/editor_workflow` | examples, debug scene tests | Examples load without editor-only errors; test/debug scene checks resource paths. |
| `PKG-02` | `BACKLOG` | `PKG-01`, `CATUI-01`, `VAL-03` | `docs/plan/2026-06-06_PKG-02_DOCS_API_MANUAL_SPLIT/` | API docs and workflow manual split | `docs/api`, `docs/manual`, `README.md` | Docs explain setup, document v2, catalog/layer stack, validation, runtime query. |
| `PKG-03` | `BACKLOG` | `PKG-02` | `docs/plan/2026-06-06_PKG-03_PACKAGE_ADDON/` | package script, manifest test, migration guide | `tools/package_addon.sh`, `dist`, tests | Addon-only zip can be built; manifest excludes dev-only files; migration guide v0.2 -> v0.3 exists. Human check only before public release upload. |

---

## 9. Cross-cutting Editor Architecture Refactor lane

Goal F は「別承認待ちの大改修」ではなく、feature task を通すための companion refactor として queue に置く。Feature implementation を止めるのではなく、巨大 file への増築が acceptance を壊す地点で実行する。

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `ARCH-01` | `COMPLETE` | `LD2-05` | `docs/plan/2026-06-06_ARCH-01_EDITOR_SESSION_STATE/` | Shared editor session state | new editor session script, `hex_map_gen_dock.gd`, `hex_map_edit_tool.gd`, tests | Generate/Edit target/document state sharing has tests; existing target auto behavior maintained. |
| `ARCH-02` | `READY` | `ARCH-01`, `CATUI-01` | `docs/plan/2026-06-06_ARCH-02_GENERATE_DOCK_STATE_EVALUATION_SPLIT/` | Separate Generate Dock state evaluation from UI construction | `hex_map_gen_dock.gd`, tests | Existing Generate Dock headless tests pass; catalog UI additions become smaller. |
| `ARCH-03` | `BACKLOG` | `ARCH-01`, `OBJ-03` | `docs/plan/2026-06-06_ARCH-03_EDIT_TOOL_MUTATION_VIEWPORT_SPLIT/` | Separate Edit Tool mutation and viewport input adapter | `hex_map_edit_tool.gd`, tests | Viewport hit/edit/undo tests pass; object and validation UI can reuse mutation helpers. |
| `ARCH-04` | `BACKLOG` | `VAL-02` | `docs/plan/2026-06-06_ARCH-04_DOCUMENT_INSPECTOR_COMPONENT/` | Document inspector / validation summary component | new editor component, edit/gen dock integration, tests | Validation/dashboard logic is not embedded only in giant dock file. |

Autopilot selection rule:

- If a feature task can be implemented without increasing giant-file coupling, continue feature task.
- If a feature task would add broad state logic to `hex_map_gen_dock.gd` or `hex_map_edit_tool.gd`, run the corresponding `ARCH-*` task first.
- No human approval is required to schedule an `ARCH-*` task when it reduces implementation risk and has test proof.

---

## 10. Dynamic follow-up queue area

Codex appends tasks here when self-review finds `follow-up-ready` work.

Template:

```md
### <TASK-ID> <title>

status: READY | BACKLOG  
dependencies: ...  
source_review: docs/review/autopilot/<...>.md  
plan_dir: docs/plan/<date>_<TASK-ID>_<slug>/

deliverable:
- ...

acceptance / test path:
- ...
```

---

## 11. Current pointer

Current recommended next task: `CAT-04` is READY.

Reason:

- Dependency sweep completed on 2026-06-07 after LST-02 completion.
- `CAT-01` is `COMPLETE`.
- `CAT-02` is `COMPLETE`.
- `CAT-03` is `COMPLETE`.
- `LST-01` is `COMPLETE`.
- `LST-02` is `COMPLETE`.
- `CATUI-01` is `COMPLETE`.
- `CAT-04` is `READY` because `CATUI-01` is `COMPLETE`.
- `VAL-01` is also `READY` because `LD2-03` and `CAT-02` are `COMPLETE`.
- `OBJ-01` is also `READY` because `LD2-01` and `CAT-01` are `COMPLETE`.
- `ARCH-02` is also `READY` because `ARCH-01` and `CATUI-01` are `COMPLETE`.
- Remaining `BACKLOG` tasks still have at least one dependency that is not `COMPLETE` or `COMPLETE_WITH_BACKLOG`.

---

## 12. Completed task proof log

### AUTO-00

status: COMPLETE  
plan: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md` and `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`  
review: `docs/review/autopilot/AUTO-00_SELF_REVIEW_2026-06-06.md`  
test result: `docs/review/autopilot/AUTO-00_TEST_RESULT_2026-06-06.md`

Notes:

- Docs-only foundation created.
- `./tools/test.sh` was attempted but the current environment lacks Godot: `Godot executable not found. Set GODOT_BIN=/path/to/Godot.`
- This is recorded as `known-env-failure`; `P0-03` remains the baseline test task for a Godot-capable environment.

### P0-01

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_P0-01_CAPABILITY_MATRIX/`
review: `docs/review/autopilot/P0-01_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/P0-01_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/review/roadmap/CURRENT_CAPABILITY_MATRIX_2026-06-06.md`
  - `docs/review/roadmap/RISK_REGISTER_2026-06-06.md`
- major files:
  - `docs/plan/2026-06-06_P0-01_CAPABILITY_MATRIX/UX.md`
  - `docs/plan/2026-06-06_P0-01_CAPABILITY_MATRIX/POLICY.md`
  - `docs/plan/2026-06-06_P0-01_CAPABILITY_MATRIX/IMPLEMENTATION_PLAN.md`

Notes:

- Docs-only task; no product code or automated test files were changed.
- `repair-now`: none.

### P0-02

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_P0-02_SCHEMA_BOUNDARY_DECISIONS/`
review: `docs/review/autopilot/P0-02_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/P0-02_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/review/roadmap/SCHEMA_BOUNDARY_DECISIONS_2026-06-06.md`
- major files:
  - `docs/plan/2026-06-06_P0-02_SCHEMA_BOUNDARY_DECISIONS/UX.md`
  - `docs/plan/2026-06-06_P0-02_SCHEMA_BOUNDARY_DECISIONS/POLICY.md`
  - `docs/plan/2026-06-06_P0-02_SCHEMA_BOUNDARY_DECISIONS/IMPLEMENTATION_PLAN.md`

Notes:

- Docs-only task; no product code or automated test files were changed.
- `repair-now`: none.

### P0-03

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_P0-03_TEST_BASELINE/`
review: `docs/review/autopilot/P0-03_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/P0-03_TEST_BASELINE_2026-06-06.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/review/autopilot/P0-03_TEST_BASELINE_2026-06-06.md`
- major files:
  - `docs/plan/2026-06-06_P0-03_TEST_BASELINE/UX.md`
  - `docs/plan/2026-06-06_P0-03_TEST_BASELINE/POLICY.md`
  - `docs/plan/2026-06-06_P0-03_TEST_BASELINE/IMPLEMENTATION_PLAN.md`

Notes:

- Test baseline task; no product code or automated test files were changed.
- `repair-now`: none.

### LD2-01

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_LD2-01_RESOURCE_SCHEMA/`
review: `docs/review/autopilot/LD2-01_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/LD2-01_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
  - `docs/knowledge/DEV_GODOT.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_metadata_resource.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_dependency_resource.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_zone_resource.gd`
  - `tests/test_hex_adapter.gd`

Notes:

- Added typed v2 schema resources while preserving v1 fields.
- Repaired `resource_path` Resource property collision and documented it in `docs/knowledge/DEV_GODOT.md`.
- `repair-now`: none.

### LD2-02

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_LD2-02_MIGRATION/`
review: `docs/review/autopilot/LD2-02_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/LD2-02_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
  - `docs/knowledge/DEV_GODOT.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
  - `tests/test_hex_adapter.gd`

Notes:

- Added `HexMapDocumentAdapter.migrate_v1_to_v2()`.
- Migration preserves legacy fields and records source version while filling typed v2 resources.
- `repair-now`: none.

### LD2-03

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_LD2-03_SUMMARY_VALIDATION_SCHEMA/`
review: `docs/review/autopilot/LD2-03_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/LD2-03_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_map_validation_result.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
  - `tests/test_hex_adapter.gd`

Notes:

- Added document summary helper and serializable `HexMapValidationResult` schema.
- Full validation engine rules remain in `VAL-01`.
- `repair-now`: none.

### LD2-04

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_LD2-04_ADAPTER_ROUNDTRIP/`
review: `docs/review/autopilot/LD2-04_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/LD2-04_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
  - `tests/test_hex_adapter.gd`
  - `tests/test_hex_tile_map_layer.gd`

Notes:

- Added v2-aware map and payload normalization helpers in `HexMapDocumentAdapter`.
- Added v2 deleted-cell cleanup for terrain assignments, overlay assignments, object placements, label placements, and zones.
- `HexTileMapLayer.apply_document()` now accepts pure v2 documents whose map lives on a terrain layer.
- `repair-now`: none.

### LD2-05

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_LD2-05_EDITOR_LOAD_SAVE/`
review: `docs/review/autopilot/LD2-05_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/LD2-05_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `tests/test_editor_plugin.gd`

Notes:

- Edit Dock now normalizes loaded/imported/target-derived documents through the v2 migration helper.
- Save/export reads v2 map state through adapter helpers and no longer overwrites loaded v2 documents with target-side v1 snapshots.
- Adapter setters now mirror tile/object/label edits into typed v2 payload resources while preserving legacy arrays.
- `repair-now`: none.

### LD2-06

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_LD2-06_RUNTIME_LOAD_SAMPLE/`
review: `docs/review/autopilot/LD2-06_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/LD2-06_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
  - `tests/test_debug_scenes.gd`

Notes:

- Added runtime-safe `HexTileMapLayer.load_document_path()` and boolean `load_document_resource()` helpers.
- Added headless debug-scene coverage for loading a v2 document path into `HexTileMapLayer`.
- Public polished examples remain queued in `PKG-01`.
- `repair-now`: none.

### ARCH-01

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_ARCH-01_EDITOR_SESSION_STATE/`
review: `docs/review/autopilot/ARCH-01_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/ARCH-01_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
  - `addons/hex_map_kit/plugin.gd`
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `tests/test_editor_plugin.gd`

Notes:

- Added shared editor session state for target/document/path references.
- Plugin now wires one session instance into Generate Dock and Edit Dock.
- Existing target auto behavior remains covered by prior tests.
- `repair-now`: none.

### CAT-01

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_CAT-01_CATALOG_RESOURCE/`
review: `docs/review/autopilot/CAT-01_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CAT-01_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd`
  - `addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd`
  - `addons/hex_map_kit/assets/sample_hex_tile_catalog.tres`
  - `tests/test_hex_adapter.gd`

Notes:

- Added typed tile catalog and catalog entry resources.
- Sample catalog loads and includes atlas, overlay, and scene-style entries.
- Catalog tests cover logical key lookup, scene tile fields, tags, fallback fields, duplicate key determinism, and saved resource roundtrip.
- `repair-now`: none.

### CAT-02

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_CAT-02_CATALOG_VALIDATION/`
review: `docs/review/autopilot/CAT-02_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CAT-02_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd`
  - `tests/test_hex_adapter.gd`

Notes:

- Added catalog validation helper returning `HexMapValidationResult`.
- Validation detects missing TileSet, missing source, invalid atlas coordinates, missing scene path, duplicate keys, and missing keys.
- Added tag and TileSet custom-data extraction by catalog key.
- `repair-now`: none.

### CAT-03

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_CAT-03_CATALOG_BACKED_ADAPTERS/`
review: `docs/review/autopilot/CAT-03_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CAT-03_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_overlay_tile_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
  - `tests/test_hex_adapter.gd`

Notes:

- Added optional catalog-backed floor/wall default resolution in `HexMapTileAdapter`.
- Added overlay item-key to catalog-key conversion in `HexOverlayTileAdapter`.
- Added catalog options and per-entry `catalog_key` resolution to `HexMapDocumentAdapter`.
- Numeric fallback remains covered by tests for missing catalog keys.
- `repair-now`: none.

### LST-01

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_LST-01_LAYER_STACK_RESOURCE/`
review: `docs/review/autopilot/LST-01_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/LST-01_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_layer_stack_entry_resource.gd`
  - `addons/hex_map_kit/adapter/hex_layer_stack_resource.gd`
  - `tests/test_hex_tile_map_layer.gd`

Notes:

- Added typed layer stack entry and stack resources.
- Standard template defines terrain, decoration, object, collision, navigation, overlay, and debug roles.
- Minimal runtime template maps current runtime terrain/overlay/debug child roles.
- Resource save/load roundtrip is covered by `tests/test_hex_tile_map_layer.gd`.
- `repair-now`: none.

### LST-02

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_LST-02_APPLY_DOCUMENT_TO_LAYER_STACK/`
review: `docs/review/autopilot/LST-02_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/LST-02_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
  - `tests/test_hex_tile_map_layer.gd`

Notes:

- Added `HexTileMapLayer.apply_document_to_layer_stack()` with explicit stack resource selection and a default minimal runtime template.
- Standard layer stacks now create/reuse child nodes by role and route terrain/overlay drawing to those role children.
- Plain `TileMapLayer` document apply remains covered as the compatibility path.
- `repair-now`: none.

### CATUI-01

status: COMPLETE
completed_by: 2026-06-07 / Codex Autopilot
plan: `docs/plan/2026-06-06_CATUI-01_CATALOG_SELECTOR_UI/`
review: `docs/review/autopilot/CATUI-01_SELF_REVIEW_2026-06-07.md`
test result: `docs/review/autopilot/CATUI-01_TEST_RESULT_2026-06-07.md`

proof:

- tests:
  - `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- docs:
  - `docs/TEST.md`
- major files:
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `tests/test_editor_plugin.gd`

Notes:

- Generate Dock now exposes floor/wall catalog selectors and per-overlay-item catalog selectors.
- Edit Dock now exposes default floor/wall catalog selectors, mode-specific tile payload selectors, and an object assignment catalog selector.
- Existing numeric spin boxes remain visible and tested as advanced fallback.
- `repair-now`: none.
