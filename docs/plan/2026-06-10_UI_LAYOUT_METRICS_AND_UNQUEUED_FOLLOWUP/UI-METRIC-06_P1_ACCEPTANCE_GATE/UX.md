# UI-METRIC-06 UX

## User Goal

Codex should be able to classify layout polish risks as P1 issues in a report, while keeping standard P0 gating separate and allowing P1 enforcement to be staged.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. P1 report API | high | low | medium | adopt | It gives later UI tasks concrete polish evidence. |
| B. Immediate P1 standard test failure | medium | high | medium | reject | Roadmap says P1 can stay separate initially. |
| C. Synthetic P1 fixtures | high | low | medium | adopt | They prove categories deterministically. |
| D. Pixel/screenshot heuristics | medium | high | high | reject | Current metric foundation is structural snapshot data. |

## Adopted UX

- `evaluate_p1()` returns `passed`, `issue_count`, category counts, and severity `p1` issue rows.
- Required P1 categories are synthetic-tested for failure and clean pass paths.
- Existing warn and P0 APIs remain unchanged.

## Deferred UX

- P1 command/report integration remains with `UI-METRIC-07`.
- P1 repair work remains with later owning UI tasks.

## Experience Steps

1. Evaluate a snapshot with `evaluate_p1()`.
2. Inspect issue rows and category counts.
3. Use P1 report as polish evidence without blocking current P0 integration.

## Existing UX Interference

P1 report creation must not downgrade P0 failures or alter warn-only reporting. It adds a separate report layer.
