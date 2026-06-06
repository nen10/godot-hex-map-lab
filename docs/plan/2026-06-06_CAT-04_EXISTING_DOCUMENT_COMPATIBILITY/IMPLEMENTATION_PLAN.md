# CAT-04 Implementation Plan

## Scope

Add catalog compatibility warning helpers, surface warning counts/details in editor target status/debug report, add adapter/editor tests, update docs, run the full suite, self-review, queue proof, and commit.

## Steps

1. Add `HexMapDocumentAdapter.catalog_compatibility_warnings(document, options)` for default terrain and tile-entry fallback warnings.
2. Keep `apply_to_tile_map_layer()` using numeric fallback values when catalog data is missing.
3. Add adapter tests for v1/v2 catalogless documents applying through fallback while returning warnings.
4. Add editor tests proving target status/debug report exposes catalog fallback warnings.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`; repair failures in-task.
7. Write self-review/test-result docs, update queue proof, and commit.
