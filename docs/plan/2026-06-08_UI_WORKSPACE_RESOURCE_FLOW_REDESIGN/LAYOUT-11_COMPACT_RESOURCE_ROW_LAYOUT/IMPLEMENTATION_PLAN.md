# LAYOUT-11 Implementation Plan

## Scope

- Refactor `HexMapEditorAssetSlotControl` from always-visible detail labels into a compact row with collapsed details.
- Add readback for compact layout tests.
- Update editor tests and `docs/TEST.md`.

## Change Targets

- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`
- `docs/review/autopilot/LAYOUT-11_SELF_REVIEW_2026-06-08.md`
- `docs/review/autopilot/LAYOUT-11_TEST_RESULT_2026-06-08.md`

## Steps

1. Add a compact row container to the asset slot control.
2. Move current/type/message labels into a collapsed details container.
3. Add tooltip text that includes current path, required type, status, source, and validation messages.
4. Add a public layout snapshot.
5. Update tests for compact default state and details toggle.
6. Run `./tools/test.sh`.
7. Self-review and update queue proof.

## Deferred Steps

- Do not remove redundant action buttons.
- Do not add resource purpose tooltip copy.
- Do not create analog tests.

## Test Path

```sh
./tools/test.sh
```

## Completion Checklist

- Top row is compact.
- Details are collapsed by default.
- Missing state remains visible.
- Long details are available through tooltip/details.
- Existing slot state behavior still passes.
