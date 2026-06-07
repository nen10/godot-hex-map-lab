# WORKSPACE-11 Policy

## Adopted Decisions

- `HexMapWorkspaceComponentRegistry` owns stable tab/component rows.
- Workspace query helpers expose component ids and asset slot ids.
- Tests verify the public-ish registry contract instead of child node names.
- Validation tab includes a mounted `validation_issue_navigator` component id even before the richer issue UI arrives.

## Rejected Decisions

- Do not assert private node names or scene tree child positions.
- Do not build full screen-specific editors in this task.
- Do not make registry rows depend on sample mode state.

## Boundary

- This task hardens registry/query contracts.
- Later SCREEN tasks can replace compact components while preserving ids.
