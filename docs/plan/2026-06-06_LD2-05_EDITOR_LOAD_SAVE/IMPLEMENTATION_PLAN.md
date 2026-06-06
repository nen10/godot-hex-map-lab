# LD2-05 Editor Load Save Implementation Plan

作成日: 2026-06-07
Queue task: `LD2-05`

## Inputs

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Outputs

- Editor document load/save paths that accept v2 documents and remain v1-compatible.
- Tests proving v2 document selection/load/save or import/export behavior.
- LD2-05 test result, self-review, and queue proof.

## Implementation Steps

1. Inspect current Edit Dock and Generate Dock resource selection, load, save, export, and import helpers.
2. Identify the narrow document paths that should call v2 migration or adapter helpers.
3. Preserve existing map resource and v1 document behavior.
4. Add or update editor tests with a v2 document fixture created in test code.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`.

## Test Path

- `tests/test_editor_plugin.gd`
- `./tools/test.sh`
