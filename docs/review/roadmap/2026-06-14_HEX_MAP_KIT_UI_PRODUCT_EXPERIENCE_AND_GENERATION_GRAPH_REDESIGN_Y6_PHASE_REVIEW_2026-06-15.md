# Phase Review Matrix

Roadmap: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ROADMAP.md`  
Phase: `Y6 process guard / metric downgrade`  
Date: 2026-06-15  
Reviewer: Codex autopilot  
Queue: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Phase Close Condition

| check | result | evidence |
|---|---|---|
| No phase task remains `READY`, `RUNNING`, `VERIFYING`, or `REPAIR_NOW`. | PASS | `PROCESS-60` is marked `COMPLETE` in queue. |
| No phase task remains `SPLIT_REQUIRED` or `BLOCKED_BY_TEST_ENV` without an explicit next action. | PASS | No Y6 task has either status. |
| `COMPLETE_WITH_BACKLOG` tasks name a queue id, dynamic follow-up item, or ledger entry. | PASS | No Y6 task uses `COMPLETE_WITH_BACKLOG`. |
| Dependency sweep result is recorded. | PASS | `DOC-70` is promoted to `READY`; `PROC-90` remains `BACKLOG` until `DOC-70_WORKFLOW_MANUAL` completes. |

## Task Matrix

| task id | status | score | evidence | debt / follow-up | next readiness |
|---|---|---:|---|---|---|
| `PROCESS-60_METRIC_AS_REGRESSION_ONLY` | `COMPLETE` | 3 | plan docs, self-review, `PROOF_LOG.md`, `./tools/test.sh` run `20260615-192722-74644` | none | closed |

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
| PROCESS-60 policy | fallback metric acceptance | Explicit reject | Metric pass is not product UX proof. | none |
| PROCESS-60 policy | mirror acceptance path | Explicit reject | Queue two-layer DoD is the source of truth. | none |
| metric implementation names | gate wording | Policy-deferred reason | Existing schema/test filenames may keep historical `gate` names; policy meaning is regression check. Revisit only if a future cleanup task renames metric artifacts. | process |

## Evidence Links

- Queue: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`
- Proof log: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/PROOF_LOG.md`
- Plan docs:
  - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/PROCESS-60_METRIC_AS_REGRESSION_ONLY/`
- Self-review docs:
  - `docs/review/autopilot/PROCESS-60_METRIC_AS_REGRESSION_ONLY_SELF_REVIEW_2026-06-15.md`
- Test-result docs:
  - `.godot_user/ui-metrics/20260615-192722-74644/workspace_layout_metrics.md`
- Test command: `TEST_JOBS=4 ./tools/test.sh`

## Next Readiness

| next action | result | reason |
|---|---|---|
| Continue to next READY task | yes | `DOC-70_WORKFLOW_MANUAL` deps `GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN` and `SCREEN-31_PAINT_AS_DESIGN_WORKSPACE` are complete. |
| Add dynamic follow-up | not needed | No Y6 debt found. |
| Mark repair-now | not needed | Acceptance is complete. |
| Split task | not needed | PROCESS-60 fit its planned scope. |
| Block on environment | not needed | `./tools/test.sh` passed. |
