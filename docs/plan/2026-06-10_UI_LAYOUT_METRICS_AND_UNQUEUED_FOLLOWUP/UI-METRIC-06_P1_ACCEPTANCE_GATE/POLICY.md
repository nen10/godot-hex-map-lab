# UI-METRIC-06 Policy

## Adopted Decisions

- P1 report severity is `p1`.
- P1 report has `passed=false` when `issue_count > 0`.
- P1 categories are separate from P0 failure semantics.
- Standard P1 enforcement remains deferred.

## Rejected Decisions

- Do not make P1 issues fail `./tools/test.sh` in this task.
- Do not use screenshot/pixel checks for P1 categories in this task.
- Do not combine P0 failures and P1 issues into one severity.

## Invariants

- P1 report is JSON-serializable.
- P1 category ids are stable strings.
- Existing warn/P0 tests keep passing.
- P1 can consume the same snapshot shape.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Synthetic P1 fixtures | allow | Current UI may not trigger each category deterministically. | None; fixtures remain category regression coverage. | Evaluator test. |
| Standard P1 gate integration deferred | defer | Roadmap explicitly allows P1 to stay separate initially. | `UI-METRIC-07` complete. | Queue proof. |
| Current UI P1 repairs deferred | policy-deferred | Repair ownership needs report output and screen ownership mapping. | Later UI tasks. | Later metric report. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Synthetic P1 risk snapshot | All required P1 categories produce severity `p1` issues. | P1 report misses key polish risk. | Evaluator P1 test. |
| Synthetic clean snapshot | P1 report can pass with zero issues. | Gate only proves failing path. | Evaluator clean P1 test. |
| JSON report | P1 report serializes and parses. | Later command/report tooling cannot consume it. | JSON assertion. |
| Existing P0 report | P1 work does not change P0 semantics. | Severity cross-contamination. | Existing P0 tests still pass. |

## Resource / API / UI Boundary

- `HexUILayoutMetricEvaluator` owns P1 report semantics.
- Product Workspace UI and Resource APIs are unchanged.
- P1 command/report output remains scheduled separately.
