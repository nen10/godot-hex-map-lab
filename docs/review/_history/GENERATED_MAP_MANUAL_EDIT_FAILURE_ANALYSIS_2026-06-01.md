# GENERATED_MAP_MANUAL_EDIT_FAILURE_ANALYSIS_2026-06-01.md

## Summary

Result: `implementation_plan_required`

Analog test `GENERATED_MAP_MANUAL_EDIT` failed at Operation Step 14, where the user clicked one visible generated floor cell in the editor viewport. Steps 1-13 were reported as complete, so generation, save, import, document path setup, target selection, document save, and edit mode selection are not the first failure boundary.

The failure boundary is the bridge from Godot Editor 2D viewport input to `HexMapEditTool.apply_local_position()`.

## Evidence

User result:

- `docs/review/GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md`
  - Steps 1-13 complete.
  - Step 14 fails.
  - Steps 16-32 are unreachable.

Code:

- `addons/hex_map_kit/plugin.gd`
  - `_forward_canvas_gui_input(event)` forwards to `_edit_tool.forward_canvas_gui_input(event)`.
  - `_handles(object)` is not implemented.
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `forward_canvas_gui_input(event)` accepts left mouse button events.
  - It calls `(_target_layer as CanvasItem).to_local(mouse_event.position)`.
  - It then calls `apply_local_position(local_pos)`.
- `tests/test_editor_plugin.gd`
  - Existing tests call `tool.apply_local_position(local_pos)` directly.
  - Existing tests do not verify the real `EditorPlugin._forward_canvas_gui_input()` route.

External API reference:

- Godot stable `EditorPlugin._forward_canvas_gui_input()` documentation states that it is called when there is an edited scene root, `_handles()` is implemented, and an `InputEvent` happens in the 2D viewport. It also states that returning `true` consumes the event and returning `false` forwards it.
  - https://docs.godotengine.org/en/stable/classes/class_editorplugin.html#class-editorplugin-private-method-forward-canvas-gui-input

## Cause

### 1. Missing `_handles()` prevents reliable 2D viewport input forwarding

`plugin.gd` declares `_forward_canvas_gui_input(event)`, but it does not implement `_handles(object)`. Godot EditorPlugin routing requires `_handles()` for 2D viewport input. Therefore the current plugin can have a fully working dock and direct test helper while still failing to receive real viewport clicks.

This matches the analog result: steps that use Dock controls succeed, and the first real viewport click fails.

### 2. Event position conversion is insufficient even if forwarding is invoked

`HexMapEditTool.forward_canvas_gui_input()` currently treats `mouse_event.position` as if it can be passed directly to `CanvasItem.to_local()`. In the editor viewport, the event position is a viewport-space position. A robust edit tool needs an explicit conversion from editor viewport coordinate to scene canvas/global coordinate, then from scene coordinate to target-local coordinate.

The direct headless tests bypass this risk because they provide target-local positions directly.

### 3. Missing runtime diagnostics makes user failure ambiguous

When the click fails, the user cannot distinguish:

- input not forwarded,
- target layer not selected,
- document missing,
- coordinate converted outside the generated shape,
- document mutated but redraw failed.

The implementation needs status/log checkpoints so analog tests can identify the first failing subsystem.

## User Operation Assessment

The reported failure does not look like a user misunderstanding. Operation Step 14 says to click a visible generated floor cell in the editor viewport. Based on the Godot EditorPlugin input contract and current `plugin.gd`, that operation is not sufficiently implemented.

If the user happened to click with a non-CanvasItem scene selection, the click would also fail under the current design. The implementation should not require hidden selection state beyond the Target control in Step 11.

## Required Plan

Create and execute:

- `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_IMPLEMENTATION_PLAN_2026-06-01.md`

The plan must keep `tests/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md` Operation Steps unchanged and make Step 14/15 pass through implementation.

## Follow-up Verification

After implementation, rerun:

```sh
./tools/test.sh
```

Then repeat analog test from Step 13 or from the beginning. Step 14 should produce either:

- visible wall/floor mutation, or
- a precise status message identifying why the click cannot be applied.
