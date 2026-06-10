# PERF-NEXT-11 Policy

## Scope

PERF-NEXT-11 adds validation traversal progress. It may update validator options, workflow state snapshots, and Generate progress integration. It must not alter validation rules or issue routing.

## Requirements

- Validator progress is monotonic and reports phase, step, total steps, progress ratio, and document counts.
- Validate workflow state exposes progress state in both state and view snapshots.
- Generate validation forwards validator progress into the existing Generate run state.
- Tests cover adapter callback behavior and editor-facing progress contracts.

## Fallback / Defer Ledger

| item | disposition | rationale |
|---|---|---|
| Per-cell progress events | defer | Phase-level traversal is enough to avoid silent long operations without creating callback overhead. |
| Async validation worker | defer | This task is progress visibility, not validation threading. |
| New modal progress UI | reject | Existing inline progress controls are the intended busy surface. |

## Test Policy

- Add Core/Adapter tests for validator progress callback and summary state.
- Extend editor tests for Validate state and Generate validation progress.
- Run `./tools/test.sh`.
