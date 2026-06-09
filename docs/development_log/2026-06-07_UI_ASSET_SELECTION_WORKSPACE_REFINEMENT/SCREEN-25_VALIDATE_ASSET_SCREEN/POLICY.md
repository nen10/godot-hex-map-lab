# SCREEN-25 Policy

## Adopted Decisions

- Validate screen uses the shared workspace asset context as validation input.
- Missing project assets are represented as `HexMapValidationResult` issues with route metadata.
- Route metadata uses stable ids: `target_tab`, `target_component_id`, and `target_slot_id`.
- Existing document validation still runs when a Level Document is selected.

## Rejected Decisions

- Do not silently substitute sample assets for missing project assets.
- Do not make Validation Rule Suite absence block core asset validation; report it as an actionable issue.
- Do not implement a custom rule-suite DSL in this screen task.

## Resource / API / UI Boundary

- `HexMapWorkspace` owns Validate screen snapshots and workspace-level asset validation.
- `HexMapDocumentValidator` remains the document content validator.
- Asset selection screens own fixes for missing assets.

## Task-Local Decisions

- Required validation assets for this task are Level Document, Tile Catalog, Object Database, Label Database, Layer Stack, Validation Rule Suite, and Generation Profile.
- Generation Profile is included so QA-owned missing setup routes to the QA tab.
