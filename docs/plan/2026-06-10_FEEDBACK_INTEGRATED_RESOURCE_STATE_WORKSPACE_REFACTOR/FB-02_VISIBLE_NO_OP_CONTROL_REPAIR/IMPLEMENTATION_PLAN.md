# FB-02 Implementation Plan

## Scope

- Remove the visible `Details` button from asset slot controls.
- Add disabled-condition tooltips for Export and Missing Unique Resources actions.
- Update editor tests that inventory visible buttons and disabled tooltips.
- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`, self-review, queue proof, and commit.

## Change Targets

- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`
- `docs/review/autopilot/FB-02_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/FB-02_TEST_RESULT_2026-06-10.md`

## Steps

1. Remove asset slot `Details` button creation and refresh behavior.
2. Preserve test/debug detail snapshots without making them a visible action.
3. Add tooltip fields to relevant Workspace snapshots.
4. Set disabled tooltips for Export `Use Recent`, Export `Create Runtime Handoff`, and Missing Unique Resources `Create Missing Resources`.
5. Update editor tests to assert placeholder controls are absent and disabled controls explain conditions.
6. Run `./tools/test.sh`.
7. Write self-review and test result.
8. Mark `FB-02` complete, sweep dependencies, and update current pointer.

## Deferred Steps

- Do not redesign all Resource row layout.
- Do not migrate Paint/Edit Tool actions to other tabs.
- Do not add analog tests.

## Test Path

```sh
./tools/test.sh
```

## Docs Update

Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with the FB-02 visible action and disabled tooltip coverage.

## Completion Checklist

- No visible Resource row `Details` button remains.
- Asset row Select/Open/Validate placeholder actions remain absent.
- Disabled Export and Missing Unique Resources actions have condition tooltips.
- Tests and self-review show no `repair-now` items.
