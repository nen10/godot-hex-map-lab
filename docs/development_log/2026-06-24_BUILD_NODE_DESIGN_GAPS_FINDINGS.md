# Build Node Design Gaps — verified findings

日付: 2026-06-24
状態: investigation record (code-verified)
目的: ユーザー指摘の Build graph node 問題を、推測でなく実コードと Godot 実挙動で裏取りし、`state管理の問題` か `表示だけの問題` かを切り分けて記録する。LLM が「内部で複数型を受け取れる」と主張しても editor 上で edge を結べない、という食い違いを再発させないための一次資料。

## 検証方法

- コード読取り: `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`, `hex_map_build_node_inspector.gd`, `addons/hex_map_kit/generation/hex_generation_node_types.gd`, `addons/hex_map_kit/core/hex_map_generator.gd`。
- Godot 実挙動: `tools/probe_region_filter_connection_typing.gd`（headless 実行で slot type id を確認）。GraphEdit は drag 接続を「port type id が一致するときのみ」許可する（`add_valid_connection_type` で追加した pair も許可）。`is_valid_connection_type` は追加 pair しか true を返さない query なので、editor の実挙動の判定には port type id 一致を使う。

---

## 結論サマリ（state / display 切り分け）

| # | 指摘 | 区分 | 一言 |
|---|---|---|---|
| 1 | Limited 選択時の item row ラベルが weight のまま | **display + data 配線** | ラベルだけでなく、limited が読む `remaining`(個数) を inspector が書いていない。 |
| 2 | Adjacency Rules の走査が非対称で include_generated_reference 時に偏る | **state / correctness** | graph は線形走査版を呼んでおり、対称走査版に繋がっていない。test も無い。 |
| 3 | probability_rules は text 入力で設計が破綻、Adjacency Rules Window が欲しい | **design 再設計** | text 廃止。hex方向トグル + 壁数 / 連結成分数の preset dropdown。 |
| 4 | Wall=Markov Mesh で custom distribution 編集 window が出ない | **state 管理 + 機能欠落** | graph 経路は `custom_distribution=null` 固定。state に応じた「編集を開く」導線が無い。 |
| 5 | Region Filter ボタンは分割したが node 共通で、overlay edge を結べない | **design 欠陥（editor typing）** | 論理層は両型OKだが、input slot type が terrain(1) 固定で overlay(3) と不一致 → editor の equal-type drag 規則で結べない。 |

---

## 1. Item Generator `Limited` の item row

事実:

- `weighted` は `_normalize_weight_item_pool` で各 entry の `weight`(0..1) を使う（`generate_random_items_interruptible`）。
- `limited` は `_normalize_limit_item_pool` で各 entry の `remaining`(整数の個数上限) を使う（`generate_limited_items_interruptible`）。
- inspector の item_pool editor (`_build_item_pool_editor` / `_refresh_item_pool_rows`) は placement_method に関係なく常に `weight:` ラベル + 0..1 SpinBox で、`weight` キーしか書かない。

影響:

- 表示だけでなく、`limited` 時に必要な `remaining`(個数) を UI が生成しないため、limited の data 配線が成立していない。

設計方針:

- placement_method ごとに item row のフィールド意味を変える（weighted=weight, limited=count）。
- design-system 的に、item row は「item 種別 + そのmethodにおける制御値（weight / count）」を明示する1コンポーネントとして再設計する。

## 2. Adjacency Rules の走査対称性

事実:

- graph の `_run_item_generator` adjacency_rules は `generate_toric_adjacency_items_interruptible` を呼ぶ。
- この関数は `for index in range(candidates.size())` の線形走査で、`include_generated_reference=true` の時に生成済み cell を即 `reference_set` に追加する → 走査順に依存して結果が偏る。
- 対称走査版 `generate_symmetric_toric_items_interruptible` は存在するが graph からは呼ばれていない。
- この経路の対称性を保証する test は無い。

影響:

- include_generated_reference 時に生成が偏る、という指摘は再現条件が一致する（state / correctness の問題）。

設計方針:

- adjacency_rules 経路を対称走査 Core 関数に接続する、または対称順序で candidate を走査する。
- weighted / limited は「素直なランダム生成の拡張」のままにする（adjacency の対称性要件を持ち込まない）。
- Core 関数との接続を test で固定する（symmetric scan proof）。

## 3. Adjacency Rules Window（probability_rules 再設計）

事実:

- 現状 `probability_rules` は inspector で text 入力。`HexAdjacencyRuleSet.parse_rules_text_report` で parse。
- 旧 Generate タブの text ルール設計は欠陥があった、という指摘。

