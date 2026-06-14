# Implementation Plan

## Scope

Split remaining editor integration tests into feature-family suites, leaving `test_editor_plugin.gd` as a small workflow smoke test, without weakening assertions. Update shared test helpers and test runner registration so all new suites execute.

## Target Files

- `tests/test_editor_plugin.gd`
- `tests/test_editor_plugin_test_base.gd`
- `tests/test_editor_workspace.gd`
- `tests/test_editor_map.gd`
- `tests/test_editor_hex.gd`
- `tests/test_editor_generation.gd`
- `tests/test_editor_distribution.gd`
- `tests/test_editor_asset.gd`
- `tests/test_editor_catalog.gd`
- `tests/test_editor_layer.gd`
- `tests/test_editor_object.gd`
- `tests/test_editor_paint.gd`
- `tests/test_editor_document.gd`
- `tests/test_editor_output.gd`
- `tests/test_editor_validate.gd`
- `tests/test_editor_qa.gd`
- `tests/test_editor_sample.gd`
- `tests/test_editor_workspace.gd`
- `tools/test.sh`
- `docs/review/autopilot/TEST-NEXT-10_SELF_REVIEW_2026-06-14.md`
- `docs/review/autopilot/TEST-NEXT-10_TEST_RESULT_2026-06-14.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

(plus each new suite `.uid` file)

## Planned implementation steps

1. Generate per-family `tests/test_editor_<family>.gd` files and move remaining `_test_*` functions verbatim from `test_editor_plugin.gd`.
2. Keep `test_editor_plugin.gd` as a compact smoke runner with plugin registration, workspace tab mapping, and viewport-to-Paint handoff assertion flow.
3. Add shared temp-resource helpers to `tests/test_editor_plugin_test_base.gd` and include them in each family.
4. Add missing `.uid` files for each new suite.
5. Register all suite scripts in `tools/test.sh` `TEST_SCRIPTS`.
6. Run `./tools/test.sh`; iterate any repair-now issues.
7. Create `SUB_TASKS.md`, `UX.md`, `POLICY.md`, `IMPLEMENTATION_PLAN.md` and review/test artifacts.
8. Update queue proof log entry in `IMPLEMENTATION_QUEUE.md` for `TEST-NEXT-10` only.

## Dependency / test matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Family extraction boundaries | accidentally omits/duplicates tests | compare function-name coverage before/after migration |
| Shared helper extraction | undefined helper references in family suites | `./tools/test.sh` run completes without runtime missing method errors |
| .uid coverage | editor test import integrity | presence of `.uid` files for each new suite |
| Test list registration | some suite not executed | `tools/test.sh` list includes all family files |

## Planned completion criteria

- `test_editor_plugin.gd` contains only smoke tests and no behavioral split scope.
- Feature-family editor test files exist and execute.
- `tools/test.sh` executes old + new editor suites end-to-end.
- No new private widget-shape assertions introduced.
- `./tools/test.sh` passes.
- Queue row for `TEST-NEXT-10` is marked COMPLETE with proof-log entry.
