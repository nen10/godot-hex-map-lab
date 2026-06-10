# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Keep current sparse labels | low | medium | low | reject | The screens remain resource-reference oriented rather than task surfaces. |
| B. Resources readiness board for node/document/dependencies | high | low | medium | adopt | Gives the user a clear project-resource setup surface. |
| C. Layers role tree summary | high | low | medium | adopt | Makes role status and writable source scannable before later role editing work. |
| D. Export runtime handoff summary | high | low | medium | adopt | Clarifies source, destination, output type, readiness, and result state. |
| E. Add all editing controls now | medium | high | high | reject | Later queue items own deeper editing/product decisions. |

## User Goal

The user should be able to scan Resources, Layers, and Export as work surfaces and understand what is ready, what is missing, and what action each screen supports.

## Adopted UX

- Resources shows selected node, Level Document, dependency groups, source badges, and next actions as grouped visible state.
- Layers shows a role tree summary with relationship, role counts, and per-role status/writable/visibility text.
- Export shows runtime handoff readiness with source, destination, output type, profile, action readiness, and result state.
- Existing asset rows remain the resource selection controls; new summaries do not introduce path text or raw JSON primary UI.

## Rejected / Deferred UX

- No Layer role editor controls in this task.
- No Paint viewport feedback work in this task.
- No package build UI decision in this task.
- No sample-backed Resources/Export completion.

## Experience Steps

1. User opens Resources and sees whether a HexTileMap node is selected, which unique/shared/optional resources are ready, and what the next setup action is.
2. User opens Layers and sees whether the Layer Stack is linked to the target, how many roles are present/missing, and which roles are visible/writable/locked.
3. User opens Export and sees runtime handoff readiness before choosing a destination or running the handoff.
4. User fixes missing inputs through existing asset slots or destination actions rather than raw path or debug data.
