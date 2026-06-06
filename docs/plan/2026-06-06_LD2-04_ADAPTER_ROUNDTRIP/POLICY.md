# LD2-04 Adapter Roundtrip Policy

作成日: 2026-06-07
Queue task: `LD2-04`

## Decisions

| Topic | Decision | Reason |
| --- | --- | --- |
| Normalized entries | Add adapter helpers that return v1-shaped dictionaries from either v1 arrays or v2 resources. | Existing layer/display code can consume one shape while v2 schema exists. |
| Map source | Prefer v1 `map` when present, otherwise first v2 terrain layer map. | Current compatibility remains stable while pure v2 docs can load. |
| Cleanup | Deleted cells remove v1 arrays and v2 typed payloads. | Save/apply should not keep orphan payloads. |
| Zones | Remove deleted cells from zones and drop zones that become empty. | Zone data should remain cell-scoped and inspectable. |
| HexTileMapLayer | Apply normalized adapter entries, not raw document arrays. | Runtime layer should accept pure v2 documents without duplicating conversion logic. |

## Test Policy

Update:

- `tests/test_hex_adapter.gd` for v2 adapter roundtrip and deleted-cell cleanup.
- `tests/test_hex_tile_map_layer.gd` for pure v2 document payload application.
- `docs/TEST.md` summaries for both test files.
