# LAYOUT-10 Implementation Plan

## Scope

- Change `HexMapWorkspace` tab pages from plain `VBoxContainer` roots to `ScrollContainer` roots with inner vertical content.
- Add public readback helpers for tab scroll support.
- Extend editor plugin tests and `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` coverage.

## Change Targets

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`
- `docs/review/autopilot/LAYOUT-10_SELF_REVIEW_2026-06-08.md`
- `docs/review/autopilot/LAYOUT-10_TEST_RESULT_2026-06-08.md`

## Steps

1. Add a tab scroll root map to `HexMapWorkspace`.
2. Update `_add_tab_page()` so the `TabContainer` child is a `ScrollContainer` named after the tab.
3. Keep component mounting pointed at the inner content `VBoxContainer`.
4. Add readback methods for scroll root presence.
5. Update editor tests to assert all workspace tabs have scroll roots and registry contracts remain stable.
6. Run `./tools/test.sh`.
7. Self-review and update queue proof.

## Deferred Steps

- Do not alter slot row content.
- Do not connect or remove action buttons.
- Do not introduce analog tests.

## Test Path

```sh
./tools/test.sh
```

## Completion Checklist

- All workspace tabs report a scroll root.
- Component ids and asset slot ids still match the registry.
- Tab selection still works.
- Primary actions remain mounted under each tab.
