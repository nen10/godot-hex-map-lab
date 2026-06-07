# Autopilot Development Implementation Queue 2026-06-07

作成日: 2026-06-07  
Roadmap: `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/UX_ROADMAP.md`  
Source review: `docs/review/AUTOPILOT_DEVELOPMENT_EVALUATION_2026-06-07.md`  
Operation rules: `docs/process/QUEUE_OPERATION_RULES.md`

この queue は、Autopilot 実装後の公開前UX仕上げと配布品質固定を Codex が実装可能な単位へ分割したものである。

---

## 0. Queue operation rules

- status は `docs/process/QUEUE_OPERATION_RULES.md` に従う。
- `READY` task は、人間承認待ちにせず plan files 作成、実装、test、self-review、queue update まで進める。
- User-facing UX task は `HEADLESS_TEST_COMPLETE` だけで閉じない。acceptance に `EDITOR_WORKFLOW_COMPLETE` / `ANALOG_TEST_COMPLETE` がある場合、それを proof に含める。
- Package task は `PACKAGE_READY` を proof に含める。
- task 完了時は dependency sweep を実行し、依存が満たされた `BACKLOG` を `READY` にする。

Completion proof template:

```text
proof:
  plan: docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/<TASK_ID>_<slug>/
  review: docs/review/autopilot/<TASK_ID>_SELF_REVIEW_<date>.md
  tests:
    - ./tools/test.sh
    - <targeted command if any>
  maturity:
    - CODE_COMPLETE
    - HEADLESS_TEST_COMPLETE
    - EDITOR_WORKFLOW_COMPLETE
    - ANALOG_TEST_COMPLETE
    - PACKAGE_READY
  docs:
    - docs/TEST.md
  major files:
    - ...
```

---

## 1. Phase 0: Package Integrity Repair

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---|---|---|---|---|---|
| `APDEV-01` | `READY` | none | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-01_SAMPLE_CATALOG_PACKAGE_INTEGRITY/` | Sample catalog references only packaged resources | `addons/hex_map_kit/assets/sample_hex_tile_catalog.tres`, sample scene/resource files, `tests/test_hex_adapter.gd`, `tools/package_addon.sh` if needed | sample catalog validator reports no missing scene/resource errors; `object.spawn_marker` scene path exists in package; `tools/package_addon.sh --check` PASS | `PACKAGE_READY` |
| `APDEV-02` | `READY` | none | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-02_DIST_ARTIFACT_FRESHNESS/` | Dist artifact freshness check and regenerated dist | `tools/package_addon.sh`, `dist/hex_map_kit-0.3.0.zip`, `dist/hex_map_kit-0.3.0.manifest.txt`, `docs/TEST.md` | committed manifest equals manifest generated from current addon tree; release check documents how to regenerate and compare; `tools/package_addon.sh --check` PASS | `PACKAGE_READY` |

---

