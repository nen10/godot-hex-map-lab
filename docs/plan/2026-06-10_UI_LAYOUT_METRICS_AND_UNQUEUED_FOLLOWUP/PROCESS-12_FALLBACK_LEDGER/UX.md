# PROCESS-12 UX

## User Goal

Codex should have a single place to check whether fallback, mirror, legacy, debug, sample, and manual override behavior is intentional, temporary, or queued for removal.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Leave these items in individual task prose | low | high | low | reject | Prose-only retention is the failure mode the feedback identifies. |
| B. Create a compact ledger table with owner/status/removal/test proof | high | low | low | adopt | It gives future reviews a scannable source of truth. |
| C. Treat every fallback-like item as a bug to remove immediately | medium | high | high | reject | Manual override and debug report details can be intentional explicit states. |
| D. Split each ledger row into a new queue task | medium | medium | medium | reject | Existing queue ids already cover implementation work; duplicate tasks would confuse dependency sweep. |

## Adopted UX

- Ledger rows are concise and decision-oriented.
- Each row states whether the item is retained, temporary, queued for removal, or policy-deferred.
- Each row has owner, status, removal condition, test proof, and queue connection.
- Manual override is allowed as explicit source state rather than hidden fallback.
- Sample learning is allowed only when it does not satisfy production asset selection.

## Deferred UX

- No user-facing UI changes are made in this slice.
- No automated ledger checker is added.

## Experience Steps

1. A future reviewer sees fallback-like language in a task or self-review.
2. The reviewer checks the fallback ledger.
3. If the item exists, the reviewer follows the queue connection or removal condition.
4. If the item does not exist, phase review must classify it before closing the phase.

## Existing UX Interference

The ledger should not weaken existing UI policy. Debug/raw details and sample learning stay out of normal production UI unless a row explicitly allows a bounded debug or learning surface.
