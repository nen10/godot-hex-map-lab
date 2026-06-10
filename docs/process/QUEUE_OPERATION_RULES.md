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
| `RESOLUTED_RUNNING` | 現在作業中。分離されたタスクを持つ。 |
| `RESOLUTED_VERIFYING` | test / review 中。分離されたタスクを持つ。 |
| `RESOLUTED_REPAIR_NOW` | acceptance 未達。修正してから再検証する。分離されたタスクを持つ。 |
| `RESOLUTED` | 分離されたタスクを進行中 |
| `COMPLETE` | acceptance と proof を満たす。 |
| `COMPLETE_WITH_BACKLOG` | acceptance は満たし、非blocking follow-up がある。 |
| `BLOCKED_BY_TEST_ENV` | 環境不足で検証できない。 |
| `SPLIT_REQUIRED` | task が大きすぎるため分割が必要。 |
| `SUPERSEDED` | 他 task に吸収された。 |

## Completion proof

Task 完了処理:

### 1. Scheduled task の追加

Task 実行中に作成された `SUB_TASK.md` 内のすべての Scheduled task を追加する。
- 通常の task と同様に `IMPLEMENTATION_QUEUE_DESIGN_POLICY.md` 記載の table format に従う。
- Scheduled task の追加は、既存task の依存関係を妨害しない。
- Scheduled task に紐づく依存関係は、未実施の他 task / Phase との依存を評価して、1つまで追加することができる。
- `RESOLUTED`タスクはコミットする。
- 全ての sub task 完了時に、`COMPLETE` へ遷移する。

### 2. Proof log の記載

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

## Phase review matrix

Phase を閉じる、または queue pointer を次 phase へ進める前に、phase review matrix を作成する。

Template:

- `docs/review/roadmap/PHASE_REVIEW_MATRIX_TEMPLATE.md`

Recommended output path:

```text
docs/review/roadmap/<ROADMAP_ID>_<PHASE_ID>_PHASE_REVIEW_<date>.md
```

### Phase close condition

Phase review は次の条件を満たした時点で作成する。

1. 対象 phase の task に `READY`, `RUNNING`, `VERIFYING`, `REPAIR_NOW`, `RESOLUTED_RUNNING`, `RESOLUTED_VERIFYING`, `RESOLUTED_REPAIR_NOW`, `SPLIT_REQUIRED`, `BLOCKED_BY_TEST_ENV` が残っていない。
2. 対象 phase の `BACKLOG` task は、未完了 dependency を持つため待機しているか、phase review で次 action が明記されている。
3. `COMPLETE_WITH_BACKLOG` task は、backlog item の queue id、dynamic follow-up item、または ledger entry を持つ。

### Required matrix fields

Phase review matrix は task ごとに次を記録する。

| field | required meaning |
|---|---|
| task id | Queue task id. |
| status | Final status at phase review time. |
| score | `3`, `2`, `1`, or `0` according to the score scale. |
| evidence | Plan, self-review, test-result, proof log, or changed docs/code. |
| debt / follow-up | `none`, queue id, dynamic follow-up id, fallback ledger entry, explicit reject, or policy-deferred reason. |
| next readiness | `closed`, `ready-next`, `needs-follow-up`, `repair-now`, `blocked`, or `split-required`. |

Score scale:

| score | meaning |
|---|---|
| `3` | Acceptance is complete, tests/proof are linked, and no follow-up is required. |
| `2` | Acceptance is complete, but tracked nonblocking backlog or ledger work remains. |
| `1` | Completion is partial, blocked, or split; the phase cannot be treated as cleanly closed. |
| `0` | Acceptance is not met or evidence is missing. |

### Prose-only defer conversion

Phase review must inspect the phase's queue rows, `SUB_TASKS.md`, `UX.md`, `POLICY.md`, `IMPLEMENTATION_PLAN.md`, self-review docs, test-result docs, and proof log for deferred wording.

The following words are not accepted as final phase proof unless mapped in the deferred conversion table:

- deferred
- future
- later
- follow-up
- fallback
- mirror
- debug-only
- sample-only
- manual override
- legacy
- temporary

Each prose-only item must become one of:

1. Existing queue id.
2. New queue candidate in the Dynamic follow-up area.
3. Fallback ledger entry.
4. Explicit reject with reason.
5. Policy-deferred reason with owner and revisit condition.

If an item cannot be classified, the current task or phase is not complete. Mark the relevant task `REPAIR_NOW` or add a scheduled task before advancing the pointer.

## Dependency sweep

Task を閉じたら、queue 全体を一度確認する。

1. `COMPLETE` と `COMPLETE_WITH_BACKLOG` だけを完了 dependency とみなす。
2. `RESOLUTED` task の resolutions を確認する。
3. `BACKLOG` task の dependencies を確認する。
4. すべて満たされた task を `READY` にする。
5. dependencies を満たさない `READY` は `BACKLOG` に戻し、理由を記録する。
6. Phase を閉じる場合は、Phase review matrix が score / debt / evidence / next readiness を記録していることを確認する。
7. Current pointer を先頭の `READY` task に合わせる。

## Follow-up

`follow-up-ready` は Dynamic follow-up area に追加する。現 task の acceptance を満たしているなら、次 task へ進んでよい。
