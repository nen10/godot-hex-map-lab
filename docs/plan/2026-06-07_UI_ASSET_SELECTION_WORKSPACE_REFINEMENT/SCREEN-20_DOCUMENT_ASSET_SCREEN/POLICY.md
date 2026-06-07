# SCREEN-20 Policy

## Adopted Decisions

- Document screen actions operate on `HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT`.
- Project document creation uses `HexMapWorkspaceAssetResourceFactory`.
- Save As persists the selected document Resource and updates session saved path state.
- Validation uses `HexMapDocumentValidator` with project context dependencies.

## Rejected Decisions

- Do not use bundled sample documents as the Document tab default.
- Do not add manual analog tests during CLEAN UI work.
- Do not implement full metadata editing in this task.

## Boundary

- This task makes Document tab asset management functional.
- Rich document editor features remain in later tasks.
