# GAME-01 UX

## User Outcome

Runtime and gameplay code should be able to ask whether a generated/document cell is passable, what it costs to enter, and which gameplay blocker keys apply.

## Gameplay Data

- Movement profiles define default floor behavior, wall behavior, movement costs, blocker keys, and blocker tags.
- Gameplay layer data extracts per-cell passability, movement cost, and blockers from map walls, catalog-backed terrain assignments, and object placements.
- Pathfinding and range APIs remain queued for `GAME-02`.

## Non-Goals

- Weighted pathfinding is deferred to `GAME-02`.
- Profile-specific reachability validation is deferred to `GAME-04`.
