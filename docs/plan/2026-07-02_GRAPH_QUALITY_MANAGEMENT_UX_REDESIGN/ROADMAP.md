# Roadmap — Graph 品質管理 UX 再設計（GQM track）

日付: 2026-07-03
状態: **確定**（DESIGN_DIALOGUE round 1-3 / RESOURCE_MODEL / DEPENDENCY_UX_PROPOSALS round 1-4 の全ユーザー確定を実行順序に変換）
関連: `DESIGN_DIALOGUE.md` / `RESOURCE_MODEL.md` / `DEPENDENCY_UX_PROPOSALS.md`（一次設計）

## 1. 目的

「編集した指標に基づいた Map 生成」＝品質管理の完全上位互換を、graph editor 上で実体化する。中心は (1) **統合 4 ノード + 無型 edge + adaptation** による依存のトポロジ表現、(2) **criteria 資産の二層管理と reference 化**、(3) **構造的 UX 欠陥（header junk・暗黙知要求）の一掃**。

## 2. 採用する方針（確定済み）

- 統合 4 ノード: **Terrain Generation / Item Generation / Set Operation / Result**（Shape・Source・Filter 2 種・Compose は node 概念として廃止）
- **無型 edge**（全 port type 0・一色）。意味は消費側 input の **adaptation（全域関数）** が一元所有。UI に型を二重符号化しない
- 唯一の構造制約 = **循環の構成不能化**（connection_request + `_is_node_hover_valid`）
- **default 常時有効**（gate UI なし）+ **連動 default**（Item Generation 定義域 = 出力 terrain の floor、素材台紙 = 出力 terrain 連動 option）
- criteria 資産の**二層**（bundled read-only / project `res://hex_map/<kind>/`、setting `hex_map_kit/asset_root`）と **inline / reference / embed** の三態明示
- Generate **一本化**・基本形 template・batch/seed/shape randomize 撤去・Load Graph 等は資産 operation へ
- Result = substrate 自動判別（最初の terrain・以降「未使用」明示）+ overlay 接続順 + promote
- 生成結果 resource は**出力 data 込み**保存・リスト・即時切替（thumbnail なし）

## 3. 廃止・保留する方針

- 廃止: gate/block UI、batch 比較 UI、thumbnail 並置、lane 帯 UI（設定同居の洞察のみ継承）、由来 chip（説明系 UI）、Node palette、UI 層の port 型制約
- 保留（最後尾・実需要待ち）: V1 dirty 検証 / V3・V4 / V7（=REPAIR-23）/ 失敗・空出力可視化 / レイヤー跨ぎ統計

## 4. Phase 構成

| phase | 内容 | 成果物 / 成功状態 |
|---|---|---|
| **G1: engine（headless）** | 統合ノード run 層・adaptation 全域関数・legacy 正規化・循環 helper／資産二層 service・新 resource／統合ノード対象の schema 中央化 | 基本形 7 node graph が legacy 等価出力（同一 seed）。adaptation matrix・正規化・round-trip の headless test green |
| **G2: canvas / node UI** | 無型 canvas + adaptation 行／ノード内 cascade（schema 描画）+ criteria chip + morph／Result stack + promote | editor 上で基本形が構築・実行・promote でき、型制約なしで接続でき、循環だけ拒否される。実描画キャプチャ |
| **G3: 導線と資産 UX** | header 一掃 + template + Generate 一本化／legacy graph 読込正規化／生成結果 save/switch | Build 上部が Generate/Apply/Revert/Template のみ。基本形 template 1 操作。結果の名前付き保存と即時切替 |
| **G4: 完全性** | runtime 同一性（reference 資産解決込み）／V8 window DoD | runtime Map Build が統合 graph + reference 資産で editor と同一 seed 同一結果 |

## 5. 最初に queue 化する範囲

`GQM-01`（統合ノード engine）と `GQM-02`（資産二層 service）は独立・並行可能。次いで `GQM-03`（schema）。詳細は `IMPLEMENTATION_QUEUE.md`。

## 6. 委譲方針

明確・自明に分解済みの headless task（G1 群）は Codex 系ワーカーへ委譲し、`tools/verify_task.py` + `./tools/test.sh` + 人手 spot-check で gate する（AGENT_ROSTER_AND_ROUTING 準拠）。UI（G2 以降）は experiential DoD / 実描画キャプチャを伴うため、設計者側で密に検証する。
