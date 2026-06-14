# STATE-NEXT-10 Root Reducer / Event Model Sub Tasks

## Complexity

Class: C4
Reason:
- The task changes event dispatch semantics, test contracts, and queue proof evidence for an existing UI-facing execution path.
- Acceptance requires architectural cleanup (typed event model) plus behavioral proof updates across implementation and tests.
- It affects reducer-like state transitions, dispatch outputs, side-effect signaling, and UI proof expectations.

Required artifacts:
- Task Resolution Candidate Matrix
- Scheduled Task Audit
- UX Candidate Matrix
- Fallback / Mirror Handling table
- State / Invariant Table
- Dependency / Test Matrix

## Task Resolution Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Replace string `match` dispatch with typed event enum + descriptor registry | high | medium | low | adopt | Makes event handling explicit, discoverable, and safe.
| Replace `result` payload with structured reducer/side-effect/ui-update keys | high | low | low | adopt | Separates concerns and improves traceability.
| Keep legacy `result` key indefinitely | low | high | low | reject | It preserves coupling and hides the new contract.
| Return plain workspace action dictionary without dispatch metadata | medium | high | medium | reject | Fails acceptance requirement for typed separation.
| Skip null/unknown typed failure tests | high | medium | low | reject | Safety regression against brittle callers.

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| optional `EXECUTION_LOG.md` | none | adopt if needed | This task is bounded and traceable in self-review.
| `result` alias in dispatch result | none | rejected | `reducer_result`, `side_effects`, and `ui_state_update` are explicit.

## Scheduled Task

No scheduled task is added from this slice.
