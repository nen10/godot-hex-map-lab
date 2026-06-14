# NODE-21 Implementation Plan

## Scope

- Rename selected-node runtime map snapshot fields to runtime display snapshot fields.
- Clarify Edit Tool target readiness/document-source text.
- Update tests and docs to assert Level Document as authoring source.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/knowledge/DEV_GODOT.md`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Steps

1. Update Workspace selected HexTileMap snapshot keys/text.
2. Update Edit Tool target readiness keys/text from `target_hex_map` to runtime display snapshot.
3. Update manual/knowledge docs to record the role split.
4. Update editor tests.
5. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] `hex_map` is labeled runtime/display snapshot, not authoring source.
- [x] Level Document is explicit as authoring source.
- [x] Tests no longer assert "runtime initial map" wording.
- [x] Docs record the role split.
- [x] Queue proof, self-review, and test result are updated.
