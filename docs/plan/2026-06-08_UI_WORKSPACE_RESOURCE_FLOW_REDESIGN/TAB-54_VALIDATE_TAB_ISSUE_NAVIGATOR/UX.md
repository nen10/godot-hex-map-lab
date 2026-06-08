# TAB-54 UX

Task: `TAB-54_VALIDATE_TAB_ISSUE_NAVIGATOR`

The Validate tab is the workspace issue navigator. It explains what is being validated, lists current issues, and lets a user move from an issue to the tab/component that can fix it.

Primary screen:

1. Show the validation purpose and current validation target.
2. Run workspace validation from the Validate tab.
3. List issues with severity, domain, focus target, fix suggestion, and routed destination.
4. Selecting an issue moves to the relevant tab: Resources, Catalog, Layers, QA, Paint, or Validate.
5. Keep Validation Rule Suite as the Validate tab asset. Other production assets stay in their owner tabs.

Empty states:

- No validation run: show a direct prompt to run validation.
- No issues: show that the workspace validation passed.
- Missing resources: show the target tab and slot instead of a generic error dump.

Non-goals:

- Do not restore row-level Validate buttons in resource rows.
- Do not expose raw validation JSON as the normal issue navigator.
- Do not add analog tests.
