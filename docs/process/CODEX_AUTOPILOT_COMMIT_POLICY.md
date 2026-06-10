# Codex Autopilot Commit Policy

## Purpose

Autopilot task の完了境界を Git commit として残すための手順を定める。

## Rule

原則は以下。

```text
1 COMPLETE queue task = 1 product completion commit
```

Commit は作業途中の保存ではなく、task completion proof である。

## Commit allowed

| status | commit |
|---|---|
| `RESOLUTED` | product completion commit |
| `COMPLETE` | product completion commit |
| `COMPLETE_WITH_BACKLOG` | product completion commit |
| `BLOCKED_BY_TEST_ENV` | docs-only state commit |
| `SPLIT_REQUIRED` | docs-only state commit |
| `SUPERSEDED` | docs-only state commit |

Commit しない状態:

- `RUNNING`
- `VERIFYING`
- `REPAIR_NOW`
- `RESOLUTED_RUNNING`
- `RESOLUTED_VERIFYING`
- `RESOLUTED_REPAIR_NOW`
- `BACKLOG`
- `READY`

## Before commit

- task 実行中に作成した Scheduled task が `IMPLEMENTATION_QUEUE.md` に追加済み。
- queue status が commit 可能状態である。
- self-review がある。
- test result または environment-blocking result がある。
- `repair-now` が残っていない。
- queue proof が更新されている。
- unrelated dirty files を含めない。

## Product commit message

```text
autopilot(<TASK_ID>): <summary>

Status: COMPLETE | COMPLETE_WITH_BACKLOG
Queue: docs/plan/<roadmap>/IMPLEMENTATION_QUEUE.md
Plan: docs/plan/<roadmap>/<TASK_ID>_<slug>/
Review: docs/review/autopilot/<TASK_ID>_SELF_REVIEW_<date>.md
Tests:
- ./tools/test.sh
```

## State commit message

```text
autopilot-state(<TASK_ID>): <summary>

Status: BLOCKED_BY_TEST_ENV | SPLIT_REQUIRED | SUPERSEDED
Reason: <short reason>
Docs:
- <state report>
```

## Rollback

History rewrite ではなく revert commit を使う。rollback も queue / review に記録する。
