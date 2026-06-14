# PERF-60 Implementation Plan

## Scope

- Review current Generate/apply/validation/global update paths.
- Record a map-size performance budget and chunked-apply policy.
- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` to point at the new review artifact.
- Run the standard test gate and write autopilot proof docs.

## Target Files

- `docs/review/roadmap/GENERATE_PERFORMANCE_BUDGET_2026-06-10.md`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/review/autopilot/PERF-60_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/PERF-60_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `PERF-60` RUNNING and create plan docs.
- [x] Inspect current Generate/apply/validation source paths.
- [x] Write the performance budget and chunked-apply review.
- [x] Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `PERF-60` COMPLETE, update pointer/dependencies, and commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Map-size budgets classify redraw/generation/apply/validation costs.
- [x] Orientation and other global update costs are classified.
- [x] Progress/busy/cancel policy is recorded for budget overrun cases.
- [x] Chunked apply need is evaluated.
