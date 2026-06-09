# CLEAN-52 Policy

## Decisions

- Treat analog tests as optional user-requested observation documents during CLEAN UI rework.
- Keep existing analog-test files available as history because they can still explain prior UX observations.
- Do not use existing analog-test files as acceptance proof for the clean editor UX.
- Completion proof for this docs-only task is `./tools/test.sh`, docs review, and no new files under `tests/analog_test/`.

## Verification

- `docs/TEST.md` states deferral, historical status, and no NEXT-03-style schedule.
- `tests/analog_test/README.md` repeats the historical/deferred status at the directory entry point.
- `./tools/test.sh` remains the completion test path.
