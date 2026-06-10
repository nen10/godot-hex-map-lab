# UI-METRIC-07 UX

## User Goal

Standard verification should run the P0 UI metric gate and leave a report that explains any failure without requiring the developer to rerun a separate command.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. `tools/test.sh` runs P0 gate | high | medium | medium | adopt | P0 UI contract violations should block standard verification. |
| B. P1 also fails standard tests | medium | high | medium | reject | P1 is intentionally staged as report-only initially. |
| C. JSON and Markdown output | high | low | medium | adopt | JSON feeds automation; Markdown is fast to inspect. |
| D. Report-only standard test | low | high | low | reject | This would not satisfy P0 integration. |

## Adopted UX

- Standard tests run the Workspace layout metric gate.
- Reports are written under `.godot_user/ui-metrics/<run-id>/`.
- P0 failures fail the test script and include report paths.
- P1 issue counts are included but do not fail the standard test yet.

## Deferred UX

- P1 standard enforcement is deferred.
- Autopilot self-review template integration remains in `UI-METRIC-08`.

## Experience Steps

1. Run `./tools/test.sh`.
2. If P0 failures exist, inspect the Markdown report path from the test output.
3. Use JSON report for automation and later self-review template integration.

## Existing UX Interference

This task intentionally makes P0 visible UI metric failures blocking. The evaluator must avoid false positives from allowed controls such as explicit debug-report copy actions.
