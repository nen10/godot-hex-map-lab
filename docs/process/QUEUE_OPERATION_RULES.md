# Queue Operation Rules

## Purpose

`IMPLEMENTATION_QUEUE.md` による作業管理規則を status、proof、dependency sweep として定める。

Queue の作成方針は `docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md`、実行 loop は `CODEX_AUTOPILOT_ORCHESTRATION.md` に従う。

## Status

| status | meaning |
|---|---|
| `BACKLOG` | 依存未完了。まだ選ばない。 |
| `READY` | 依存が満たされた。次に実装してよい。 |
| `RUNNING` | 現在作業中。 |
| `VERIFYING` | test / review 中。 |
| `REPAIR_NOW` | acceptance 未達。修正してから再検証する。 |
| `COMPLETE` | acceptance と proof を満たす。 |
| `COMPLETE_WITH_BACKLOG` | acceptance は満たし、非blocking follow-up がある。 |
| `BLOCKED_BY_TEST_ENV` | 環境不足で検証できない。 |
| `SPLIT_REQUIRED` | task が大きすぎるため分割が必要。 |
| `SUPERSEDED` | 他 task に吸収された。 |

## Completion proof

Task 完了時は queue または proof log に以下を残す。

```text
proof:
  plan: docs/plan/<roadmap>/<TASK_ID>_<slug>/
  review: docs/review/autopilot/<TASK_ID>_SELF_REVIEW_<date>.md
  tests:
    - ./tools/test.sh
  docs:
    - docs/TEST.md if changed
  major files:
    - ...
```

## Dependency sweep

Task を閉じたら、queue 全体を一度確認する。

1. `COMPLETE` と `COMPLETE_WITH_BACKLOG` だけを完了 dependency とみなす。
2. `BACKLOG` task の dependencies を確認する。
3. すべて満たされた task を `READY` にする。
4. dependencies を満たさない `READY` は `BACKLOG` に戻し、理由を記録する。
5. Current pointer を先頭の `READY` task に合わせる。

## Follow-up

`follow-up-ready` は Dynamic follow-up area に追加する。現 task の acceptance を満たしているなら、次 task へ進んでよい。
