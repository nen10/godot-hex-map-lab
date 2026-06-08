# ASSET-31 Implementation Plan

## Scope

- Remove redundant/no-op visible action buttons from asset slot rows.
- Expose action button snapshot metadata for tests.
- Update editor tests and `docs/TEST.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Steps

1. Remove visible `Select...`, `Open`, `Clear`, and `Validate` button creation from asset slot controls.
2. Keep `Create New...` and sample action visibility tied to state.
3. Add layout snapshot action button texts.
4. Update tests to assert removed buttons are absent and remaining buttons are implemented actions.
5. Run `./tools/test.sh`, self-review, update queue proof, and commit.

## Completion Checklist

- No visible no-op row buttons remain.
- Selection/clear path remains available through ResourcePicker state changes.
- Create New remains covered.
- Sample action remains explicit and state-gated.
- No `repair-now` items remain.
