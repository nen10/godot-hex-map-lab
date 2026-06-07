# CLEAN-33 Policy

## Decisions

- Prefer hiding/demoting internal controls over preserving them as normal authoring UI.
- Read-only path status is allowed when it reports a selected/saved resource; editable path input is not normal UX.
- Backend numeric state can remain when required by tests or runtime adapters, but normal controls must not be visible.
- Manual apply is advanced/support behavior; generation should normally apply through Generate/auto-apply or workspace workflows.

## Verification

- Headless tests assert hidden numeric controls, read-only path status, and demoted manual apply wording.
- `./tools/test.sh` remains the completion test path.
