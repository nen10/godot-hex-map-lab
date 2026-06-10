# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Text-only preview summary | low | medium | low | reject | Users still cannot visually inspect the selected catalog entry. |
| B. One dedicated detail preview with atlas texture and scene identity rendering | high | low | medium | adopt | Makes the Catalog tab feel like an asset work surface. |
| C. Preview every row as a Control | medium | medium | high | reject | The task targets detail; row rendering would expand scope without acceptance need. |
| D. Badge/tooltip for missing or invalid preview | high | low | low | adopt | Missing TileSet/source/scene should be visible and actionable. |
| E. Use bundled sample visuals when project data is missing | medium | high | medium | reject | Violates no sample-only completion and hides unconfigured project state. |

## User Goal

The user should select or create a Tile Catalog entry and immediately see what the atlas tile or scene entry represents, with clear feedback when the preview cannot be rendered.

## Adopted UX

- Catalog detail includes a stable preview region.
- Atlas entries render from the selected catalog TileSet texture region.
- Scene entries render as a scene preview glyph with scene identity metadata.
- Unavailable, placeholder, and invalid states show a compact badge and tooltip reason.
- Raw source id, atlas coordinates, and path-like details remain metadata/snapshot detail rather than primary visible controls.

## Rejected / Deferred UX

- No sample fallback for prettier previews.
- No duplicated Paint-side catalog management UI.
- No full TileSet editor replacement in the Catalog tab.

## Experience Steps

1. User selects or creates a project Tile Catalog.
2. User creates an atlas entry from a project TileSet and sees the selected tile render in Catalog detail.
3. User creates a scene entry from a PackedScene and sees a scene preview state in Catalog detail.
4. User selects a placeholder or invalid entry and sees an unavailable badge with a tooltip reason.
5. User can validate the catalog without raw coordinate fields becoming the primary workflow.
