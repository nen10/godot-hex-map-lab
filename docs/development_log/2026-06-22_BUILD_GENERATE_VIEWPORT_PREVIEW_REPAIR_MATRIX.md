# Build Generate Viewport Preview Repair Matrix

Date: 2026-06-22
Source handoff: `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`
Roadmap baseline: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ROADMAP.md`

## Decision

`Generate` must project the generated result into the Godot 2D viewport through a real `HexTileMapLayer`.
The selected `HexTileMapLayer` is the target when one exists; otherwise Build creates and selects `BuildHexMapLayer`.
The result is a reversible preview until `Apply` is pressed. `Revert` restores the previous in-memory document and reapplies it to the target layer.

The small square tile panel concern refers to `HexMapPreviewThumbnail` and related preview payload terminology.
It must not be reintroduced as visible Build completion UI. If thumbnail data remains in snapshots for legacy Generate/QA flows, it is not completion evidence for Build viewport projection.

## Matrix

| item | decision | reason | proof path |
|---|---|---|---|
| Generate viewport path | repair-now | Primary action must make the map visible in the viewport, not only in node output cache. | `tests/test_generation_promote.gd` top Generate viewport tests |
| Context-provider race | repair-now | Build screen must synchronously know the active layer/document before run/apply. | `HexMapBuildScreen.set_build_context_provider()` |
| Preview thumbnail labeling | repair-now | Thumbnail terminology was mistaken for a visible Build result panel. Build completion must name viewport projection, not thumbnail preview. | design clarification + viewport proof fields |
| Top Generate tests | repair-now | Existing tests covered bootstrap/promote but not the top button viewport outcome. | `tests/test_generation_promote.gd` |
| Graph-wide generation state model | follow-up | Handoff notes show node-to-node mode constraints are product-relevant but larger than viewport repair. | future Build graph state task |
| Region Filter item-key UX | follow-up | Item-key selection should come from the incoming overlay's planned keys, not raw text. | future inspector/input-state task |
| Graph canvas operability/layout | follow-up | Canvas height, node text clipping, and action placement need layout work beyond the hotfix. | future Build canvas UX task |
| Edge deletion behavior | follow-up | Current Remove/Delete behavior does not fully cover edge deletion. | future graph canvas interaction task |
| Thumbnail-only preview proof | reject | A thumbnail proves cache data exists, not that the map is visible/usable in Godot viewport. | require `viewport_preview_visible` and layer display cells |
| Sample-only success | reject | Samples are learning assets, not production completion proof. | use selected/new project layer |
| Cache-only graph tests | reject | Passing graph run/cache does not prove user-visible projection. | require `display_used_cell_count() > 0` |
