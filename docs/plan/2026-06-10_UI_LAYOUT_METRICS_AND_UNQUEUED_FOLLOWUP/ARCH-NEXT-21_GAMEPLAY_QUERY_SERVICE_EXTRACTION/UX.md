# User Goal

Keep `HexTileMapLayer` as the runtime coordinator while moving gameplay query computation into a dedicated façade/service so movement/path/connectivity behavior is isolated from rendering ownership.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Preserve existing public query methods on `HexTileMapLayer` while shifting underlying computation to a service object | high | low | low | adopt | No caller breakage; API continuity for map layer users. |
| Keep query code inline in layer with small helper function | medium | low | low | reject | does not improve maintenance boundary for runtime query logic. |
| Duplicate service logic in samples and layer to reduce indirection | low | high | high | reject | duplicates logic and increases drift risk in gameplay results. |

## Adopted Experience

- Existing gameplay query public calls (`find_path`, `find_weighted_path`, `movement_range`, connectivity methods) keep working and now delegate to a service.
- Rendering and overlay methods remain in `HexTileMapLayer` and call the service only for computed data.
- Runtime sample path/range output is still produced from public intent (document, start/goal, budget, profile) but now explicitly from the service path.

## Experience Steps

1. Runtime query call enters `HexTileMapLayer` public API (`find_path`, `movement_range`, etc.).
2. Layer builds/uses a `HexGameplayQueryService` with map data and passes optional movement profile/catalog.
3. Service computes path/range/connectivity on map data.
4. Layer renders overlay/selection using existing rendering methods with returned service values.
5. Runtime sample calls service helper and validates computed results via same path/range profile rules.
