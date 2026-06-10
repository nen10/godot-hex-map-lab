# PROCESS-12 Implementation Plan

## Scope

- Create `docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md`.
- Populate rows for fallback, mirror, legacy, debug, sample, and manual override categories.
- Link rows to existing queue ids, owner, status, removal condition, and test proof.
- Run standard verification and write proof docs.
- Update queue status, dependency sweep, proof log, and current pointer.

## Target Files

- `docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-12_FALLBACK_LEDGER/`
- `docs/review/autopilot/PROCESS-12_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/PROCESS-12_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `PROCESS-12` RUNNING and create plan docs.
- [x] Create fallback ledger.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `PROCESS-12` COMPLETE, promote `PROCESS-13` to READY, update proof, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Feedback LG-01..LG-04 | Ledger misses a requested category. | Ledger includes manual override, sample learning, debug/raw detail, and mirror fields. |
| Current queue ids | Ledger creates duplicate future tasks. | Rows point to existing queue ids where applicable. |
| Future phase review | Ledger rows lack removal/test proof. | Ledger schema requires owner/status/removal/test proof. |
| Standard repo verification | Docs-only change still needs baseline proof. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Fallback entries have owner/status/removal/test proof.
- [x] Mirror entries have owner/status/removal/test proof.
- [x] Legacy entries have owner/status/removal/test proof.
- [x] Debug entries have owner/status/removal/test proof.
- [x] Sample entries have owner/status/removal/test proof.
- [x] Manual override entries have owner/status/removal/test proof.
