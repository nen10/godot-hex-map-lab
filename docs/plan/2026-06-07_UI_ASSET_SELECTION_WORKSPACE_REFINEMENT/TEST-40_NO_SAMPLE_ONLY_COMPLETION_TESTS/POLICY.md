# TEST-40 Policy

## Requirement

Headless feature-screen tests must not use bundled sample success as completion evidence. They must assert one of these production states:

- sample mode OFF with no silent sample assignment
- project asset selected in an asset slot with `SOURCE_PROJECT`
- arbitrary user-provided Resource selection
- missing project asset validation issue with routing metadata

## Boundaries

- Sample mode ON/OFF behavior belongs to Settings / Samples tests.
- Bundled sample catalog and package inclusion validity belongs to sample/package integrity tests.
- Normal feature tests may reference samples only to assert that they are not silently injected.

## Test Rule

Prefer public workspace snapshots, asset slot snapshots, and shared context state over private node names.
