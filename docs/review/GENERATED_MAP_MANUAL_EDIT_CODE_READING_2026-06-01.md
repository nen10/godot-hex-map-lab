# GENERATED_MAP_MANUAL_EDIT_CODE_READING_2026-06-01.md

## Summary

Result: `superseded_by_analog_result`

2026-06-01 analog execution failed at Step 14. This file remains as the pre-execution code-reading record, but its conclusion is superseded by:

- `docs/review/GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md`
- `docs/review/GENERATED_MAP_MANUAL_EDIT_FAILURE_ANALYSIS_2026-06-01.md`
- `docs/plan/MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_IMPLEMENTATION_PLAN_2026-06-01.md`

The missed gap was the real Editor viewport input bridge: `plugin.gd` does not implement `_handles()`, and `HexMapEditTool.forward_canvas_gui_input()` uses `mouse_event.position` as if it were already target-local/canvas-local.

The use case is supported for primary generated map data:

1. Map Generation Dock produces a `HexMapResource` from current primary generation data and saves it as `.tres`.
2. Hex Map Edit imports that saved `HexMapResource` into a `HexMapDocumentResource`.
3. Manual wall/floor and shape edits mutate the document, redraw the target layer, and are undoable.
4. The document can be saved and loaded.
5. The edited document can export a `HexMapResource`.
6. The exported edited map can be loaded into Map Generation Dock Source Registry as primary map data exposing `Any` / `Floor` / `Wall` item keys.

No development plan is required for this primary-map manual editing use case.

## Scope

対象:

- `docs/complete_on_test/MULTI_LAYER.md`
- `docs/complete_on_test/EDITOR_PLUGIN.md`
- `docs/plan/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md`
- `.test/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md`

This verification does not claim direct manual editing of `HexOverlayResource`. Overlay linkage is verified as "edited primary map exported from manual edit can be reused as a Multi Layer Source Registry input."

## Test Execution Evidence

Command:

```sh
./tools/test.sh
```

Result:

- `tests/test_hex_core.gd`: all tests passed
- `tests/test_hex_map_generation.gd`: all tests passed
- `tests/test_hex_adapter.gd`: all tests passed
- `tests/test_hex_tile_map_layer.gd`: all tests passed
- `tests/test_editor_plugin.gd`: all tests passed
- `tests/test_debug_scenes.gd`: all tests passed

Godot emitted the documented macOS certificate warning:

```text
ERROR: Condition "ret != noErr" is true. Returning: ""
```

`docs/TEST.md` states that this non-fatal macOS certificate error with exit code 0 is known and ignored.

## Requirement Verification

| Requirement | Evidence | Judgement |
| --- | --- | --- |
| File-output generated primary map data can exist as `HexMapResource`. | `HexMapGenDock.current_resource()` returns `HexMapResource.from_map_data(_current_data, _current_orientation)` when Overlay is off. `Save .tres` uses `ResourceSaver.save(resource, path)`. | `code_reading_pass` |
| Generated map file can be imported by manual edit. | `HexMapEditTool.import_map_resource_from_path()` loads the path, requires `resource is HexMapResource`, then calls `import_map_resource()`. `HexMapDocumentAdapter.from_map_resource()` copies map data and orientation. | `code_reading_pass` |
| Imported generated map becomes resource-primary editable document. | `HexMapDocumentResource` exports `map`, `tile_overrides`, `objects`, `labels`, `version`. `HexMapEditTool.save_document()` persists `_document`. | `code_reading_pass` |
| User can manually edit wall/floor and shape cells. | `apply_local_position()` resolves a hit, then `apply_cell()` snapshots the document and calls `_apply_mode_to_document()`. Shape uses `set_cell_exists()`. Wall/floor uses `set_wall()`. | `code_reading_pass` |
| Manual edit redraws display layer. | `_commit_document_change()` calls `_apply_document_to_target()` for do/undo. Plain `TileMapLayer` uses `HexMapDocumentAdapter.apply_to_tile_map_layer()`. `HexTileMapLayer` uses `apply_map()` with converted map resource. | `code_reading_pass` |
| Undo / Redo restores document and display. | `_commit_document_change()` registers do/undo methods for document replacement and target apply. `tests/test_editor_plugin.gd` verifies document state and tile atlas after undo/redo. | `code_reading_pass` |
| Document save/load preserves manual edits. | `save_document()` uses `ResourceSaver.save(_document, actual_path)`. `load_document()` requires `HexMapDocumentResource`, assigns `_document`, and reapplies target. Adapter tests save and load document resource. | `code_reading_pass` |
| Edited document exports back to map resource. | `export_map_resource_to_path()` saves `export_map_resource()`. `export_map_resource()` calls `HexMapDocumentAdapter.to_map_resource()`, which copies `document.map.to_map_data()` and orientation. | `code_reading_pass` |
| Edited exported map can be used by Multi Layer Source Registry. | `HexMapGenDock.load_mapdata_source()` loads a resource and calls `register_mapdata_source()`. `register_mapdata_source()` accepts `HexMapResource`, converts to `to_map_data()`, and stores `data.item_keys()`. Source Registry tests verify `Any`, `Floor`, `Wall` counts. Placement Mask tests verify selected primary item keys filter overlay candidates. | `code_reading_pass` |

## Code Trace

### Plugin and Dock Availability

- `addons/hex_map_kit/plugin.gd`
  - `_enter_tree()` creates Map Generation Dock and adds it to the dock.
  - `_enter_tree()` creates `Hex Map Edit`, gives it editor UndoRedo, and adds it to the dock.
  - `_forward_canvas_gui_input()` forwards viewport mouse events to Hex Map Edit.

