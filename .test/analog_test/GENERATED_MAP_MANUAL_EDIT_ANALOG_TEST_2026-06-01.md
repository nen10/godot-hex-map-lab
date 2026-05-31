# GENERATED_MAP_MANUAL_EDIT Analog Test

## Metadata

- Status: blocked_by_step_14_viewport_input
- Code reading: `docs/review/GENERATED_MAP_MANUAL_EDIT_CODE_READING_2026-06-01.md`
- Result review: `docs/review/GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md`
- Failure analysis: `docs/review/GENERATED_MAP_MANUAL_EDIT_FAILURE_ANALYSIS_2026-06-01.md`
- Implementation plan: `docs/plan/MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_IMPLEMENTATION_PLAN_2026-06-01.md`
- Source plans:
  - `docs/complete_on_test/MULTI_LAYER.md`
  - `docs/complete_on_test/EDITOR_PLUGIN.md`
  - `docs/plan/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md`
- Target Editor Plugin area: Map Generation Dock, Hex Map Edit Dock, Source Registry
- Participating features: Primary Generation, `Save .tres`, Target `TileMapLayer` apply, `HexMapResource` import, `HexMapDocumentResource` save/load, wall/floor edit, shape edit, Undo/Redo, edited `HexMapResource` export, edited map Source Registry load
- Created date: 2026-06-01

## Use Case

- Actor: Godot Editor user
- Goal: File-output primary map data generated in bulk can be imported into the manual editing tool, edited by hand, saved as an editing document, exported as edited map data, and reused as a Multi Layer source.
- Scenario: The user generates a primary map from the Map Generation Dock, saves it as `HexMapResource`, imports that file in Hex Map Edit, changes wall/floor and shape cells manually, saves the document, exports an edited `HexMapResource`, then loads the edited resource into Source Registry for overlay generation.
- Success state: The edited canonical map data is visible in the target layer, survives document save/load, exports as `HexMapResource`, and exposes `Any` / `Floor` / `Wall` item keys when loaded as a Source Registry source.

## Preconditions

- Godot project state: `res://addons/hex_map_kit/plugin.cfg` is enabled in the editor.
- Addon state: The left dock contains Map Generation Dock and `Hex Map Edit`.
- Scene/resource files: A scene is open. It may be empty if `Add new layer...` is used.
- Required node setup: One editable `TileMapLayer` exists, or the user creates one from the Map Generation Dock Target control.
- Data to prepare:
  - Generated map path: `res://.godot_user/analog_generated_primary_map.tres`
  - Manual document path: `res://.godot_user/analog_manual_document.tres`
  - Edited map export path: `res://.godot_user/analog_manual_export.tres`

## Inputs

- User operations: Generate, Save `.tres`, Import Map, viewport cell click, Undo, Redo, Save document, Load document, Export map, Source Registry Load `.tres`.
- Editor selection: Target `TileMapLayer` for generated display and manual edit display.
- Resource files: Saved generated `HexMapResource`, saved `HexMapDocumentResource`, exported edited `HexMapResource`.
- Runtime/display settings:
  - Primary Generation mode
  - Orientation: flat-top / Vertical Offset
  - Apply Write: Clear And Write
  - Floor tile: source 0, atlas `(0, 0)`
  - Wall tile: source 0, atlas `(1, 0)`

## Outputs

- Visible Editor state:
  - Generated primary map appears in the selected `TileMapLayer`.
  - Manual wall/floor and shape edits redraw the selected `TileMapLayer`.
  - Undo / Redo changes both document state and displayed tile state.
  - Source Registry shows the edited resource path and `Any` / `Floor` / `Wall` counts.
- Resource mutations:
  - `HexMapResource` is saved from generation output.
  - `HexMapDocumentResource` is created from imported map resource and saved.
  - Edited `HexMapResource` is exported from the document.
- Saved files:
  - `res://.godot_user/analog_generated_primary_map.tres`
  - `res://.godot_user/analog_manual_document.tres`
  - `res://.godot_user/analog_manual_export.tres`
- Status text / logs:
  - Generation stats show cells / walls / floors / connected.
  - Hex Map Edit status reports import, edit, save, export events.
  - Source Registry status shows loaded source details.

## Operation Steps

