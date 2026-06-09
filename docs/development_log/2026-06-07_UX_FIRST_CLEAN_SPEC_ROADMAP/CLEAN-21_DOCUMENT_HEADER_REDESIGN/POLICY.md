# CLEAN-21 Policy

## Decisions

- Document state is shown as selected/saved/dirty/validation summary.
- Saved path is metadata labeled `Saved`, never editable input.
- New/Open/Save/Save As/Validate are the primary document actions.
- Import/export remain available but are labeled as conversion/export workflows.
- Dirty state should be conservative: edits/import/new/target-derived documents are dirty until saved; loaded/saved resources are clean.

## Verification

- Headless tests should check button labels, document state text, Save fallback behavior, and dirty state transitions.
- Tests should not assert obsolete path fields or migration/v2 wording.
