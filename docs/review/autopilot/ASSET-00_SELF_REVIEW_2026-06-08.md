# ASSET-00 Self Review 2026-06-08

## Task

Asset selection policy reset for `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`.

## Changes

- Added task planning files under `ASSET-00_ASSET_SELECTION_POLICY_RESET/`.
- Added `No sample-only completion` and `sample-only prototype` wording to `AGENTS.md`, domain policy, implementation policy, test design policy, and `docs/TEST.md`.
- Updated autopilot orchestration so self-review checks that sample-only success is not used as completion proof.
- Connected headless UI test policy to sample mode OFF, user-selected project asset state, and visible missing-asset validation state.

## Acceptance Review

- `sample-only prototype` is defined as sample-demonstrable UI that does not support arbitrary project assets in the normal workflow.
- `No sample-only completion` is documented in source-of-truth policy/test docs.
- Headless tests are instructed not to treat sample preset success as feature completion.
- Analog tests remain deferred during CLEAN UI work unless the user explicitly asks for them.
- This task is docs/policy only; no product code or analog test files were added.

## Test Result

- PASS: `./tools/test.sh`
- Result file: `docs/review/autopilot/ASSET-00_TEST_RESULT_2026-06-08.md`

## Repair Classification

- `repair-now`: none.
- `follow-up-ready`: none.
- `known-env-failure`: none.
- `accepted-risk`: none.

## Completion Decision

`ASSET-00` satisfies acceptance and can be marked `COMPLETE`. Dependency sweep should unlock `ASSET-01`.
