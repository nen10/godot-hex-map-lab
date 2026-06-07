# CLEAN-32 Self Review

Date: 2026-06-07
Task: CLEAN-32 UX responsibility component extraction

## Acceptance

- Added `HexMapWorkspace` as the single dock-level workspace selected by CLEAN-31.
- Added `HexMapWorkspaceComponentRegistry` to map tabs to UX responsibilities: DocumentHeader, GenerationPanel, BrushPalette, CatalogPanel, LayerStackPanel, ValidationPanel, SeedLabPanel, and ExportPanel.
- Updated `plugin.gd` to register one `Hex Map Workspace` dock and route viewport input through the workspace to the Paint/Edit component.
- Added headless coverage for workspace tabs, component mapping, shared session forwarding, and viewport input gating.

## Verification

- `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`.
- `git diff --check` PASS.

## Review Notes

- Existing `HexMapGenDock` and `HexMapEditTool` remain mounted as interim Generate and Paint/Edit components so behavior stays available during staged extraction.
- The component registry is keyed by UX responsibility rather than source file size.
- `repair-now`: none.

## Residual Risk

- Some dedicated workspace tabs are responsibility targets before their full controls are migrated. This is a staged extraction boundary; harmful old paths are still owned by CLEAN-33 and manuals by CLEAN-40.
