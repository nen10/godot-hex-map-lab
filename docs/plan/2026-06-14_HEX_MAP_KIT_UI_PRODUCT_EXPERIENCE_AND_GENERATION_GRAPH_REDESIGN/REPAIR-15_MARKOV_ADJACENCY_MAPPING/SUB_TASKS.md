# REPAIR-15 Markov Adjacency Mapping Sub Tasks

日付: 2026-06-22
状態: documentation draft
依存: `REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT`

## Complexity

Class: C4

Reason:
- 旧 Generate の mode/state evaluator と Build graph node の対応を監査する必要がある。
- Markov Mesh / wall generation / overlay adjacency / item generation が混ざって見える。
- 既存 core static を再利用しつつ、node params と runner key の対応を証明する必要がある。

Required artifacts:
- `SUB_TASKS.md`
- `UX.md`
- `POLICY.md`
- `IMPLEMENTATION_PLAN.md`

## task境界

この task は、旧 Generate にあった Markov / adjacency 系の意図を Build graph の node / params / runner に対応付ける。

含む:

- Markov Mesh / Wall Field の対応。
- overlay adjacency / adjacency rule の対応。
- Item Generator の adjacency mode の対応。
- 旧 Generate state evaluator から移植すべき制約の洗い出し。
- param propagation audit との接続。

含まない:

- graph-wide state evaluator 全体の実装。これは `REPAIR-13`。
- node add row UI。これは `REPAIR-13A`。
- Result multi-overlay。これは `REPAIR-11`。

## task resolution candidate matrix

| candidate | decision | reason |
|---|---|---|
| A. 旧 Generate の UI state をそのまま graph に移植 | reject | dynamic graph と相性が悪く、不要な mode coupling が残る。 |
| B. Markov / adjacency を現 node に隠したままにする | reject | どの param がどこへ効くか分からない。 |
| C. 旧意図を parity matrix 化し、node params に対応付ける | adopt | 実装前に欠落と誤対応を見つけられる。 |
| D. 新 engine を作る | reject | roadmap 原則に反する。既存 core static を再利用する。 |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| terrain/overlay filter split | `REPAIR-13` | dependency | adjacency filter の input 型に影響する。 |
| Source typing UI | `REPAIR-13A` | defer | Source の見せ方は別 queue。 |
| Result overlay projection | `REPAIR-11` | defer | adjacency で作った overlay を最終投影する契約は別。 |

## Scheduled task

| id | dependency | 概要 |
|---|---|---|
| `REPAIR-15.1_OLD_GENERATE_PARITY_MATRIX` | `REPAIR-15` | 旧 Generate state / mode / params を列挙する。 |
| `REPAIR-15.2_NODE_PARAM_MAPPING` | `REPAIR-15.1` | Wall Field / Item Generator / Filter への対応を決める。 |
| `REPAIR-15.3_ADJACENCY_PROOF_PLAN` | `REPAIR-15.2` | 期待される生成差分と test proof を定義する。 |

## completion proof方針

- Markov / adjacency の旧 UI 設定が、どの node param へ移るか説明できる。
- runner が読む key と UI が書く key が一致する。
- adjacency rule の変更が生成結果に差を出す。
- sample-only success ではなく、任意 graph params で proof する。

