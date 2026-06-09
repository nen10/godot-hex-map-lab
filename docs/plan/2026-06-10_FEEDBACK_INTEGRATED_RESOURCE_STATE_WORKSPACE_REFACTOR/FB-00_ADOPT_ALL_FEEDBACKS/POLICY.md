# FB-00 Policy

## Adopted Decisions

- `ROADMAP.md` is the source of truth for the feedback-integrated refactor.
- `IMPLEMENTATION_QUEUE.md` is the executable queue for this roadmap.
- The source feedback priority order is binding for later implementation decisions.
- Resource ownership work precedes broad UI redesign, except for explicit early safety repairs.
- `dist` freshness is a final process concern handled by `PROC-90`, not a per-task test gate.
- No new analog tests are added during this CLEAN UI refactor unless the user explicitly asks.

## Rejected Decisions

- Do not continue the older roadmap queue when this roadmap has an active READY task.
- Do not treat `FB-00` as an opportunity to implement FileDialog or no-op control changes; those have separate acceptance.
- Do not use sample-only success as proof that the feedback-integrated roadmap is complete.
- Do not add committed `dist` freshness checks to `./tools/test.sh`.

## Breaking Change Rationale

This task does not introduce runtime breaking changes. It does make the new roadmap authoritative, which can supersede older UI-shape expectations and old test convenience decisions in later tasks. The addon is unpublished, and the active policy allows replacing bad UX contracts.

## Resource / API / UI Boundary

- Resource/API decisions are established at roadmap level and implemented in later Resource tasks.
- UI state and first-impression decisions are established at roadmap level and implemented in later State/UI/Screen tasks.
- Process proof lives in the queue, self-review, and test result files.

## Task-Local Decisions

- `FB-00` only records adoption and execution readiness.
- Dependency successors should be promoted after completion if their only dependency is `FB-00`.
- The next current pointer should be the first valid READY task after dependency sweep.
