# PERF-61 Progress And Busy UI UX

Date: 2026-06-08

## User goal

Long Generate and global tile update operations should show the current step in the dock instead of appearing unresponsive.

## Flow

1. Press Generate.
2. The existing inline ProgressBar appears.
3. The status text advances through preparing, generating, validating, applying, and ready.
4. Orientation / tile-setting changes that reapply the current layer use the same inline status surface with an approximate delayed-operation message.

## Visible contract

- No modal progress window is introduced.
- Cancel stays available only while threaded generation is running.
- Validation/apply/tile-update steps are visible as coarse progress states.
- Completion remains visible briefly and then hides as today.
