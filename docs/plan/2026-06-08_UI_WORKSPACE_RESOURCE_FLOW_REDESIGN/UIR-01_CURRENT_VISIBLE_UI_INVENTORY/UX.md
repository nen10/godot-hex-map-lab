# UIR-01 UX

## User Goal

Record what the workspace actually shows today so later tasks fix the visible first-impression problems instead of assuming the existing code already communicates the workflow.

## Operation Steps

1. Read the current workspace tab registry and mount code.
2. Read the asset-slot control shape because resource rows dominate the first impression.
3. Compare each visible tab against the roadmap's first-impression observations.
4. Classify each problem as display bug, missing design, no-op action, or scheduled redesign.
5. Leave the next implementation task with a precise target.

## Adopted UX

- Inventory is based on source/readback facts: tab names, mounted components, asset slots, visible labels, buttons, and scroll ownership.
- The report reproduces the user-observed impression for Document, Paint, Catalog, Layers, Validate, QA, Export, and Settings.
- Sample-only or API-only success is not used to soften the visible inventory.

## Retained UX

- Existing Generate and Paint embedded tools are recognized as real working components.
- Existing headless readback helpers remain useful evidence for mounted components and asset slot ids.

## Removed or Deferred UX

- No UI changes are made in this task.
- No analog test is created.
- Browser/editor visual QA is deferred until layout tasks alter the actual UI.

## Existing UX Interference

The current tab registry and tests assert `Document` as a tab name and resource-reference panels across most tabs. This inventory treats those as current facts, not as UX to preserve.
