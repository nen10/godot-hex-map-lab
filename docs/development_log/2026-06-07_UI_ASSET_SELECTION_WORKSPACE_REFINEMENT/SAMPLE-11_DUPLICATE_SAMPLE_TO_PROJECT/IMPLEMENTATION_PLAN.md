# SAMPLE-11 Implementation Plan

## Scope

Duplicate bundled sample catalog dependencies into project paths and assign the resulting catalog to workspace context.

## Files

- `addons/hex_map_kit/editor/hex_map_sample_asset_duplicator.gd`
- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SAMPLE-11` `RUNNING`.
2. Implement sample catalog duplication to a project `.tres` path.
3. Copy sample tile texture and object scene beside the duplicated catalog.
4. Rebuild the duplicated catalog TileSet and scene entries to use project dependency paths.
5. Assign the duplicated catalog to workspace asset context only after successful duplication.
6. Add Settings panel entry point and headless tests.
7. Update `docs/TEST.md`.
8. Run `./tools/test.sh`.
9. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Sample catalog duplicates to a project path.
- [x] Sample tile texture and object scene are copied to project paths.
- [x] Duplicated catalog references project dependency paths.
- [x] Duplicated catalog enters workspace asset context.
- [x] No sample is silently assigned without duplicate action.
- [x] Queue proof and next READY task are clear.
