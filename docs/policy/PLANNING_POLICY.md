# Planning Policy

## Purpose

Queue task ごとに計画文書を作成し、実装判断の方針を定める。
UX -> POLICY -> IMPLEMENTATION_PLAN の順に実施し、後段で決定できない判断事項は前段にescalationして基準を具体化する。

Roadmap 決定は `ROADMAP_DECISION_POLICY.md`、queue 作成は `IMPLEMENTATION_QUEUE_DESIGN_POLICY.md` に従う。

## Plan directory

```text
docs/plan/<YYYY-MM-DD>_<ROADMAP_ID>/<TASK_ID>_<slug>/
  UX.md
  POLICY.md
  IMPLEMENTATION_PLAN.md
```

大きい task のみ `TEST_PLAN.md` を追加してよい。

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

含まないこと:

- 実装詳細。
- test の都合で UI を決める説明。
- fallback / hack / legacy を仕様として扱う記述。

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

実装前に確認する。

- Roadmap と矛盾しないか。
- task の完了状態が test または review で確認できるか。
- 旧互換や旧 UI を理由なく守っていないか。
- 実装途中で人間承認待ちになる未決事項を残していないか。
