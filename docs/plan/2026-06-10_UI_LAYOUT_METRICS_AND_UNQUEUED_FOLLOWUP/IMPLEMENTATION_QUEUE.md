# UI Layout Metrics And Unqueued Workspace Follow-up Implementation Queue 2026-06-10

作成日: 2026-06-10
Roadmap: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ROADMAP.md`
Source feedbacks:
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/_feedbacks/UI_LAYOUT_METRIC_TEST_PROCESS_ROADMAP_2026-06-10.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/_feedbacks/UNQUEUED_REQUIREMENTS_EXTRACT_2026-06-10.md`
Queue design policy: `docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md`
Operation process: `docs/process/QUEUE_OPERATION_RULES.md`
Autopilot process: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
Commit process: `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`

この queue は、UI Layout Metric Test process と未queue化要件抽出を、Codex autopilot が実装・検証・self-review・queue update できる task slice に分割したものである。

---

## 0. Queue operation notes

- status 更新、dependency sweep、proof 記録は `docs/process/QUEUE_OPERATION_RULES.md` に従う。
- `READY` task は plan files を作成して実装まで進める。Plan 作成は承認ゲートではない。
- 大きな task は `docs/policy/PLANNING_POLICY.md` に従い `SUB_TASKS.md` で分解する。
- UI task の completion proof は UI metric / state / screen contract に接続する。headless API availability だけで `COMPLETE` にしない。
- 新規 analog test は作らない。
- `dist` freshness は通常テスト化しない。final packaging task でのみ再生成する。

---

## 1. Phase M0: Feedback adoption / process guardrails

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `NEXT-00` | `COMPLETE` | none | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/NEXT-00_ADOPT_UI_METRIC_AND_UNQUEUED_FEEDBACKS/` | Feedback adoption proof, roadmap, and queue source-of-truth | `ROADMAP.md`, `IMPLEMENTATION_QUEUE.md`, feedback docs | Both feedback files are represented in the roadmap and queue; intentional non-queue items are recorded; `./tools/test.sh` passed. |
| `PROCESS-10` | `COMPLETE` | `NEXT-00` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-10_COMPLEXITY_CLASS_FOR_TASK_PLANS/` | Complexity class for task plans | `docs/policy/PLANNING_POLICY.md`, plan templates, review docs | C1-C5 complexity classes exist; `SUB_TASKS.md` template has complexity header; C4/C5 require candidate matrix, fallback table, and state table. |
| `PROCESS-11` | `COMPLETE` | `PROCESS-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-11_PHASE_REVIEW_MATRIX/` | Phase review matrix process | `docs/process/QUEUE_OPERATION_RULES.md`, review template docs | Phase completion records task score, debt, evidence, and next readiness; prose-only defer is converted to queue candidate. |
| `PROCESS-12` | `COMPLETE` | `PROCESS-11` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-12_FALLBACK_LEDGER/` | Fallback / mirror / debug ledger | `docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md`, planning/review docs | fallback, mirror, legacy, debug, sample, and manual override entries have owner/status/removal condition/test proof. |
| `PROCESS-13` | `COMPLETE` | `PROCESS-12` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-13_PLAN_EXECUTION_BOUNDARY/` | Plan/execution proof boundary | planning policy, self-review templates, queue proof docs | `IMPLEMENTATION_PLAN.md` stays pre-execution; executed checklist/deviation moves to self-review or execution log. |

---

