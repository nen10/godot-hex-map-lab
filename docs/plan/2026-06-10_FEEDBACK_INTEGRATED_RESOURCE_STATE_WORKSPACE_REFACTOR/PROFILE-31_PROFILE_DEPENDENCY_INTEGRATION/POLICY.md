# PROFILE-31 Policy

## Adopted Decisions

- Validation Rule Suite, Generation Profile, and Export Profile dependencies must be typed to their concrete Resource classes.
- Workspace hydration may only select a profile slot when the dependency Resource matches that concrete class.
- Missing profile resources are optional workflow configuration. The UI should show missing state, while document validation should reserve errors for required dependencies or type mismatches.

## Boundaries

- The selected Level Document remains the owner of shared profile dependencies.
- QA / Validate / Export profile behavior remains lightweight in this task; later screen tasks own deeper workflow changes.
- Generic `Resource` compatibility is not preserved for these profile slots.
