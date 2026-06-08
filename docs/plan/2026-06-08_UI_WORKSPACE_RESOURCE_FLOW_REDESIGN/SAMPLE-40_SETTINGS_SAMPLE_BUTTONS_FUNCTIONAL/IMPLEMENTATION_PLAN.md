# SAMPLE-40 Implementation Plan

## Scope

- Add a functional Settings sample duplicate button for the bundled sample catalog.
- Add a duplicate save dialog/action path with headless selectable path support.
- Show duplicate result status and expose it in panel snapshots.
- Update editor tests, `docs/TEST.md`, queue proof, and review records.

## Target Files

- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add sample action ids and duplicate result snapshot state.
2. Reintroduce a visible `Duplicate To Project` button only for the sample catalog row.
3. Route the button to a save dialog, and route selected paths to `duplicate_sample_catalog_to_project()`.
4. Add a test that presses the duplicate action path, asserts project-owned files, verifies Catalog slot `SOURCE_PROJECT`, and confirms visible result status.
5. Run `./tools/test.sh`, self-review, update queue, and commit.

## Completion Checklist

- `Open` remains absent.
- `Duplicate To Project` chooses a path and creates project assets.
- The workspace Catalog slot updates to the duplicated project catalog.
- The panel shows what changed.
- No `repair-now` items remain.
