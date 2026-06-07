# Process Index

Process は実行手順であり、判断基準ではない。

Roadmap の決定や queue 設計は `docs/policy/` に置く。ここでは、作成済み queue をどう実行し、どう status 更新し、どう commit するかを扱う。

## Files

| file | 責務 |
|---|---|
| `CODEX_AUTOPILOT_ORCHESTRATION.md` | implementation queue を連続実行する手順。 |
| `QUEUE_OPERATION_RULES.md` | queue status、proof、dependency sweep の規則。 |
| `CODEX_AUTOPILOT_COMMIT_POLICY.md` | task 完了時の commit 手順。 |

## Flow

```text
ROADMAP.md
  -> IMPLEMENTATION_QUEUE.md
    -> Autopilot loop
      -> queue update
        -> completion commit
          -> next READY task
```
