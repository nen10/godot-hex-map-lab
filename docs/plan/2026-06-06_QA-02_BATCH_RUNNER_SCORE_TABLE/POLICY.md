# QA-02 Policy

## Decisions

- Batch generation reuses the existing Generate Dock snapshot and generator helpers instead of forking generation rules.
- Batch runs do not mutate `_current_data`, `_current_overlay_data`, target layers, or single-generation validation state.
- Score rows are dictionaries so tests and future UI can consume the same table without a new visual component in this task.
- The default score favors valid, connected primary maps and penalizes validation errors and warnings.
- Sorting is deterministic and uses seed as a tie-breaker.

## Compatibility

- Existing Generate button, history save, auto apply, and debug report behavior remain unchanged.
- `QA-03` can use the stored seed rows later to promote a chosen seed into a document.

## Test Policy

- Add editor plugin headless tests for N seed generation, validation summaries, score ordering, and no current-map mutation.
- Update `docs/TEST.md` because the editor plugin Test path gains batch runner coverage.
- Final proof requires `./tools/test.sh`.
