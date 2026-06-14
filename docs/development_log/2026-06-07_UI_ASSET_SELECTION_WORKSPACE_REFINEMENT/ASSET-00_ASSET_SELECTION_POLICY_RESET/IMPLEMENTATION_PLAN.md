# ASSET-00 Implementation Plan

## Scope

Reset the project policy and autopilot instructions so later roadmap tasks cannot be completed by sample preset success alone.

## Files

- `AGENTS.md`
- `docs/policy/DOMAIN_POLICY.md`
- `docs/policy/IMPLEMENTATION_POLICY.md`
- `docs/policy/TEST_DESIGN_POLICY.md`
- `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark the queue task `RUNNING`.
2. Add explicit `sample-only prototype` and `No sample-only completion` rules to policy docs.
3. Connect headless UI test policy to sample mode OFF and project-asset state.
4. Keep analog tests deferred for this CLEAN UI roadmap.
5. Run `./tools/test.sh`.
6. Write self-review.
7. Update queue proof and dependency status, then commit.

## Test Path

- `./tools/test.sh`

This task changes docs and policy only, so the test proves the repository remains green while the self-review checks the policy acceptance.

## Completion Checklist

- [x] Plan files exist.
- [x] Policy reset is documented in source-of-truth docs.
- [x] Headless test rule rejects sample-only completion.
- [x] Analog test deferral remains explicit.
- [x] Queue proof and next READY task are clear.