## 2. Phase M1: UI metric contract foundation

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `UI-METRIC-00` | `COMPLETE` | `PROCESS-12` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-00_WORKSPACE_UI_CONTRACT/` | Workspace UI metric contract | `docs/ui/WORKSPACE_UI_CONTRACT.md`, docs/tests notes | Each tab has purpose, required components, forbidden visible text, and metric thresholds; Resource row/button/debug/sample contracts are defined. |
| `UI-METRIC-01` | `COMPLETE` | `UI-METRIC-00` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-01_WORKSPACE_STATE_MATRIX/` | Workspace state matrix | `docs/ui/WORKSPACE_STATE_MATRIX.md` | no selected node, selected node without resources, selected with resources, sample on/off, generate preview, validation errors, QA, Export, Settings states define expected and forbidden visible output. |
| `UI-METRIC-02` | `COMPLETE` | `UI-METRIC-00` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-02_STATIC_UI_AUDIT/` | Static UI audit tool | `tools/ui_static_audit.py`, docs/TEST.md | Detects suspicious buttons without pressed connection, forbidden button text, visible debug label patterns, generic ResourcePicker patterns, and tab constructor without ScrollContainer suspicion. |
| `UI-METRIC-03` | `COMPLETE` | `UI-METRIC-00`, `UI-METRIC-01` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-03_LAYOUT_SNAPSHOT_COLLECTOR/` | Runtime layout snapshot collector | `addons/hex_map_kit/editor/testing/`, `tests/test_workspace_layout_metrics.gd` | Workspace can be built across scenarios/sizes; visible Control rect/minimum/text/base_type/tooltip/scroll parent/metadata can be serialized to JSON; report only, not fail gate. |
| `UI-METRIC-04` | `COMPLETE` | `UI-METRIC-03` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-04_LAYOUT_METRIC_EVALUATOR_WARN_ONLY/` | Layout metric evaluator in warn-only mode | metric evaluator, layout metric tests, docs/TEST.md | text truncation, resource row, scroll, dead area, debug leakage, no-op, picker specificity, and state contradiction produce WARN report without failing tests. |

---

## 3. Phase M2: UI metric acceptance gates

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `UI-METRIC-05` | `COMPLETE` | `UI-METRIC-04` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-05_P0_ACCEPTANCE_GATE/` | P0 UI metric acceptance gate | metric evaluator, tests, docs/TEST.md | visible no-op button, missing required scroll, state contradiction, sample fallback in production, debug leakage, required generic Resource picker, and unreachable primary action fail P0. |
| `UI-METRIC-06` | `COMPLETE` | `UI-METRIC-05` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-06_P1_ACCEPTANCE_GATE/` | P1 UI metric acceptance gate | metric evaluator, tests, docs/TEST.md | resource row compression, normal width label truncation, large dead area, disabled action without tooltip, and summary-only task tab are P1 fail/report conditions. |
| `UI-METRIC-07` | `COMPLETE` | `UI-METRIC-05` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-07_TEST_SH_INTEGRATION/` | P0 metric integration in standard tests | `tools/test.sh`, metric report output docs | `tools/test.sh` runs P0 gate; P1 can stay separate initially; JSON/MD report is written under `.godot_user/ui-metrics/<run-id>/`. |
| `UI-METRIC-08` | `COMPLETE` | `UI-METRIC-05`, `PROCESS-13` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-08_AUTOPILOT_ACCEPTANCE_TEMPLATE_UPDATE/` | Autopilot UI acceptance template update | policy/process docs, self-review templates | UI task self-review references UI metric report; UI task completion includes P0 failures = 0. |

---

## 4. Phase M3: P0 UI architecture / performance debt

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `ARCH-NEXT-10` | `COMPLETE` | `UI-METRIC-05` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-10_PHYSICAL_WORKSPACE_UI_NODE_EXTRACTION/` | Physical Workspace UI node construction extraction | `HexMapWorkspace`, screen component scripts, tests | Workspace is tab host/context/dispatcher; screen-specific UI node construction moves to screen component classes; screen contract tests cover class ownership. |
| `ARCH-NEXT-11` | `COMPLETE` | `UI-METRIC-05` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-11_GENERATE_DOCK_INTERNAL_COMPONENT_SPLIT/` | Generate Dock internal component split | `hex_map_gen_dock.gd`, Generate components, tests | Generate run controls, profile/source controls, preview/result summary, output/apply/save controls split; `HexMapGenDock` orchestrates state binding. |
| `CAT-NEXT-10` | `COMPLETE` | `UI-METRIC-05` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/CAT-NEXT-10_CATALOG_EDITOR_COMPONENT_EXTRACTION/` | Catalog editor component extraction | Catalog screen/components, EditTool helper cleanup, tests | Catalog entry list/detail/create/validate is dedicated component; Paint/EditTool no longer own normal Catalog UI responsibility. |
| `PERF-NEXT-10` | `COMPLETE` | `UI-METRIC-05` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PERF-NEXT-10_CHUNKED_TILEMAP_APPLY_IMPLEMENTATION/` | Chunked TileMap apply implementation | apply paths, progress/busy state, tests | Target apply scope is explicit; apply advances by chunks; progress/busy state and cancel/interrupt consistency are defined and tested. |

---

## 5. Phase M4: P1 screen polish and visual work surfaces

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `GEN-NEXT-10` | `COMPLETE` | `ARCH-NEXT-11` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GEN-NEXT-10_GENERATE_TAB_LAYOUT_REDESIGN/` | Full Generate tab layout redesign | Generate components, UI metric tests | Input/Profile/Preview/Apply/Save/Performance state are visually separated; reload/save/apply purpose is clear. |
| `GEN-NEXT-11` | `COMPLETE` | `GEN-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GEN-NEXT-11_GENERATE_QA_PREVIEW_THUMBNAILS/` | Generate / QA preview thumbnails | Generate/QA preview components, cache/budget tests | Generate candidate thumbnail and QA score row preview are connected; thumbnail is from project document/candidate data, not sample fallback. |
| `CAT-NEXT-11` | `COMPLETE` | `CAT-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/CAT-NEXT-11_CATALOG_TILE_SCENE_PREVIEW_UI/` | Rich tile / scene preview UI | Catalog entry detail, TileSet/scene preview tests | Atlas tile and scene preview render in detail; invalid/missing preview uses badge/tooltip. |
| `SCREEN-NEXT-10` | `COMPLETE` | `ARCH-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/SCREEN-NEXT-10_RESOURCES_LAYERS_EXPORT_VISUAL_REDESIGN/` | Rich Resources / Layers / Export visual redesign | Resources/Layers/Export screens, tests | Resources, Layers, and Export become clearer task surfaces for node/document/dependency, role tree, and runtime handoff state. |
| `LAYER-NEXT-10` | `COMPLETE` | `SCREEN-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/LAYER-NEXT-10_LAYER_ROLE_EDITOR/` | Fine-grained Layer role editor | Layer screen/resource/tests | Role visible/locked/z-index/writable source can be edited and reflected in LayerStack/selected node state. |
| `PAINT-NEXT-10` | `COMPLETE` | `SCREEN-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PAINT-NEXT-10_VIEWPORT_AFFORDANCE_POLISH/` | Paint viewport affordance polish | Paint tab, viewport adapter, tests | Brush cursor, selected cell, target layer, mode, and last edit feedback sync between viewport and Paint tab. |
| `VAL-NEXT-10` | `COMPLETE` | `UI-METRIC-05` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/VAL-NEXT-10_VALIDATE_RICH_ISSUE_TABLE_ACTIONS/` | Rich Validate issue table and actions | Validate screen, validation dashboard, tests | Issue table has severity/domain/scope/target/suggestion columns and only real per-issue actions. |
| `QA-NEXT-10` | `COMPLETE` | `GEN-NEXT-11` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/QA-NEXT-10_SCORE_TABLE_VISUAL_REDESIGN/` | QA scored table visual redesign | QA screen/table/tests | Seed rows, score columns, validation status, selected seed, preview, and promotion state are easy to compare. |
| `SETTINGS-NEXT-10` | `COMPLETE` | `UI-METRIC-05` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/SETTINGS-NEXT-10_SETTINGS_GROUPING_TOGGLE_STYLING/` | Settings grouping and toggle styling | Settings/sample panels, tests | Sample Learning, Debug, Project Defaults, and UI Preferences are separated; booleans use toggles/checks with tooltip detail. |
| `SAMPLE-NEXT-10` | `COMPLETE` | `SETTINGS-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/SAMPLE-NEXT-10_SAMPLE_DETAIL_DRAWER/` | Sample detail drawer | Settings sample detail UI/tests | Sample asset type, dependencies, duplicate target, and learning use are inspectable without injecting samples into production flow. |

---

## 6. Phase M5: State / profile / generation pipeline debt

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `PERF-NEXT-11` | `COMPLETE` | `PERF-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PERF-NEXT-11_LARGE_MAP_VALIDATION_PROGRESS/` | Large-map validation progress | validator/progress state/tests | Validation traversal reports phase/progress and connects to Validate/Generate busy state. |
| `GENPIPE-NEXT-10` | `COMPLETE` | `GEN-NEXT-11` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GENPIPE-NEXT-10_GENERATION_RESULT_RESOURCE_AND_REPLAY_API/` | GenerationResultResource and replay API | new Resource/API/tests | primary/overlay/filter/candidate/validation result scope is defined; Generate/QA can replay/promote result resources. |
| `GENPIPE-NEXT-20` | `COMPLETE` | `GENPIPE-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GENPIPE-NEXT-20_PIPELINE_GRAPH_UI_RESEARCH_AND_SPIKE/` | Pipeline graph UI research/spike | review docs/prototype if needed | Resource pass / linear pipeline / node graph options are updated; pass graph is either scoped or explicitly rejected. |
| `PROFILE-NEXT-10` | `COMPLETE` | `UI-METRIC-05` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROFILE-NEXT-10_CONCRETE_PROFILE_BEHAVIOR_SCHEMAS/` | Concrete profile behavior schemas | profile Resources, editors/tests | Validation Suite, Generation Profile, and Export Profile gain real behavior schemas and editor/screen connections. |
| `STATE-NEXT-10` | `COMPLETE` | `UI-METRIC-05` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/STATE-NEXT-10_ROOT_REDUCER_EVENT_MODEL/` | Root reducer / event model expansion | dispatcher/root state/tests | Workspace events are typed; reducer results, side effects, UI state update, and debug report proof are separated. |
| `STATE-NEXT-11` | `READY` | `STATE-NEXT-10`, `ARCH-NEXT-11` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/STATE-NEXT-11_GENERATION_PRIVATE_FLAG_MIRROR_RETIREMENT/` | Generation private flag mirror retirement | Generate run state/dock/tests | `_generation_*` mirror inventory exists; replaced fields are removed or read-only; removal conditions and tests are recorded. |

---

## 7. Phase M6: Runtime extraction / tests / release decision

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path |
|---|---|---|---|---|---|---|
| `ARCH-NEXT-20` | `COMPLETE` | `ARCH-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION/` | Object layer rendering extraction | HexTileMapLayer/object layer adapter/tests | Object placement rendering/runtime instancing boundary is separated; `HexTileMapLayer` remains coordinator. |
| `ARCH-NEXT-21` | `BACKLOG` | `ARCH-NEXT-20` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-21_GAMEPLAY_QUERY_SERVICE_EXTRACTION/` | Gameplay query service extraction | path/range/connectivity services/tests | Runtime query helpers move to service/facade boundary; runtime samples use service path. |
| `ARCH-NEXT-22` | `BACKLOG` | `ARCH-NEXT-20` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-22_DEBUG_OVERLAY_RENDERER_EXTRACTION/` | Debug overlay renderer extraction | debug overlay/validation focus/tests | Debug overlay rendering is separated from normal gameplay rendering and connects to Validate/debug report paths. |
| `TEST-NEXT-10` | `READY` | `UI-METRIC-08` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/TEST-NEXT-10_CONTINUE_EDITOR_TEST_FILE_SPLIT/` | Continue editor integration test split | tests/test_editor_plugin.gd, new test files, tools/test.sh | Remaining integration tests split by feature family; `test_editor_plugin.gd` becomes workflow smoke; no old private widget shape expansion. |
| `EXPORT-NEXT-10` | `READY` | `SCREEN-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/EXPORT-NEXT-10_PACKAGE_BUILD_UI_DECISION/` | Package build UI product decision | Export docs/screen/process docs | Decide whether package build belongs in editor Export UI or remains process-only; manual/process are updated accordingly. |
| `DOC-NEXT-90` | `BACKLOG` | `UI-METRIC-08`, `TEST-NEXT-10`, `EXPORT-NEXT-10` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/DOC-NEXT-90_MANUAL_AND_PROCESS_UPDATE/` | Manual/process update for metric and follow-up work | manuals, docs/TEST.md, README.md | Manuals explain UI metric gates, new surfaces, fallback ledger, and sample/debug boundaries; no analog test is added. |
| `PROC-NEXT-90` | `BACKLOG` | `DOC-NEXT-90` | `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROC-NEXT-90_FINAL_DIST_REGENERATION/` | Final dist regeneration | `tools/package_addon.sh`, `dist/`, self-review/test-result docs | `tools/package_addon.sh` runs; manifest/zip match current addon tree; dist freshness remains outside normal test gate. |

---

## 8. Dynamic follow-up area

Codex appends `follow-up-ready` work here when self-review finds nonblocking work.

### PROFILE-NEXT-11 Integrate profile behavior schemas into engine behavior

status: READY
dependencies: PROFILE-NEXT-10
source_review: docs/review/autopilot/PROFILE-NEXT-10_SELF_REVIEW_2026-06-13.md
plan_dir: docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROFILE-NEXT-11_PROFILE_ENGINE_INTEGRATION/

depth: integrated

context:
- PROFILE-NEXT-10 added concrete behavior schemas + screen exposure only (depth: surface).
- A competing dual-run draft (opencode / DeepSeek) demonstrated real engine wiring for the
  validation suite. That draft was rejected overall (no tests, scope + queue-integrity
  violations) but the wiring approach is sound and is harvested here.

deliverable:
- `HexMapDocumentValidator` consumes `HexValidationRuleSuiteResource` to skip disabled rules
  and apply severity overrides (reference approach below).
- Generation flow consumes `HexGenerationProfileResource.generation_options()` for seed/shape/terrain.
- Export flow consumes `HexExportProfileResource.export_options()` for output type / inclusion flags.
- Every integration is null-safe: an absent profile keeps current default behavior.

reference approach (validation suite, harvested from the rejected draft):
```gdscript
# validate_document(): run after issues are collected, before _update_counts()
_apply_validation_rule_suite(result, options)

