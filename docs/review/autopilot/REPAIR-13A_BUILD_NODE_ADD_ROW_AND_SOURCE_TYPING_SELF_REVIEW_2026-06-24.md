# REPAIR-13A Build Node Add Row and Source Typing self-review

Date: 2026-06-24
Branch: `autopilot/ui`

## Scope

Implemented a grouped Add Node row under the Build graph canvas and typed Source entries.

## Changed source files

- `addons/hex_map_kit/editor/hex_map_build_node_palette.gd`
  - Palette is now a bottom grouped Add Node row.
  - Groups: Anchor / Build / Select.
  - Adds Source Terrain and Source Overlay typed templates.
  - Compose is not in the primary Add Node row.
- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
  - Places the Add Node row below the graph canvas.
  - Handles node templates with initial params.
- `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
  - Supports initial node params at creation so Source Overlay is typed before slot/output construction.
  - Source node title reflects output type: Source Terrain / Source Overlay.
- `tests/test_build_graph_canvas.gd`
  - Proves grouped row snapshot, Source Overlay typed params, output type, and title.

## Notes

- Terrain Filter / Overlay Filter runner split is still REPAIR-13 proper; this task only creates the UI/source typing affordance.
- Compose remains available as a node type internally but is not a primary row button.
