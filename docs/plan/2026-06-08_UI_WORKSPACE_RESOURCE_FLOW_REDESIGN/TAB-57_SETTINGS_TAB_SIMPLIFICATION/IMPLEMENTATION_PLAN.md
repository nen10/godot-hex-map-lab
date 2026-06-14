# TAB-57 Settings Tab Simplification Implementation Plan

Date: 2026-06-08

## Target files

- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Move Movement Profile ownership from Settings to Resources in the component registry and mounted asset rows.
2. Add a Settings preferences/debug purpose panel and snapshot so tests can assert the intended tab role without private node paths.
3. Update Resources grouping to classify Movement Profile as optional.
4. Update editor tests for the new tab contract, strict type checks, sample/debug isolation, and functional sample actions.
5. Run `./tools/test.sh`, self-review, repair any `repair-now` item, and update queue proof.
