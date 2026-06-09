# SAMPLE-12 Implementation Plan

## Scope

Add a first-run learning CTA that routes users to Settings / Samples and can be dismissed without changing production asset selection state.

## Files

- `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SAMPLE-12` `RUNNING`.
2. Add session state for first-run learning CTA dismissal/visibility.
3. Add workspace CTA controls and public state/routing helpers.
4. Route CTA activation to the Settings tab without enabling sample mode.
5. Add headless tests for first-run visibility, Settings routing, dismissal, and normal project asset state.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`.
8. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] First-run CTA is visible until dismissed.
- [x] CTA activation selects Settings / Samples.
- [x] CTA dismissal hides the CTA.
- [x] CTA does not enable sample mode or assign sample assets.
- [x] Normal project asset selection remains visible after dismissal.
- [x] Queue proof and next READY task are clear.
