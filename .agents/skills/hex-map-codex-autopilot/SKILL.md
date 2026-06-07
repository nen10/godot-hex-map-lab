---
name: hex-map-codex-autopilot
description: Continue a Hex Map Kit implementation queue without human approval gates. Use for roadmap queue execution, task repair, queue proof updates, and completion commits.
---

# Hex Map Kit Codex Autopilot Skill

## Read first

1. `AGENTS.md`
2. `docs/process/README.md`
3. Target `ROADMAP.md`
4. Target `IMPLEMENTATION_QUEUE.md`
5. `docs/policy/README.md`
6. `docs/TEST.md`

## Loop

1. Select the first valid `READY` task.
2. Mark it `RUNNING`.
3. Create or update `UX.md`, `POLICY.md`, and `IMPLEMENTATION_PLAN.md` for the task.
4. Implement without stopping for approval after planning.
5. Update code, tests, and docs.
6. Run `./tools/test.sh`.
7. Fix all `repair-now` issues before moving on.
8. Write self-review and test result under `docs/review/autopilot/`.
9. Update queue proof and dependency status.
10. Commit completed tasks following `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`.
11. If complete and context remains, proceed to the next READY task; otherwise leave the queue ready for the next invocation.


## Decision reminders

- Roadmap UX is already validated.
- UX/API rationality beats compatibility and old headless UI tests.
- Do not preserve path text, raw JSON, numeric fallback, migration wording, or legacy schema unless the roadmap explicitly requires it.
- Do not create new analog tests during CLEAN UI work unless the user asks.

## Stop only for

- Missing test environment.
- External credentials or public release upload.
- Destructive action outside the repo.
- Direct contradiction with the active roadmap or user instruction.
