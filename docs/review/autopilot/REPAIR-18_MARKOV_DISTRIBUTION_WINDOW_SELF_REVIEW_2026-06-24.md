# REPAIR-18 Markov Distribution Window self-review

Date: 2026-06-24
Branch: `autopilot/ui`

## Scope

Restored Build graph Wall Field state/UI for custom Markov Mesh distributions.

## Changed files

- `addons/hex_map_kit/adapter/hex_wall_distribution_resource.gd`
  - New Resource implementing `prob(ref_conditions)` for 8-state Markov distribution weights.
- `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd`
  - Wall Field exposes `custom_distribution` when `wall_method=markov_mesh`.
  - Adds `Edit Distribution` action opening a Markov Mesh Distribution window with 8 probability spinboxes.
- `addons/hex_map_kit/generation/hex_generation_node_types.gd`
  - Wall Field passes `custom_distribution` into `generate_symmetric_toric_walls_interruptible` instead of always passing `null`.
- `tests/test_generation_graph.gd`
  - Proves an all-zero custom distribution reaches the wall generator and creates no walls.
- `tests/test_build_graph_canvas.gd`
  - Proves the inspector shows the Markov distribution editor action.

## Notes

Preset `distribution_id` remains available. Custom distribution is stored as an 8-value array in node params; the runtime wraps it in a Resource that implements the core `prob(ref_conditions)` contract.
