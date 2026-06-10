# Codex Autopilot Orchestration

## Purpose

作成済み `IMPLEMENTATION_QUEUE.md` を、Codex が人間承認待ちで止めずに実装するための手順を定める。

Roadmap 作成は `docs/policy/ROADMAP_DECISION_POLICY.md`、queue 作成は `docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md` に従う。

## Inputs

- `docs/plan/<YYYY-MM-DD>_<ROADMAP_ID>/ROADMAP.md`
- `docs/plan/<YYYY-MM-DD>_<ROADMAP_ID>/IMPLEMENTATION_QUEUE.md`
- `docs/policy/`
- `docs/TEST.md`

## Autopilot loop

1. Queue から先頭の `READY` task を選ぶ。
2. task を `RUNNING` にする。
3. `docs/policy/PLANNING_POLICY.md`に従い、実装計画を作成する。`ROADMAP.md` 内の該当 taskも参照する。`IMPLEMENTATION_PLAN.md` は pre-execution planning proof として扱う。
4. plan 後に承認待ちで止まらず、同じ run で実装する。
5. code / tests / docs を更新する。cf.`docs/policy/IMPLEMENTATION_POLICY.md`
6. `./tools/test.sh` を実行する。
7. 失敗や不足を分類し、`repair-now` は同じ task で修正する。
8. task 実行中に作成した Scheduled task を `IMPLEMENTATION_QUEUE.md` に追加する。
9.  `docs/review/autopilot/SELF_REVIEW_TEMPLATE.md` に沿って `docs/review/autopilot/<TASK_ID>_SELF_REVIEW_<date>.md` を作り、実行summary、変更ファイル、plan deviation、repair-now、sample-only success を completion proof にしていないことを確認する。UI-facing task は `./tools/test.sh` の UI metric report path と P0 failures = 0 を self-review に記録する。
10. `QUEUE_OPERATION_RULES.md` に従って queue を更新する。
11. 完了状態なら `CODEX_AUTOPILOT_COMMIT_POLICY.md` に従って commit する。
12. 次の `READY` task へ進む。

## Failure classes

| class | handling |
|---|---|
| `repair-now` | acceptance 未達。次 task に進まず修正する。 |
| `follow-up-ready` | 現 task は完了できるが、後続 task にする。 |
| `known-env-failure` | Godot など環境不足。`BLOCKED_BY_TEST_ENV` にする。 |
| `accepted-risk` | 理由と解除条件を self-review に残す。 |
| `manual-optional` | 自動 loop を止めない。CLEAN UI 再編中は analog test を作らず deferred として残す。 |

## Stop conditions

Codex が止まってよいのは以下だけ。

- Godot 実行環境など completion proof に必要な環境がない。
- 外部 credential、公開 upload、署名など repo 外の操作が必要。
- repo 外の破壊的操作が必要。
- Roadmap とユーザー指針が直接矛盾し、合理的な解釈で進められない。

## Clean UX rule

CLEAN / UX-first roadmap では、旧互換、path text、raw JSON、numeric fallback、古い headless UI test を守るために UX を歪めない。sample preset success だけで成立する UI は `sample-only prototype` であり、production feature completion ではない。必要なら test を更新または削除する。

## UI Metric Completion Rule

UI-facing task は標準テストで生成される UI metric report を self-review に参照し、P0 failures が `0` であることを completion proof に含める。P1 issue count は現時点では report-only として記録する。ただし active roadmap が P1 gating を有効化した場合は、その roadmap の条件に従う。
