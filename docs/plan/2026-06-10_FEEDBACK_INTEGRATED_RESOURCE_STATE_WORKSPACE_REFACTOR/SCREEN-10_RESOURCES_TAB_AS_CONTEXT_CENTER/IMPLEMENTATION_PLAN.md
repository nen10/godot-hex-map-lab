# SCREEN-10 Implementation Plan

## Scope

- Add Resources context center fields to the screen snapshot.
- Render selected map summary, group readiness, source badges, and next actions in the Resources panel.
- Remove node path from primary selected-map status text.
- Update editor tests and `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- Update queue proof, self-review, and test result.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add selected map display fields and keep node path in tooltip/snapshot detail.
2. Add resource group readiness counts and missing labels.
3. Add source badge rows with tooltip/detail ownership explanation.
4. Add Resources next-action state from selection and missing-resource context.
5. Refresh visible Resources panel labels from the new screen snapshot.
6. Run `./tools/test.sh`.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Resources shows selected HexTileMap summary without primary node path text.
- [x] Required/shared/optional resource status is visible at screen level.
- [x] Missing-resource actions and next actions are visible.
- [x] Source badges are visible and explain Node / Document Dependency / Manual Override / Sample / Missing semantics.
- [x] Tests cover SCREEN-10 state contract.
- [x] Queue proof, self-review, and test result are updated.
