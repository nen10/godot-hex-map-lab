# UI-METRIC-07 Policy

## Adopted Decisions

- P0 failure count greater than zero fails standard verification.
- P1 issue count is reported but does not fail standard verification in this task.
- Report output path is `.godot_user/ui-metrics/<run-id>/`.
- Reports include scenario id, viewport, P0 failures, and P1 issue counts.

## Rejected Decisions

- Do not make P1 issue count a standard failure yet.
- Do not store reports under `dist` or committed docs.
- Do not use bundled samples as the only report scenario.

## Invariants

- P0 report JSON is machine-readable.
- Markdown report is human-readable enough for repair triage.
- Standard test uses the same `HEX_MAP_TEST_RUN_ID` as other test artifacts.
- The report directory is generated output and not committed.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| P1 report-only state | allow | Queue acceptance explicitly permits P1 to stay separate initially. | Future task chooses P1 enforcement. | Metric gate test verifies P1 report is written. |
| Representative scenario matrix | allow | Keeps standard test time bounded. | Later metric task expands sizes/states if needed. | Gate test covers three scenario states. |
| Generated report output | allow | Reports are proof artifacts, not source files. | None. | File existence assertions. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| No selected HexTileMap | P0 gate can evaluate unconfigured target state. | First-impression empty state not gated. | Metric gate test. |
| Selected HexTileMap without resources | P0 gate can evaluate missing-resource state. | Setup state not gated. | Metric gate test. |
| Selected HexTileMap with shared resources | P0 gate can evaluate ready resource state. | Happy path not gated. | Metric gate test. |
| Report output | JSON and Markdown are written. | Failures cannot be inspected. | File existence assertions. |

## Resource / API / UI Boundary

- Test script owns report execution and output.
- Evaluator owns P0/P1 semantics.
- Product UI behavior is unchanged unless needed to remove true P0 failures.
