# UI-METRIC-00 Implementation Plan

## Scope

- Create `docs/ui/WORKSPACE_UI_CONTRACT.md`.
- Define global Workspace rules.
- Define per-tab purpose, required components, forbidden visible text, metric thresholds, primary actions, and state source.
- Define Resource row, button/action, debug/report, and sample learning contracts.
- Run standard verification and write proof docs.
- Update queue status, dependency sweep, proof log, and current pointer.

## Target Files

- `docs/ui/WORKSPACE_UI_CONTRACT.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-00_WORKSPACE_UI_CONTRACT/`
- `docs/review/autopilot/UI-METRIC-00_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/UI-METRIC-00_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Steps

- Mark `UI-METRIC-00` RUNNING and create plan docs.
- Create `WORKSPACE_UI_CONTRACT.md`.
- Run `./tools/test.sh`.
- Write self-review and test-result docs.
- Mark `UI-METRIC-00` COMPLETE, promote dependency-satisfied tasks, update proof, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Existing UI-00 contract docs | New contract misses known screen/resource/debug rules. | Consolidate old Workspace screen, resource row, debug label, and inventory docs. |
| Component registry | Required component ids drift from current registry. | Use `HexMapWorkspaceComponentRegistry` component ids in contract. |
| UI-METRIC-01 | State-specific content leaks into UI contract. | Contract references state matrix as a later source of truth. |
| UI-METRIC-02..06 | Thresholds are too vague for automation. | Contract gives named thresholds and baseline values. |
| Standard repo verification | Docs-only change still needs baseline proof. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- Every Workspace tab has purpose, required components, forbidden visible text, and metric thresholds.
- Resource row contract is defined.
- Button/action contract is defined.
- Debug/report contract is defined.
- Sample learning/production separation contract is defined.
