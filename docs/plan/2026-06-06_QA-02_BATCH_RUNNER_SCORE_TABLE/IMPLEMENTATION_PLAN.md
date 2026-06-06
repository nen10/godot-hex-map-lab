# QA-02 Implementation Plan

## Inputs

- Queue item: `QA-02`
- Dependencies: `QA-01`
- Target files:
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `tests/test_editor_plugin.gd`
  - `docs/TEST.md`

## Steps

1. Add batch result state to `HexMapGenDock`.
2. Add a reusable document snapshot helper for generated primary or overlay data.
3. Implement `run_generation_batch()` with seed count, start seed, explicit seeds, and score options.
4. Implement row scoring and deterministic sort helpers.
5. Add headless tests that generate multiple seeds, assert validation summary and scores, assert sorting, and confirm current map state is not promoted.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`, repair any `repair-now` findings, then write self-review and queue proof.

## Acceptance

- N seeds generate from one settings snapshot.
- Each row includes validation summary and score.
- Score table is sortable/headless-testable.
- `./tools/test.sh` passes or records an allowed environment block.
