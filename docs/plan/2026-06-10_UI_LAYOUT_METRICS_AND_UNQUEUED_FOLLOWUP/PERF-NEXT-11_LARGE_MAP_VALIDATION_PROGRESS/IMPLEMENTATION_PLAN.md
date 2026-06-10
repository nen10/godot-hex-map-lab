# Implementation Plan

## Scope

Add phase-level validation progress reporting for large maps and surface it through Validate and Generate busy/progress state.

## Target Files

- `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
- `addons/hex_map_kit/editor/hex_map_validation_workflow_state.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Planned Implementation Steps

1. Add validator progress helpers and phase reports around existing validation phases.
2. Store final progress in validation result summary and options for callers.
3. Add progress fields to `HexMapValidationWorkflowState` snapshots/view state.
4. Capture Validate run progress in `HexMapWorkspace` and expose it in Validate snapshots.
5. Forward Generate validation progress into existing Generate progress controls.
6. Add focused adapter/editor tests and update `docs/TEST.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Per-cell callback reporting | defer | Phase-level reports meet the visible progress contract with lower overhead. |
| Threaded validation | defer | No roadmap requirement to change execution model. |
| Modal progress UI | reject | Existing inline workflow states are the product surface. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Validator progress | Progress regresses or is non-monotonic. | Adapter progress callback test. |
| Validate state | Progress remains invisible to screen state. | Validate workspace test inspects snapshot and run result. |
| Generate state | Validation progress bypasses Generate controls. | Generation dock validation failure test inspects progress state. |
| Existing rules | Validation issue semantics change accidentally. | Existing validator tests remain green. |

## Docs Updates

- Update `docs/TEST.md` with `PERF-NEXT-11` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Validator reports phase/progress snapshots for document validation.
- Validate workflow snapshots expose completed progress state after runs.
- Generate validation uses the existing validating progress state.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
