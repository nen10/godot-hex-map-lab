# CLEANUP-30 Implementation Plan

## Scope

Quarantine numeric tile fallback behind an explicit Settings debug flag.

## Files

- `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `CLEANUP-30` `RUNNING`.
2. Add session debug flag for numeric tile fallback, default OFF.
3. Expose the flag in Settings snapshot and checkbox.
4. Make plain target document apply read only the explicit debug flag.
5. Update existing tests that intentionally use numeric plain-target rendering to opt in.
6. Add a dedicated cleanup test for normal OFF / debug ON / validation issue behavior.
7. Update `docs/TEST.md`.
8. Run `./tools/test.sh`.
9. Self-review, repair, update queue proof, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Numeric fallback is OFF by default in session/settings state.
- [x] Settings exposes explicit debug numeric fallback opt-in.
- [x] Normal plain target apply does not silently fill missing catalog assignments.
- [x] Debug opt-in restores numeric fallback behavior intentionally.
- [x] Missing catalog assignment remains a validation issue.
- [x] Queue proof and next READY task are clear.
