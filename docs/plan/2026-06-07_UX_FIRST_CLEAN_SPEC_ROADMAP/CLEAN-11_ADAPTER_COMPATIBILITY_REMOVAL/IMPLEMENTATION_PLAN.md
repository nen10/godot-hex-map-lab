# CLEAN-11 Implementation Plan

## Scope

1. Remove document adapter catalog compatibility warning API and editor/test callers.
2. Change catalog-aware tile and overlay adapter resolution so missing keys do not fall back to numeric tile configs.
3. Change document apply so catalog keys resolve through catalog entries, and missing assignment is not silently drawn.
4. Extend document validation for missing default terrain keys and missing per-cell catalog assignments.
5. Rewrite adapter/layer tests around validation-clean catalog apply and validation errors.
6. Update `docs/TEST.md`, write test proof and self-review, update queue, and commit.

## Verification

- `./tools/test.sh`
- Search for stale `catalog_compatibility_warnings` and fallback assertions in adapter/layer tests.

## Completion Criteria

- Normal adapter path has no public compatibility warning API.
- Catalogless or missing-key documents produce validation issues.
- Validation-clean document apply resolves catalog tiles at runtime.
- `repair-now` self-review items are complete.
