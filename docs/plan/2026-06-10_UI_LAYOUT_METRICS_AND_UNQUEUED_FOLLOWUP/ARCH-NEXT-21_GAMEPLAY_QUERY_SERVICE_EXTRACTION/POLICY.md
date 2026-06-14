## Adopted Decisions

- `HexTileMapLayer` remains the public runtime coordinator and public method surface.
- `HexGameplayQueryService` owns runtime gameplay query computation:
  - `find_path`
  - `find_weighted_path`
  - `movement_range`
  - `is_map_connected`
  - `connected_component`
  - `connected_component_from_local`
- Query computation is null-safe and usable without scene-node context.

## Rejected Decisions

- Do not change public signatures on `HexTileMapLayer` gameplay query methods.
- Do not move rendering methods (`draw_path`, `draw_movement_range`, `_draw_overlay`, highlight methods) off the layer.
- Do not duplicate gameplay query logic in runtime samples and layer.

## Resource / API / UI Boundary

| area | owner | boundary |
|---|---|---|
| Gameplay query compute + movement profile + tile passability/cost interpretation | `HexGameplayQueryService` | Canonical compute boundary. |
| Query API entry points and overlay rendering | `HexTileMapLayer` | Coordinator boundary. |
| Runtime query examples (`runtime_query_sample.gd`) | `HexRuntimeQuerySample` | Calls into `HexGameplayQueryService` and returns service-derived results. |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Legacy inline query path in `HexTileMapLayer` | remove | task objective is seam extraction and identity parity | not kept | `tests/test_hex_tile_map_layer.gd` delegation assertions |
| Direct path/range logic copy in sample | remove | duplicates logic and can drift from service behavior | not kept | `tests/test_debug_scenes.gd` service parity assertions |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Null map data in service | service methods return empty/neutral results | null calls from tests or startup paths | `tests/test_hex_tile_map_layer.gd` null-safe section in parity test |
| Layer public query behavior | delegated output matches prior service-calculated output | silent behavior drift under wall/profile/cost variations | `tests/test_hex_tile_map_layer.gd` parity test |
| Runtime sample output | query output equals service output for same profile and budget | sample path/range divergence from canonical logic | `tests/test_debug_scenes.gd` runtime query assertions |
