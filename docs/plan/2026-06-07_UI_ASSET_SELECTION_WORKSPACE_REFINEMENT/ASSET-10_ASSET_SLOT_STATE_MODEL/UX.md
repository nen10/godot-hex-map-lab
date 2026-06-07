# ASSET-10 UX

## User Goal

Every workspace asset slot can expose the same user-facing state: not selected, selected, invalid, or warning. Sample resources can be offered as an explicit learning action without becoming the default current selection.

## Operation Steps

1. A screen creates an asset slot state with slot id, display name, required type, and required/optional flag.
2. The user selects a project resource, clears it, or explicitly applies a sample source when allowed.
3. The slot reports selected resource/path and validation messages through a public state snapshot.
4. Tests assert the state snapshot and status, not private labels/buttons.

## Adopted UX

- Missing required asset is visible as `not_selected`.
- Wrong resource type is visible as `invalid`.
- Valid resource with nonblocking issues is visible as `warning`.
- Sample source is visible as optional learning state and is only selected by explicit action.

## Deferred UX

- Create-new file dialogs are deferred to `ASSET-12`.
- Full workspace context wiring is deferred to `ASSET-11`.
- Screen migration is deferred to `WORKSPACE-10` and screen tasks.
