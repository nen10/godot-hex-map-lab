# ASSET-01 Implementation Plan

## Scope

Create the current asset slot inventory for the UI Asset Selection / Workspace Refinement roadmap.

## Files

- `docs/review/roadmap/ASSET_SLOT_INVENTORY_2026-06-07.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`
- `docs/review/autopilot/ASSET-01_SELF_REVIEW_2026-06-08.md`
- `docs/review/autopilot/ASSET-01_TEST_RESULT_2026-06-08.md`

## Source Review Targets

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_dist_editor.gd`
- `addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd`
- `docs/manual/MANUAL_EDITOR_PLUGIN.md`

## Steps

1. Mark `ASSET-01` `RUNNING`.
2. Inspect current tab/component mapping and UI source.
3. Build the inventory document with all required fields.
4. Run `./tools/test.sh`.
5. Self-review against acceptance and classify repair-now items.
6. Update queue proof, unlock `ASSET-10`, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Inventory file exists.
- [x] Required roadmap inventory fields are present.
- [x] `Use Sample Tiles`, target atlas presets, sample catalog keys, distribution presets, object scene sample, and manual sample references are classified.
- [x] Project asset selection presence/absence is explicit for each slot.
- [x] Queue proof and next READY task are clear.
