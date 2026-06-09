# PROFILE-31 UX

## User Goal

When a Level Document declares profile dependencies, the workspace should show those concrete profile resources in the related workflow tabs. If a profile is not configured, the tab should say it is missing or optional instead of silently using a sample or pretending a generic `Resource` is valid.

## Operation Steps

1. Select a `HexTileMapLayer` or Level Document with document dependencies.
2. The workspace hydrates Validation Rule Suite, Generation Profile, and Export Profile dependencies into shared asset context.
3. Validate, QA, and Export show the concrete resource type and `Document Dependency` source badge for selected profile resources.
4. If a profile dependency is absent, the tab state remains visible as optional/missing and does not fall back to bundled samples.

## Adopted UX

- Profile dependency rows use concrete type labels.
- Validate, QA, and Export snapshots expose concrete profile resource classes.
- Missing profile rows are optional/missing state, not blocking workspace validation issues.

## Rejected UX

- No generic `Resource` state for profile tabs.
- No sample profile fallback as completion proof.
- No broad workflow redesign inside this integration task.
