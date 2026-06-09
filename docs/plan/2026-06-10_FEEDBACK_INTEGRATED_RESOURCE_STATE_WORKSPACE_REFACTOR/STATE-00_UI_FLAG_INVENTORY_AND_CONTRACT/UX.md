# STATE-00 UX

## User Goal

Future state-machine work should make UI behavior predictable: a user should see one coherent state per workflow instead of controls assembled from unrelated booleans.

## Operation Steps

1. Review Generate, Workspace binding, asset rows, Paint, Validation, Export, Sample learning, and Dialog lifecycle code paths.
2. Record current flags and derived UI symptoms.
3. Assign P0 / P1 / P2 state-machine priority.
4. Decide whether existing UI tests should be kept, rewritten as state-contract tests, or deleted.

## Adopted UX

- State-machine priority follows user-facing confusion and implementation risk.
- Tests should verify state transitions and visible contracts, not private widget shape.
- This task produces a review artifact rather than partial state-machine code.

## Rejected UX

- No direct state-machine implementation in STATE-00.
- No new analog tests.
- No preservation of tests that exist only to freeze old UI details.
