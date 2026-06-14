# NODE-20 Implementation Plan

## Scope

- Add `HexMapWorkspaceBindingService`.
- Route Workspace selection resolution, selected-node context sync, and slot writeback through the service.
- Write shared Workspace resources to selected Level Document dependencies.
- Update tests and docs.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Steps

1. Implement service methods for resolving `HexTileMapLayer`, hydrating context from selected node, and applying slot writeback.
2. Use service from `HexMapWorkspace` for node selection and workspace asset writes.
3. Keep RES-11 dependency hydration source metadata intact for reads.
4. Add editor tests proving shared writeback updates document dependencies and internal layer selection resolves.
5. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Scene selection resolves `HexTileMapLayer`.
- [x] Node-owned refs read from and write to node exports.
- [x] Document dependencies read shared resources into context.
- [x] Shared resource selections write to document dependencies.
- [x] Queue proof, self-review, and test result are updated.
