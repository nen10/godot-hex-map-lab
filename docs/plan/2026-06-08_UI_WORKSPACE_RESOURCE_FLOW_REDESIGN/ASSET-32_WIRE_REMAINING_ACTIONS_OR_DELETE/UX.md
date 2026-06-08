# ASSET-32 UX

## User Goal

Every visible action in resource-related workspace UI should either complete a concrete change or be absent. Pressing a button should not leave the user with only an emitted signal, hidden state, or a test-only success path.

## Operation Steps

1. Open a workspace tab with asset slots.
2. Use `Create New...` to create a project resource for that slot.
3. Use explicit sample application only when the slot has a sample candidate.
4. Open Settings / Samples without seeing row actions that do not yet complete a user-visible result.

## Adopted UX

- `Create New...` remains a visible asset-row action because choosing a project path creates, saves, and selects the resource in the workspace context.
- Explicit sample application remains visible only when the slot state has a sample candidate and pressing it selects that candidate.
- Settings sample row `Open` / `Duplicate To Project` buttons are removed until a later task gives them a complete focus, path-choice, copy, and selection flow.

## Rejected UX

- No visible button whose only behavior is to emit a signal.
- No sample duplicate button without a destination choice and resulting project selection.
- No sample open button without a visible preview or focus result.

## Existing UX Interference

- Programmatic sample duplication stays available for direct package/test support, but it is not exposed as a half-wired Settings row button in this task.
