# LD2-01 Level Document v2 Resource Schema Policy

作成日: 2026-06-07
Queue task: `LD2-01`

## Source Documents

- `docs/review/roadmap/SCHEMA_BOUNDARY_DECISIONS_2026-06-06.md`
- `docs/review/roadmap/CURRENT_CAPABILITY_MATRIX_2026-06-06.md`
- `docs/review/roadmap/RISK_REGISTER_2026-06-06.md`
- `docs/policy/DOMAIN_POLICY.md`
- `docs/policy/IMPLEMENTATION_POLICY.md`
- `docs/TEST.md`

## Decisions

| Topic | Decision | Reason |
| --- | --- | --- |
| v1 compatibility | Keep existing `map`, `tile_overrides`, `objects`, `labels`, and `version` fields. | Existing `.tres` resources and current adapter/editor/runtime code depend on them. |
| v2 storage | Add Resource-based fields for terrain, overlay, object placements, label placements, zones, metadata, and dependencies. | Later tasks need typed storage targets before migration and validation. |
| Field naming | Use `label_placements` for typed labels while preserving v1 `labels`. | Reusing `labels` would break current dictionary payloads. |
| Metadata | Store metadata as a typed resource, not a loose dictionary. | This follows the typed schema policy while allowing nested custom data. |
| Dependency records | Store dependency records separately from layer content. | Catalog/TileSet/scene validation should inspect dependencies without parsing layer payloads. |

## Compatibility Boundary

This task does not remove or repurpose v1 arrays. The v2 fields are additive. `LD2-02` owns migration helpers and may fill v2 fields from v1 payloads.

## Test Policy

Update `tests/test_hex_adapter.gd` to verify:

- `HexMapDocumentResource` exposes v2 schema fields.
- Typed v2 subresources save/load through `ResourceSaver` and `load`.
- A v1-style document still saves/loads with its legacy payloads after the v2 fields are added.

Update `docs/TEST.md` to mention the new v2 schema checks under `tests/test_hex_adapter.gd`.
