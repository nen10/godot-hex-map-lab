# Process / Policy Reorganization 2026-06-07

## Purpose

開発フロー資料の責務を整理し、policy / process / plan / review / manual の境界を明確にした。

今回の整理では、詳細すぎる運用文書を短縮し、Roadmap 決定と Implementation Queue 作成の方針を Autopilot 実行 process から分離した。

## New responsibility model

| kind | role | location |
|---|---|---|
| Policy | 判断基準。何を良い設計とみなすか。 | `docs/policy/` |
| Process | 実行手順。queue をどう動かすか。 | `docs/process/` |
| Plan | 個別 roadmap / task の成果物。 | `docs/plan/` |
| Review | 実行後の評価、根拠、不足整理。 | `docs/review/` |
| Manual | ユーザー向けの使い方。 | `docs/manual/` |
| Analog test | ユーザー指示がある場合の操作観察手順。 | `tests/analog_test/` |

## Added files

- `docs/policy/README.md`
- `docs/process/README.md`
- `docs/policy/ROADMAP_DECISION_POLICY.md`
- `docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md`

## Rewritten files

- `AGENTS.md`
- `.agents/skills/hex-map-codex-autopilot/SKILL.md`
- `docs/policy/DOMAIN_POLICY.md`
- `docs/policy/PLANNING_POLICY.md`
- `docs/policy/IMPLEMENTATION_POLICY.md`
- `docs/policy/TEST_DESIGN_POLICY.md`
- `docs/policy/ANALOG_TEST_POLICY.md`
- `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
- `docs/process/QUEUE_OPERATION_RULES.md`
- `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`

## Main changes

### Policy layer

- `DOMAIN_POLICY.md` is now the top-level design boundary document.
- `ROADMAP_DECISION_POLICY.md` decides roadmap from feedback and approved brainstorm items.
- `IMPLEMENTATION_QUEUE_DESIGN_POLICY.md` converts a roadmap into a queue.
- `PLANNING_POLICY.md` is limited to task-level `UX.md` / `POLICY.md` / `IMPLEMENTATION_PLAN.md`.
- `IMPLEMENTATION_POLICY.md` is limited to implementation judgement.
- `TEST_DESIGN_POLICY.md` is limited to automated test design.
- `ANALOG_TEST_POLICY.md` is kept short and explicitly deferred during CLEAN UI work.

### Process layer

- `CODEX_AUTOPILOT_ORCHESTRATION.md` now only describes the execution loop.
- `QUEUE_OPERATION_RULES.md` now only describes status, proof, and dependency sweep.
- `CODEX_AUTOPILOT_COMMIT_POLICY.md` now only describes commit timing and message shape.

### Skill

`SKILL.md` now points to the indexes and target roadmap/queue instead of duplicating policy details.

## Intended usage

1. User gives feedback or approved brainstorm.
2. Use `ROADMAP_DECISION_POLICY.md` to write `ROADMAP.md`.
3. Use `IMPLEMENTATION_QUEUE_DESIGN_POLICY.md` to write `IMPLEMENTATION_QUEUE.md`.
4. Use `CODEX_AUTOPILOT_ORCHESTRATION.md` to execute the queue.
5. Use `QUEUE_OPERATION_RULES.md` and `CODEX_AUTOPILOT_COMMIT_POLICY.md` only during execution.

## Non-goals

- Existing historical `docs/plan/` files were not rewritten.
- Existing completed task documents were not migrated.
- Code behavior was not changed.
- New analog tests were not created.