Evidence:

- `tests/test_editor_plugin.gd::_test_map_edit_tool_builds_dock_controls()` checks the separate `Hex Map Edit` dock name, document path controls, import controls, export button, edit mode list, and target layer options.

### Generated Map Output

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `Save .tres` button is wired to `_on_save_pressed()`.
  - `_on_save_pressed()` obtains `_resource_for_save_button()`, opens an editor save file dialog, and binds the selected path to `_on_save_file_selected()`.
  - `_on_save_file_selected()` calls `ResourceSaver.save(resource, path)`.
  - `current_resource()` returns `HexMapResource.from_map_data(_current_data, _current_orientation)` in primary mode.

Evidence:

- `tests/test_editor_plugin.gd::_test_generation_dock_resource_stores_orientation()` verifies `current_resource()` keeps orientation and map cells.
- `tests/test_editor_plugin.gd::_test_generation_dock_applies_configured_tile_entries()` verifies generated data applies to a target layer with configured floor/wall tiles.
- `tests/test_editor_plugin.gd::_test_generation_dock_applies_orientation_to_tile_entries()` verifies orientation affects tile entries.

### Manual Import and Document Save

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `import_map_resource_from_path()` loads the path and rejects non-`HexMapResource`.
  - `import_map_resource()` converts the resource with `HexMapDocumentAdapter.from_map_resource()`.
  - `save_document()` writes `_document` with `ResourceSaver.save()`.
  - `load_document()` loads `HexMapDocumentResource` and reapplies it to target.

- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
  - `from_map_resource()` copies `resource.to_map_data()` and orientation into a new document.
  - `to_map_resource()` copies document map data and orientation back into `HexMapResource`.

Evidence:

- `tests/test_editor_plugin.gd::_test_map_edit_tool_imports_generated_map_resource()` verifies import, export, save document, export-to-path, and import-from-path.
- `tests/test_hex_adapter.gd::_test_hex_map_document_roundtrips_map_and_payloads()` verifies document save/load preserves cells, walls, orientation, tile override, object properties, and labels.

### Manual Editing and Undo/Redo

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
  - `forward_canvas_gui_input()` converts left mouse click to target local position.
  - `apply_local_position()` resolves editable cell hit.
  - `apply_cell()` duplicates before/after document snapshots.
  - `_apply_mode_to_document()` applies shape, wall/floor, tile override, object, or label mutation.
  - `_commit_document_change()` registers do/undo document replacement and target redraw.
  - `_apply_document_to_target()` redraws either `HexTileMapLayer` or plain `TileMapLayer`.

- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
  - `set_wall()` updates document map walls.
  - `set_cell_exists()` adds/removes shape cells and removes payloads for deleted cells.
  - `apply_to_tile_map_layer()` redraws the map and applies tile overrides.

Evidence:

- `tests/test_editor_plugin.gd::_test_map_edit_tool_click_updates_document_with_undo_redo()` verifies wall/floor click, layer redraw, undo, redo, shape add, floor tile override, object payload, and label payload.
- `tests/test_hex_adapter.gd::_test_hex_map_document_adapter_updates_wall_floor()` verifies wall/floor and shape mutation plus payload cleanup.
- `tests/test_hex_adapter.gd::_test_hex_map_document_adapter_applies_tile_overrides()` verifies redraw with tile override source / atlas / alternative.

### Edited Map as Multi Layer Source

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `load_mapdata_source()` loads a `.tres` resource with `ResourceLoader`.
  - `register_mapdata_source()` accepts both `HexMapResource` and `HexOverlayResource`.
  - For `HexMapResource`, it stores `resource.to_map_data()` and `data.item_keys()`.
  - Primary map data exposes `Any`, `Floor`, and `Wall` item keys through `HexMapData`.

Evidence:

- `tests/test_editor_plugin.gd::_test_generation_dock_mapdata_source_registry_load_reload_clear()` verifies Source Registry stores sources, reloads by path, and for a `HexMapResource` shows `Any`, `Floor`, and `Wall` counts.
- `tests/test_editor_plugin.gd::_test_generation_dock_mapdata_query_rows_evaluate_offset_and_toric()` verifies `HexMapResource` query rows expose scoped item-key combos and evaluate `Floor` / `Wall` source items.
- `tests/test_editor_plugin.gd::_test_generation_dock_overlay_placement_mask_filters_candidates()` verifies a registered `HexMapResource` source and selected primary item key restrict overlay generation candidates.
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_CORE_OVERLAY_UNIFORM.md` records primary item keys and overlay data behavior.
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_EDITOR_OVERLAY_BASIC.md` records overlay generation and Source Registry use as completed-on-test scope.

## Remaining Runtime Observations

These do not block code reading pass, but they are appropriate ChatGPT agent observation points:

- Save file dialog path selection for generated `.tres`.
- Viewport click location for boundary Shape mode add.
- Visual confirmation that target `TileMapLayer` redraws in the editor viewport.
- Visual confirmation that Source Registry details show the edited exported resource and item counts.
- Visual confirmation that overlay generation uses the edited exported map as Placement Mask source.

## Follow-up Test Candidates

- Direct manual editing of `HexOverlayResource`, if overlay data manual editing becomes a requested use case.
- A focused headless test that chains `HexMapGenDock.current_resource()` -> `HexMapEditTool.import_map_resource()` -> manual edit -> `export_map_resource()` -> `HexMapGenDock.register_mapdata_source()` in one scenario.
- A UI analog test focused on Source Registry Placement Mask visualization after manual edited export.
