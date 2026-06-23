# REPAIR-16 Region Filter node typing redesign self-review

Date: 2026-06-24
Branch: `autopilot/ui`
Decision: 案A (separate typed node types).

## Problem (verified)

Region Filter declared `accepts=[terrain, overlay]` but the canvas maps a multi-accept
input to a single slot type id (`accepts[0]` = terrain = 1). GraphEdit only allows a drag
connection when port type ids are equal, so an overlay output (3) could never be connected
to the filter in the editor, even though logical validation accepted it. The REPAIR-13A
Terrain/Overlay Filter buttons only changed params on the same `region_filter` node, so the
port type did not actually differ.

## Change

- `hex_generation_node_types.gd`: added `NODE_TERRAIN_FILTER` (input accepts terrain only)
  and `NODE_OVERLAY_FILTER` (input accepts overlay only); both output selection and reuse
  `_run_region_filter`. `NODE_REGION_FILTER` is retained as a known type for backward graph
  loading and existing tests, but is no longer offered in the Add Node row.
- `hex_map_build_graph_canvas.gd`: titles, NODE_TYPE_ORDER, and default params for the two
  typed nodes; default vertical slice chain now uses `terrain_filter`.
- `hex_map_build_node_palette.gd`: Terrain Filter / Overlay Filter buttons now create the
  typed node types instead of region_filter+params.
- `hex_map_build_node_inspector.gd`: param keys/visibility/migration and `filter_target`
  options for the typed nodes (Overlay Filter exposes item key only; Terrain Filter floor/wall/any).
- `hex_map_build_screen.gd`: effective flat-top hook also covers terrain_filter.
- `tests/test_build_graph_canvas.gd`: proves overlay output port type matches Overlay Filter
  input type (editor-connectable), terrain matches Terrain Filter, and cross-type ids differ
  (editor blocks), plus logical validate_connection parity.

## Notes

- The editor connectivity is achieved through Godot's implicit equal-type drag rule, so no
  `add_valid_connection_type` registration is needed once ports are single-typed.
- `is_valid_connection_type` was intentionally NOT used as the test signal because it only
  reports explicitly added pairs (false for unadded equal types); the test asserts type-id
  equality instead.
