# ASSET-30 Implementation Plan

## Scope

- Inspect asset slot state/control and workspace asset panel slot definitions.
- Ensure typed slots configure `EditorResourcePicker.base_type` with concrete addon Resource classes.
- Add tooltip and snapshot metadata for expected type and flexibility reason.
- Update editor plugin tests and `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd`
- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Steps

1. Read current slot state/control contracts and slot creation metadata.
2. Add or tighten expected type metadata where missing.
3. Apply expected type to `EditorResourcePicker.base_type`.
4. Add snapshot coverage for typed filters and flexible slot documentation.
5. Run `./tools/test.sh`, self-review, update queue proof, and commit.

## Completion Checklist

- Typed slots no longer request generic `Resource`.
- Tooltips say what type to pick.
- Type mismatch is prevented at picker stage where feasible.
- Flexible slots document their reason.
- No `repair-now` items remain.
