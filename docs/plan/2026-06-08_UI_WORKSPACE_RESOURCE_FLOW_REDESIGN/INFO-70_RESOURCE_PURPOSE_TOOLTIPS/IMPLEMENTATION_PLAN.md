# INFO-70 Resource Purpose Tooltips Implementation Plan

Date: 2026-06-08

## Target files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add TileSet purpose text for Catalog detail tooltip/snapshot.
2. Add tests that all roadmap resource targets expose purpose and pick/type tooltip guidance.
3. Confirm flexible profile slots keep their filter explanation.
4. Run `./tools/test.sh`, self-review, repair any `repair-now` item, and update queue proof.
