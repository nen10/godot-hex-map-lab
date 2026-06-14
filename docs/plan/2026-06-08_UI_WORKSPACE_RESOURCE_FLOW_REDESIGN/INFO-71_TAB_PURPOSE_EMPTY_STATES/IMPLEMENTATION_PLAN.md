# INFO-71 Tab Purpose Empty States Implementation Plan

Date: 2026-06-08

## Target files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add a central tab empty-state snapshot contract with purpose, short text, one or two next actions, and help tooltip.
2. Include the contract in Resources, Paint, Catalog, Layers, Validate, QA, Export, and Settings snapshots.
3. Use the contract in existing visible status labels where the tab already has an empty-state label.
4. Add headless editor coverage for action counts, sample policy, and tooltip/detail placement.
5. Run `./tools/test.sh`, self-review, repair any `repair-now` item, and update queue proof.
