# CLEAN-26 Implementation Plan

1. Mark CLEAN-26 `RUNNING` in the queue.
2. Add action-oriented row fields to `HexMapValidationDashboard`: domain, severity label, focus target, and fix suggestion.
3. Render concise issue labels and selected issue detail.
4. Extend edit-tool issue focus to report catalog/resource targets where metadata exists while preserving cell highlight behavior.
5. Route catalog validation results into the dashboard.
6. Update tests/docs.
7. Run `./tools/test.sh`, self-review, queue update, and commit.
