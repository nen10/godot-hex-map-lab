# CLEAN-26 Validation Screen Refinement UX

## Goal

Validation should tell the user what to fix next, not expose raw validator state as the primary screen.

## User Contract

- Issues are grouped into user-facing domains: Document, Catalog, Layer, Object, Gameplay, and Package.
- Severity is visible as Error, Warning, or Info.
- Selecting an issue shows the focus target and a fix suggestion.
- Cell issues focus the target cell when possible; catalog/resource issues expose the relevant entry or resource target.
- `Copy Debug Report` keeps dense diagnostic detail while normal dashboard/status text stays short.

## Non-Goals

- CLEAN-31 owns final workspace/tab placement.
- CLEAN-40 owns full manual reorganization.
- Validator rule schema is not changed for this slice; the dashboard adds the action-oriented display layer.
