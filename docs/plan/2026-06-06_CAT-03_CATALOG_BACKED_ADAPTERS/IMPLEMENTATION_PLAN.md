# CAT-03 Implementation Plan

## Scope

Add optional catalog-backed tile resolution to map, overlay, and document adapters; extend tests and `docs/TEST.md`; run `./tools/test.sh`; self-review; queue proof; commit.

## Steps

1. Add reusable tile config helpers to `hex_map_tile_adapter.gd`.
2. Add `apply_to_tile_map_layer_with_catalog()` for floor/wall default catalog keys.
3. Add overlay item-key-to-catalog-key conversion helper in `hex_overlay_tile_adapter.gd`.
4. Extend `HexMapDocumentAdapter.apply_to_tile_map_layer()` to accept catalog options and resolve per-entry `catalog_key`.
5. Add adapter tests covering floor, wall, overlay item, v2 document assignment, and missing-key numeric fallback.
6. Update `docs/TEST.md` test overview.
7. Run `./tools/test.sh`; repair failures in-task.
8. Write `docs/review/autopilot/CAT-03_SELF_REVIEW_2026-06-07.md`, update queue proof, and commit.