## 2. Phase 1: UX Evidence Pack

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---|---|---|---|---|---|
| `APDEV-03` | `BACKLOG` | `APDEV-01`, `APDEV-02` | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-03_NEW_FEATURE_ANALOG_TEST_PACK/` | Analog tests for v0.3 user-facing workflows | `tests/analog_test/*.md`, `docs/TEST.md` | Add analog tests for Validation Dashboard cell focus, Catalog selector and tile preview, Layer Stack workflow, Object placement editor, Generation QA / Seed promotion, Clean package install; each has Operation Steps, Expected Observations, Failure Signals, Evidence To Attach | `ANALOG_TEST_COMPLETE` |
| `APDEV-04` | `BACKLOG` | `APDEV-03` | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-04_EDITOR_PLUGIN_MANUAL_V03_WORKFLOWS/` | v0.3 workflow manual update | `docs/manual/MANUAL_EDITOR_PLUGIN.md`, `docs/manual/MANUAL_WORKFLOW.md`, `docs/TEST.md` | Manual explains Catalog selector, Layer Stack workflow, Validation Dashboard, Object Placement, Generation QA / Seed promotion, Copy Debug Report, Clean package install by user goal | `ANALOG_TEST_COMPLETE` |

---

## 3. Phase 2: Screen Workflow Completion

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---|---|---|---|---|---|
| `APDEV-05` | `BACKLOG` | `APDEV-03` | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-05_CATALOG_LAYER_STACK_SCREEN_WORKFLOW/` | Catalog and Layer Stack screen workflow | `addons/hex_map_kit/editor/`, `tests/test_editor_plugin.gd` or feature-specific tests, `tests/analog_test/` | Catalog resource picker, entry list, tile preview or equivalent preview state, missing asset warning, Layer Stack template/apply operation are usable without primary numeric `source_id / atlas_coords` workflow | `EDITOR_WORKFLOW_COMPLETE` |
| `APDEV-06` | `BACKLOG` | `APDEV-03` | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-06_VALIDATION_DASHBOARD_WORKFLOW/` | Validation Dashboard workflow polish | `addons/hex_map_kit/editor/`, validation helpers, editor tests, analog test | Validate button/list grouping/cell focus/debug report summary behave as one workflow; document-level and cell-scoped issues are distinguishable | `EDITOR_WORKFLOW_COMPLETE` |
| `APDEV-07` | `BACKLOG` | `APDEV-01`, `APDEV-03` | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-07_OBJECT_PROPERTY_EDITOR_WORKFLOW/` | Object placement property editor workflow | `addons/hex_map_kit/editor/`, object resource/adapter helpers, editor tests, analog test | Object definition picker, placement list, rotation/variant/properties/spawn condition editing, save/reload roundtrip, validation warning on wall cell | `EDITOR_WORKFLOW_COMPLETE` |
| `APDEV-08` | `BACKLOG` | `APDEV-03` | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-08_GENERATION_QA_DASHBOARD_WORKFLOW/` | Generation QA / Seed Lab dashboard workflow | `addons/hex_map_kit/editor/hex_map_gen_dock.gd`, new panel if split, generation tests, analog test | Batch count/seed range/run, score table, pass/fail filter, selected seed promotion, generation snapshot metadata, dirty state display | `EDITOR_WORKFLOW_COMPLETE` |

---

## 4. Phase 3: API and Architecture Containment

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---|---|---|---|---|---|
| `APDEV-09` | `BACKLOG` | `APDEV-06`, `APDEV-07` | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-09_CANONICAL_MUTATION_AND_VALIDATION_ISSUE_HELPERS/` | v2 canonical mutation path and validation issue helpers | adapter resources/helpers, validation result helpers, editor integration tests | UI no longer constructs raw validation Dictionary issues or edits legacy v1 fields directly where v2 helpers exist; rule id constants/accessors cover current validation UI needs | `HEADLESS_TEST_COMPLETE` |
| `APDEV-10` | `BACKLOG` | `APDEV-05`, `APDEV-06`, `APDEV-07`, `APDEV-08` | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-10_EDITOR_FILE_SIZE_CONTAINMENT/` | Feature panel extraction from giant editor files | `addons/hex_map_kit/editor/hex_map_gen_dock.gd`, `addons/hex_map_kit/editor/hex_map_edit_tool.gd`, new editor panel scripts | Catalog, validation, object, and generation QA screen logic have extracted panel/component boundaries; giant dock files remain integration shells for those panels | `HEADLESS_TEST_COMPLETE` |
| `APDEV-11` | `BACKLOG` | `APDEV-10` | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-11_EDITOR_FEATURE_TEST_SPLIT/` | Feature-specific editor test split | `tests/test_editor_catalog_ui.gd`, `tests/test_editor_validation_dashboard.gd`, `tests/test_editor_object_placement_ui.gd`, `tests/test_editor_generation_qa_ui.gd`, `docs/TEST.md` | Feature-specific tests cover the extracted panels; `tests/test_editor_plugin.gd` remains shared plugin smoke/integration coverage | `HEADLESS_TEST_COMPLETE` |

---

## 5. Phase 4: Release Quality Gate

| id | status | dependencies | plan_dir | deliverable | target files | acceptance / test path | maturity |
|---|---|---|---|---|---|---|---|
| `APDEV-12` | `BACKLOG` | `APDEV-01`, `APDEV-02`, `APDEV-03`, `APDEV-11` | `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/APDEV-12_RELEASE_QUALITY_GATE/` | Release quality gate for v0.3 package | `.github/workflows/` if CI is added, `tools/`, `docs/TEST.md`, `docs/manual/MANUAL_PACKAGE.md` | One documented gate runs package check, dist freshness, sample catalog validation, and `./tools/test.sh`; public upload remains a manual release step | `PACKAGE_READY` |

---

## 6. Current pointer

Current recommended next task: `APDEV-01`.

Reason:

- `APDEV-01` fixes a sample asset break that can damage first-run package UX.
- `APDEV-02` is also `READY` and can run in parallel if it does not conflict with `APDEV-01`.
- Phase 1 and later tasks depend on package integrity being stable enough to document and test.

---

## 7. Completed task proof log

No tasks have been completed in this roadmap yet.
