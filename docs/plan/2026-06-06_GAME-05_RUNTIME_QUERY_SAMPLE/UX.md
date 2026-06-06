# GAME-05 Runtime Query Sample UX

Date: 2026-06-07

## User-facing outcome

A runtime script can load a saved Level Document v2 resource and ask movement questions without editor-only dependencies:

- weighted path between two cells;
- movement range from a start cell;
- profile id included in the returned summary.

## Operation Steps

1. Save or provide a `HexMapDocumentResource`.
2. Call `HexRuntimeQuerySample.query_document_path(path, start, goal, budget, profile)`.
3. Read the returned `path`, `range`, and counts.

## Non-goals

- No polished example scene UI in this task.
- No packaging or public release docs beyond the runtime sample note.