static func _apply_validation_rule_suite(result, options: Dictionary) -> void:
    var suite = options.get("validation_rule_suite", null)
    if suite == null or not suite.has_method("rule_enabled"):
        return
    var filtered: Array = []
    for issue in result.issues:
        var rule_id: String = str(issue.get("rule_id", ""))
        if rule_id != "" and not suite.rule_enabled(rule_id):
            continue
        var sev: String = str(suite.rule_severity(rule_id, ""))
        if sev != "":
            issue["severity"] = sev
        filtered.append(issue)
    result.issues = filtered
```

note: align method names to the merged PROFILE-NEXT-10 API
(`rule_severity()` / `generation_options()` / `export_options()`), not the draft's
`severity_for_rule()`.

acceptance / test path:
- Tests prove a disabled rule is dropped and a severity override is applied per engine path.
- Null-profile regression test proves default behavior is unchanged.
- `./tools/test.sh` ; `python3 tools/verify_task.py --task PROFILE-NEXT-11 --head <branch>`

Template:

```md
### <TASK-ID> <title>

status: READY | BACKLOG
dependencies: ...
source_review: docs/review/autopilot/<...>.md
plan_dir: docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/<TASK-ID>_<slug>/

deliverable:
- ...

acceptance / test path:
- ...
```

---

## 9. Current pointer

Current recommended next task: `ARCH-NEXT-20`.

Reason:

- `NEXT-00` is complete.
- `PROCESS-10` is complete.
- `PROCESS-11` is complete.
- `PROCESS-12` is complete.
- Phase M0 tasks are complete.
- `UI-METRIC-00` is complete.
- `UI-METRIC-01` is complete.
- `UI-METRIC-02` is complete.
- `UI-METRIC-03` is complete.
- `UI-METRIC-04` is complete.
- `UI-METRIC-05` is complete.
- `UI-METRIC-06` is complete.
- `UI-METRIC-07` is complete.
- `UI-METRIC-08` is complete.
- Phase M2 review is recorded at `docs/review/roadmap/UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP_M2_PHASE_REVIEW_2026-06-10.md`.
- `ARCH-NEXT-10` is complete.
- `ARCH-NEXT-11` is complete.
- `CAT-NEXT-10` is complete.
- `PERF-NEXT-10` is complete.
- Phase M3 review is recorded at `docs/review/roadmap/UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP_M3_PHASE_REVIEW_2026-06-10.md`.
- `GEN-NEXT-10` is complete.
- `GEN-NEXT-11` is complete.
- `CAT-NEXT-11` is complete.
- `SCREEN-NEXT-10` is complete.
- `LAYER-NEXT-10` is complete.
- `PAINT-NEXT-10` is complete.
- `VAL-NEXT-10` is complete.
- `QA-NEXT-10` is complete.
- `SETTINGS-NEXT-10` is complete.
- `SAMPLE-NEXT-10` is complete.
- Phase M4 review is recorded at `docs/review/roadmap/UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP_M4_PHASE_REVIEW_2026-06-10.md`.
- `PERF-NEXT-11` is complete.
- `GENPIPE-NEXT-10` is complete.
- `GENPIPE-NEXT-20` is complete.
- `PROFILE-NEXT-10` is complete.
- `STATE-NEXT-10` is COMPLETE because `UI-METRIC-05` is complete.
- `ARCH-NEXT-20` is READY because `ARCH-NEXT-10` is complete.
- `EXPORT-NEXT-10` is READY because `SCREEN-NEXT-10` is complete.
- `TEST-NEXT-10` remains READY because `UI-METRIC-08` is complete.

---

## 10. Completed task proof log

### NEXT-00 Adopt UI metric and unqueued feedbacks

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/NEXT-00_ADOPT_UI_METRIC_AND_UNQUEUED_FEEDBACKS/`
  review: `docs/review/autopilot/NEXT-00_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ROADMAP.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/NEXT-00_ADOPT_UI_METRIC_AND_UNQUEUED_FEEDBACKS/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/NEXT-00_ADOPT_UI_METRIC_AND_UNQUEUED_FEEDBACKS/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/NEXT-00_ADOPT_UI_METRIC_AND_UNQUEUED_FEEDBACKS/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/NEXT-00_ADOPT_UI_METRIC_AND_UNQUEUED_FEEDBACKS/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/NEXT-00_TEST_RESULT_2026-06-10.md`

