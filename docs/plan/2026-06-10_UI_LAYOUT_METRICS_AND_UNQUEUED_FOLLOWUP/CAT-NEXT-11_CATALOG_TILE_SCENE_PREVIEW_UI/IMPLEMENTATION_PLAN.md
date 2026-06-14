# Implementation Plan

## Scope

Add a Catalog-specific rich preview UI for selected Tile Catalog atlas/scene entries, including explicit unavailable-state badge/tooltip proof.

## Target Files

- `addons/hex_map_kit/editor/hex_tile_catalog_preview_control.gd`
- `addons/hex_map_kit/editor/hex_tile_catalog_preview_control.gd.uid`
- `addons/hex_map_kit/editor/hex_map_catalog_editor_component.gd`
- `addons/hex_map_kit/editor/hex_map_catalog_screen.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Add `HexTileCatalogPreviewControl` with snapshot storage and drawing for atlas texture-region, scene, and unavailable states.
2. Extend Catalog entry preview snapshots with render kind, atlas texture data, scene metadata, badge text, and tooltip reason.
3. Update Catalog detail panel builder to mount the preview control and unavailable badge label.
4. Refresh the mounted preview/badge from `catalog_screen_snapshot()`.
5. Add tests for atlas preview render kind, scene preview render kind, missing/placeholder badge tooltip, and mounted control snapshot.
6. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Full TileSet editor preview parity | reject for this task | The acceptance is detail rendering, not replacing Godot's TileSet editor. |
| Row-level visual cards | reject for this task | The roadmap row targets entry detail. |
| Sample-backed placeholder visuals | reject | Production preview must use selected project resources or explicit unavailable state. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| `HexMapCatalogEditorComponent.entry_preview()` | Snapshot lacks enough render data. | Catalog test asserts render kind and metadata. |
| Mounted Catalog detail panel | Preview data exists but does not render in UI. | Test finds mounted preview control and badge label. |
| TileSet atlas source | Invalid source/tile incorrectly appears available. | Missing/placeholder tests assert unavailable state. |
| PackedScene entry | Scene preview state missing from detail. | Scene detail test asserts scene render kind. |
| UI metrics | New control causes layout regression. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `CAT-NEXT-11` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Atlas catalog entry detail has an available preview with `render_kind == "atlas_texture_region"`.
- Scene catalog entry detail has an available preview with `render_kind == "scene_resource"`.
- Mounted Catalog detail has a `HexTileCatalogPreviewControl` whose snapshot matches selected detail.
- Missing/placeholder/invalid states show badge text and tooltip reason.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