設計方針（本来の想定）:

- text 入力を廃止する。
- `Adjacency Rules Window` を作る:
  - 任意個数 add 可能な hex パネルボタン（各方向トグル可能）。
  - 参照範囲内での「周囲の壁数」「壁の連結成分個数」を指定。
  - いくつかの preset を選べる dropdown（参考: Markov Mesh の distribution id preset 指定）。
- Core 側 `_adjacency_rule_probability(rules, count, components)` は count/components を既に受けるので、UI から構造化 rule を作って渡す形にする。

## 4. Wall=Markov Mesh の custom distribution window

事実:

- graph の `_run_wall_field` markov_mesh は `generate_symmetric_toric_walls_interruptible(... distribution_id, null, ...)` で `custom_distribution=null` 固定。
- 旧 Generate タブには distribution custom 用 window があったが、Wall node を Markov Mesh にしても編集画面が出ない。
- inspector wall_field は `distribution_id` dropdown を出すだけ。

設計方針:

- state 管理に従い、wall_method=markov_mesh の時に「distribution を編集する window を開く」ボタンを inspector に出す。
- これは #3 の Adjacency Rules Window の Markov Mesh 版に相当する機能として共通設計にできる。
- custom_distribution を graph params / graph resource に持たせて runner へ配線する。

## 5. Region Filter の editor 上 typing（最重要・crux）

事実（`tools/probe_region_filter_connection_typing.gd` 実行結果）:

```json
{
  "item_generator_output_type_id": 3,
  "region_filter_input_type_id": 1,
  "SLOT_TERRAIN": 1,
  "SLOT_OVERLAY": 3,
  "region_filter_accepts": ["terrain", "overlay"],
  "logical_validate_ok": true,
  "port_type_ids_match_editor_connectable": false,
  "is_valid_connection_type_added_pair_only": false
}
```

解釈:

- Region Filter の input port は `accepts=[terrain, overlay]` だが、canvas の `_input_slot_type_id` は `accepts[0]`=terrain の slot type(1) しか設定しない。
- Item Generator の output slot type は overlay(3)。
- GraphEdit は default で「port type id が一致する drag だけ」許可する（equal-type 規則）。3 ≠ 1 なので drag は弾かれ、`connection_request` を発火しない。
- そのため `validate_connection`（logical ok=true）に**到達しない**。
- 補足: `is_valid_connection_type(a,b)` は `add_valid_connection_type` で追加した pair しか true を返さない（equal でも未追加なら false）。よって editor 実挙動の指標には type id 一致を使う。
- 結論: 「内部では両型を受け取れる」は logical 層では真だが、**editor 上では overlay→Region Filter の edge を結べない**。REPAIR-13A のボタン分割（Terrain Filter / Overlay Filter）は同一 node を生成するだけで、port 型は分かれていない。

「edge を結べない事実」をどう伝えるか:

- この findings doc に slot type id 実測値（overlay=3 / terrain=1）と equal-type drag 規則を残す。
- `tools/probe_region_filter_connection_typing.gd` を再実行可能な証拠として残す。
- 今後の実装では editor 上で結べることを test で固定する（port type id 一致を検証）。案A（node 分割）で input port 型を単一化すれば equal-type 規則で自然に結べる。

設計方針（node 設計の再検討）:

- 案A: `Terrain Filter` / `Overlay Filter` を**実際に別 node type** にし、input port をそれぞれ terrain only / overlay only にする（型が UI と一致、validation が単純）。
- 案B: Region Filter を1 node のまま、multi-accept port を GraphEdit drag 層でも通すために `add_valid_connection_type(overlay, terrain_slot)` 等を登録し、slot 表示も multi を示す。
- 第一候補は案A（REPAIR-13A の typed Source と同じ方向で、UI と内部型を一致させる）。
- いずれにせよ「multi-accept port を単一 slot type id にマップする」現状を廃する。

---

## queue 反映

- `REPAIR-15_MARKOV_ADJACENCY_MAPPING`: #1(limited data/label) と #2(対称走査配線+test) を acceptance に含める。
- `REPAIR-16_REGION_FILTER_NODE_TYPING_REDESIGN`(新規): #5。Terrain/Overlay Filter を typed node に再設計し、editor 上で overlay edge を結べることを test で固定。
- `REPAIR-17_ADJACENCY_RULES_WINDOW`(新規): #3。text 廃止、hex方向トグル + 壁数/連結成分 preset window。
- `REPAIR-18_MARKOV_DISTRIBUTION_WINDOW`(新規): #4。state 管理で markov_mesh 時に distribution 編集 window を開く導線 + custom_distribution 配線。