### PROCESS-10 Complexity class for task plans

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-10_COMPLEXITY_CLASS_FOR_TASK_PLANS/`
  review: `docs/review/autopilot/PROCESS-10_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/policy/PLANNING_POLICY.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-10_COMPLEXITY_CLASS_FOR_TASK_PLANS/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-10_COMPLEXITY_CLASS_FOR_TASK_PLANS/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-10_COMPLEXITY_CLASS_FOR_TASK_PLANS/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-10_COMPLEXITY_CLASS_FOR_TASK_PLANS/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/PROCESS-10_TEST_RESULT_2026-06-10.md`

### PROCESS-11 Phase review matrix process

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-11_PHASE_REVIEW_MATRIX/`
  review: `docs/review/autopilot/PROCESS-11_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/process/QUEUE_OPERATION_RULES.md`
    - `docs/review/roadmap/PHASE_REVIEW_MATRIX_TEMPLATE.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-11_PHASE_REVIEW_MATRIX/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-11_PHASE_REVIEW_MATRIX/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-11_PHASE_REVIEW_MATRIX/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-11_PHASE_REVIEW_MATRIX/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/PROCESS-11_TEST_RESULT_2026-06-10.md`

### PROCESS-12 Fallback / mirror / debug ledger

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-12_FALLBACK_LEDGER/`
  review: `docs/review/autopilot/PROCESS-12_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-12_FALLBACK_LEDGER/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-12_FALLBACK_LEDGER/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-12_FALLBACK_LEDGER/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-12_FALLBACK_LEDGER/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/PROCESS-12_TEST_RESULT_2026-06-10.md`

### PROCESS-13 Plan / execution proof boundary

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-13_PLAN_EXECUTION_BOUNDARY/`
  review: `docs/review/autopilot/PROCESS-13_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/PROCESS-13_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/policy/PLANNING_POLICY.md`
    - `docs/process/QUEUE_OPERATION_RULES.md`
    - `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
    - `docs/review/autopilot/SELF_REVIEW_TEMPLATE.md`
    - `docs/review/roadmap/UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP_M0_PHASE_REVIEW_2026-06-10.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-13_PLAN_EXECUTION_BOUNDARY/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-13_PLAN_EXECUTION_BOUNDARY/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-13_PLAN_EXECUTION_BOUNDARY/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-13_PLAN_EXECUTION_BOUNDARY/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/PROCESS-13_TEST_RESULT_2026-06-10.md`

### UI-METRIC-00 Workspace UI metric contract

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-00_WORKSPACE_UI_CONTRACT/`
  review: `docs/review/autopilot/UI-METRIC-00_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/UI-METRIC-00_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/ui/WORKSPACE_UI_CONTRACT.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-00_WORKSPACE_UI_CONTRACT/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-00_WORKSPACE_UI_CONTRACT/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-00_WORKSPACE_UI_CONTRACT/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-00_WORKSPACE_UI_CONTRACT/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/UI-METRIC-00_TEST_RESULT_2026-06-10.md`

