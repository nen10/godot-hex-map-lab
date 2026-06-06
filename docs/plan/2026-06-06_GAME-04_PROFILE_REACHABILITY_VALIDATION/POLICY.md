# GAME-04 Policy

Date: 2026-06-07

## Decisions

- Profile reachability validation is opt-in. Existing validation calls without a movement profile keep their current result shape.
- Reachability uses passable cells from `HexGameplayLayerData`, so catalog tags, object blockers, and wall passability stay profile-specific.
- A single connected-area query from the first passable important point is enough because grid movement is undirected.
- Blocked important points and unreachable important points share one rule id, with metadata identifying `profile_id`, `reason`, and blocker data.

## Repair classification

- `repair-now`: missing profile id in issues, existing validation regressions, false pass for blocked important points, false fail without movement profile, or failing `./tools/test.sh`.
- `follow-up-ready`: editor UI affordances beyond existing validation issue rows.
- `manual-optional`: none.
