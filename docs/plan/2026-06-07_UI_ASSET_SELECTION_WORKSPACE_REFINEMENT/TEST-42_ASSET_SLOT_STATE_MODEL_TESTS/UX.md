# TEST-42 UX

## User Goal

Asset slots must present clear states for production project assets while keeping bundled samples as explicit learning candidates.

## Contract

- Required missing assets show a missing/not-selected state.
- Invalid Resource types report type mismatch.
- Selected project assets use project source state.
- Sample mode OFF hides bundled samples from main selectors.
- Sample mode ON exposes learning candidates without overriding selected project assets.
- Duplicating a bundled sample creates a project asset state.

## Non-goals

- Do not add analog tests.
- Do not make samples the default production path.
- Do not inspect private node paths.
