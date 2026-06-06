# GAME-05 Policy

Date: 2026-06-07

## Decisions

- The sample lives under `examples/basic_runtime/` and uses runtime-safe adapter/core scripts only.
- The sample returns data dictionaries rather than drawing UI, which keeps it easy to test headlessly.
- Missing/invalid document paths return `loaded=false` with an error string instead of throwing.
- The sample accepts an optional movement profile and tile catalog so it can exercise profile-specific movement without editor code.

## Repair classification

- `repair-now`: editor-only dependency, invalid resource path behavior, missing path/range query, missing test proof, or failing `./tools/test.sh`.
- `follow-up-ready`: richer example scene or package docs beyond this sample.
- `manual-optional`: visual example walkthrough.
