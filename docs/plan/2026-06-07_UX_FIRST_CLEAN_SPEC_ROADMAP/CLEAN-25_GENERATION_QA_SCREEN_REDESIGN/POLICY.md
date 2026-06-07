# CLEAN-25 Policy

## Decisions

- Seed Lab wraps existing batch scoring and promotion APIs.
- Score rows remain lightweight; preview text is enough for this task when a visual preview is not yet available.
- Promoted documents carry generation metadata and are marked as promoted state in the dock.

## Verification

- Tests should exercise the visible controls: run batch, score table rows, row selection, preview/status, and promotion.
