# REPAIR-14 Graph Canvas Edge Delete Sub Tasks

日付: 2026-06-22
状態: documentation draft
依存: `REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY`

## Complexity

Class: C3

Reason:
- graph canvas の selection state、edge hit testing、keyboard / toolbar action、dirty propagation が絡む。
- 失敗するとユーザーは graph を修正できず、node を消すしかなくなる。
- 操作が見えないと「できるが発見できない」状態になる。

Required artifacts:
- `SUB_TASKS.md`
- `UX.md`
- `POLICY.md`
- `IMPLEMENTATION_PLAN.md`

## task境界

この task は、edge deletion を明示的で発見可能な操作として設計する。

含む:

- edge selection state。
- delete action の gesture。
- edge delete toolbar / shortcut。
- edge delete 後の graph dirty / validation 更新。

含まない:

- node add row の配置。これは `REPAIR-13A`。
- graph-wide state evaluator の全体実装。これは `REPAIR-13`。
- connection type redesign。これは `REPAIR-13` と `REPAIR-11`。

## task resolution candidate matrix

| candidate | decision | reason |
|---|---|---|
| A. context menu だけで delete | reject | 壊れた時に発見不能で、証明も弱い。 |
| B. edge click selection + Delete key | adopt | editor 操作として自然。 |
| C. selected edge toolbar button | adopt | shortcut を知らなくても削除できる。 |
| D. node delete 時に関連 edge だけ削除 | keep as secondary | node削除の副作用であり、edge deleteの代替ではない。 |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| full canvas layout redesign | `REPAIR-13A` | defer | deletion interactionとは別。 |
| invalid edge visual redesign | `REPAIR-13` | defer | edge delete後に状態更新はするが、全体validation設計は別。 |
| multi-overlay slot UI | `REPAIR-11` | defer | Result slot edge の意味は別 task。 |

## Scheduled task

| id | dependency | 概要 |
|---|---|---|
| `REPAIR-14.1_EDGE_SELECTION` | `REPAIR-14` | edge を選択可能にする。 |
| `REPAIR-14.2_DELETE_ACTIONS` | `REPAIR-14.1` | Delete key と toolbar button を設計する。 |
| `REPAIR-14.3_DIRTY_AND_PROOF` | `REPAIR-14.2` | edge delete 後の dirty / validation / snapshot proof を定義する。 |

## completion proof方針

- edge を選択できる。
- selected edge が視覚的に区別される。
- Delete key または toolbar button で削除できる。
- edge delete 後に downstream node が dirty になる。
- edge deletion は node deletion と混同されない。

