# REPAIR-10 Implementation Plan

## Scope

Repair the Build `Generate` path so it projects to a real viewport layer, records explicit projection proof, and preserves the handoff uncertainties as follow-up tasks.

## Steps

1. Documentation and queue
   - Add this task packet.
   - Add `REPAIR-10` to the queue as a repair task.
   - Add the follow-up tasks from the handoff issue matrix.

2. Context contract
   - Keep `HexMapBuildScreen.set_build_context_provider(provider: Callable)`.
   - Top `Generate` and `Generate (Simple)` must call the provider before running.
   - The provider returns the selected/created layer, document, graph, and restore status.
   - Fire-and-forget `build_context_requested` can remain as compatibility, but Generate success must not depend on an uninspectable signal side effect.

3. Viewport projection
   - Snapshot the document before projection.
   - Promote selected/terminal Result before other outputs.
   - Apply a document snapshot to the active layer with display tiles guaranteed.
   - Record a viewport projection report with layer path, tree state, display tile status, used cells, and blocked reason.

4. Preview commit state
   - `none`: no pending/kept preview.
   - `preview_pending`: viewport projection succeeded and Apply/Revert are available.
   - `applied`: user kept preview; Revert disabled.
   - `reverted`: user restored previous document and display.

5. Simple Generate
   - Simple preset graph must end in Result.
   - Simple Generate must use the same context and viewport proof as top Generate.

6. Build canvas cleanup
   - Move batch/Apply/Revert/Remove controls below the graph surface.
   - Increase canvas minimum height and make it dominant in the dock.
   - Reduce button/node text size and prevent normal node text clipping.

7. Diagnostic probe
   - Add a Build Generate viewport probe script.
   - Write JSON under `.godot_user/visual-verification/REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY/`.
   - Include screenshot/non-background sampling when the runtime can capture it.

8. Tests
   - Update `tests/test_generation_promote.gd`.
   - Update `tests/test_build_screen_full.gd`.
   - Update `tests/test_build_graph_canvas.gd` only for layout/snapshot contract if needed.
   - Run targeted tests first, then `./tools/test.sh`.

## Acceptance

- No selected layer path: top Generate creates/selects `BuildHexMapLayer`, attaches document/graph, and records successful viewport projection.
- Selected graphless layer path: top Generate keeps that layer, attaches document/graph, and records successful viewport projection.
- Vertical slice with Result: Generate promotes terrain and overlay through Result and applies both to the active layer.
- Revert restores previous document state and viewport display.
- Apply keeps the generated viewport result and disables Revert.
- Square thumbnail/cache-only proof is explicitly rejected.
