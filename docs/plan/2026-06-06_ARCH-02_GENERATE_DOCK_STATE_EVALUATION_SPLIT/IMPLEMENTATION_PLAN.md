# ARCH-02 Implementation Plan

Task: `ARCH-02`  
Created: 2026-06-07  
Status: COMPLETE

## Acceptance

Existing Generate Dock headless tests pass; catalog UI additions become smaller.

## Steps

1. Add a pure `HexMapGenStateEvaluator` helper under `addons/hex_map_kit/editor/`.
2. Move `_refresh_controls()` decision logic into evaluator output while preserving dock node mutation.
3. Move generation block reason decisions into evaluator output.
4. Add focused headless tests for evaluator states and block reasons.
5. Update `docs/TEST.md`.
6. Run targeted editor plugin test and `./tools/test.sh`.
7. Write ARCH-02 test result and self-review docs.
8. Update queue proof and dependency sweep.

## Repair Classification

- `repair-now`: any Generate Dock behavior/test regression or evaluator mismatch.
- `follow-up-ready`: deeper Generate Dock state/model extraction beyond this acceptance.
- `manual-optional`: inspect Generate Dock in editor after refactor.
