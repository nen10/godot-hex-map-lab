# ASSET-00 UX

## User Goal

Game developers can trust roadmap completion language: a feature is only complete when the normal workflow supports user-selected project assets. Bundled samples remain useful for learning, but sample preset success cannot be presented as production workflow completion.

## Operation Steps

1. During planning, classify any editor-facing feature that only works through bundled samples as `sample-only prototype`.
2. During implementation, require the normal path to expose arbitrary project asset selection before the task can be marked complete.
3. During test design, verify sample mode OFF or unconfigured project-asset state for feature screens; test sample mode separately.
4. During review, record sample-only coverage as non-completion unless the active roadmap explicitly says the task is sample/package integrity work.
5. During CLEAN UI work, keep analog tests deferred until the user explicitly asks for them.

## Adopted UX

- Production UI starts from user-selected project assets and valid unconfigured state.
- Sample UI is learning/onboarding UI, ideally under Settings / Samples, and never silently replaces production asset selection.
- Missing project assets are surfaced as visible setup or validation state, not hidden by sample defaults.

## Deprecated UX

- Treating `Use Sample...` success as feature completion.
- Adding fixed sample paths or sample-only buttons to satisfy acceptance.
- Preserving old headless tests that require sample-only or private-widget behavior.

## Existing UX Interference

Existing Generate/Paint/Catalog paths may still expose sample shortcuts near the main workflow. Later tasks will move or reclassify those paths, but this task only establishes the completion rule that governs them.
