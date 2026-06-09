# SCREEN-23 UX

## User Goal

A project author manages Object and Label databases as project assets, creates typed definitions from selected resources, and places objects/labels by selecting definitions rather than typing raw ids.

## Operation Steps

1. Open the Workspace Paint/Object-Label panel.
2. Create or select a project Object Database.
3. Add an Object Definition from a selected `PackedScene` and optional preview texture.
4. Select an Object Definition for placement.
5. Create or select a project Label Database.
6. Add a Label Definition with default text/style.
7. Select a Label Definition for placement.

## Adopted UX

- Object Database and Label Database are project asset slots in the Paint screen family.
- Object placement starts from an Object Definition picker/list, with `PackedScene` held by the definition.
- Label placement starts from a Label Definition picker/list.
- Sample object scenes stay in Settings / Samples and are not silently assigned.

## Deferred UX

- Rich preview thumbnails, variant list editing, and full property schema editing remain presentation follow-up; this task establishes the Resource/action/state contract.
- Raw variant/spawn-condition cleanup remains scheduled under cleanup tasks.

## Removed UX

- Treating raw object id or raw label id text as the normal placement source.
- Treating the bundled sample object scene as production completion.
