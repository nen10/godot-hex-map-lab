# UI-METRIC-05 Policy

## Adopted Decisions

- P0 gate report severity is `p0`.
- P0 report has `passed=false` when `failure_count > 0`.
- Existing warning report remains available for non-P0 findings.
- Standard test integration over current Workspace output remains deferred to `UI-METRIC-07`.

## Rejected Decisions

- Do not make current Workspace warnings fail `./tools/test.sh` in this task.
- Do not add P1 categories to the P0 report.
- Do not require pixel/screenshot data for P0 structural failures.

## Invariants

- P0 report is JSON-serializable.
- P0 failure category ids are stable strings.
- P0 gate consumes the same snapshot shape as warn-only evaluation.
- `tools/test.sh` proves gate behavior through tests, not actual Workspace failure enforcement yet.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Synthetic P0 failure fixtures | allow | Current UI may not trigger every P0 category deterministically. | None; fixtures remain gate regression coverage. | Evaluator test. |
| Actual workspace gate integration deferred | defer | `UI-METRIC-07` owns report output and nonzero exit behavior. | `UI-METRIC-07` complete. | Queue proof. |
| Current UI P0 repairs deferred | policy-deferred | Repair ownership needs concrete report output and owning screen tasks. | P0 integration produces actionable failures. | Later UI tasks. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Synthetic P0 risk snapshot | All required P0 categories produce severity `p0` failures. | Gate misses critical first-impression risk. | Evaluator P0 test. |
| Synthetic clean snapshot | P0 report can pass with zero failures. | Gate only proves failing path. | Evaluator clean P0 test. |
| JSON report | P0 report serializes and parses. | Later integration cannot consume it. | JSON assertion. |
| Runtime Workspace warning evaluation | Existing warn-only behavior remains intact. | P0 changes accidentally alter UI-METRIC-04 report behavior. | Existing evaluator test still runs. |

## Resource / API / UI Boundary

- `HexUILayoutMetricEvaluator` owns metric report semantics.
- Product Workspace UI and Resource APIs are unchanged.
- `UI-METRIC-07` owns execution wiring and report persistence.
