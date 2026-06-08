# SAMPLE-40 UX

## User Goal

The Settings sample area should help a user move from bundled learning assets to project-owned assets without silently using samples as production execution inputs.

## Operation Steps

1. Open Settings / Samples.
2. Review the bundled sample catalog row.
3. Press `Duplicate To Project`.
4. Choose a project `.tres` destination.
5. See that the project copy was created and selected as the Catalog asset.

## Adopted UX

- Keep sample rows as learning references.
- Keep `Open` removed because the current workspace component has no implemented Inspector, FileSystem focus, or preview target.
- Reintroduce `Duplicate To Project` only for the bundled sample catalog row.
- After duplication, show the saved catalog path and the affected asset slot.

## Rejected UX

- No disabled duplicate buttons for texture/scene rows; those assets are copied as catalog dependencies.
- No implicit destination or silent overwrite path.
- No production execution fallback to bundled sample paths.

## Existing UX Interference

- Existing direct duplication helper remains available, but the visible button path must choose a destination and update the workspace asset context.
