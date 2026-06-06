# GAME-03 Movement Debug Overlay UX

Date: 2026-06-07

## User-facing outcome

Runtime and debug tooling can show a movement range overlay that communicates:

- which cells are reachable from a start cell;
- each reachable cell's accumulated movement cost;
- a simple heat color ramp from low cost to high cost.

## Operation Steps

1. Load or generate a map in `HexTileMapLayer` or the generated-map debug scene.
2. Compute movement range with an optional movement profile.
3. Draw the movement range overlay.
4. Inspect the same overlay state through headless-testable getters.

## Non-goals

- No validation rules in this task; that is `GAME-04`.
- No standalone runtime sample scene in this task; that is `GAME-05`.
- No new editor dock panel or validation dashboard coupling.
