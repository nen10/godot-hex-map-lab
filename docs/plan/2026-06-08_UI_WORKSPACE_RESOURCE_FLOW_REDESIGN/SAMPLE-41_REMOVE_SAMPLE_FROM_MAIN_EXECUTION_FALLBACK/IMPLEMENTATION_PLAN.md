# SAMPLE-41 Implementation Plan

## Scope

- Remove editor-session sample catalog fallback from Generate/Paint execution lookup.
- Ignore bundled sample catalog paths as execution catalogs even if directly selected.
- Classify bundled sample selections as `SOURCE_SAMPLE` warning state in asset slot rows.
- Update editor tests and `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Change Generate/Paint session fallback policy so sample mode never auto-loads bundled catalog.
2. Exclude bundled sample catalog paths from execution catalog lookup.
3. Add asset slot source classification/warning for bundled sample paths.
4. Update existing sample-mode tests and add direct bundled sample selection coverage.
5. Run `./tools/test.sh`, self-review, update queue, and commit.

## Completion Checklist

- Sample mode ON leaves Generate/Paint catalog unset when no project Catalog exists.
- Direct sample selection is visible as `SOURCE_SAMPLE` warning.
- Duplicated project sample copy remains production-ready.
- No `repair-now` items remain.
