# ARCH-NEXT-11 Self Review 2026-06-10

Task: `ARCH-NEXT-11_GENERATE_DOCK_INTERNAL_COMPONENT_SPLIT`
Status: COMPLETE

## Summary

Extracted key physical Generate Dock control groups into dedicated builder scripts while keeping `HexMapGenDock` as the orchestrator for state binding, signal handling, generation execution, and refresh logic.

## Changed Files

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_gen_run_controls.gd`
- `addons/hex_map_kit/editor/hex_map_gen_run_controls.gd.uid`
- `addons/hex_map_kit/editor/hex_map_gen_source_controls.gd`
- `addons/hex_map_kit/editor/hex_map_gen_source_controls.gd.uid`
- `addons/hex_map_kit/editor/hex_map_gen_output_controls.gd`
- `addons/hex_map_kit/editor/hex_map_gen_output_controls.gd.uid`
- `addons/hex_map_kit/editor/hex_map_gen_result_controls.gd`
- `addons/hex_map_kit/editor/hex_map_gen_result_controls.gd.uid`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-11_GENERATE_DOCK_INTERNAL_COMPONENT_SPLIT/`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Acceptance

| requirement | result | evidence |
|---|---|---|
| Generate run controls are split | pass | `HexMapGenRunControls` builds run and progress controls. |
| Profile/source controls are split | pass | `HexMapGenSourceControls` builds source registry controls; generation profile state remains owned by Workspace/QA as currently scoped. |
| Preview/result summary controls are split | pass | `HexMapGenResultControls` builds seed lab and result summary controls. |
| Output/apply/save controls are split | pass | `HexMapGenOutputControls` builds output target and save/apply controls. |
| `HexMapGenDock` orchestrates state binding | pass | Existing signal connections and refresh methods remain in `HexMapGenDock`. |
| Screen/component contract tests cover ownership | pass | `tests/test_editor_plugin.gd` validates builder script owner rows and mounted metadata. |

## Plan Deviation

| item | classification | reason |
|---|---|---|
| Generation profile UI not moved into a dedicated builder | policy-deferred | Current Generation Profile selection is Workspace/QA asset context work; Generate profile layout redesign remains queued as `GEN-NEXT-10`. |

## Repair-Now Audit

None.

## Sample-Only Completion Audit

No sample-only success was used as completion proof. The change is component ownership and is verified by headless contracts plus existing generation behavior tests.

## UI Metric Review

- report: `.godot_user/ui-metrics/20260610-185451-65129/workspace_layout_metrics.md`
- P0 failures: `0`
- P1 issues: `0`
- applicability: UI-facing Generate architecture task; metric proof is required.

## Tests

- `./tools/test.sh`

Known nonblocking output:
- macOS CA certificate warnings from Godot.
- Existing negative-path warnings in generation/source query tests.
