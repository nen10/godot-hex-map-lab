# VAL-03 Implementation Plan

## Scope

Add compact validation summary/debug-report integration for Edit Dock and Generate Dock, update tests and docs, run full proof, self-review, queue proof, and commit.

## Steps

1. Add Edit Dock validation report summary/row helpers and include them in `debug_report_text()`.
2. Add Generate Dock validation summary and `debug_report_text()` for the current generated map.
3. Keep existing normal status labels free of validation issue dumps.
4. Add `tests/test_editor_plugin.gd` coverage for both reports.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`; repair failures in-task.
7. Write self-review/test-result docs, update queue proof, and commit.
