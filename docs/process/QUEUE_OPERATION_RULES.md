# QUEUE_OPERATION_RULES.md

Orchestration: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
Commit policy: `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`

queue は validate 済みロードマップを Codex が連続実装するための task 分割である。Plan 作成は承認ゲートではない。各 task は、必要な plan files を作ったら同じ Autopilot run で実装・テスト・self-review・queue 更新まで進める。

---

## status

- `READY`: 依存が満たされた。Codex が次に実装してよい。
- `BACKLOG`: 依存未完了。
- `RUNNING`: 現在の Autopilot run 対象。
- `REPAIR_NOW`: acceptance 未達。次 task へ進まず修正する。
- `BLOCKED_BY_TEST_ENV`: Godot / CI など環境不足で completion proof を作れない。
- `COMPLETE`: acceptance と test proof を満たす。
- `COMPLETE_WITH_BACKLOG`: acceptance は満たし、非blocking follow-up を queue へ追加済み。
- `SUPERSEDED`: 他 task に吸収済み。

## required proof

各 task の完了時、該当行の `proof` に以下を書く。

```text
proof:
  plan: docs/plan/<date>_<TASK_ID>_<slug>/
  review: docs/review/autopilot/<TASK_ID>_SELF_REVIEW_<date>.md
  tests:
    - ./tools/test.sh
  docs:
    - docs/TEST.md
  major files:
    - ...
```

## dependency rule

`dependencies` がすべて `COMPLETE` または `COMPLETE_WITH_BACKLOG` になったら、Codex は `BACKLOG` を `READY` に更新してよい。

