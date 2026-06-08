# ASSET-31 UX

## User Goal

Workspace resource rows should have one clear interaction path: use the ResourcePicker to select or clear, use `Create New...` when a project asset must be created, and use explicit sample actions only when the sample learning flow is visible.

## Operation Steps

1. Open a workspace asset row.
2. Use the ResourcePicker for selecting or clearing a Resource.
3. Use `Create New...` for a new project `.tres` Resource when the slot supports creation.
4. Use explicit sample/learning actions only from the sample flow.

## Adopted UX

- Remove visible `Select...`, `Open`, `Clear`, and `Validate` action buttons from compact asset rows.
- Keep `Create New...` because it creates project assets and has an implemented Save As path.
- Keep explicit sample action only when sample state provides a real sample candidate.

## Rejected UX

- No row-level no-op action buttons.
- No duplicate `Clear` button when ResourcePicker already supports clearing.
- No row-level `Validate` action that competes with the Validate tab.

## Existing UX Interference

- Existing signal/API methods may remain for non-visible integrations, but hidden no-op buttons are not considered part of the normal UI.
