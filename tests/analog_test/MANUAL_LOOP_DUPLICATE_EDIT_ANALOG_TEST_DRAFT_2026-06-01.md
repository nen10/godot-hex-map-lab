# MANUAL_LOOP_DUPLICATE_EDIT Analog Test Draft

## Metadata

- Status: draft_for_review_wait
- Source plans:
  - `docs/complete_on_test/RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md`
  - `docs/complete_on_test/RUNTIME_INTERACTION_LOOP_DISPLAY_TILE_COPY_IMPLEMENTATION_PLAN_2026-05-31.md`
  - `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md`
  - `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY_IMPLEMENTATION_PLAN_2026-05-31.md`
- Target Editor Plugin area: Hex Map Edit Dock and `HexTileMapLayer` target scene view
- Participating features: toric loop display, loop duplicate tile copy, viewport hit, canonical document edit, Undo / Redo
- Created date: 2026-06-01

## Use Case

- Actor: Godot Editor user
- Goal: A toric map duplicate shown outside the canonical domain can be edited as a visible tile while saving only the canonical document cell.
- Scenario: The user loads or creates a toric `HexMapResource`, displays it with `HexTileMapLayer` loop display enabled, imports it into Hex Map Edit, clicks a duplicate visual tile, and confirms the canonical document cell and all visual copies stay synchronized.
- Success state: The duplicate tile is visible before editing, the click changes the canonical wall/floor state, Undo / Redo restores both canonical and duplicate tile display, and saved/exported resources do not store visual duplicate cells.

## Preconditions

- Godot project state: `res://addons/hex_map_kit/plugin.cfg` is enabled in the editor.
- Addon state: `Hex Map Edit` Dock is visible.
- Scene/resource files: A scene contains one `HexTileMapLayer`.
- Required node setup: The `HexTileMapLayer` has a visible hex TileSet and `loop_display_enabled = true`, `loop_display_mode = Toric`.
- Data to prepare:
  - Toric source map path: `res://.godot_user/analog_toric_loop_source.tres`
  - Manual document path: `res://.godot_user/analog_toric_loop_document.tres`
  - Edited map export path: `res://.godot_user/analog_toric_loop_export.tres`

## Inputs

- User operations: Import Map, Target selection, viewport duplicate tile click, Undo, Redo, Save document, Export map.
- Editor selection: The `HexTileMapLayer` target.
- Resource files: A toric `HexMapResource` with `cyclic_size > 0`.
- Runtime/display settings:
  - Loop display: Toric
  - Loop display rect/margin: configured so at least one duplicate tile is visible
  - Edit Mode: `Wall / Floor`

## Outputs

- Visible Editor state:
  - Canonical and duplicate toric tiles are visible with floor / wall tile art.
  - Clicking a duplicate tile changes all representatives of the canonical cell.
  - Undo / Redo restores all representatives.
- Resource mutations:
  - `HexMapDocumentResource.map` changes only the canonical cell wall/floor state.
  - Exported `HexMapResource` keeps canonical cells and `cyclic_size`; visual duplicates are not persisted as separate cells.
- TileMapLayer / HexTileMapLayer state:
  - Base tile layer contains canonical cells.
  - Loop copy tile layer contains duplicate visual representatives only.
- Saved files:
  - `res://.godot_user/analog_toric_loop_document.tres`
  - `res://.godot_user/analog_toric_loop_export.tres`
- Status text / logs:
  - Hex Map Edit status distinguishes canonical and visual coordinates when the clicked representative differs from the canonical cell.

## Operation Steps

1. Open Godot Editor with this project and confirm the addon is enabled.
2. Create or select a scene containing one `HexTileMapLayer`.
3. Assign or generate a toric square map resource with visible floor cells and `cyclic_size > 0`.
4. Configure the `HexTileMapLayer` so loop display is enabled and mode is `Toric`.
5. Adjust loop display rect/margin or scene view so at least one duplicate floor tile outside the canonical domain is visible.
6. Open `Hex Map Edit`.
7. In `Import Map`, enter the toric source map path and press `Import`.
8. In `Target`, select the `HexTileMapLayer`.
9. Set `Edit Mode` to `Wall / Floor`.
10. Click a visible duplicate floor tile.
11. Confirm the clicked duplicate tile and its canonical representative become wall tiles.
12. Use Godot Editor Undo.
13. Confirm both the canonical tile and duplicate tile return to floor.
14. Use Godot Editor Redo.
15. Confirm both the canonical tile and duplicate tile become wall again.
16. Save the document.
17. Export the edited map resource.
18. Load or inspect the exported resource and confirm the changed wall is stored on the canonical cell only.

## Expected Observations

- Duplicate cells are shown as actual tiles, not only outline overlays.
- The clicked visual duplicate resolves to the same canonical coordinate used by the document.
- Undo / Redo changes both document state and loop duplicate tile display.
- Status text reports the canonical coordinate and, when different, the visual coordinate used for the click.

## Failure Signals

- Duplicate cells are only outlines or are not visible.
- Clicking a duplicate tile is ignored or changes a non-corresponding canonical cell.
- Undo / Redo changes the canonical domain but leaves duplicate tiles stale.
- Exported resource contains duplicate visual cells as persisted map cells.

## Code Reading Verification

| Step | Expected program behavior | Code path | Evidence | Remaining risk |
| --- | --- | --- | --- | --- |
| 2-5 | Runtime target can show toric duplicate tiles. | `HexTileMapLayer.visual_cell_entries_for_rect()`, `refresh_loop_display()` | `tests/test_hex_tile_map_layer.gd` checks entry schema, duplicate tile drawing, and wall/floor sync. | Editor scene view framing still needs observation. |
| 6-10 | Editor viewport click reaches Hex Map Edit and uses loop-aware hit. | `EditorPlugin._handles()`, `HexMapEditTool.forward_canvas_gui_input()`, `HexTileMapLayer.local_to_cell_hit()` | `tests/test_editor_plugin.gd` checks viewport transform route and loop duplicate viewport edit. | Godot editor forwarding requires manual observation. |
| 11-15 | Canonical document and duplicate tile update through Undo / Redo. | `HexMapEditTool._commit_document_change()`, `_apply_document_to_target()`, `HexTileMapLayer.refresh_loop_display()` | `tests/test_editor_plugin.gd` checks duplicate edit with Undo / Redo. | Visual confirmation in editor viewport remains useful. |
| 16-18 | Saved/exported resource persists canonical map only. | `HexMapDocumentAdapter.to_map_resource()` | Existing import/export tests cover canonical map roundtrip. | This draft does not include a dedicated exported-resource duplicate-count assertion. |

## ChatGPT Agent Judgement Packet

- Material to pass:
  - This file.
  - `docs/TEST.md`.
  - User observations or screenshots from the duplicate tile click, Undo, Redo, and exported resource inspection.
- Judgement criteria:
  - Duplicate tile visibility and clickability are observed.
  - The canonical and visual coordinate distinction is visible in status or inferred from changed cells.
  - Exported resource is canonical, not visual-copy-expanded.
- Required answer format:

```md
## Judgement

- Result: pass | conditional | fail
- Scope judged:
- Evidence:
- Missing observations:
- Follow-up test candidates:
```

## Follow-up Test Candidates

- Add an exported-resource assertion that counts canonical cells after duplicate edit.
- Add a visual debug scene control that exposes runtime `HexTileMapLayer` loop copy state directly.
