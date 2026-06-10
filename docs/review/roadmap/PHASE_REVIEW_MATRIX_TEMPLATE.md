# Phase Review Matrix Template

Roadmap:
Phase:
Date:
Reviewer:
Queue:

## Phase Close Condition

| check | result | evidence |
|---|---|---|
| No phase task remains `READY`, `RUNNING`, `VERIFYING`, or `REPAIR_NOW`. |  |  |
| No phase task remains `SPLIT_REQUIRED` or `BLOCKED_BY_TEST_ENV` without an explicit next action. |  |  |
| `COMPLETE_WITH_BACKLOG` tasks name a queue id, dynamic follow-up item, or ledger entry. |  |  |
| Dependency sweep result is recorded. |  |  |

## Task Matrix

| task id | status | score | evidence | debt / follow-up | next readiness |
|---|---|---:|---|---|---|
|  |  |  |  |  |  |

Score scale:

| score | meaning |
|---|---|
| `3` | Acceptance is complete, tests/proof are linked, and no follow-up is required. |
| `2` | Acceptance is complete, but tracked nonblocking backlog or ledger work remains. |
| `1` | Completion is partial, blocked, or split; the phase cannot be treated as cleanly closed. |
| `0` | Acceptance is not met or evidence is missing. |

## Deferred / Prose-only Conversion

| source | phrase / item | classification | queue id / ledger entry / reject reason / revisit condition | owner |
|---|---|---|---|---|
|  |  |  |  |  |

Allowed classifications:

- Existing queue id
- New dynamic follow-up
- Fallback ledger entry
- Explicit reject
- Policy-deferred

## Evidence Links

- Queue:
- Proof log:
- Plan docs:
- Self-review docs:
- Test-result docs:
- Test command:

## Next Readiness

| next action | result | reason |
|---|---|---|
| Continue to next READY task |  |  |
| Add dynamic follow-up |  |  |
| Mark repair-now |  |  |
| Split task |  |  |
| Block on environment |  |  |

## Required Action

State the single queue operation that follows this review.
