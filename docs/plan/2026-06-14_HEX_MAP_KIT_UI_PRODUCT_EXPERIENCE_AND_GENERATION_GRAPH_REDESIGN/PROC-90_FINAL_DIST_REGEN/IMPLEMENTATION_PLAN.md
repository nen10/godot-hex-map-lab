# PROC-90 IMPLEMENTATION PLAN

## Scope

Regenerate final addon distribution artifacts.

## Target Files

- `dist/hex_map_kit-0.3.0.manifest.txt`
- `dist/hex_map_kit-0.3.0.zip`
- `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/PROOF_LOG.md`

## Planned Steps

1. Run `./tools/package_addon.sh` to refresh `dist/`.
2. Run `./tools/package_addon.sh --check` or `./tools/test.sh` package check to validate package contents.
3. Run `./tools/test.sh`.
4. Record self-review, proof log, queue completion, and final phase review.

## Test Path

- `./tools/package_addon.sh`
- `./tools/test.sh`

## Planned Completion Criteria

- The manifest and zip under `dist/` are refreshed from the current addon tree.
- Standard tests pass.
- Roadmap queue has no remaining READY/RUNNING/BACKLOG tasks except parked track.
