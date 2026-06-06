# GENERATED_MAP_MANUAL_EDIT Analog Test Result

## Metadata

- Source spec: `GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md`
- Result file created: 2026-06-01
- Reported runtime state: Godot Editor already running
- Reported progress: Operation steps 1-13 completed; failure begins at step 14
- Verification mode: user-observed analog test result consolidation

## Judgement

- Result: fail
- Scope judged:
  - Primary Generation through `HexMapResource` save/import/document save setup was treated as passed through step 13 based on the reported execution progress.
  - The manual edit interaction path beginning at viewport click was judged failed because step 14 did not produce the expected step 15 wall/floor mutation.
  - Steps 16-32 were not validly reachable after the step 14 failure.
- Evidence:
  - Test specification requires step 14 to click one visible generated floor cell in the editor viewport.
  - Expected observation after that click is that the clicked cell changes from floor to wall in the target `TileMapLayer`.
  - User report: “テストケース13まで実行しましたが、14から失敗しています。”
  - Therefore the first failing feature boundary is the manual viewport click handling path: `Hex Map Edit` `Wall / Floor` mode → viewport local position conversion → document mutation → redraw.
- Missing observations:
  - Exact failure symptom at step 14 is not yet captured: no visual change, wrong cell changes, click ignored, editor selection steals input, error log, or status text failure.
  - Godot Output panel errors/warnings at the moment of the click are not captured.
  - Selected `TileMapLayer` identity after `Refresh`/Target selection is not captured.
  - Mouse/tool focus state is not captured: whether the Hex Map Edit tool is actively receiving viewport input.
  - The clicked cell coordinate/resource state before and after click is not captured.
- Follow-up test candidates:
  - Add a minimal UI instrumentation test/log around `HexMapEditTool.apply_local_position()` to print local position, resolved cell coordinate, previous cell state, next cell state, and target layer name.
  - Add an editor-input smoke test that confirms Hex Map Edit receives viewport click events after `Edit Mode = Wall / Floor`.
  - Add a redraw checkpoint after document mutation: document changed count, wall/floor count, and visible `TileMapLayer` cell count.
  - Add a target-binding checkpoint after step 11: selected target layer path, tile set presence, orientation, and tile atlas settings.

## Failure Boundary

The failure boundary is **step 14: viewport click in Wall / Floor mode**.

The preceding steps establish that a generated primary map can be saved, imported, converted into an editing document, assigned to a target layer, saved, and put into `Wall / Floor` edit mode. The next required behavior is an interactive editor-viewport mutation. Because the test fails from step 14, the likely fault zone is not generation/import/document saving itself, but the bridge from editor input to document mutation and display redraw.

## Most Likely Fault Zones

1. **Viewport input is not reaching the edit tool**
   - Symptom: click is ignored completely.
   - Check: whether `_forward_canvas_gui_input`, editor plugin forwarding, or equivalent viewport input hook is active for the dock/tool.

2. **Target `TileMapLayer` is missing or stale**
   - Symptom: document may mutate internally, but display does not change.
   - Check: target layer path/name after step 11, and whether the layer is the same one used by generation.

3. **Local position to hex cell conversion is wrong**
   - Symptom: wrong cell changes, or click resolves outside the generated shape.
   - Check: printed local position and resolved axial/offset/canonical coordinate.

4. **Wall/Floor edit mutation is blocked by document state**
   - Symptom: click resolves to a cell but state does not toggle.
   - Check: previous cell classification, next classification, and whether `_commit_document_change()` is reached.

5. **Redraw path is not executed after mutation**
   - Symptom: save/load might later contain edit, but target layer remains visually unchanged.
   - Check: redraw call after commit and target layer cell count/atlas state.

## Recommended Immediate Debug Patch

Add temporary print logging at the entry and exit of the click application path. The log should include:

```gdscript
print("[HexMapEdit] apply click local=", local_position)
print("[HexMapEdit] target=", target_layer, " path=", target_layer.get_path() if target_layer else "<null>")
print("[HexMapEdit] mode=", edit_mode)
print("[HexMapEdit] resolved_cell=", cell)
print("[HexMapEdit] before=", before_state)
print("[HexMapEdit] after=", after_state)
print("[HexMapEdit] committed/redrawn")
```

If the first line does not appear, the bug is viewport input routing. If the first line appears but `target` is null/stale, the bug is target binding. If `resolved_cell` is invalid, the bug is coordinate conversion. If `after` changes but the screen does not, the bug is redraw/application to `TileMapLayer`.

## Final Status

This analog test cannot be marked pass or conditional pass. It is a concrete fail at the first manual viewport interaction checkpoint. The rest of the scenario should remain blocked until step 14/15 is fixed, because Undo/Redo, Shape edit, save/load persistence, export, and Source Registry reuse all depend on the same document mutation path being trustworthy.
