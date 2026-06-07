# GAME-02 Policy

Date: 2026-06-07

## Decisions

- Weighted movement uses cost-to-enter semantics. The start cell has accumulated cost `0.0`; each neighbor adds that neighbor's movement cost.
- A missing movement cost defaults to `1.0` so legacy floor-only data remains usable.
- Negative costs are treated as non-enterable for weighted queries. `HexMovementProfile` already clamps configured costs to zero; this guard protects direct dictionary callers.
- `HexGrid.shortest_path()` remains unchanged and keeps breadth-first, fewest-step behavior.
- `HexTileMapLayer` derives weighted query inputs from `HexGameplayLayerData`, preserving the movement profile boundary introduced by `GAME-01`.

## Repair classification

- `repair-now`: incorrect blocked-cell exclusion, broken legacy `find_path()`, range returning cells above budget, or missing `./tools/test.sh` proof.
- `follow-up-ready`: richer range visualization or validation UI beyond queue acceptance.
- `manual-optional`: visual confirmation of future overlays only.