### UI-METRIC-01 Workspace state matrix

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-01_WORKSPACE_STATE_MATRIX/`
  review: `docs/review/autopilot/UI-METRIC-01_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/UI-METRIC-01_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/ui/WORKSPACE_STATE_MATRIX.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-01_WORKSPACE_STATE_MATRIX/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-01_WORKSPACE_STATE_MATRIX/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-01_WORKSPACE_STATE_MATRIX/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-01_WORKSPACE_STATE_MATRIX/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/UI-METRIC-01_TEST_RESULT_2026-06-10.md`

### UI-METRIC-02 Static UI audit tool

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-02_STATIC_UI_AUDIT/`
  review: `docs/review/autopilot/UI-METRIC-02_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/UI-METRIC-02_SELF_REVIEW_2026-06-10.md`
  tests:
    - `python3 tools/ui_static_audit.py`
    - `./tools/test.sh`
  docs:
    - `tools/ui_static_audit.py`
    - `docs/TEST.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-02_STATIC_UI_AUDIT/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-02_STATIC_UI_AUDIT/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-02_STATIC_UI_AUDIT/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-02_STATIC_UI_AUDIT/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/UI-METRIC-02_TEST_RESULT_2026-06-10.md`

### UI-METRIC-03 Runtime layout snapshot collector

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-03_LAYOUT_SNAPSHOT_COLLECTOR/`
  review: `docs/review/autopilot/UI-METRIC-03_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/UI-METRIC-03_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/testing/hex_ui_layout_snapshot_collector.gd`
    - `addons/hex_map_kit/editor/testing/hex_ui_state_scenario_builder.gd`
    - `tests/test_workspace_layout_metrics.gd`
    - `tools/test.sh`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-03_LAYOUT_SNAPSHOT_COLLECTOR/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-03_LAYOUT_SNAPSHOT_COLLECTOR/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-03_LAYOUT_SNAPSHOT_COLLECTOR/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-03_LAYOUT_SNAPSHOT_COLLECTOR/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/UI-METRIC-03_TEST_RESULT_2026-06-10.md`

