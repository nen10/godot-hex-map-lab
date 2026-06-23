# REPAIR-11 Result Multi Overlay Contract Sub Tasks

日付: 2026-06-22
状態: documentation draft
依存: `REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY`

## Complexity

Class: C4

Reason:
- `Result` の graph 契約、runtime output、document projection、viewport preview が同時に変わる。
- 複数 overlay の順序、衝突、Apply/Revert、test proof が絡む。
- `Compose` と `Result` の責務分離を再定義する必要がある。

Required artifacts:
- `SUB_TASKS.md`
- `UX.md`
- `POLICY.md`
- `IMPLEMENTATION_PLAN.md`

## task境界

この task は、`Result` node の契約を `1 terrain + N overlay` に固定する。

含む:

- `Result` の input contract。
- 複数 overlay input の保持方法。
- overlay 合成順序と衝突警告。
- viewport projection / Apply / Revert で terrain と overlay を同時に扱う契約。
- `Compose` を primary flow から外す判断。

含まない:

- node add row の UI 移動。これは `REPAIR-13A`。
- Terrain Filter / Overlay Filter 分離。これは `REPAIR-13`。
- 中間出力 child node 化。これは `REPAIR-12`。

## task resolution candidate matrix

| candidate | decision | reason |
|---|---|---|
| A. Result は terrain 1本だけを扱う | reject | overlay 生成結果が viewport / document に出ない混乱を残す。 |
| B. Result は `terrain + one overlay` だけ扱う | reject | 複数 Item Generator と Source Overlay を同時に扱えない。 |
| C. Result は `terrain + overlay_inputs[]` を扱う | adopt | graph の終端として、表示可能な bundle を明示できる。 |
| D. Result は `result` input も受ける | reject | Result の入れ子化で終端責務が曖昧になる。 |
| E. Compose が result を作り、Result がそれを受ける | reject | `Compose` と `Result` の説明が分裂する。 |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| node add row の分類 | `REPAIR-13A` | defer | UI配置は Result contract 確定後に反映する。 |
| intermediate output child node | `REPAIR-12` | defer | Result の final projection と中間 output は ownership が異なる。 |
| filter split | `REPAIR-13` | defer | overlay input の意味は filter split と連動するが、この task は Result 終端に限定する。 |
| Markov / adjacency parity | `REPAIR-15` | defer | overlay 生成方法の parity は Result contract の後。 |

## Scheduled task

| id | dependency | 概要 |
|---|---|---|
| `REPAIR-11.1_RESULT_PORT_CONTRACT` | `REPAIR-11` | Result input / output schema を確定する。 |
| `REPAIR-11.2_OVERLAY_ORDER_AND_CONFLICTS` | `REPAIR-11.1` | overlay order と item key conflict warning を設計する。 |
| `REPAIR-11.3_PROJECTION_AND_PROOF` | `REPAIR-11.2` | viewport / document projection proof を定義する。 |

## completion proof方針

- Result が `terrain` 1本と `overlay_inputs[]` を保持する。
- 複数 overlay が document に別 layer として残る。
- Apply/Revert が terrain と全 overlay を対象にする。
- `Result -> Result` が invalid になる。
- thumbnail-only proof は拒否する。

