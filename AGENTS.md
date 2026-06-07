# AGENTS.md

## Source of truth

Read the smallest relevant set.

- Policy index: `docs/policy/README.md`
- Process index: `docs/process/README.md`
- Tests: `docs/TEST.md`
- Godot notes: `docs/knowledge/DEV_GODOT.md`
- Autopilot skill: `.agents/skills/hex-map-codex-autopilot/SKILL.md`

## Project principles

- The addon is unpublished; compatibility is not a default requirement.
- Core functionality is stable. Most current work is about clean Resource/API and Editor UX presentation.
- UI/API design is based on game-development UX rationality, not headless-test convenience.
- Old UI tests may be deleted or rewritten when they preserve bad UX.
- No sample-only completion: sample preset success is not production feature completion. A UI path that only works with bundled samples is a `sample-only prototype` unless the active roadmap explicitly scopes the task to sample/package integrity.
- Feature completion requires arbitrary project asset selection or a visible unconfigured/validation state; samples are learning/onboarding assets, not silent defaults.
- Fallback, hack, legacy, migration wording, path text, raw JSON, and numeric fallback are not specification unless the active roadmap explicitly keeps them.
- During CLEAN UI work, do not create new analog tests unless the user asks.

## Which document to use

| Request | Use |
|---|---|
| Decide a roadmap from feedback / brainstorm | `docs/policy/ROADMAP_DECISION_POLICY.md` |
| Convert a roadmap to implementation queue | `docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md` |
| Write task-level UX / POLICY / IMPLEMENTATION_PLAN | `docs/policy/PLANNING_POLICY.md` |
| Implement a task | `docs/policy/IMPLEMENTATION_POLICY.md` |
| Design or update tests | `docs/policy/TEST_DESIGN_POLICY.md` |
| Execute an existing queue | `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md` |
| Update queue status | `docs/process/QUEUE_OPERATION_RULES.md` |
| Commit completed autopilot task | `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md` |

## Autopilot rule

For roadmap execution, do not stop after planning for approval. Select the next valid `READY` task, implement it, test it, self-review it, repair `repair-now` items, update the queue, and commit completed work.

Use `./tools/test.sh` for standard verification. If Godot is missing, record `BLOCKED_BY_TEST_ENV` rather than marking implementation complete.