### UI-METRIC-04 Layout metric evaluator warn-only

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-04_LAYOUT_METRIC_EVALUATOR_WARN_ONLY/`
  review: `docs/review/autopilot/UI-METRIC-04_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/UI-METRIC-04_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd`
    - `tests/test_workspace_layout_metric_evaluator.gd`
    - `tools/test.sh`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-04_LAYOUT_METRIC_EVALUATOR_WARN_ONLY/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-04_LAYOUT_METRIC_EVALUATOR_WARN_ONLY/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-04_LAYOUT_METRIC_EVALUATOR_WARN_ONLY/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-04_LAYOUT_METRIC_EVALUATOR_WARN_ONLY/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/UI-METRIC-04_TEST_RESULT_2026-06-10.md`

### UI-METRIC-05 P0 acceptance gate

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-05_P0_ACCEPTANCE_GATE/`
  review: `docs/review/autopilot/UI-METRIC-05_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/UI-METRIC-05_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd`
    - `tests/test_workspace_layout_metric_evaluator.gd`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-05_P0_ACCEPTANCE_GATE/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-05_P0_ACCEPTANCE_GATE/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-05_P0_ACCEPTANCE_GATE/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-05_P0_ACCEPTANCE_GATE/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/UI-METRIC-05_TEST_RESULT_2026-06-10.md`

### UI-METRIC-06 P1 acceptance gate

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-06_P1_ACCEPTANCE_GATE/`
  review: `docs/review/autopilot/UI-METRIC-06_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/UI-METRIC-06_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd`
    - `tests/test_workspace_layout_metric_evaluator.gd`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-06_P1_ACCEPTANCE_GATE/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-06_P1_ACCEPTANCE_GATE/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-06_P1_ACCEPTANCE_GATE/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-06_P1_ACCEPTANCE_GATE/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/UI-METRIC-06_TEST_RESULT_2026-06-10.md`

### UI-METRIC-07 P0 metric integration in standard tests

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-07_TEST_SH_INTEGRATION/`
  review: `docs/review/autopilot/UI-METRIC-07_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/UI-METRIC-07_SELF_REVIEW_2026-06-10.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `tests/test_workspace_layout_metric_gate.gd`
    - `tools/test.sh`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-07_TEST_SH_INTEGRATION/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-07_TEST_SH_INTEGRATION/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-07_TEST_SH_INTEGRATION/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-07_TEST_SH_INTEGRATION/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/UI-METRIC-07_TEST_RESULT_2026-06-10.md`

### UI-METRIC-08 Autopilot UI acceptance template update

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-08_AUTOPILOT_ACCEPTANCE_TEMPLATE_UPDATE/`
  review: `docs/review/autopilot/UI-METRIC-08_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/UI-METRIC-08_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-182912-27153/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/review/autopilot/SELF_REVIEW_TEMPLATE.md`
    - `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
    - `docs/process/QUEUE_OPERATION_RULES.md`
    - `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-08_AUTOPILOT_ACCEPTANCE_TEMPLATE_UPDATE/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-08_AUTOPILOT_ACCEPTANCE_TEMPLATE_UPDATE/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-08_AUTOPILOT_ACCEPTANCE_TEMPLATE_UPDATE/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-08_AUTOPILOT_ACCEPTANCE_TEMPLATE_UPDATE/IMPLEMENTATION_PLAN.md`
    - `docs/review/roadmap/UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP_M2_PHASE_REVIEW_2026-06-10.md`
    - `docs/review/autopilot/UI-METRIC-08_TEST_RESULT_2026-06-10.md`

### STATE-NEXT-10 Root reducer / event model expansion

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/STATE-NEXT-10_ROOT_REDUCER_EVENT_MODEL/`
  review: `docs/review/autopilot/STATE-NEXT-10_SELF_REVIEW_2026-06-14.md`
  execution:
    - `docs/review/autopilot/STATE-NEXT-10_SELF_REVIEW_2026-06-14.md`
    - `docs/review/autopilot/STATE-NEXT-10_TEST_RESULT_2026-06-14.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/process/PLANNING_POLICY.md`
    - `docs/process/QUEUE_OPERATION_RULES.md`
    - `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/STATE-NEXT-10_ROOT_REDUCER_EVENT_MODEL/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/STATE-NEXT-10_ROOT_REDUCER_EVENT_MODEL/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/STATE-NEXT-10_ROOT_REDUCER_EVENT_MODEL/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/STATE-NEXT-10_ROOT_REDUCER_EVENT_MODEL/IMPLEMENTATION_PLAN.md`
    - `addons/hex_map_kit/editor/hex_map_workspace_dispatcher.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/STATE-NEXT-10_SELF_REVIEW_2026-06-14.md`
    - `docs/review/autopilot/STATE-NEXT-10_TEST_RESULT_2026-06-14.md`