1. Open Godot Editor with this project and confirm the addon is enabled.
2. In Map Generation Dock, select Primary Generation by leaving `Overlay` off.
3. Choose a small deterministic map, for example `Simple`, `Rectangle`, `Width = 6`, `Height = 4`, `Seed = 1201`, `Wall Prob = 0.35`, `Restore Connectivity = On`.
4. Select or create a `TileMapLayer` from `Target`. Use `Use Sample Tiles` if the layer does not already have a visible hex TileSet.
5. Press `Generate`.
6. Confirm the target layer displays a generated floor/wall map and the stats text reports nonzero cells.
7. Press `Save .tres` and save the resource as `res://.godot_user/analog_generated_primary_map.tres`.
8. Open `Hex Map Edit`.
9. In `Import Map`, enter `res://.godot_user/analog_generated_primary_map.tres` and press `Import`.
10. In `Document`, enter `res://.godot_user/analog_manual_document.tres`.
11. Set `Target` to the same `TileMapLayer` used for generation, or press `Refresh` and select it.
12. Press `Save` in Hex Map Edit to save the imported map as a document.
13. Set `Edit Mode` to `Wall / Floor`.
14. Click one visible generated floor cell in the editor viewport.
15. Confirm the clicked cell changes from floor to wall in the target layer.
16. Use Godot Editor Undo.
17. Confirm the clicked cell returns to floor.
18. Use Godot Editor Redo.
19. Confirm the clicked cell becomes wall again.
20. Set `Edit Mode` to `Shape`.
21. Click an empty hex position adjacent to the generated map boundary.
22. Confirm a new shape cell is added and drawn in the target layer.
23. Press `Save` in Hex Map Edit.
24. For a persistence checkpoint, reopen the project or start from a fresh editor session, then press `Load` with `res://.godot_user/analog_manual_document.tres`.
25. Confirm the saved wall/floor and shape edits are restored after loading the document.
26. In `Export`, enter `res://.godot_user/analog_manual_export.tres` and press `Export`.
27. Return to Map Generation Dock and enable `Overlay`.
28. In Source Registry, press `Load .tres` and load `res://.godot_user/analog_manual_export.tres`.
29. Confirm Source Registry details include `Any`, `Floor`, and `Wall` item counts for the edited map.
30. In Placement Mask, add a row using the edited map source and item key `Floor`.
31. Generate a simple overlay item, for example `Uniform Distribution`, one item key `Tree`, and a small limit or low placement probability.
32. Confirm overlay generation runs using the edited map source as a candidate filter.

## Expected Observations

- The generated file imports into Hex Map Edit without type errors.
- The document is created from the generated map resource, not from the visual `TileMapLayer`.
- Manual `Wall / Floor` edits affect the document map and redraw the target layer.
- Manual `Shape` edits can add a missing cell and redraw the target layer.
- Undo / Redo restores both document data and target layer display.
- Saving and loading `HexMapDocumentResource` preserves map edits.
- Exported `HexMapResource` preserves canonical cells, walls, orientation, and cyclic size.
- Loading the exported map in Source Registry exposes primary item keys from the edited map.

## Failure Signals

- `Import Map` reports that the saved generated file is not a `HexMapResource`.
- The imported map does not redraw on the selected target layer.
- A viewport click changes the `TileMapLayer` visually but is lost after document save/load.
- Undo / Redo changes the document without redrawing the target layer, or redraws without changing the document.
- Exported edited map cannot be loaded as `HexMapResource`.
- Source Registry does not show `Any` / `Floor` / `Wall` for the edited export.

## Code Reading Verification

| Step | Expected program behavior | Code path | Evidence | Remaining risk |
| --- | --- | --- | --- | --- |
| 1-7 | Primary generation can become saved `HexMapResource`. | `HexMapGenDock.current_resource()` and save handler. | `code_reading_pass`; see `docs/review/GENERATED_MAP_MANUAL_EDIT_CODE_READING_2026-06-01.md`. | File dialog operation still needs UI observation. |
| 8-12 | Saved `HexMapResource` imports into `HexMapDocumentResource` and can be saved. | `HexMapEditTool.import_map_resource_from_path()`, `HexMapDocumentAdapter.from_map_resource()`, `save_document()`. | `code_reading_pass`; relevant headless tests passed in `./tools/test.sh`. | None beyond UI path entry. |
| 13-25 | Manual wall/floor and shape edits mutate the document, redraw target layer, and support Undo/Redo save/load. | `apply_local_position()`, `_apply_mode_to_document()`, `_commit_document_change()`, `HexMapDocumentAdapter`, `EditorPlugin._forward_canvas_gui_input()`. | `blocked_by_missing_editor_viewport_trace`; direct `apply_local_position()` tests pass, but user analog result fails at Step 14. | Requires `docs/plan/MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_IMPLEMENTATION_PLAN_2026-06-01.md`. |
| 26-32 | Edited map exports and can be loaded as Multi Layer Source Registry primary data. | `export_map_resource_to_path()`, `HexMapDocumentAdapter.to_map_resource()`, `HexMapGenDock.load_mapdata_source()`. | `code_reading_pass`; Source Registry and Placement Mask tests cover `HexMapResource` item key details and overlay candidate filtering. | Overlay placement result should be observed visually. |

## ChatGPT Agent Judgement Packet

- Material to pass:
  - This file.
  - `docs/review/GENERATED_MAP_MANUAL_EDIT_CODE_READING_2026-06-01.md`.
  - Optional user observations: screenshots of generated map, edited map, Source Registry details, and overlay result.
- Judgement criteria:
  - The generated `.tres` is imported as map data, not manually reconstructed.
  - Manual edits are saved in `HexMapDocumentResource` and can be reloaded.
  - Exported edited `HexMapResource` can be used as Source Registry input.
  - Any missing observation is listed as runtime/UI observation, not as code evidence.
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

- A dedicated analog test for manual editing of overlay resources, if direct `HexOverlayResource` manual edit becomes a user goal.
- A UI observation focused only on Source Registry Placement Mask result after edited-map export.
- A visual check for Shape mode boundary clicking on a large map where the target empty hex is easy to identify.
