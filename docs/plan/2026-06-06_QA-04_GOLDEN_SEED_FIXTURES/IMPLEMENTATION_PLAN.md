# QA-04 Implementation Plan

Task: `QA-04`  
Created: 2026-06-07  
Status: RUNNING

## Acceptance

Deterministic scores/fixtures guard important seeds; preview data exists without requiring visual assertion.

## Steps

1. Add `docs/test/fixtures/qa04_golden_seed_previews_2026-06-07.json` with selected generation scenarios.
2. Extend `tests/test_hex_map_generation.gd` to load the fixture, regenerate each seed, compute summary/score/wall keys/preview rows, and compare them.
3. Update `docs/TEST.md` to document the QA-04 fixture coverage.
4. Run `./tools/test.sh`.
5. Write QA-04 test result and self-review docs.
6. Update the autopilot queue proof and current pointer after dependency sweep.

## Repair Classification

- `repair-now`: fixture cannot load, generator output comparison is nondeterministic, or `./tools/test.sh` fails due to QA-04 changes.
- `follow-up-ready`: broader seed lab UX or screenshot-based preview review beyond the current acceptance.
- `manual-optional`: visually inspect ASCII preview rows for readability.

