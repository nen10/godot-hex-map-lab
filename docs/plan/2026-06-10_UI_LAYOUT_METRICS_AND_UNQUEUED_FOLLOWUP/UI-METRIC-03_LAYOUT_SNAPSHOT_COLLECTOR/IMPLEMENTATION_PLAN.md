# UI-METRIC-03 Implementation Plan

## Scope

- Add a runtime Workspace layout snapshot collector under addon editor testing helpers.
- Add a scenario builder for representative Workspace states and viewport sizes.
- Add a Godot test that verifies visible control field collection, JSON serialization, scroll parent evidence, and multi-scenario coverage.
- Wire the new test into `tools/test.sh` and document it in `docs/TEST.md`.
- Write self-review and test-result proof, update queue status/proof, and commit.

## Target Files

- `addons/hex_map_kit/editor/testing/hex_ui_layout_snapshot_collector.gd`
- `addons/hex_map_kit/editor/testing/hex_ui_state_scenario_builder.gd`
- `tests/test_workspace_layout_metrics.gd`
- `tools/test.sh`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-03_LAYOUT_SNAPSHOT_COLLECTOR/`
- `docs/review/autopilot/UI-METRIC-03_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/UI-METRIC-03_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Steps

- Mark `UI-METRIC-03` RUNNING and create plan docs.
- Implement collector with visible Control traversal and JSON-safe field serialization.
- Implement Workspace scenario builder for selected/unselected/resource states.
- Add layout metrics test coverage.
- Add the test script to `tools/test.sh`.
- Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- Run `./tools/test.sh`.
- Write self-review and test-result docs.
- Mark `UI-METRIC-03` COMPLETE, promote dependency-satisfied tasks, update proof log, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Workspace UI construction | Scenario cannot build the Workspace outside the editor plugin dock. | `tests/test_workspace_layout_metrics.gd`. |
| State matrix | Collector only covers one state. | Multi-scenario loop in layout metrics test. |
| Layout field schema | Later evaluator cannot consume collector output. | JSON serialization and parsed scenario id assertion. |
| Scroll containers | Snapshot cannot prove scroll ancestry. | Test asserts at least one visible control has a ScrollContainer parent. |
| Standard verification | New test breaks package/test flow. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- Workspace can be built across scenario and size matrix.
- Visible Control snapshots include rect, minimum size, text, base type, tooltip, scroll parent, and metadata fields.
- Snapshot JSON parses back into a dictionary.
- The collector remains report infrastructure and does not introduce metric fail gates.
