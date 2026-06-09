# CLEAN-20 Implementation Plan

1. Mark CLEAN-20 `RUNNING` in the queue.
2. Update `HexMapEditorSessionState` so selected document/import resources are first-class state and saved paths are optional metadata.
3. Update `HexMapEditTool`:
   - Keep document/object/label resource pickers as standard inputs.
   - Add an import `HexMapResource` picker.
   - Convert document/import/export path controls to read-only saved-location status.
   - Stop wiring path `LineEdit.text_changed` to selection state.
   - Enable Load/Import from selected resources or saved paths.
4. Rewrite editor tests away from editable path control expectations.
5. Run `./tools/test.sh`, self-review, repair any `repair-now` findings, update queue, and commit.
