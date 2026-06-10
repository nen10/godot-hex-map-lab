# PROCESS-11 Implementation Plan

## Scope

- Add phase review matrix rules to `docs/process/QUEUE_OPERATION_RULES.md`.
- Add `docs/review/roadmap/PHASE_REVIEW_MATRIX_TEMPLATE.md`.
- Run standard verification and write proof docs.
- Update the queue status, dependency sweep, proof log, and current pointer.

## Target Files

- `docs/process/QUEUE_OPERATION_RULES.md`
- `docs/review/roadmap/PHASE_REVIEW_MATRIX_TEMPLATE.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-11_PHASE_REVIEW_MATRIX/`
- `docs/review/autopilot/PROCESS-11_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/PROCESS-11_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `PROCESS-11` RUNNING and create plan docs.
- [x] Update `QUEUE_OPERATION_RULES.md` with phase review matrix rules.
- [x] Add the phase review matrix template.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `PROCESS-11` COMPLETE, promote `PROCESS-12` to READY, update proof, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Queue operation process | Phase close rules conflict with task-level proof. | `QUEUE_OPERATION_RULES.md` keeps task proof and phase proof separate. |
| Future phase reviews | Review authors omit debt conversion. | Template requires deferred/prose-only conversion table. |
| Dependency sweep | Pointer moves before phase review records readiness. | Queue rules place phase review before or during phase-close dependency sweep. |
| Standard repo verification | Docs-only change still needs baseline proof. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Phase completion records task score.
- [x] Phase completion records debt classification.
- [x] Phase completion records evidence links.
- [x] Phase completion records next readiness.
- [x] Prose-only defer conversion is required.
