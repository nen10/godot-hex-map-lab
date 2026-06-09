# SCREEN-27 Implementation Plan

## Scope

Add Export screen project asset state, explicit destination selection/recent destination state, and export handoff verification.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd`
- `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SCREEN-27` `RUNNING`.
2. Add optional `export_profile` asset slot and create-new resource support.
3. Add Export tab destination component and snapshot.
4. Add create / open / save as / clear actions for Export Profile.
5. Add explicit destination selection, recent destination selection, and Save As dialog config.
6. Add export action that requires a selected Level Document and destination, writes `HexMapResource`, and updates session handoff state.
7. Add headless tests for export profile, destination state, no sample destination, and export handoff.
8. Update `docs/TEST.md`.
9. Run `./tools/test.sh`.
10. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Export tab exposes Level Document and Export Profile slots.
- [x] Export Profile can be created, opened, saved as, and cleared.
- [x] Save As destination dialog config is exposed without editable path input as completion proof.
- [x] Export refuses to run without a user-selected destination.
- [x] Recent destination selection updates active destination.
- [x] Export writes a `HexMapResource` and updates session package/runtime handoff path.
- [x] Sample export destination is absent.
- [x] Queue proof and next READY task are clear.
