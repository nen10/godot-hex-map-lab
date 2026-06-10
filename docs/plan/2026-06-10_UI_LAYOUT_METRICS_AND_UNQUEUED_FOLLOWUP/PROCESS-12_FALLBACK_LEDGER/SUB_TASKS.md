# PROCESS-12 Fallback Ledger Sub Tasks

## Complexity

Class: C4
Reason:
- This task creates a roadmap-level ledger for fallback, mirror, legacy, debug, sample, and manual override items.
- It must classify items that are intentionally retained, queued for removal, or policy-deferred.
- The output affects future phase reviews and UI metric acceptance, even though no product code changes in this slice.

Required artifacts:
- Task Resolution candidate matrix
- Scheduled Task Audit
- UX Candidate Matrix
- Fallback / Mirror Handling table
- State / Invariant Table
- Dependency / Test Matrix
- Standard test proof

## Task Resolution Candidate Matrix

| candidate | decision | reason |
|---|---|---|
| Create `docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md`. | Adopt | This is the required deliverable and gives phase review a concrete ledger target. |
| Include one row per known ledger-only feedback item. | Adopt | LG-01..LG-04 directly request ledger treatment. |
| Add rows for legacy numeric fallback/raw detail surfaces. | Adopt | Acceptance names legacy and debug; current policy forbids these in normal UI but allows debug/report contexts. |
| Add queue connections for items already scheduled. | Adopt | Ledger rows must not become a second source of truth when queue ids exist. |
| Change product code to remove the ledger entries now. | Reject | This task is process/review documentation; removal work belongs to scheduled implementation tasks. |
| Add new implementation tasks from this slice. | Reject | The current queue already has task ids for mirror, sample, debug, and metric gate work; no untracked implementation gap is found. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Private generation mirror retirement | `STATE-NEXT-11` | already queued | Ledger row should point to this implementation task. |
| Sample grouping and sample detail UX | `SETTINGS-NEXT-10`, `SAMPLE-NEXT-10` | already queued | Ledger row should point to both visible follow-up surfaces. |
| Debug overlay extraction | `ARCH-NEXT-22` | already queued | Ledger row should point to runtime debug rendering extraction. |
| Normal UI debug/sample/fallback metric enforcement | `UI-METRIC-02`, `UI-METRIC-05` | already queued | Detection and P0 gate work is covered later. |
| Product code removal during this process task | none | rejected | Out of scope for a ledger-only process task. |

## Scheduled Task

No scheduled task is added from this slice.
