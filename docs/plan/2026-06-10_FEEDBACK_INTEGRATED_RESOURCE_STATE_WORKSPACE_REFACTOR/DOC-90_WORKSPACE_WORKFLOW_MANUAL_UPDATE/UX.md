# DOC-90 UX

## User Goal

A user opening the editor documentation should understand the production workspace path, where resource ownership is shown, and why samples are separate learning assets rather than silent defaults.

## Operation Steps

1. Select a `HexTileMap` in the scene.
2. Use `Resources` to confirm the selected node, Level Document, node-owned resources, and shared project dependencies.
3. Use `Generate` to preview or apply generated results to the selected document.
4. Use `Paint` with resources selected from the project context.
5. Use `Catalog` when tile/scene entries need inspection, creation, or validation.
6. Use `Validate`, `QA`, and `Export` to prepare the Level Document for runtime handoff.
7. Use Settings / Samples only to learn from bundled assets or duplicate them into project-owned files.

## Adopted UX

- Resource rows explain ownership through concise source badges and detailed tooltips.
- The manual documents the requested production tab path directly.
- Sample learning remains a separate chapter and separate onboarding path.
- Existing docs continue to route detailed API use to the API/manual references.

## Deferred UX

- No analog/manual screenshot test is added.
- No new UI controls are introduced by this task.

## Existing UX Interference

- New-project setup often requires Catalog configuration before Paint can be useful. The documentation should still preserve the accepted route while explaining that Catalog is where missing tile/scene entries are repaired.
