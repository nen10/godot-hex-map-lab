# REPAIR-17 Adjacency Rules Window self-review

Date: 2026-06-24
Branch: `autopilot/ui`

## Scope

Replaced the Build graph Item Generator adjacency rules UI path with a structured editor entry instead of raw text as the primary path.

## Changed files

- `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd`
  - `probability_rules` now uses an `Edit Rules` action with an `Adjacency Rules Window`.
  - Window includes a hex direction panel plus wall-count, connected-component-count, and probability controls.
  - The committed param is structured: `{default, rules:[{count, components, probability, directions}]}`.
- `addons/hex_map_kit/generation/hex_generation_node_types.gd`
  - Item Generator adjacency_rules accepts structured dictionary params and converts them to core probability rules.
  - Text parsing is still accepted as a fallback for existing graphs, but it is no longer the primary inspector UI path.
- `tests/test_generation_graph.gd`
  - Proves structured adjacency rules are accepted by the runner.
- `tests/test_build_graph_canvas.gd`
  - Proves the inspector exposes the Adjacency Rules editor action.

## Notes

This is a first structured window. It records direction toggles in state, while the current core probability model still uses count/components; REPAIR-15 will audit whether direction masks should affect generation semantics beyond UI state.
