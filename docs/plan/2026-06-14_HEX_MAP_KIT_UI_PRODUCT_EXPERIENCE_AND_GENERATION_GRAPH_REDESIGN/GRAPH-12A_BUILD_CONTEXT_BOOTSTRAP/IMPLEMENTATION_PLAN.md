# GRAPH-12A Implementation Plan

## Scope

Repair Build tab context ownership so a new graph and a graph-less `HexTileMapLayer` can execute the GRAPH-12 vertical slice without Resource-reference shortages.

## Target Files

- `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_generation_promote.gd`
- `tools/test.sh`
- `docs/TEST.md`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`

## Planned Steps

1. Add a minimal embedded `HexGenerationGraphResource` wrapper for Dictionary graph models.
2. Add `generation_graph_resource` to `HexTileMapLayer`.
3. Add canvas restore/replace helpers so Build can load an embedded graph model into GraphEdit.
4. Add Build screen bootstrap API that creates a default vertical slice graph resource and Level Document when missing.
5. Add Workspace API that creates/selects a HexTileMapLayer when absent and delegates to Build bootstrap.
6. Add tests for no-selection bootstrap, selected graph-less layer bootstrap, existing-resource preservation, and Generate/Promote after bootstrap.
7. Run `./tools/test.sh`, self-review, proof update, queue update, commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Selected node tracking | graph context owner diverges | Workspace bootstrap tests assert selected node owns graph/document |
| Build canvas restore | graph model exists but UI cannot run | tests assert node count, connection count, selected output preview |
| Promote | document context still missing | tests assert Promote writes generated overlay layer |
| Existing Resources flow | regression | existing `test_editor_workspace.gd` NODE-22/NODE-23 |

## Planned Completion Criteria

- `ensure_build_graph_context()` works with no selected HexTileMapLayer.
- `ensure_build_graph_context()` works with a selected graph-less HexTileMapLayer.
- Build can Generate and Promote after bootstrap without bundled samples or file paths.
- Existing graph/document refs are preserved.
- `./tools/test.sh` passes and UI metric P0 failures are zero.
