# Current Capability Matrix

作成日: 2026-06-07
Queue task: `P0-01`
Scope: current implementation classification for the validated roadmap.

## Summary

Hex Map Kit already has a broad generation/editor/runtime/test surface, but its saved level document model is still v1. The main implementation risk is not missing basic map editing; it is that later game-facing UX needs typed schema, validation, catalog keys, layer roles, and migration on top of currently useful but loose payloads.

## Capability Matrix

| Area | Current capability | Current evidence | Roadmap gap | Next queue dependency |
| --- | --- | --- | --- | --- |
| Generate | Primary map generation supports rectangle, hexagon, toric square, seed-driven wall generation, connectivity recovery, symmetric toric generation, overlay generation, source registry/query rows, crop, history save, progress/cancel wiring, and apply-to-target behavior. | `addons/hex_map_kit/core/hex_map_generator.gd`; `addons/hex_map_kit/editor/hex_map_gen_dock.gd`; `tests/test_hex_map_generation.gd`; `tests/test_editor_plugin.gd`. | Generated results are not promoted into a typed Level Document v2 with generation snapshot metadata, validation summary, catalog-backed tile keys, or score/seed comparison. | `LD2-05`, `QA-01`, `QA-02`, `QA-03`. |
| Edit | Edit Dock can load/import/export/save documents/resources, resolve targets, edit shape/wall/floor/tile/object/label/overlay payloads, apply viewport input, and keep UndoRedo-compatible document/display state. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd`; `tests/test_editor_plugin.gd`. | Editor state is still concentrated in a large dock file and uses numeric tile controls and v1 payload arrays. Validation/dashboard and typed object placement are absent. | `LD2-05`, `CATUI-01`, `VAL-02`, `OBJ-03`, `ARCH-01`, `ARCH-03`. |
| Runtime | `HexTileMapLayer` can load `HexMapResource` and `HexMapDocumentResource`, expose display/cell state, emit click/hover signals, maintain toric visual/canonical identity, display loop duplicates, highlights, paths, document payload markers, and overlay tiles. | `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`; `tests/test_hex_tile_map_layer.gd`; `tests/test_debug_scenes.gd`. | Runtime does not yet expose Level Document v2 layer-stack loading, movement profiles, weighted path/range queries, object scene placement, runtime sample, or validation-aware debug overlays. | `LD2-06`, `LST-02`, `GAME-01`, `GAME-02`, `OBJ-04`. |
| Document | `HexMapResource` stores cells/walls/cyclic size/orientation; `HexOverlayResource` stores overlay cells/item keys; `HexMapDocumentResource` v1 stores map, tile overrides, objects, labels, version. Adapter helpers duplicate documents, mutate walls/cells/payloads, clean payloads on deleted cells, convert to map resources, and apply tile overrides to plain layers. | `addons/hex_map_kit/adapter/hex_map_resource.gd`; `addons/hex_map_kit/adapter/hex_overlay_resource.gd`; `addons/hex_map_kit/adapter/hex_map_document_resource.gd`; `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`; `tests/test_hex_adapter.gd`. | No typed v2 fields for terrain layers, overlay layers, object placements, labels, zones, metadata, dependencies, validation result, summary, migration, or runtime/authoring split. | `P0-02`, `LD2-01`, `LD2-02`, `LD2-03`, `LD2-04`. |
| Test | Core, generation, adapter, runtime layer, editor plugin, and debug scene headless tests are indexed in `docs/TEST.md`. The suite covers current high-risk editor and layer behaviors. | `docs/TEST.md`; `tools/test.sh`; `tests/*.gd`. | The current environment must be proven separately by `P0-03`. New v2 schema, catalog, validation, layer stack, gameplay, object, QA, and package features need new or extended test cases. | `P0-03` and every implementation task. |

## Plain TileMapLayer vs HexTileMapLayer

| Target | Current role | Strengths | Limitations | Roadmap classification |
| --- | --- | --- | --- | --- |
| Plain `TileMapLayer` | Compatibility target for direct tile writes and existing Godot layer workflows. | `HexMapTileAdapter.apply_to_tile_map_layer()` can write floor/wall cells; Edit Dock readiness and redraw tests preserve explicit default tile settings; Generate Dock still lists plain targets for explicit/overlay use. | No document payload marker model, no loop/canonical identity API, no runtime helper signals, no overlay child stack, no future layer-role contract. | Keep as legacy/advanced compatibility path. Do not make it the primary Level Document v2 target. |
| `HexTileMapLayer` | Primary Hex Map Kit runtime/editor target wrapper. | Owns display TileSet settings, internal base/loop/overlay layers, document payload state, object/label markers, overlay tile map, click/hover hit schema, toric duplicate display, path/highlight helpers, and resource persistence through `hex_map`. | Current child layers are implementation internals, not a typed layer stack resource; object/label are marker payloads, not scene/object placements. | Use as primary target for layer stack, runtime load, validation focus, movement overlay, and object placement adapters. |

## Object / Label / Overlay Schema Classification

| Payload type | Current storage | Current behavior | Missing boundary | Roadmap action |
| --- | --- | --- | --- | --- |
| Tile overrides | `HexMapDocumentResource.tile_overrides: Array`; entries use `cell`, `kind`, `item_key`, `source_id`, `atlas_coords`, `alternative_tile`. | Floor/wall overrides can be applied to plain layers and `HexTileMapLayer`; overlay tile entries can be displayed by `HexTileMapLayer`. | Numeric tile source fields are exposed as normal authoring data; no catalog key, dependency, validation, or layer role. | `LD2-01`, `CAT-01`, `CAT-03`, `LST-02`. |
| Objects | `HexMapDocumentResource.objects: Array`; `HexObjectDatabaseResource.objects: Array`. | Edit/runtime can store and draw object markers by `object_id` and properties. | No typed object definition, placement schema, scene path, variant, rotation, spawn condition, uniqueness, validation, or runtime placement adapter. | `OBJ-01`, `OBJ-02`, `OBJ-03`, `OBJ-04`, `OBJ-05`. |
| Labels | `HexMapDocumentResource.labels: Array`; `HexLabelDatabaseResource.labels: Array`. | Edit/runtime can store and draw label markers by `label_id` and text. | No typed label schema, category/zone relationship, validation, localization, or dashboard reporting. | `LD2-01`, `LD2-03`, `VAL-01`. |
| Overlay data | `HexOverlayResource` and `HexOverlayData` store cells and item-key-to-cells data; document overlay display uses `tile_overrides` entries with `kind=overlay`. | Overlay generation, item pool, adjacency/reference generation, crop, apply policy, and item tile adapter are implemented and tested. | Overlay layers are not first-class document layers; item keys are not catalog-backed; validation cannot distinguish unmapped item from intentional invisible overlay. | `LD2-01`, `CAT-03`, `LST-01`, `VAL-01`, `QA-01`. |

## Current High-Coupling Files

| File | Current size | Risk |
| --- | ---: | --- |
| `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | 3737 lines | Broad Generate Dock state/UI coupling; catalog and QA UI additions should avoid expanding it without companion refactor. |
| `addons/hex_map_kit/editor/hex_map_edit_tool.gd` | 2766 lines | Edit mutation, target state, viewport input, persistence, and debug report are concentrated; validation/object UI additions may need `ARCH-*`. |
| `addons/hex_map_kit/adapter/hex_tile_map_layer.gd` | 1582 lines | Runtime helper already owns map, payload, overlay, loop, hit, and display state; layer-stack additions need clear resource/adapter boundary. |
| `tests/test_editor_plugin.gd` | 3506 lines | Strong coverage but high maintenance cost; new UI tests should stay workflow-focused. |

## Phase 0 Readiness Notes

- `P0-02` should decide which current payloads are maintained, migrated, or removed from primary UX.
- `P0-03` should prove the local test environment separately. Earlier `AUTO-00` already recorded a missing Godot binary in its environment.
- `LD2-01` should not extend v1 arrays as the primary schema. It should introduce typed resource fields and keep v1 compatibility through migration/adapter behavior.
