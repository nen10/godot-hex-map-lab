# UI-METRIC-04 UX

## User Goal

Codex should be able to inspect a Workspace layout snapshot and receive a readable warning report for known UI contract risks, while continuing the queue even when warnings are present.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Warn-only runtime metric report | high | low | medium | adopt | It exposes measurable UI debt without blocking the current queue. |
| B. Immediate failing gate | medium | high | medium | reject | The acceptance policy intentionally stages P0/P1 gates later. |
| C. Synthetic category tests | high | low | medium | adopt | They prove all warning categories even if current UI does not trigger them. |
| D. Screenshot-based visual scoring | medium | high | high | reject | The current collector is structural JSON, not image QA. |
| E. Persisted report artifacts | medium | medium | medium | reject | Output location and standard integration belong to `UI-METRIC-07`. |

## Adopted UX

- Evaluator returns a report dictionary with schema, scenario id, warning count, category counts, and warning rows.
- Every finding is severity `warn` in this task.
- Tests assert that all required categories can be reported.
- Runtime Workspace snapshots can be evaluated without making warnings fail the test.

## Deferred UX

- P0/P1 failure semantics remain in `UI-METRIC-05` and `UI-METRIC-06`.
- Persistent report files and standard metric output remain in `UI-METRIC-07`.

## Experience Steps

1. Build or load a layout snapshot.
2. Evaluate the snapshot.
3. Read warning categories and evidence.
4. Later gate tasks decide which warnings become failures.

## Existing UX Interference

The evaluator must not normalize current first-impression issues as acceptable. It names them as warnings and leaves severity escalation to queued gate tasks.
