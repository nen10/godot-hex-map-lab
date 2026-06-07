# SCREEN-21 UX

## User Goal

A project author can manage a Tile Catalog as a project asset, attach an arbitrary TileSet, and create entries from selected TileSet or PackedScene resources without using bundled samples.

## Operation Steps

1. Open the Catalog tab.
2. Create or select a project Tile Catalog.
3. Assign a project TileSet to the catalog.
4. Add atlas entries from TileSet tile selection.
5. Add scene entries from PackedScene selection.
6. Validate, open, save as, or clear the catalog.

## Adopted UX

- Tile Catalog is the Catalog tab's primary asset slot.
- TileSet and PackedScene entry creation are explicit project-resource actions.
- Sample catalog candidates remain hidden unless sample mode is enabled.

## Deferred UX

- Rich entry list/detail editing and visual previews remain deferred.
- Opening the TileSet editor is represented by state/action contract only in this task.
