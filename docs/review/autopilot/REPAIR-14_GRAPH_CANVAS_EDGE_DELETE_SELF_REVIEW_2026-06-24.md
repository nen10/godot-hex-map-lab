# REPAIR-14 Graph Canvas Edge Delete self-review

Date: 2026-06-24
Branch: `autopilot/ui`

## Scope

Implemented first-class Build graph edge selection/deletion.

## Changed source files

- `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
  - Added selected edge state.
  - Added `select_edge`, `selected_edge`, `delete_selected_edge`, and `delete_edge` APIs.
  - Delete/Backspace deletes selected edge before node deletion.
  - Mouse click can select the closest connection via `get_closest_connection_at_point`.
  - Edge delete disconnects only the selected connection, clears edge selection, increments graph revision, and dirties the target/downstream nodes.
  - `canvas_snapshot()` now exposes selected edge proof fields.
- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
  - Added visible `Delete Edge` button.
  - Button enables only when an edge is selected and invokes selected-edge deletion.
- `tests/test_build_graph_canvas.gd`
  - Added regression proof for edge selection, visible action enable/disable, deletion without node deletion, and dirty downstream state.

## Notes

- Node deletion remains separate from edge deletion.
- Context menu is not required for proof.
- Selection visual highlight uses GraphEdit connection activity; snapshot proof backs it with deterministic state assertions.
