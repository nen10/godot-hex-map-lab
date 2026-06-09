# PROFILE-30 Policy

## Adopted Decisions

- Profile slots are typed to concrete Resource classes.
- Factory-created profile resources must use the concrete classes.
- Built-in profile duplication paths must duplicate concrete classes.
- The concrete classes are intentionally minimal until later profile behavior tasks define deeper schemas.

## Boundaries

- Document dependency hydration with these concrete types remains handled by existing dependency service mechanics.
- Profile-specific screen behavior remains in later QA / Validate / Export screen tasks.
- Existing saved generic profile compatibility is not a default requirement for this unpublished addon.
