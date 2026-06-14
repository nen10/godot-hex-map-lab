# PROFILE-NEXT-11 Implementation Plan

## Scope

- Wire `HexValidationRuleSuiteResource` into `HexMapDocumentValidator`.
- Pass selected Validation Rule Suite through Workspace and Generate validation options.
- Apply selected Generation Profile options to Generate Dock snapshots.
- Apply selected Export Profile options to Export screen context/action result.
- Add focused adapter/editor tests and update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.

## Target Files

- `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_editor_generation.gd`
- `tests/test_editor_output.gd`
- `docs/TEST.md`
- `docs/review/autopilot/PROFILE-NEXT-11_SELF_REVIEW_2026-06-14.md`
- `docs/review/autopilot/PROFILE-NEXT-11_TEST_RESULT_2026-06-14.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROOF_LOG.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Implementation Steps

1. Add validation suite post-processing in `HexMapDocumentValidator`.
2. Add selected Validation Rule Suite to Workspace and Generate validation options.
3. Add Generate Dock helpers that derive and apply `generation_options()` to snapshots.
4. Add Export helpers that derive `export_options()` and expose/apply output type/file extension/inclusion flags.
5. Add tests for suite filtering/severity, generation profile snapshot/data, export profile result, and null-profile defaults.
6. Run `./tools/test.sh` and `python3 tools/verify_task.py --task PROFILE-NEXT-11 --head autopilot/continue`.
7. Add self-review/test-result docs, update queue/proof, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| `PROFILE-NEXT-10` Resource helpers | Method names drift from queue reference. | Tests call `rule_severity()`, `generation_options()`, and `export_options()`. |
| Validation result counts | Filtering after counts would leave stale summary. | Adapter test checks issue absence/severity and counts. |
| Generation snapshot mapping | Profile shape/connectivity strings map incorrectly to generator constants. | Editor generation test checks snapshot and generated data. |
| Export profile options | Flags are visible but not consumed by result path. | Editor export test checks result output/options/inclusion flags. |
| Null profile | Default behavior changes. | Adapter and editor tests keep no-profile behavior. |

## Test Path

- `./tools/test.sh`
- `python3 tools/verify_task.py --task PROFILE-NEXT-11 --head autopilot/continue`

## Docs Update

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with PROFILE-NEXT-11 coverage.
- Add self-review and test-result docs under `docs/review/autopilot/`.

## Planned Completion Criteria

- Disabled validation rules are dropped and severity overrides apply per engine path.
- Null validation profile preserves default behavior.
- Generation profile options affect generated seed/shape/terrain/connectivity.
- Export profile options affect export result output type/file extension/inclusion flags.
- Standard tests pass.
