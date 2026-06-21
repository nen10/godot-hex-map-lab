# REPAIR-10 Build Generate Viewport and Graph Recovery Sub Tasks

Date: 2026-06-22
Complexity: C5
Queue: `IMPLEMENTATION_QUEUE.md`
Handoff source: `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`

## Task Boundary

This task repairs the Build `Generate` first impression and records the handoff confusion as explicit design debt. It is not a full Build tab redesign and it does not declare the whole graph product complete.

## Repair Now

- [x] Add the REPAIR-10 task packet and queue entry before treating code proof as complete.
- [x] Make top `Generate` and `Generate (Simple)` synchronously acquire the active Build context through `HexMapBuildScreen.set_build_context_provider(provider: Callable)`.
- [x] Target the selected `HexTileMapLayer`; if no selected layer exists, create and select `BuildHexMapLayer`.
- [x] Attach/create `Level Document` and embedded graph resource before graph execution.
- [x] Make Generate projection deterministic:
  - selected `result` output first,
  - terminal `result` output next,
  - graph promote targets next,
  - terminal terrain/overlay outputs next,
  - selected output by output type last.
- [x] Call `ensure_display_tiles()` and apply a document-derived map to the active layer.
- [x] Mark viewport preview success only when projection report is successful, the target layer is in the tree, the display tiles are ready, and used display cells are present.
- [x] Keep generated preview reversible with `Apply` and `Revert`.
- [x] Prohibit `Apply` when viewport projection failed.
- [x] Keep `HexMapPreviewThumbnail` as snapshot/cache support only; do not treat it as the visible Build result.
- [x] Repair tightly related Build canvas layout:
  - canvas takes the dominant height,
  - commit/batch/remove actions move below the canvas,
  - node/button text is smaller,
  - node labels no longer clip in normal titles/ports.
- [x] Add a diagnostic probe that writes viewport-projection JSON before relying on tests.
- [x] Update targeted tests so thumbnail/cache-only success is rejected.

## Follow-Up Tasks Scheduled Here

These are not solved by this hotfix. They are recorded so they are not silently folded into the viewport repair.

- `REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT`: Result owns `1 terrain + N overlay`, preserves each generated overlay as a separate layer.
- `REPAIR-12_INTERMEDIATE_OUTPUT_CHILD_NODES`: Intermediate terrain/overlay outputs become run-replaced child nodes, not mixed into the main scene node data.
- `REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT`: Graph-wide generation state, old Generate intent mapping, and Region Filter split into Terrain Filter / Overlay Filter.
- `REPAIR-14_GRAPH_CANVAS_EDGE_DELETE`: Edge deletion behavior and graph canvas interaction repair.
- `REPAIR-15_MARKOV_ADJACENCY_MAPPING`: Markov Mesh and adjacency rules mapped against the old Generate state transitions with proof.

## Completion Gate

Completion must include:

- `docs/plan/.../REPAIR-10.../HANDOFF_ISSUE_MATRIX.md`
- viewport projection probe JSON
- targeted tests:
  - `tests/test_generation_promote.gd`
  - `tests/test_build_screen_full.gd`
  - `tests/test_build_graph_canvas.gd`
- final gate: `./tools/test.sh`

Rejected completion proof:

- thumbnail-only preview,
- sample-only success,
- tests that only prove graph cache exists,
- screen snapshot without target layer path and viewport projection report.
