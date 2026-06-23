# REPAIR-12 Intermediate Output Child Nodes Sub Tasks

日付: 2026-06-22
状態: documentation draft
依存: `REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY`

## Complexity

Class: C4

Reason:
- graph run cache、editor scene ownership、viewport inspection、Apply/Revert の境界が絡む。
- 中間 output を見せる価値と、main target layer を壊さない制約を両立する必要がある。
- run replace lifecycle を設計しないと、古い中間 node が残る。

Required artifacts:
- `SUB_TASKS.md`
- `UX.md`
- `POLICY.md`
- `IMPLEMENTATION_PLAN.md`

## task境界

この task は、中間生成 output を main target layer の document data に混ぜず、inspectable な child node として扱う設計を作る。

含む:

- intermediate terrain / overlay output の scene node ownership。
- run ごとの replace / cleanup lifecycle。
- selected intermediate output の viewport inspection。
- Apply/Revert との境界。

含まない:

- `Result` multi-overlay final projection。これは `REPAIR-11`。
- graph-wide dirty state の全体設計。これは `REPAIR-13`。
- edge deletion interaction。これは `REPAIR-14`。

## task resolution candidate matrix

| candidate | decision | reason |
|---|---|---|
| A. 中間 output を target layer document に直接混ぜる | reject | main data が汚れ、Revert / Apply の境界が壊れる。 |
| B. 中間 output は cache のみで UI には出さない | reject | graph の学習・debug・inspect 価値が落ちる。 |
| C. 中間 output ごとに managed child node を作る | adopt | target layer を守りつつ、viewport で inspect できる。 |
| D. 毎 run で child node を追加し続ける | reject | scene tree が増殖し、どれが最新か分からない。 |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Result final projection | `REPAIR-11` | defer | final output と intermediate output は ownership が異なる。 |
| graph-wide state evaluator | `REPAIR-13` | defer | child lifecycle は evaluator の利用者であり、全体所有者ではない。 |
| node add row | `REPAIR-13A` | defer | inspection node の表示位置とは別。 |

## Scheduled task

| id | dependency | 概要 |
|---|---|---|
| `REPAIR-12.1_CHILD_NODE_OWNERSHIP` | `REPAIR-12` | 中間 output child の命名・owner・parent を決める。 |
| `REPAIR-12.2_RUN_REPLACE_LIFECYCLE` | `REPAIR-12.1` | run ごとの replace / cleanup / stale 表示を決める。 |
| `REPAIR-12.3_INTERMEDIATE_INSPECTION_PROOF` | `REPAIR-12.2` | target layer 汚染なしに inspect できる証明を定義する。 |

## completion proof方針

- Generate 後、intermediate output は managed child node として作られる。
- 同じ graph revision の再 Generate で古い child は置換される。
- main target layer の document は Result / Apply まで汚れない。
- user は中間 output を viewport で inspect できる。

