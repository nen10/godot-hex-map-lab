# Planning Policy

## Purpose

Queue task ごとに計画文書を作成し、実装判断の方針を定める。
SUB_TASKS ->UX -> POLICY -> IMPLEMENTATION_PLAN の順に実施し、後段で決定できない判断事項は前段にescalationして基準を具体化する。
実装中に判断しきれない事象は、SUB_TASKS.md を追加編集して責務分割することが可能。

Roadmap 決定は `ROADMAP_DECISION_POLICY.md`、queue 作成は `IMPLEMENTATION_QUEUE_DESIGN_POLICY.md` に従う。

## Plan directory

```text
docs/plan/<YYYY-MM-DD>_<ROADMAP_ID>/<TASK_ID>_<slug>/
  SUB_TASKS.md
  UX.md
  POLICY.md
  IMPLEMENTATION_PLAN.md
```

大きい task のみ `TEST_PLAN.md` を追加してよい。

## 0. SUB_TASKS.md

目標の完結と価値最大化に向けて task resolution を行う

### planning for sub-tasks

task resolution : [
  task 候補 : { 目標/UX, 採否, 概要 },
  ...
]

- 今回task の 目標が定める範囲が実装上曖昧な場合、目標に該当する新規の小目標を数多く提案し、採否の判断を任意の数だけ記載する。
- 今回task の 目標が発散的な場合、目標に該当する新規 UX を数多く提案し、採否の判断を任意の数だけ記載する。
- 今回task の 目標が大きく、小目標,UX 自体が複数の実装フローから構成される必要がある場合、実装計画候補を必要なだけ提案・検討し、採否の判断を任意の数だけ記載する。
- 今回task が 設計判断の場合、目標を実現する設計と複数のtaskから構成される採否の判断を任意の数だけ記載する。
- 今回task が 計画を作成することを目標にする場合、本質的な価値を実現する新規の目標を数多く提案し、採否の判断を任意の数だけ記載する。

### plan scheduling

Scheduled task : {
  `id` : <今回task id>.<%dd> ,
  `dependency` : ...,
  概要 : ...
}

- 採用した複数の新規小目標, 新規 UX, 実装計画候補 については、実装上の依存関係を評価し Scheduled task として記載する。
- 設計を行うための状況調査、調査実験用test作成等、task完了がプロダクトの本質的な価値を伴う段階に至らない目標の場合 "<今回task run の成果物> をもとに計画を作成する task" を Scheduled task として記載する。依存関係は 今回task自身 に紐付ける。
- 今回task が目標の本質的な価値を実現するに及ばない場合 "<今回task run の成果物> をもとに計画を作成する task" を Scheduled task として記載する。依存関係は 今回task自身 に紐付ける。
- 今回task の実装中に高度な設計判断が必要になり、良いところで task を分解する場合、現在目標を実現する設計計画の必要性を Scheduled task として記載して task 分離できる。

### add sub-tasks rules

- `SUB_TASKS.md` 内の Scheduled task は 今回task 完了処理時に `IMPLEMENTATION_QUEUE.md` に割り込みで追加する。
  - 記載の format は通常の task と同様とし、詳細は `docs/process/QUEUE_OPERATION_RULES.md` に従う。

## 1. UX.md

目標を operation steps として具体化するため、複数の UX を提案し、各候補を評価する。
implementation queue の task packet は最小限の説明であり、目標の具体化のため `ROADMAP.md` の該当 task を参照して検討する。

以下を含む:

- user goal。
- operation steps。
- { 採用, 維持 }する UX。
- { 廃止, 保留 }する UX。
- hack 扱いとして廃止または backlog残置する UX
- 既存 UX との干渉。

## 2. POLICY.md

目標を実現するため、採用UXを基準に必要な設計を判断する。

以下を含む:

- 採用判断。
- 不採用判断。
- 破壊的変更の理由。
- legacy 扱いとして廃止または backlog残置する設計
- Resource / API / UI の境界。
- 未確定だが task 内で決めてよい事項。

## 3. IMPLEMENTATION_PLAN.md

目標を実現するため、採用設計を基準に実装を計画する。

以下を含む:

- Scope。
- 変更対象ファイル。
- 実装 steps。
- fallback 扱いとして廃止または backlog残置する step
- Test path。
- docs 更新。
- completion checklist。

## Review before implementation

`UX.md`, `POLICY.md`, `IMPLEMENTATION_PLAN.md` を確認する:

- Roadmap と矛盾しないか。
- task の完了状態が test または review で確認できるか。
- 旧互換や旧 UI を理由なく守っていないか。
- 未決事項を`SUB_TASKS.md`に移して責務分割できているか。

`SUB_TASKS.md` が存在する場合確認する:

- task 分割が進捗の確実さに貢献しているか。
- 目標価値を最大化する提案・採否判断ができているか。
