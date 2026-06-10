# STATE-40 Implementation Plan

## Scope

- Add explicit Paint interaction state/ViewState to `HexMapEditTool`.
- Surface that state in Workspace Paint snapshots.
- Cover missing target/document/asset, active brush, hover/selected cell, apply/dirty/result, and validation focus.
- Update tests and `docs/TEST.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_edit_viewport_input_adapter.gd` if needed
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Steps

1. Inspect current Paint/edit tool snapshots and tests.
2. Add a Paint interaction state snapshot and ViewState.
3. Wire Workspace Paint snapshot to include it.
4. Extend existing editor tests.
5. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Target and document state are explicit.
- [x] Active brush state is explicit.
- [x] Hovered/selected cell state is explicit.
- [x] Apply/dirty/result state is explicit.
- [x] Validation focus/missing asset state is explicit.
- [x] Workspace Paint snapshot exposes the ViewState.
- [x] Tests cover the state snapshot contract.
- [x] Queue proof, self-review, and test result are updated.
