# LD2-06 Runtime Load Sample UX

作成日: 2026-06-07
Queue task: `LD2-06`

## Goal

Runtime code can load a Level Document v2 `.tres` and apply it to `HexTileMapLayer` without editor-only dependencies. A project user should have a small, testable runtime path for loading a saved document into a scene.

## Operation Steps

1. Runtime helper accepts a document resource or resource path.
2. Helper loads only runtime-safe resource classes.
3. Helper applies the document to `HexTileMapLayer` using the v2-aware adapter path.
4. A debug scene or sample script proves the runtime path in headless tests.

## Maintained UX

- Existing `HexTileMapLayer.apply_document()` remains available.
- Existing map-resource application remains compatible.
- Runtime load failure returns a boolean/status rather than requiring editor UI.

## Non-Goals

- No movement/pathfinding runtime API.
- No catalog/layer-stack runtime sample.
- No public package example polish beyond the minimal tested runtime path.
