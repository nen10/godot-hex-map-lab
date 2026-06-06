# P0-02 Schema Boundary Decisions Policy

作成日: 2026-06-07
Queue task: `P0-02`

## Source Documents

- `docs/review/roadmap/CURRENT_CAPABILITY_MATRIX_2026-06-06.md`
- `docs/review/roadmap/RISK_REGISTER_2026-06-06.md`
- `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`
- `docs/review/_history/HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md`
- `docs/review/_history/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_REVIEW_2026-06-05.md`
- `docs/policy/DOMAIN_POLICY.md`
- `docs/policy/IMPLEMENTATION_POLICY.md`

## Decisions

| Topic | Decision | Reason |
| --- | --- | --- |
| Compatibility | Maintain v1 `.tres` load and migration input. | Saved resource compatibility is a roadmap invariant. |
| Primary schema | Migrate primary authoring to typed v2 resource classes. | Extending untyped arrays would preserve the main risk identified in P0-01. |
| Numeric tile data | Maintain as legacy/debug fallback; remove from normal UX after catalog UI lands. | Numeric TileSet coordinates are fragile authoring data. |
| Catalog boundary | Put TileSet source IDs, atlas coordinates, scene tile references, tags, and TileSet custom data interpretation in catalog resources/adapters. | Document layers should store logical keys and dependencies, not raw TileSet internals. |
| Object boundary | Put object definitions and scene paths in object database/catalog resources; document stores placements. | Object placement is gameplay/entity data, not tile atlas data. |
| Layer boundary | Put layer roles/templates in layer stack resources; document records layer content and target role. | `HexTileMapLayer` internals should not become authoring schema by accident. |
| Validation boundary | Validation results are explicit schema, not status strings. | Later dashboard/debug report tasks need serializable grouped errors/warnings. |

## Fallback / Hack Classification

- v1 `Array` dictionaries are migration inputs and compatibility output, not v2 schema.
- Plain `TileMapLayer` direct apply is compatibility behavior, not the v2 primary runtime path.
- Unmapped overlay item fallback is warning-worthy behavior, not a successful authoring state.

## Test Policy

P0-02 changes no code. Completion proof uses:

- `./tools/test.sh` execution result recorded in `docs/review/autopilot/P0-02_TEST_RESULT_2026-06-07.md`.
- Self-review that verifies the decision record covers all queue acceptance categories.
