# REPAIR-11 Result Multi Overlay Contract Sub Tasks

日付: 2026-06-23
状態: READY — Codex implementation-ready
依存: `REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY`

## Complexity

Class: C4

Reason:
- `Result` の graph 契約、runtime output、document projection、viewport preview が同時に変わる。
- 複数 overlay の順序、衝突、Apply/Revert、test proof が絡む。
- 既存 `overlay_map` 単数フィールドとの mirror / fallback を扱う必要がある。
- `Compose` と `Result` の責務分離を明示しないと、Codex が安全側に寄せて単一 overlay 実装で止まりやすい。

Required artifacts:
- `SUB_TASKS.md`
- `UX.md`
- `POLICY.md`
- `IMPLEMENTATION_PLAN.md`
- `CODEX_HANDOFF.md`

## task境界

この task は、`Result` node の契約を `1 terrain + up to 3 explicit overlays` に固定し、Generate 結果が viewport/document に全 overlay を別 layer として出ることを証明する。

含む:

- `Result` の input contract。
- `terrain` required + `overlay_0`, `overlay_1`, `overlay_2` optional ports。
- 複数 overlay input の runtime resource 表現。
- overlay 合成順序と item/cell conflict warning metadata。
- viewport projection / Apply / Revert で terrain と overlay を同時に扱う実装。
- `Compose` を primary proof から外す判断。
- active tests の更新。

含まない:

- node add row の UI 移動。これは `REPAIR-13A`。
- Terrain Filter / Overlay Filter 分離。これは `REPAIR-13`。
- 中間出力 child node 化。これは `REPAIR-12`。
- arbitrary dynamic overlay slot add/remove UI。
- old asset migration for arbitrary saved user graphs。

## task resolution candidate matrix

| candidate | decision | reason |
|---|---|---|
| A. Result は terrain 1本だけを扱う | reject | overlay 生成結果が viewport / document に出ない混乱を残す。 |
| B. Result は `terrain + one overlay` だけ扱う | reject | 複数 Item Generator と Source Overlay を同時に扱えない。 |
| C. Result は `terrain + overlay_inputs[]` を扱う | adopt conceptually | graph の終端として、表示可能な bundle を明示できる。 |
| C-1. `overlay_inputs[]` を dynamic slot UI で実装 | defer | GraphEdit slot add/remove、serialization migration、inspector design が別 task 相当。 |
| C-2. `overlay_inputs[]` を `overlay_0..overlay_2` 固定 slot で実装 | adopt for REPAIR-11 | Codex に実装させる粒度として deterministic で、multi-overlay contract を十分に証明できる。 |
| D. Result は `result` input も受ける | reject | Result の入れ子化で終端責務が曖昧になる。 |
| E. Compose が result を作り、Result がそれを受ける | reject | `Compose` と `Result` の説明が分裂する。 |
| F. Result 内で overlays を1枚に merge して document に出す | reject | layer inspection / Apply/Revert proof ができない。 |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| node add row の分類 | `REPAIR-13A` | defer | UI配置は Result contract 確定後に反映する。 |
| dynamic overlay slot UI | none yet | defer | `overlay_0..2` が通った後に必要なら新規 queue 化する。 |
| intermediate output child node | `REPAIR-12` | defer | Result の final projection と中間 output は ownership が異なる。 |
| filter split | `REPAIR-13` | defer | overlay input の意味は filter split と連動するが、この task は Result 終端に限定する。 |
| Markov / adjacency parity | `REPAIR-15` | defer | overlay 生成方法の parity は Result contract の後。 |
| edge deletion interaction | `REPAIR-14` | defer | multi-overlay connections may make this more visible, but deletion gesture is a separate UI task. |

## Scheduled implementation slices

| id | dependency | 概要 | done when |
|---|---|---|---|
| `REPAIR-11.1_RESULT_PORT_CONTRACT` | `REPAIR-11` | Result schema を `terrain + overlay_0..2` に変更し、duplicate input edge を validation error にする。 | graph validation tests pass for required terrain, duplicate port, Result->Result rejection |
| `REPAIR-11.2_RESULT_RESOURCE_MULTI_OVERLAY` | `REPAIR-11.1` | `_run_result` と `HexGenerationResultResource` を multi-overlay 化する。 | runtime test proves 2 overlays in port order and legacy `overlay_map` mirror |
| `REPAIR-11.3_OVERLAY_ORDER_AND_CONFLICTS` | `REPAIR-11.2` | conflict metadata と deterministic order を入れる。 | reversed edge insertion and same item/cell conflict tests pass |
| `REPAIR-11.4_BUILD_SCREEN_PROJECTION` | `REPAIR-11.2` | Build screen Result preview が terrain + all overlays を document に promote する。 | two generated overlay layers appear with deterministic ids |
| `REPAIR-11.5_UI_SNAPSHOT_AND_CANVAS_PROOF` | `REPAIR-11.4` | canvas slots / selected snapshot に overlay summary を出す。 | canvas and build snapshot tests pass |
| `REPAIR-11.6_APPLY_REVERT_AND_QUEUE_PROOF` | `REPAIR-11.4` | Apply/Revert test と queue proof を更新する。 | `./tools/test.sh` passes and queue/proof row is accurate |

## Acceptance checklist for Codex

- [ ] `HexGenerationNodeTypes.NODE_RESULT` has no old `"overlay"` input.
- [ ] `HexGenerationNodeTypes.NODE_RESULT` has `terrain`, `overlay_0`, `overlay_1`, `overlay_2`.
- [ ] `terrain` is required.
- [ ] `overlay_0..2` are optional.
- [ ] No Result input accepts `HexGenerationPorts.RESULT`.
- [ ] `HexGenerationGraph.validate()` reports `duplicate_input_edge` for same target port duplicates.
- [ ] `HexGenerationResultResource` exports `overlay_maps` and keeps `overlay_map`.
- [ ] `_run_result()` fills `overlay_maps` in numeric port order.
- [ ] `_run_result()` fills `metadata.overlay_inputs`, `metadata.overlay_count`, `metadata.overlay_conflicts`.
- [ ] `HexGenerationPromote` can preserve existing generated overlays when Build screen is promoting a multi-overlay Result.
- [ ] Build screen Result projection creates separate generated overlay layers, not one merged layer.
- [ ] `_last_promote_result` or debug snapshot exposes overlay count and layer ids.
- [ ] Apply/Revert covers generated overlay layers.
- [ ] Tests prove the above.

## completion proof方針

Proof must be source + test evidence, not visual assertion only:

- Result graph validation:
  - missing terrain invalid
  - duplicate `overlay_0` invalid
  - `Result -> Result` invalid
- Runtime:
  - terrain + 2 overlay graph yields `overlay_maps.size() == 2`
  - order is `overlay_0`, then `overlay_1` even when edges are inserted in reverse order
  - first overlay mirrors into `overlay_map`
- Document / viewport:
  - Build screen preview creates one generated terrain layer and two generated overlay layers
  - projection success uses REPAIR-10 viewport proof rules
  - Apply/Revert returns document state to pre-preview state
- UI/canvas:
  - Result node exposes/connects `overlay_0` and `overlay_1`
  - Result selected snapshot/status exposes overlay count or input summary

## completion proofとして拒否するもの

| rejected proof | reason |
|---|---|
| cache has two overlay-producing nodes | does not prove Result includes them |
| one merged generated overlay layer | violates separate layer contract |
| thumbnail or node preview only | does not prove viewport/document projection |
| tests that use only bundled samples | sample-only success is not production proof |
| a passing graph without Apply/Revert proof | reversible preview is part of REPAIR-10 contract and must remain intact |
