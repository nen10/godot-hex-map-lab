# NODE-22 Policy

## Adopted Decisions

- `Create Missing Resources` creates selected-node unique resources only:
  - Level Document
  - Layer Stack
- Existing unique resources are preserved.
- Shared project resources are never created by this action.
- Shared project resources already present in Workspace context are written to the selected Level Document dependencies after the Level Document exists.

## Boundaries

- Individual shared resource creation and picker writeback remain owned by the asset slot flows.
- Generic profile Resource classes remain unchanged until `PROFILE-30`.
- Larger Resource row redesign remains in later UI tasks.