### ARCH-NEXT-10 Physical Workspace UI node construction extraction

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-10_PHYSICAL_WORKSPACE_UI_NODE_EXTRACTION/`
  review: `docs/review/autopilot/ARCH-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/ARCH-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-184324-48462/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_resources_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_catalog_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_layers_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_validate_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_qa_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_export_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_settings_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/ARCH-NEXT-10_TEST_RESULT_2026-06-10.md`

### ARCH-NEXT-11 Generate Dock internal component split

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-11_GENERATE_DOCK_INTERNAL_COMPONENT_SPLIT/`
  review: `docs/review/autopilot/ARCH-NEXT-11_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/ARCH-NEXT-11_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-185451-65129/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_run_controls.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_source_controls.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_output_controls.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_result_controls.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/ARCH-NEXT-11_TEST_RESULT_2026-06-10.md`

### CAT-NEXT-10 Catalog editor component extraction

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/CAT-NEXT-10_CATALOG_EDITOR_COMPONENT_EXTRACTION/`
  review: `docs/review/autopilot/CAT-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/CAT-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-190705-87584/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_catalog_editor_component.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/CAT-NEXT-10_TEST_RESULT_2026-06-10.md`

### PERF-NEXT-10 Chunked TileMap apply implementation

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PERF-NEXT-10_CHUNKED_TILEMAP_APPLY_IMPLEMENTATION/`
  review: `docs/review/autopilot/PERF-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/PERF-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-192211-13770/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
    - `docs/review/roadmap/UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP_M3_PHASE_REVIEW_2026-06-10.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
    - `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
    - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
    - `addons/hex_map_kit/editor/hex_map_generation_run_state.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/PERF-NEXT-10_TEST_RESULT_2026-06-10.md`

### GEN-NEXT-10 Full Generate tab layout redesign

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GEN-NEXT-10_GENERATE_TAB_LAYOUT_REDESIGN/`
  review: `docs/review/autopilot/GEN-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/GEN-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-193656-38055/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_run_controls.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_source_controls.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_output_controls.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_result_controls.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/GEN-NEXT-10_TEST_RESULT_2026-06-10.md`

### GEN-NEXT-11 Generate / QA preview thumbnails

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GEN-NEXT-11_GENERATE_QA_PREVIEW_THUMBNAILS/`
  review: `docs/review/autopilot/GEN-NEXT-11_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/GEN-NEXT-11_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-194911-55751/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_preview_thumbnail.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_result_controls.gd`
    - `addons/hex_map_kit/editor/hex_map_qa_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/GEN-NEXT-11_TEST_RESULT_2026-06-10.md`

### CAT-NEXT-11 Catalog tile / scene preview UI

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/CAT-NEXT-11_CATALOG_TILE_SCENE_PREVIEW_UI/`
  review: `docs/review/autopilot/CAT-NEXT-11_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/CAT-NEXT-11_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-195943-72258/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_tile_catalog_preview_control.gd`
    - `addons/hex_map_kit/editor/hex_map_catalog_editor_component.gd`
    - `addons/hex_map_kit/editor/hex_map_catalog_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/CAT-NEXT-11_TEST_RESULT_2026-06-10.md`

### SCREEN-NEXT-10 Resources / Layers / Export visual redesign

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/SCREEN-NEXT-10_RESOURCES_LAYERS_EXPORT_VISUAL_REDESIGN/`
  review: `docs/review/autopilot/SCREEN-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/SCREEN-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-200929-88986/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_resources_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_layers_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_export_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/SCREEN-NEXT-10_TEST_RESULT_2026-06-10.md`

### LAYER-NEXT-10 Fine-grained Layer role editor

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/LAYER-NEXT-10_LAYER_ROLE_EDITOR/`
  review: `docs/review/autopilot/LAYER-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/LAYER-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-202250-10191/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_layers_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/LAYER-NEXT-10_TEST_RESULT_2026-06-10.md`

### PAINT-NEXT-10 Paint viewport affordance polish

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PAINT-NEXT-10_VIEWPORT_AFFORDANCE_POLISH/`
  review: `docs/review/autopilot/PAINT-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/PAINT-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-203023-23601/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/PAINT-NEXT-10_TEST_RESULT_2026-06-10.md`

### VAL-NEXT-10 Rich Validate issue table and actions

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/VAL-NEXT-10_VALIDATE_RICH_ISSUE_TABLE_ACTIONS/`
  review: `docs/review/autopilot/VAL-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/VAL-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-203734-34721/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/VAL-NEXT-10_TEST_RESULT_2026-06-10.md`

