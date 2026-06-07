# VAL-01 UX

## User Outcome

The project should have a reusable validation engine that detects common document/catalog mistakes before editor dashboard work begins. Results must be serializable through `HexMapValidationResult` and precise enough for future UI grouping.

## Rules Covered

- Tile payload outside the map.
- Orphan object/label payloads.
- Catalog key used without a catalog resource.
- Catalog key or entry pointing to a missing tile.
- Required dependency path missing.
- Object placement on a wall cell.

## Non-Goals

- Dashboard UI and click-to-focus behavior are deferred to `VAL-02`.
- Exhaustive rule matrix fixtures are deferred to `VAL-04`.
