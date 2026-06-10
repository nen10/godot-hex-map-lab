# UI-METRIC-05 UX

## User Goal

Codex should be able to ask whether a layout metric report has P0 failures and receive a clear `passed` boolean plus failure rows, before standard test integration makes those failures block queue completion.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. P0 gate report API | high | low | medium | adopt | It is the required boundary between warn-only metrics and future test gating. |
| B. Immediate actual Workspace gate in `tools/test.sh` | high | high | medium | reject | Integration/report output is explicitly queued as `UI-METRIC-07`. |
| C. Synthetic fail/pass fixtures | high | low | medium | adopt | They prove P0 semantics without depending on current UI debt. |
| D. Auto-repair P0 findings | medium | high | high | reject | Repair ownership belongs to later UI tasks. |

## Adopted UX

- `evaluate_p0()` returns a P0 report with `passed`, `failure_count`, category counts, and failure rows.
- P0 failure rows include category, severity, path, message, and evidence.
- Tests prove both failing and passing synthetic reports.

## Deferred UX

- Actual Workspace P0 gate execution from standard test output remains in `UI-METRIC-07`.
- UI task self-review template adoption remains in `UI-METRIC-08`.

## Experience Steps

1. Evaluate a snapshot with `evaluate_p0()`.
2. Inspect `passed` and failure rows.
3. Later integration decides whether nonzero failures exit nonzero.

## Existing UX Interference

This task must not hide or downgrade P0 categories. It creates the fail report semantics while leaving current UI enforcement to the scheduled integration step.
