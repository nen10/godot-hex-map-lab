# P0-02 Schema Boundary Decisions Implementation Plan

作成日: 2026-06-07
Queue task: `P0-02`

## Inputs

- `docs/review/roadmap/CURRENT_CAPABILITY_MATRIX_2026-06-06.md`
- `docs/review/roadmap/RISK_REGISTER_2026-06-06.md`
- `docs/review/_history/HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md`
- `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
- `addons/hex_map_kit/adapter/hex_object_database_resource.gd`
- `addons/hex_map_kit/adapter/hex_label_database_resource.gd`
- `addons/hex_map_kit/adapter/hex_overlay_resource.gd`

## Outputs

- `docs/review/roadmap/SCHEMA_BOUNDARY_DECISIONS_2026-06-06.md`
- `docs/review/autopilot/P0-02_TEST_RESULT_2026-06-07.md`
- `docs/review/autopilot/P0-02_SELF_REVIEW_2026-06-07.md`
- Queue proof update in `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`

## Work Items

1. Create plan packet.
2. Decide maintain / migrate / remove for v1 document fields.
3. Decide TileSet / scene / custom data boundaries.
4. Decide primary target boundary for plain `TileMapLayer` and `HexTileMapLayer`.
5. Write schema boundary decision record.
6. Run `./tools/test.sh`.
7. Write self-review with `repair-now` classification.
8. Update queue status and proof.

## Test Path

No test file is added. Completion command:

```sh
./tools/test.sh
```
