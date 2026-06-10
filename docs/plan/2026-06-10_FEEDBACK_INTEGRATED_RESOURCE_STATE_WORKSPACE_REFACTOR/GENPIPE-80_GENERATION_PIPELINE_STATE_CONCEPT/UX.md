# GENPIPE-80 UX

## User Goal

Users need Generate and QA to stay focused on creating, comparing, previewing, and committing map results, while future advanced generation pipelines have a clean place to store intermediate maps without turning the current Generate tab into a graph editor.

## Operation Steps

1. Configure a Generation Profile or current Generate controls.
2. Generate a preview primary map and optional overlay output.
3. Inspect validation/status and optionally compare seed candidates in QA.
4. Apply or promote a chosen result into the selected Level Document.
5. Future advanced users may persist intermediate results for replay or chaining, but that must be Resource/API-backed before UI expansion.

## Adopted UX

- Final Level Document remains the committed authoring state.
- Generation Preview remains transient by default.
- QA Seed Lab rows remain candidate summaries unless a future persisted result model exists.
- Intermediate maps may become named Resources or subresources later, but not normal visible controls today.
- Graph UI remains research-only until resource save/load, replay, and invalidation rules exist.

## Deferred UX

- Generation Result browser.
- Pass/node graph editor.
- Visual dependency edges.
- Partial invalidation or cache UI.
- Manual editing of intermediate maps as first-class authoring layers.

## Existing UX Interference

- Current overlay source/query controls already behave like a lightweight pipeline but are stored as dock control state.
- Adding graph UI now would compete with Generate/QA primary actions and make save/load behavior ambiguous.
