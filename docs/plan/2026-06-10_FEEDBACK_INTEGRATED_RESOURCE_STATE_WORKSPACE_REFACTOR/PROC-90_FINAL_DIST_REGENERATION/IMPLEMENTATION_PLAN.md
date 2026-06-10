# PROC-90 Implementation Plan

## Scope

- Regenerate `dist/` with `tools/package_addon.sh`.
- Inspect manifest/zip changes and record the diff result.
- Run `./tools/test.sh`.
- Write self-review and test-result docs.
- Complete the queue and commit.

## Target Files

- `dist/hex_map_kit-0.3.0.manifest.txt`
- `dist/hex_map_kit-0.3.0.zip`
- `docs/review/autopilot/PROC-90_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/PROC-90_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `PROC-90` RUNNING and create plan docs.
- [x] Run `tools/package_addon.sh`.
- [x] Inspect manifest/zip diff result.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `PROC-90` COMPLETE and commit.

## Test Path

- `tools/package_addon.sh`
- `./tools/test.sh`

## Completion Checklist

- [x] `tools/package_addon.sh` runs successfully.
- [x] Committed manifest/zip match the current addon tree.
- [x] Dist diff result is recorded in self-review.
- [x] Dist freshness is not added to normal `tools/test.sh` gates.
