# UI-METRIC-04 Policy

## Adopted Decisions

- All findings emitted by this task have severity `warn`.
- The evaluator accepts snapshot dictionaries produced by `HexUILayoutSnapshotCollector`.
- Synthetic snapshot tests are valid proof for warning category coverage.
- Runtime Workspace evaluation is valid proof that current snapshots can be evaluated without failing the queue.

## Rejected Decisions

- Do not fail `./tools/test.sh` on warning count in this task.
- Do not persist report artifacts from standard tests in this task.
- Do not mutate product UI to manufacture warning categories.
- Do not encode final P0/P1 thresholds here.

## Invariants

- Warning rows are JSON-serializable.
- Category ids are stable strings.
- Current UI warnings are observable but nonblocking.
- Later gates can reuse the report without parsing human prose.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Warn-only severity | allow | This task is a staging layer before gates. | `UI-METRIC-05` and `UI-METRIC-06` introduce fail semantics. | `tests/test_workspace_layout_metric_evaluator.gd`. |
| Synthetic category fixtures | allow | Current UI may not trigger every category at once. | None; fixtures remain regression coverage for evaluator categories. | Synthetic snapshot test. |
| Persistent report output deferred | defer | Output path and standard integration are separate acceptance work. | `UI-METRIC-07`. | Queue proof. |
| Metadata-assisted no-op/state checks | allow | Snapshot data cannot infer every action binding or state source yet. | Future screen extraction can add richer metadata. | Synthetic snapshot test. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Synthetic risk snapshot | All required categories produce WARN findings. | Missing category leaves later gates without a source signal. | `tests/test_workspace_layout_metric_evaluator.gd`. |
| Runtime Workspace snapshot | Evaluation returns a report and does not fail on warnings. | Warn-only evaluator becomes an accidental gate. | Runtime scenario test. |
| JSON report | Report can be serialized and parsed. | Later tooling cannot consume evaluator output. | JSON serialization assertion. |
| Expected state id | Contradicting control state metadata is reported as WARN. | State contradiction is not represented. | Synthetic state contradiction fixture. |

## Resource / API / UI Boundary

- Evaluator lives under addon editor testing helpers.
- Product Workspace UI and Resource APIs are unchanged.
- Tests own category fixtures and runtime smoke evaluation.
