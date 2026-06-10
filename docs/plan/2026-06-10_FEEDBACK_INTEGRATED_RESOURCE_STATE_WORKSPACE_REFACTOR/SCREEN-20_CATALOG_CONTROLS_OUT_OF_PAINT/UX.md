# SCREEN-20 UX

## User Goal

A developer edits and validates Tile Catalog contents in Catalog, then uses Paint to choose catalog keys as brushes.

## Operation Steps

1. Open Catalog.
2. Select or create a Tile Catalog.
3. Review entry rows, preview, tags, and status.
4. Create atlas or scene entries from selected project assets.
5. Validate catalog contents.
6. Open Paint.
7. Choose a catalog key as the active brush without editing raw source id or atlas coordinates.

## Adopted UX

- Catalog owns entry list, detail, preview, tags/status, create/edit entry, and validation state.
- Paint owns active brush selection and painting state.
- Paint may show catalog-key selectors but not catalog entry management controls.
- Raw source id/atlas metadata remains detail/debug, not primary Paint UI.

## Deferred UX

- Full Catalog editor component extraction is deferred to later architecture work.
- Rich visual tile/scene thumbnails are deferred.
