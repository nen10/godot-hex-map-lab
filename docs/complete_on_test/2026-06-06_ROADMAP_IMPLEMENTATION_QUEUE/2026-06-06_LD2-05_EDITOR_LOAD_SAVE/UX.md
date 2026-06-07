# LD2-05 Editor Load Save UX

作成日: 2026-06-07
Queue task: `LD2-05`

## Goal

Editor document flows accept Level Document v2 resources while preserving existing v1 `.tres` load, save, export, and import behavior. Users can browse or select a document resource, load it into the Edit Dock / Generate Dock workflow, save the edited state, and export/import without losing v2 typed payloads.

## Operation Steps

1. Editor paths that load a `HexMapDocumentResource` normalize v1 documents through the migration helper and accept pure v2 documents.
2. Save/export paths write v2-compatible documents without dropping terrain layers, overlay layers, object placements, label placements, zones, metadata, or dependencies.
3. Existing v1 map-data workflows remain compatible.
4. Headless editor tests cover v2 document file load/save or equivalent import/export paths.

## Maintained UX

- Existing map resource load/save behavior remains available.
- Existing v1 document fixtures remain loadable.
- Errors and status labels remain actionable when a selected resource is missing or incompatible.

## Non-Goals

- No catalog selector UI.
- No full validation dashboard.
- No layer-stack UI.
