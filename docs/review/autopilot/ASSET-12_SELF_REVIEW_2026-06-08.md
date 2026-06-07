# ASSET-12 Self Review 2026-06-08

## Scope Reviewed

- `HexMapWorkspaceAssetResourceFactory` slot-to-resource mapping, save path normalization, ResourceSaver use, and context assignment.
- `HexMapEditorAssetSlotControl` create-new dialog config, Save As dialog hook, and selected path signal.
- Editor tests for resource creation, sample payload exclusion, and context assignment.
- Queue proof and next READY pointer.

## Findings

- repair-now: none.
- follow-up-ready: none.

## Repairs Completed During Review

- Added headless-safe Save As dialog config and `select_create_path()` path acceptance because `EditorFileDialog` cannot be instantiated by headless script tests outside the editor.

## Acceptance Check

- Asset slots expose a `Create New...` Save As path contract.
- Level Document, Tile Catalog, Object DB, Label DB, Layer Stack, Movement Profile, Validation Suite, and Generation Profile resources can be created and saved.
- Created resources are assigned to `HexMapWorkspaceAssetContext`.
- Created project resources do not silently include bundled sample assets.
- `./tools/test.sh` passed after the repair.
