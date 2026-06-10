# TEST-80 UX

## User Goal

Developers should be able to change workspace screens, state machines, and Generate/Paint flows without fighting tests that encode stale widget layout details.

## Operation Steps

1. Run `./tools/test.sh`.
2. State-machine tests verify derived states and view states directly.
3. Workspace binding tests verify hydration/writeback contracts directly.
4. Screen contract tests verify public snapshot shape and workflow ownership.
5. Integration tests still cover end-to-end editor workflows where widget interaction matters.

## Adopted UX

- Tests focus on user-visible state and workflow ownership.
- Tests prefer public snapshots, ViewState, and service results over private node shape.
- The monolithic editor test remains for full workflow coverage, but new focused files own state-contract coverage.

## Deferred UX

- No analog/manual visual test is added.
- Full rewrite of every editor integration test is deferred.

## Existing UX Interference

- Some old assertions inspect private widget visibility or exact labels. Those should not be the only proof of a screen contract when a public snapshot exists.
