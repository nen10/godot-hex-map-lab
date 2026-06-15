# ADOPT-00 IMPLEMENTATION_PLAN（pre-execution）

## Scope
改訂 Roadmap / baseline を SoT 化し、二層 DoD acceptance gate と QA park を process docs・self-review template に実装する。

## 変更対象ファイル
- `docs/review/autopilot/SELF_REVIEW_TEMPLATE.md`（experiential DoD セクション追加）
- `docs/process/QUEUE_OPERATION_RULES.md`（two-layer DoD gate + QA park 規則追加）
- `docs/policy/PLANNING_POLICY.md`（review checklist に experiential DoD / baseline 整合追加）
- `docs/plan/2026-06-14_.../IMPLEMENTATION_QUEUE.md`（status / pointer 更新）

## Planned steps
1. self-review template に「Experiential DoD」表を追加。
2. queue rules に two-layer DoD gate / QA park を追加。
3. planning policy の review checklist に bullet 追加。
4. queue: ADOPT-00 → COMPLETE、DESIGN-10 / GRAPH-10 → READY、pointer 更新。
5. PROOF_LOG.md と self-review を作成。

## Test path
- `./tools/test.sh`（docs-only 変更だが回帰が無いことを確認）。

## Planned completion criteria
- self-review template に experiential 欄が存在。
- queue rules に two-layer DoD gate と QA park が明文化。
- queue に park 区分が存在し、UI/graph task が二層 DoD なしに COMPLETE できない旨が参照可能。
- `./tools/test.sh` green。
