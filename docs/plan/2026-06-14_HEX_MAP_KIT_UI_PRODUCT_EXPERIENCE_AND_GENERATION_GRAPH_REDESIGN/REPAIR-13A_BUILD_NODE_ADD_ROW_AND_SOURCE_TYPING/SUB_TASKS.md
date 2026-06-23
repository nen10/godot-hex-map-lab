# REPAIR-13A Build Node Add Row and Source Typing Sub Tasks

日付: 2026-06-22
状態: documentation draft
依存: `REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT`

## Complexity

Class: C3

Reason:
- UI layout、node palette、Source typing、filter split の見え方が絡む。
- graph 操作の第一印象に直接影響する。
- 内部 schema を増やすか、typed Source として見せるかの判断が必要。

Required artifacts:
- `SUB_TASKS.md`
- `UX.md`
- `POLICY.md`
- `IMPLEMENTATION_PLAN.md`

## task境界

この task は、Build graph の node add UI を graph 下部に置き、node を layer generation role ごとに選べるようにする。

含む:

- node add row の位置。
- `Anchor / Build / Select` の分類。
- `Source Terrain` / `Source Overlay` の UI 表示。
- typed Source の inspector 表示。

含まない:

- Terrain Filter / Overlay Filter の runner 実装。これは `REPAIR-13`。
- Result multi-overlay の実体。これは `REPAIR-11`。
- edge deletion。これは `REPAIR-14`。

## task resolution candidate matrix

| candidate | decision | reason |
|---|---|---|
| A. 既存の左 palette を維持 | reject | graph の下で flow として読めない。 |
| B. node add row を graph 下部に置く | adopt | ユーザーが graph を見ながら次 node を選べる。 |
| C. Source button は1つだけ | reject for UI | Source が何を出すか分からない。 |
| D. `Source Terrain` / `Source Overlay` に分ける | adopt | filter split と接続意味が揃う。 |
| E. `Compose` を row に残す | reject for primary | Result との責務差が曖昧。 |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| graph-wide state evaluator | `REPAIR-13` | dependency | Source typing は evaluator の結果を表示する。 |
| Result multi-overlay slot | `REPAIR-11` | defer | Result row button は置くが、複数 overlay 実装は別。 |
| edge delete toolbar | `REPAIR-14` | defer | node add row と delete interaction を混ぜない。 |

## Scheduled task

| id | dependency | 概要 |
|---|---|---|
| `REPAIR-13A.1_ROW_LAYOUT` | `REPAIR-13` | node add row を graph 下部に置く。 |
| `REPAIR-13A.2_SOURCE_TYPING_UI` | `REPAIR-13A.1` | Source Terrain / Source Overlay を UI と node title に出す。 |
| `REPAIR-13A.3_ROW_SNAPSHOT_PROOF` | `REPAIR-13A.2` | layout と Source typing の snapshot proof を定義する。 |

## completion proof方針

- graph 下部に `Add Node` row がある。
- row は `Anchor / Build / Select` に分類される。
- `Source Terrain` / `Source Overlay` が選べる。
- Source node header / inspector に output type が見える。
- `Compose` は primary row に出ない。

