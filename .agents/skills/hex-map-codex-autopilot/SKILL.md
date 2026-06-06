---
name: hex-map-codex-autopilot
description: Continue Hex Map Kit roadmap implementation from the Autopilot queue. Use when asked to proceed with roadmap implementation, implement the next plan file, repair missing items, or automate Codex task orchestration without human approval gates.
---

# Hex Map Kit Codex Autopilot Skill

## Source of truth

Read these before acting:

1. `AGENTS.md`
2. `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
3. `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`
4. `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`
5. `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`
6. `docs/policy/*.md`
7. `docs/TEST.md`

## Prime directive

The roadmap UX is already validated. Do not stop after planning for human approval. Convert the next READY queue item into plan files if needed, implement it, test it, self-review it, repair missing acceptance, update the queue, and leave the next READY task clear.

## Loop

1. Select the first `READY` task whose dependencies are complete.
2. Mark it `RUNNING` in `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`.
3. Create or update the task plan directory:
   - `UX.md`
   - `POLICY.md`
   - `IMPLEMENTATION_PLAN.md`
4. Implement the plan in the same run.
5. Add or update tests and `docs/TEST.md`.
6. Run `./tools/test.sh`.
7. If tests fail, classify failures and repair `repair-now` issues before moving on.
8. Write self-review under `docs/review/autopilot/`.
9. Update queue status and proof.
10. If status is `COMPLETE` or `COMPLETE_WITH_BACKLOG`, create one product completion commit following `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`.
11. If the status is `BLOCKED_BY_TEST_ENV`, `SPLIT_REQUIRED`, or `SUPERSEDED`, create a docs-only state commit when it improves resumability.
12. If complete and context remains, proceed to the next READY task; otherwise leave the queue ready for the next invocation.

## Decision policy

- Prefer typed resource schema and migration over extending untyped `Array` payloads.
- Prefer catalog keys and adapter boundaries over exposing raw `source_id / atlas_coords` in normal UX.
- Preserve saved `.tres` compatibility unless the queue explicitly says otherwise.
- Fallback and hack behavior are never specification.
- UI wording, helper naming, test fixture structure, and internal implementation order are Codex decisions.
- Human approval is only required for external credentials, public release upload, destructive actions outside the repo, or direct contradiction inside the validated roadmap.

## Failure handling

- `repair-now`: fix immediately in the same task.
- `follow-up-ready`: append a follow-up task to the dynamic queue.
- `known-env-failure`: document exact missing environment and mark `BLOCKED_BY_TEST_ENV`.
- `accepted-risk`: document reason and解除条件; do not hide it.
- `manual-optional`: add analog test candidate; do not block automation.

## Commit policy

- One `COMPLETE` / `COMPLETE_WITH_BACKLOG` queue task maps to one product completion commit.
- Do not create product completion commits for `RUNNING`, `VERIFYING`, or `REPAIR_NOW` work.
- Allowed docs-only state commits: `BLOCKED_BY_TEST_ENV`, `SPLIT_REQUIRED`, `SUPERSEDED`.
- Use commit messages shaped like `autopilot(<TASK_ID>): <summary>` or `autopilot-state(<TASK_ID>): <summary>`.

## Completion proof

A task is complete only when:

- queue acceptance is satisfied,
- tests or environment-blocking result are documented,
- `docs/TEST.md` is updated when tests changed,
- self-review exists,
- `repair-now` is empty,
- queue proof is updated.
