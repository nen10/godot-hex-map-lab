# ASSET-32 Implementation Plan

## Scope

- Add a button-path action entry point for the remaining asset-row actions.
- Expose workspace asset panel/workspace helpers that press those action paths and return resulting state.
- Remove undefined Settings sample row action buttons.
- Update editor tests, `docs/TEST.md`, and queue proof.

## Target Files

- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add named action ids and an action-press helper to asset slot controls.
2. Route action presses through workspace asset panels and workspace tab helpers.
3. Remove visible Settings sample row `Open` and `Duplicate To Project` buttons.
4. Add tests that press `Create New...` through the workspace, press sample application through the control path, and assert undefined Settings buttons are absent.
5. Run `./tools/test.sh`, self-review, repair any `repair-now` items, update queue state, and commit.

## Completion Checklist

- Remaining visible asset-row actions have an observable state effect.
- Settings sample rows do not expose incomplete actions.
- Tests cover button/signal path behavior.
- No `repair-now` items remain.
