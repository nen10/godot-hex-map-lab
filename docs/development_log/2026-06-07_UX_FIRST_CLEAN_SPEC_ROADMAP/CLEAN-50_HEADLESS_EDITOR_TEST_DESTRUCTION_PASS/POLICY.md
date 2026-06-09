# CLEAN-50 Policy

## Decisions

- Remove node-existence assertions for obsolete path and numeric fallback controls.
- Prefer assertions on selected resources, saved path metadata, document/catalog payload state, target readiness state, and generated/apply results.
- If an old test only proves that a soon-to-be-deleted control exists, delete that assertion instead of designing around it.
- Keep high-value behavior tests temporarily when no clean replacement screen exists, but avoid wording that treats fallback UI as the desired UX.

## Repair Criteria

- `repair-now`: a test still fails because it requires an obsolete control.
- `follow-up-ready`: a useful behavior needs a new clean screen test after CLEAN-21/CLEAN-22/CLEAN-23/CLEAN-33.
- `accepted-risk`: product code may still contain old controls until the relevant UI deletion task.
