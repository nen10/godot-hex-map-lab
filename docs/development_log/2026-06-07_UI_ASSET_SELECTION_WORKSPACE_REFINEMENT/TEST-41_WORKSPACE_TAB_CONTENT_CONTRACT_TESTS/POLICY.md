# TEST-41 Policy

## Requirement

Workspace tab content tests must use the public workspace registry/query surface:

- `workspace_tab_names()`
- `component_rows()`
- `components_for_tab()`
- `tab_component_ids()`
- `tab_asset_slot_ids()`
- `asset_slot_count()`
- `tab_has_component()`

## Assertions

- Every tab in the registry has its expected mounted components.
- Asset slot ids match the tab responsibility contract.
- Components expose stable ids and responsibilities.
- Tests avoid private node names and visual tree paths.

## Boundary

Screen-specific workflow details remain in the screen tests. TEST-41 owns the cross-tab query contract.
