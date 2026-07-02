# Old Generate 実行方式依存関係の Build graph 適用 — 確定判断と model 設計

日付: 2026-07-02
状態: decision record（ユーザー判断確定済み。REPAIR-19/20 は同日実装済み、REPAIR-21/22/23 は queue 化）
関連:
- `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-15_MARKOV_ADJACENCY_MAPPING/OLD_GENERATE_MIGRATION_AUDIT_MATRIX.md`（一次資料。本記録で status 更新）
- `docs/design/GENERATION_GRAPH_MODEL.md`（設計原則1: headless / UI 非依存 pass）

## 0. 目的

旧 Generate タブ（`hex_map_gen_dock.gd`）が持っていた「実行方式依存関係」——方式選択が他の option の可視性・排他・実行可否を決める規則群——を、UI コードへの再結合なしに Build graph パラダイムへ適用する。単純移植ではなく、graph-native な語彙（method enum / typed port / semantic gate）への昇格を伴う。

## 1. 旧タブの実行方式依存関係の分類と graph での対応原則

| 旧タブでの形 | 例 | graph での対応原則 |
|---|---|---|
| mode 結合（UI 可視性/排他） | symmetric ⇔ radius+markov+toric、adjacency XOR item_limit | node の method enum + method 別 param schema（排他は enum で構造化） |
| データ依存 | overlay 生成は primary/document に依存、mask query は既存層に依存 | typed port + edge（REPAIR-13A/16 で確立済み） |
| 実行ゲート | 空 mask / 空 rules → Generate 無効 + 理由 tooltip | node 単位の semantic validate + block reason 表示（REPAIR-22） |
| 実行 state machine | preparing→generating→validating→applying | Build async run + progress relay（REPAIR-10 で確立済み） |

構造的 debt: 現在 method 別 param 依存規則は inspector のハードコード分岐（`_param_keys_for_type` / `_param_visibility_for_type` / `_param_control_type` / `_param_options` / `_param_default`）に散在しており、旧 `hex_map_gen_state_evaluator.gd` と同型の「UI に方式依存が結合する」debt を再生産している。→ REPAIR-21 で generation 層の宣言的 schema へ中央化する。

## 2. ユーザー確定判断（2026-07-02）

| # | audit matrix gap | 判断 | 帰結 |
|---|---|---|---|
| 1 | #8 protected_floor | **UI 移行しない（drop）**。保護領域は filter 用中間レイヤーの合成で表現すれば足りる | engine の `params.protected_floor` 読み取り（Wall Field / Connectivity）は headless 用に現状維持。inspector UI / port は作らない |
| 2 | #10 toric 貫通 / #2 symmetric shape | **toric は Connectivity 側で管理**。shape 決定時に指定が要るのは実装事情で、本質的には connectivity でしか使わない | Shape node から `toric` param を撤去し、Connectivity node の `toric_passage` param に移設（REPAIR-20 実装済み）。symmetric 専用 option は作らない（square + Wall Field markov の合成で表現） |
| 3 | #16 mask+crop / #17 deductor floor | **drop（明示記録）** | Terrain/Overlay Filter + Set Operation で自力構成できるものとし、専用 node / preset 化はしない。復活させる場合は本記録を起点に再設計 |
| 4 | #14 adjacency 方向トグル semantics | **multiset のまま確定（closed）** | 方向トグルは連結成分サイズ multiset の入力手段（REPAIR-17 決定どおり）。core の方向一致拡張はしない |

追加確定（推奨採用）:

- **#4 seed lab: park**。score/比較は QA 系 UX であり、QA park 方針（中心化・波及禁止）に従い移行しない。batch N + seed randomize は現状維持。
- **#18 source registry / overlay source stack: superseded**。typed `Source` nodes + edge 合成が上位互換であり、stack/registry UX は復活させない。

## 3. toric ownership の設計（REPAIR-20、実装済み）

- 旧実挙動: `generate_symmetric_square(..., connect_toric, ...)` の `connect_toric` は `HexMapData.square(size, connect_toric)` の cyclic_size 設定のみを制御し、効果は connectivity 復元の境界 wrap（と下流の wrap 演算）に現れる。
- 新配置:
  - `Shape` node: `toric` param 撤去。出力は常に flat topology（cyclic_size=0）。
  - `Connectivity` node: `toric_passage: bool`（default false）。true の時、入力 cell 集合が **完全な size×size square の場合のみ** cyclic_size=size を設定してから復元を実行（core が toric に width==height を要求する契約に一致）。square でない集合には wrap を適用しない（cyclic_size 0 のまま）。false は入力 topology を変更しない（toric な Source 入力を破壊しない）。
- legacy fallback は作らない（addon 未公開・互換性は default 要件でない）。既存 preset / canvas default / test fixture の `"toric": false` 残骸は撤去済み。

## 4. method 別 item フィールド（REPAIR-19、実装済み）

- `Item Generator` の item pool 行は placement_method 依存で意味が変わる:
  - `weighted`: `weight`（0..1, step 0.05）
  - `limited`: `count`ラベル → **`limit`**（int 0..999。core `_normalize_limit_item_pool` が読む key は `limit`。`limit<=0` の entry は core が除外）
- 値は正直に描画する（未設定の limit は 0 を表示。1 と偽装しない）。method 切替時に行を再描画し、他方の key は保持する（設定を失わない）。
- `adjacency_rules` は item_pool を使わないため pool editor を隠し、代わりに `item_name`（生成される item key、default "item"）を露出。従来 adjacency 出力の item key が常に "item" 固定だった欠落を解消。
- placement_method の排他（weighted XOR limited XOR adjacency）は旧タブの checkbox 排他の enum 昇格として維持。

## 5. 残 gap の routing（queue 反映）

| gap | routing | 内容 |
|---|---|---|
| inspector の方式依存分岐の散在 | `REPAIR-21_NODE_PARAM_SCHEMA_CENTRALIZATION` | method 別 param schema（keys/visibility/control/options/range/default）を generation 層の宣言的 registry へ移し、inspector は schema render に徹する。headless で schema をテスト可能にする |
| semantic 実行ゲートの不在 | `REPAIR-22_SEMANTIC_RUN_GATE` | 旧 `generation_block_reason`（空 mask/空 rules → Generate 無効+理由）の graph 版。node 単位 `validate_semantics(node)` → node badge + Generate button tooltip |
| #15 adjacency 走査 parity / #7 markov custom parity | `REPAIR-23_ADJACENCY_SCAN_PARITY_REAUDIT` | 走査戦略は perf branch（border-start / center-arc seeds, 2026-06-28〜29）で再設計済みのため、findings #2 の「対称走査版へ接続」はもう前提が古い。新戦略の bias/parity を監査し matrix を refresh |

## 6. 実装証跡（2026-07-02）

- engine: `hex_generation_node_types.gd` — `_run_shape` から toric 撤去、`_run_connectivity` に `toric_passage` + `_toric_passage_cyclic_size`（square 完全一致チェック）。
- editor: `hex_map_build_node_inspector.gd` — param schema 変更（shape −toric / connectivity +toric_passage / item_generator +item_name・pool 可視性）、item pool 行の method 依存描画、placement_method 変更時の行再描画、item_pool control の可視性 refresh 修正。
- cleanup: `hex_generation_preset.gd` / `hex_map_build_graph_canvas.gd` / `test_generation_graph_resource.gd` の `"toric": false` 撤去。
- tests: `test_generation_graph.gd` に toric ownership 契約（square wrap / flat / 非square 拒否）と limited 正確数配置、`test_editor_generation.gd` に method 依存 item フィールドと toric ownership の inspector 検証を追加。
