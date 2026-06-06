# GAME-02 Self Review

Date: 2026-06-07
Task: `GAME-02`
Status: COMPLETE

## Acceptance review

| Requirement | Evidence | Status |
|---|---|---|
| Weighted path | `HexGrid.weighted_path()` / `weighted_path_to_any()` use Dijkstra traversal with cost-to-enter semantics. Core tests prove a longer route can beat a high-cost direct route. | pass |
| Blocked cells | Weighted traversal accepts only `enterable_points`; layer calls use `HexGameplayLayerData.passable_cells()`. Core and layer tests cover disconnected blocked cells and default wall blockers. | pass |
| Profile-specific range | `HexTileMapLayer.movement_range()` builds passable cells and costs from the active movement profile. Layer tests cover default blocked walls and a passable-wall profile reaching through the same cell. | pass |
| Existing unweighted path compatibility | `HexGrid.shortest_path()` and `HexTileMapLayer.find_path()` were left unchanged. Core tests assert unweighted path still prefers the fewest-step direct route. | pass |
| Test path | `./tools/test.sh` completed with exit code `0`. | pass |
| Docs update | `docs/TEST.md` now lists weighted path/range and layer profile coverage. | pass |

## Repair classification

- `repair-now`: none.
- `follow-up-ready`: none.
- `known-env-failure`: none.
- `accepted-risk`: none.
- `manual-optional`: none.

## Notes

- Range results are dictionaries keyed by `HexVector.key()` with `{ "cell": HexVector, "cost": float }` values so future overlays can use both display cell and accumulated cost.
- Weighted helper costs can be passed directly as key-to-float dictionaries; missing costs default to `1.0`.
