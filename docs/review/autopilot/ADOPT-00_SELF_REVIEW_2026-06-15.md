# ADOPT-00 Self Review

Task: `ADOPT-00_BASELINES_AND_ACCEPTANCE_GATE`
Queue: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ADOPT-00_BASELINES_AND_ACCEPTANCE_GATE/`
Date: 2026-06-15

## Execution Summary

改訂 Roadmap / baseline 2点を SoT として固定し、**二層 DoD（structural + experiential）acceptance gate** を process docs と self-review template に実装。QA/Validate park を process 規則化。コード（.gd）は非変更、docs/process のみ。

## Changed Files

| file | change |
|---|---|
| `docs/review/autopilot/SELF_REVIEW_TEMPLATE.md` | `Experiential DoD (UI/graph task)` セクション追加（What user sees first / can do / chain runs / label-heavy 不可） |
| `docs/process/QUEUE_OPERATION_RULES.md` | `Two-layer DoD gate` と `QA / Validate park` セクション追加 |
| `docs/policy/PLANNING_POLICY.md` | review checklist に experiential DoD / baseline 整合 / QA 非中心化の bullet 追加 |
| `docs/plan/.../ADOPT-00_.../{SUB_TASKS,UX,POLICY,IMPLEMENTATION_PLAN}.md` | plan proof（C2） |
| `docs/plan/.../IMPLEMENTATION_QUEUE.md` | ADOPT-00→COMPLETE、DESIGN-10/GRAPH-10→READY、pointer 更新 |
| `docs/plan/.../PROOF_LOG.md` | 新規・ADOPT-00 proof entry |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| none | as planned | — | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| self-review template に experiential 欄 | PASS | `SELF_REVIEW_TEMPLATE.md` の `Experiential DoD` セクション |
| park 区分が queue に存在 | PASS | queue `PARK-50` + operation notes + `QUEUE_OPERATION_RULES.md` QA park |
| 二層 DoD なしに UI/graph task を COMPLETE できない旨が明文化 | PASS | `QUEUE_OPERATION_RULES.md` Two-layer DoD gate |
| `./tools/test.sh` green | PASS | 全 `test_*.gd` all tests passed |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | not applicable | process/docs task（UI 非変更） |
| What user can do | not applicable | 同上 |
| (graph task) chain runs | not applicable | graph task ではない |
| Label-heavy but metrics pass | not applicable | UI なし |

理由: ADOPT-00 は process gate を定義する docs-only task であり、画面要素を持たない。

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | not applicable | UI 非変更 |
| P0 failures | not applicable | 同上 |
| P1 issues | not applicable | 同上 |
| UI metric applicability | non-UI task | docs/process のみの変更 |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| none | — | — |

## Repair-now Review

repair-now 無し。

## Test Review

- Command: `./tools/test.sh`
- Result: 全 `test_*.gd` が `all tests passed`（`set -euo pipefail` 下で最後の `test_debug_scenes.gd` まで完走）。
- Notes: 出力中の `push_warning`（overlay source 無し）は既存テストシナリオの想定内警告であり失敗ではない。本 task はコード非変更。
