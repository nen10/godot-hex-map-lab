# CAT-02 UX

## User Outcome

Authors can check whether a tile catalog can resolve its raw Godot asset references before later editor UI or runtime apply paths use the catalog. Validation reports missing TileSet, missing source ids, invalid atlas coordinates, missing scene paths, and extracted tag/custom-data facts in a headless-testable format.

## Operation Steps

1. Provide a `HexTileCatalogResource` and optional `TileSet` to the validation helper.
2. Receive a `HexMapValidationResult` with grouped catalog warnings/errors.
3. Ask the helper for a catalog key's tags and TileSet custom data when a valid atlas tile exists.
4. Use the result in later dashboard and adapter tasks without duplicating raw TileSet probing logic.

## Non-Goals

- Render validation in editor UI. That belongs to `VAL-02`.
- Apply catalog keys to documents or tile maps. That belongs to `CAT-03`.
- Define movement profile rules. That belongs to `GAME-01`.
