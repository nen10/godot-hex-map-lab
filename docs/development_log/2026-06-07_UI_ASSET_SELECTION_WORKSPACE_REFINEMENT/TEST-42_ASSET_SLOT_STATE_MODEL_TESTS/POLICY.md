# TEST-42 Policy

## Requirement

Asset slot state tests must cover the state matrix used by editor screens:

- required missing
- invalid type
- selected project asset
- optional sample source not selected by default
- explicit sample source
- sample mode OFF/ON visibility boundary
- duplicated sample as project asset

## Boundary

Sample catalog file validity belongs to adapter/package tests. TEST-42 owns editor state and source classification.

## Test Rule

Use asset slot snapshots, workspace context, sample settings snapshots, and screen snapshots. Do not test private UI child names.
