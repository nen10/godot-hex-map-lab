# Editor Workspace Model Decision 2026-06-07

Date: 2026-06-07
Task: `CLEAN-31`
Roadmap: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/UX_ROADMAP.md`
Inventory: `docs/review/roadmap/EDITOR_UX_COMPONENT_INVENTORY_2026-06-07.md`

## Decision

Use one `Hex Map Workspace` dock with tabs.

The workspace owns one shared document/session header and a `TabContainer` with these first-class work areas:

- `Document`
- `Generate`
- `Paint`
- `Catalog`
- `Layers`
- `Validate`
- `QA`
- `Export`

Existing `HexMapGenDock` and `HexMapEditTool` should be treated as interim containers. CLEAN-32 should extract reusable components by UX responsibility and mount them in the workspace tabs.

## Why

### Document-centered workflow

A single workspace gives the user one selected document, one selected target, one dirty state, one validation summary, and one saved path status. The current two-dock model already needs `HexMapEditorSessionState` to synchronize Generate and Edit. That is a signal that document/session identity is shared and should be visible as one workspace state, not split across two top-level docks.

### Discoverability

Catalog, Layers, Validate, and QA are now real workflows:

- Catalog has resource identity, TileSet, entries, scene resources, and validation status.
- Layers has templates, roles, visibility, locked state, z-index, writable source, apply, and clear role actions.
- Validate has domain/severity issue rows, focus targets, and fix suggestions.
- QA has batch generation, score rows, selected seed preview, and promotion.

Keeping those workflows inside two long docks makes them secondary and hard to find. Dedicated tabs give each workflow a stable home without requiring the user to remember which historical dock owns it.

### Godot editor compatibility

A dock is safer than a main screen for this addon. Hex map authoring depends on the Scene tree, Inspector, FileSystem, and 2D viewport remaining visible and familiar. A main screen would compete with Godot's existing 2D editor and raise the implementation cost without improving the core map-document workflow.

### Narrow-width behavior

The current long-scroll docks force unrelated controls into one vertical lane. A workspace dock with tabs keeps each tab dense but bounded. Individual tabs can scroll internally, and wide or detailed workflows such as Catalog, Layers, Validate, and QA no longer have to compete with generation controls in the same column.

## Options Considered

| Option | Result | Reason |
|---|---|---|
| Keep two docks: `Hex Map Generate` and `Hex Map Edit` | Rejected | Preserves historical split rather than user goals. Requires shared state but hides that state across two surfaces. Catalog/Layers/Validate/QA remain hard to place. |
| One `Hex Map Workspace` dock with tabs | Selected | Matches document-centered authoring, gives each workflow a clear home, preserves Godot viewport/Inspector context, and supports staged component extraction. |
| Main screen | Rejected for now | Too much overlap with Godot's 2D editor and scene workflow. Better reserved for a future full visual authoring surface after the dock UX is stable. |

## Target Component Map

| Workspace tab | Primary component owner for CLEAN-32 | Notes |
|---|---|---|
| `Document` | `HexMapDocumentHeader` | New/Open/Save/Save As, dirty state, document summary, validation summary. |
| `Generate` | `HexMapGenerationPanel` | Shape, seed, generation mode, progress/cancel, single-run generation. |
| `Paint` | `HexMapBrushPalette` | Target layer, edit mode, catalog-key brush selection, viewport edit state. |
| `Catalog` | `HexMapCatalogPanel` | Catalog resource, TileSet, entries, preview/status, scene entry PackedScene picker. |
| `Layers` | `HexMapLayerStackPanel` | Template picker, role rows, Create Missing Layers, Apply Document, Clear Role. |
| `Validate` | `HexMapValidationPanel` | Domain/severity issue list, focus target, fix suggestion, Copy Debug Report entry. |
| `QA` | `HexMapSeedLabPanel` | Batch seed run, score table, selected seed preview, Promote to Document. |
| `Export` | `HexMapExportPanel` | Runtime export/package handoff and support/debug actions. |

## Implementation Constraints For CLEAN-32

- Create one workspace dock in `plugin.gd` instead of registering independent Generate/Edit docks.
- Keep `HexMapEditorSessionState` as the shared workspace session model.
- Keep viewport input routing through the Paint/Edit component so `_handles()` and `_forward_canvas_gui_input()` still have one editing owner.
- Do not split code by line count. Split by the tab/component responsibilities above.
- Tests should assert user state transitions such as `document selected`, `catalog entry selected`, `validation issue selected`, and `seed promoted`, not internal container depth.
- Do not preserve editable path text, numeric fallback controls, or plain `TileMapLayer` primary paths just because older tests referenced them.

## Follow-up Owners

- `CLEAN-32`: build the workspace shell and extract responsibility components.
- `CLEAN-33`: delete or demote harmful old paths that should not survive the workspace move.
- `CLEAN-40`: update manuals around the selected workspace/tab model.
- `CLEAN-61`: package only after docs/tests reflect the workspace model.

## Decision Status

Accepted for the CLEAN roadmap.
