# GAME-02 Weighted Path and Range UX

Date: 2026-06-07

## User-facing outcome

Runtime and editor-facing scripts can ask a `HexTileMapLayer` for movement-aware gameplay queries without reimplementing traversal:

- unweighted `find_path()` keeps the existing floor-only behavior;
- weighted pathfinding can choose a longer route when terrain costs make it cheaper;
- blocked cells are excluded by the active movement profile;
- movement range returns reachable cells with accumulated movement cost.

## Operation Steps

1. Create or load a `HexTileMapLayer`.
2. Optionally provide a `HexMovementProfileResource`.
3. Call `find_weighted_path(start, goal, profile)` for cost-aware pathing.
4. Call `movement_range(start, budget, profile)` for range preview data.
5. Use the returned path/range data in gameplay scripts or later debug overlays.

## Non-goals

- No new visual heatmap overlay in this task; that is `GAME-03`.
- No profile-specific validation issue UI in this task; that is `GAME-04`.
- No runtime example scene in this task; that is `GAME-05`.
