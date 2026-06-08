# PROCESS-91 Final Dist Regeneration Step Implementation Plan

Date: 2026-06-08

## Target files

- `dist/hex_map_kit-0.3.0.manifest.txt`
- `dist/hex_map_kit-0.3.0.zip`
- `docs/review/autopilot/PROCESS-91_TEST_RESULT_2026-06-08.md`
- `docs/review/autopilot/PROCESS-91_SELF_REVIEW_2026-06-08.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Run `tools/package_addon.sh` to regenerate committed `dist` artifacts.
2. Generate a temporary package manifest and compare it to the committed manifest.
3. Run `./tools/test.sh` for the standard suite.
4. Record test/process proof and self-review.
5. Mark `PROCESS-91` complete and leave no READY tasks in the queue.
