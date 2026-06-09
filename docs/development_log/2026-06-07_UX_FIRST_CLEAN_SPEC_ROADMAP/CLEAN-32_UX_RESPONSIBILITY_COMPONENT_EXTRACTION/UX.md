# CLEAN-32 UX Responsibility Component Extraction UX

## Goal

Start converting the selected `Hex Map Workspace` model into product code by introducing a workspace shell and explicit component responsibility map.

## User Contract

- The addon registers one `Hex Map Workspace` dock.
- Workspace tabs match the accepted CLEAN-31 model: Document, Generate, Paint, Catalog, Layers, Validate, QA, Export.
- Viewport input remains owned by the Paint/Edit responsibility.
- Existing Generate and Paint/Edit behavior remains available during staged extraction.

## Non-Goals

- Full per-tab UI migration is not completed in this slice.
- CLEAN-33 still owns harmful path/fallback deletion.
- Later slices may move existing controls from interim Generate/Edit containers into dedicated tab panels.