### QA-NEXT-10 QA scored table visual redesign

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/QA-NEXT-10_SCORE_TABLE_VISUAL_REDESIGN/`
  review: `docs/review/autopilot/QA-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/QA-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-204647-49048/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_qa_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/QA-NEXT-10_TEST_RESULT_2026-06-10.md`

### SETTINGS-NEXT-10 Settings grouping and toggle styling

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/SETTINGS-NEXT-10_SETTINGS_GROUPING_TOGGLE_STYLING/`
  review: `docs/review/autopilot/SETTINGS-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/SETTINGS-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-205241-58403/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_settings_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/SETTINGS-NEXT-10_TEST_RESULT_2026-06-10.md`

### SAMPLE-NEXT-10 Sample detail drawer

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/SAMPLE-NEXT-10_SAMPLE_DETAIL_DRAWER/`
  review: `docs/review/autopilot/SAMPLE-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/SAMPLE-NEXT-10_SELF_REVIEW_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-205936-68440/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/SAMPLE-NEXT-10_TEST_RESULT_2026-06-10.md`

### PERF-NEXT-11 Large-map validation progress

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PERF-NEXT-11_LARGE_MAP_VALIDATION_PROGRESS/`
  review: `docs/review/autopilot/PERF-NEXT-11_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/PERF-NEXT-11_SELF_REVIEW_2026-06-10.md`
    - `docs/review/autopilot/PERF-NEXT-11_TEST_RESULT_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-211309-90551/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
    - `addons/hex_map_kit/editor/hex_map_validation_workflow_state.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
    - `tests/test_hex_adapter.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/PERF-NEXT-11_TEST_RESULT_2026-06-10.md`

### GENPIPE-NEXT-10 GenerationResultResource and replay API

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GENPIPE-NEXT-10_GENERATION_RESULT_RESOURCE_AND_REPLAY_API/`
  review: `docs/review/autopilot/GENPIPE-NEXT-10_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/GENPIPE-NEXT-10_SELF_REVIEW_2026-06-10.md`
    - `docs/review/autopilot/GENPIPE-NEXT-10_TEST_RESULT_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-212438-8456/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_generation_result_resource.gd`
    - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_hex_adapter.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/GENPIPE-NEXT-10_TEST_RESULT_2026-06-10.md`

### GENPIPE-NEXT-20 Pipeline graph UI research/spike

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GENPIPE-NEXT-20_PIPELINE_GRAPH_UI_RESEARCH_AND_SPIKE/`
  review: `docs/review/autopilot/GENPIPE-NEXT-20_SELF_REVIEW_2026-06-10.md`
  execution:
    - `docs/review/autopilot/GENPIPE-NEXT-20_SELF_REVIEW_2026-06-10.md`
    - `docs/review/autopilot/GENPIPE-NEXT-20_TEST_RESULT_2026-06-10.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260610-212936-15705/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GENPIPE-NEXT-20_PIPELINE_GRAPH_UI_RESEARCH_AND_SPIKE/PIPELINE_GRAPH_DECISION.md`
    - `docs/TEST.md`
    - `docs/review/autopilot/GENPIPE-NEXT-20_TEST_RESULT_2026-06-10.md`

### ARCH-NEXT-20 Object layer rendering extraction

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION/`
  review: `docs/review/autopilot/ARCH-NEXT-20_SELF_REVIEW_2026-06-14.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
    - `addons/hex_map_kit/adapter/hex_object_layer_renderer.gd`
    - `addons/hex_map_kit/adapter/hex_object_layer_renderer.gd.uid`
    - `tests/test_hex_tile_map_layer.gd`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION/SUB_TASKS.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION/UX.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION/POLICY.md`
    - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION/IMPLEMENTATION_PLAN.md`
    - `docs/review/autopilot/ARCH-NEXT-20_SELF_REVIEW_2026-06-14.md`
    - `docs/review/autopilot/ARCH-NEXT-20_TEST_RESULT_2026-06-14.md`

### PROFILE-NEXT-10 Concrete profile behavior schemas

proof:
  plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROFILE-NEXT-10_CONCRETE_PROFILE_BEHAVIOR_SCHEMAS/`
  review: `docs/review/autopilot/PROFILE-NEXT-10_SELF_REVIEW_2026-06-13.md`
  execution:
    - `docs/review/autopilot/PROFILE-NEXT-10_SELF_REVIEW_2026-06-13.md`
    - `docs/review/autopilot/PROFILE-NEXT-10_TEST_RESULT_2026-06-13.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260613-230938-80117/workspace_layout_metrics.md`
  tests:
    - `./tools/test.sh`
  docs:
    - `docs/TEST.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_validation_rule_suite_resource.gd`
    - `addons/hex_map_kit/adapter/hex_generation_profile_resource.gd`
    - `addons/hex_map_kit/adapter/hex_export_profile_resource.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd`
    - `tests/test_hex_adapter.gd`
    - `tests/test_editor_plugin.gd`
    - `docs/review/autopilot/PROFILE-NEXT-10_TEST_RESULT_2026-06-13.md`
