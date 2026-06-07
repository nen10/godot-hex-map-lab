# GAME-04 Profile Reachability Validation UX

Date: 2026-06-07

## User-facing outcome

Validation can answer whether important document points are mutually reachable under a selected movement profile.

Important points come from:

- document object placements;
- document label placements;
- explicit validation options for scripts/tests.

Validation issues include the movement profile id so designers can tell which profile made a point blocked or unreachable.

## Operation Steps

1. Build or load a `HexMapDocumentResource`.
2. Choose one or more `HexMovementProfileResource` instances.
3. Call document validation with `movement_profile` or `movement_profiles`.
4. Read movement reachability issues from the normal validation result.

## Non-goals

- No new dashboard UI is required here; existing validation issue rows already display validation output.
- No runtime sample scene; that is `GAME-05`.
