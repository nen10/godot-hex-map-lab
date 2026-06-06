# GAME-01 Policy

## Profile Boundary

`HexMovementProfile` owns core passability/cost/blocker rule logic. `HexMovementProfileResource` is the saveable adapter-layer wrapper. Gameplay extraction should produce plain per-cell state that later pathfinding can consume without depending on editor UI.

## Defaults

The default profile treats floors as passable at cost `1.0` and walls as blocked by the stable blocker key `wall`. Profiles may override default costs, wall passability, catalog-key costs, tag costs, blocker keys, and blocker tags.

## Repair Classification

- `repair-now`: missing defaults, missing Resource wrapper, missing map/document gameplay extraction, or full test suite failure.
- `follow-up-ready`: weighted pathfinding/range queries beyond this data layer.
- `manual-optional`: none.
