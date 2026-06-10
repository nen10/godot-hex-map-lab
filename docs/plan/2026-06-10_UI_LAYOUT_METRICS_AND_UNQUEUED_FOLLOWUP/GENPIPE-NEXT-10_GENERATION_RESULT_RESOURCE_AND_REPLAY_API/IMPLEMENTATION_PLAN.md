# Implementation Plan

## Scope

Add `HexGenerationResultResource` and connect Generate/QA batch candidates to replay/promotion through that Resource.

## Target Files

- `addons/hex_map_kit/adapter/hex_generation_result_resource.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Planned Implementation Steps

1. Create `HexGenerationResultResource` with result scope and replay helpers.
2. Build result resources for blocked/generated batch rows.
3. Expose result resource id/replay state in Generate and QA row snapshots.
4. Promote selected rows through `promote_generation_result()` when a result resource is present.
5. Store result id/source metadata on promoted documents.
6. Add focused adapter/editor tests and update `docs/TEST.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Pipeline graph UI | defer | Covered by `GENPIPE-NEXT-20`. |
| Full row replacement | defer | Existing table dictionaries remain the UI model. |
| Behavior schema expansion | defer | Covered by `PROFILE-NEXT-10`. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Resource serialization | Candidate scope is not durable. | Adapter save/load test. |
| Batch rows | Rows remain dictionary-only. | Generate batch test checks `generation_result`. |
| Replay/promotion | QA promotes regenerated data instead of selected result. | Promotion test checks result id metadata and replay document. |
| QA exposure | QA screen hides result scope. | QA snapshot test checks result id/replay fields. |

## Docs Updates

- Update `docs/TEST.md` with `GENPIPE-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Generated candidates have `HexGenerationResultResource` payloads.
- Generate/QA can replay/promote from result resources.
- Promoted documents record generation result metadata.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
