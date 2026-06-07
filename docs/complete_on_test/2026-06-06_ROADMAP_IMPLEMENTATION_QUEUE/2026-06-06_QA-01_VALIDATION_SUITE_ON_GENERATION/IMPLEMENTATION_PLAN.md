# QA-01 Implementation Plan

## Inputs

- Queue item: `QA-01`
- Dependencies: `VAL-01`, `LD2-04`
- Target files:
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `tests/test_editor_plugin.gd`
  - `docs/TEST.md`

## Steps

1. Add generation validation state to `HexMapGenDock`.
2. Add helpers to build a generated v2 document from current primary map and optional overlay data.
3. Add a public/testable validation capture helper returning a pass/fail summary and raw validation result.
4. Call the validation capture helper after successful generation completion and before automatic target apply.
5. Keep debug report validation summary connected to the stored capture when present.
6. Add headless tests for successful generated map validation and failing generated document capture.
7. Run `./tools/test.sh`, repair `repair-now` findings, then document self-review and queue proof.

## Acceptance

- Generated map can be validated before promotion.
- Pass/fail validation result is captured.
- Existing Generate Dock auto apply tests still pass.
- `./tools/test.sh` passes or records an allowed environment block.
