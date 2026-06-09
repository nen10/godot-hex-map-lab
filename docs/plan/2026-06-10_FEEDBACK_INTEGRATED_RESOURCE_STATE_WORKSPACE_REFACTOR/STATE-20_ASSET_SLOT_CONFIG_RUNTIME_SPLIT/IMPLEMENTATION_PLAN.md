# STATE-20 Implementation Plan

## Scope

- Extend asset slot state with explicit config/runtime/validation/sample/operation sections.
- Route asset slot control status and action availability through ViewState.
- Preserve current user-visible layout until `UI-01`.
- Update tests and `docs/TEST.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd`
- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- workspace asset panel integration if needed
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Steps

1. Inspect current asset slot state and control usage.
2. Add structured state sections and ViewState output while preserving current API where needed.
3. Update the control to render status/action availability from ViewState.
4. Extend existing asset slot tests for config/runtime/validation/sample/operation separation.
5. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Slot definition is distinct from runtime selection.
- [x] Validation result is distinct from operation result.
- [x] Sample availability/source is explicit and not a silent selection.
- [x] Row status/action rendering consumes ViewState.
- [x] Tests cover the new state contract.
- [x] Queue proof, self-review, and test result are updated.
