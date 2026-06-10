# ARCH-40 UX

## User Goal

Workspace resource state should behave consistently when a HexTileMap is selected, a document dependency hydrates, or a workspace asset is written back, without the UI reassembling those relationships itself.

## Operation Steps

1. Select a HexTileMap.
2. Workspace hydrates node-owned Level Document / Layer Stack.
3. Level Document dependencies hydrate shared project resources.
4. Workspace asset changes write back to the selected node or document dependency according to ownership.
5. UI panels render the resulting service state.

## Adopted UX

- The UI still shows selected node, source badges, hydration, pending writeback, applied writeback, and conflict states.
- Hydration/writeback state is service-derived and visible in existing snapshots.
- Manual override and document dependency behavior remain unchanged.

## Deferred UX

- Visual screen component extraction is deferred to `ARCH-41`.
- No analog test is added for this architecture slice.

## Existing UX Interference

- Existing Resources and selection snapshots depend on relationship details; those fields must remain available while moving ownership out of Workspace.
