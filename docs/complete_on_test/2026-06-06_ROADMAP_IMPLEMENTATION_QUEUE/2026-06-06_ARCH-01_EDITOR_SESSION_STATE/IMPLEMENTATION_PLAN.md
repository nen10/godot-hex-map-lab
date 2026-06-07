# ARCH-01 Editor Session State Implementation Plan

作成日: 2026-06-07
Queue task: `ARCH-01`

## Inputs

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Outputs

- Shared editor session state script.
- Edit Dock / Generate Dock narrow session hooks.
- Headless tests for shared target/document state and existing auto-target behavior.
- ARCH-01 test result, self-review, and queue proof.

## Implementation Steps

1. Inspect existing plugin and dock target/document state wiring.
2. Add a small editor session state script.
3. Add session setter/getter hooks to Generate Dock and Edit Dock.
4. Publish relevant target/document/path state through those hooks.
5. Add editor tests that share one session between docks and verify target/document propagation.
6. Run `./tools/test.sh`.

## Test Path

- `tests/test_editor_plugin.gd`
- `./tools/test.sh`
