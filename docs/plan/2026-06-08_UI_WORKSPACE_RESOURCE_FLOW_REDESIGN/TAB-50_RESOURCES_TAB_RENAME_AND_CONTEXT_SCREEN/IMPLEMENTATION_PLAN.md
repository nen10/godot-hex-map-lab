# TAB-50 Implementation Plan

## Scope

- Rename the first visible workspace tab from `Document` to `Resources`.
- Add a Resources context/group summary component.
- Expose group, selected-node, and create-missing-resource state in snapshots.
- Update tests and `docs/TEST.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Rename the registry tab label to `Resources` and keep a compatibility alias for old programmatic `Document` queries.
2. Mount a Resources context panel showing selected HexTileMap state and Unique/Shared/Optional resource groups.
3. Add Resources screen snapshot fields for selected node, resource groups, and Create Missing Resources availability.
4. Update workspace/tab tests to expect `Resources`.
5. Run `./tools/test.sh`, self-review, update queue, and commit.

## Completion Checklist

- Visible tab list starts with `Resources`, not `Document`.
- Selected HexTileMap node context is visible on the Resources screen.
- Unique/Shared/Optional groups are available with tooltips.
- `Create Missing Resources` remains available.
- No `repair-now` items remain.
