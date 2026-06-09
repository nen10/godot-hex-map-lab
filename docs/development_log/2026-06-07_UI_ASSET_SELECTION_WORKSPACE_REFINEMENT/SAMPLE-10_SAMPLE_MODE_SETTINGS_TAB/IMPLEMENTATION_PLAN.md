# SAMPLE-10 Implementation Plan

## Scope

Add a Settings / Samples workspace panel and make bundled sample catalog fallback conditional for workspace sessions.

## Files

- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SAMPLE-10` `RUNNING`.
2. Add session sample visibility flags and snapshot fields.
3. Add `HexMapSampleSettingsPanel` with sample setting toggles and sample asset reference rows.
4. Add Settings tab/component registration and mount the sample panel.
5. Make Generate/Paint sample catalog fallback conditional on session setting while keeping project context primary.
6. Add headless tests for OFF/ON selector source and project asset precedence.
7. Update `docs/TEST.md`.
8. Run `./tools/test.sh`.
9. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Settings / Samples panel is mounted in workspace.
- [x] Sample visibility is OFF by default for workspace sessions.
- [x] Sample mode OFF hides bundled sample catalog candidates from main selectors.
- [x] Sample mode ON can expose bundled sample candidates.
- [x] Project asset context remains primary when sample mode is ON.
- [x] Queue proof and next READY task are clear.
