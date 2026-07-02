# Implementation Queue — GQM track（Graph 品質管理 UX 再設計）

Roadmap: `ROADMAP.md` / 一次設計: `DEPENDENCY_UX_PROPOSALS.md`（Round 3/4 確定）・`RESOURCE_MODEL.md`
Status 運用: `docs/process/QUEUE_OPERATION_RULES.md`。Proof は `PROOF_LOG.md`（本 dir）。

## Phase G1: engine（headless）

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `GQM-01_CONSOLIDATED_NODE_ENGINE_AND_ADAPTATION` | `COMPLETE` | — | 統合 4 ノード（`terrain_generation` / `item_generation` / `set_operation` / `result`）の headless run 層。(1) `terrain_generation`: 台紙 mode（shape: rectangle/square/hexagon ／ source: document terrain / map resource / prior result）+ 壁 method（none/random/markov, distribution 資産）+ 通路 method（none/dense/sparse/terminal）+ `toric_passage` + optional `terminals` 入力。(2) `item_generation`: `domain` 入力 + placement method（weighted/limited/adjacency_rules）+ 定義域 source mode（document overlay 等）。未接続 domain の default は「Result の substrate になっている terrain の floor」に**連動**（Q-DEP-9）。(3) `set_operation`: n 入力 + op（union/intersection/difference）+ node 名（部分式名）。(4) `result`: substrate 自動判別（最初の terrain。以降は `unused` 扱いを report に明示）+ overlay 接続順。**adaptation を全域関数として実装**: terrain→floor(既定)/wall/any/item(key)、overlay→cells(既定)/item(key)、selection→そのまま（消費側 input ごとの adaptation param、edge 単位で保持）。**legacy 正規化 converter**: 旧 node 型（shape/wall_field/connectivity/region_filter/terrain_filter/overlay_filter/source/item_generator/set_operation/compose/result）の graph を統合 graph へ変換（Q-DEP-2 (a)）。**循環 helper**: `would_create_cycle(graph, from, to)`。既存 core static（HexMapGenerator 等）のみを呼び、新規生成アルゴリズムは書かない | `addons/hex_map_kit/generation/`（node_types 拡張 or 新 `hex_generation_adaptation.gd` / `hex_generation_graph_normalizer.gd`）, `hex_generation_graph.gd`, `tests/test_generation_graph.gd` + 新 test | S: (a) 基本形（DEPENDENCY_UX_PROPOSALS R2-3 の 7 node / 9 edge）が実行でき、**legacy 15 node 相当 graph と同一 seed で意味的に同一の Result 出力**（substrate cells/walls・overlay item cells 一致）。(b) adaptation matrix の全 (producer, consumer-input) 組が定義済み（未定義例外なし）を test で網羅。(c) legacy サンプル graph（preset/`_sample_graph` 系）の正規化が runner で同一出力。(d) 循環 helper の true/false 各例。(e) `./tools/test.sh` green。旧 node 型の run 経路は正規化互換のため当面残置（削除しない） |
| `GQM-02_ASSET_TWO_TIER_SERVICE_AND_RESOURCES` | `READY` | — | criteria 資産の二層 service（汎用 `<kind>`: bundled `res://addons/hex_map_kit/assets/<kind>_presets/`（read-only）/ project `ProjectSettings "hex_map_kit/asset_root"`（default `res://hex_map`）+ `/<kind>/`）。`HexAdjacencyRulePresets` を汎用 service ベースに移行（save は project 層のみ・bundled は Duplicate to project）。`HexItemPoolResource` 新設（entries: name/weight/limit + display_name）。`HexWallDistributionResource` に display_name と **組込み preset（Ilands/Maze/Discrete）からの生成 loader**（preset を root として custom 編集の初期値化、0..8 scale）。V5: `toric_passage` / `custom_distribution` / structured `probability_rules` / `limit` / 新 resource の save/load round-trip test | `addons/hex_map_kit/editor/hex_adjacency_rule_presets.gd`（or 新汎用 service）, `addons/hex_map_kit/adapter/hex_item_pool_resource.gd`（新規）, `hex_wall_distribution_resource.gd`, `tests/test_generation_graph_resource.gd` + 新 test | S: (a) bundled/project の一覧統合・出所区別・bundled 書込不可。(b) project root が setting で変更可能。(c) 各 resource の round-trip 完全性 test。(d) preset→custom root 読込の等価性 test（Ilands の重みが custom 初期値に一致）。(e) `./tools/test.sh` green |
| `GQM-03_SCHEMA_FOR_CONSOLIDATED_NODES` | `COMPLETE` | `GQM-01` | 統合 4 ノードの宣言的 param schema（keys / visibility(`visible_when`) / control 種 / options / range / default / `label_by_mode`（例: markov 時 wall_probability=\"Initial Probability\"）/ `derived_default`（Item Generation 定義域の連動 default・素材台紙の `= 出力terrain` 連動）/ `affects` / `asset_kind`）を generation 層に。**default 常時有効**を schema が保証（default のみで全 node 型が有効生成）。旧 REPAIR-21 の置換（対象が legacy 11 node 型から統合 4 型に変わった） | 新 `hex_generation_param_schema.gd` + headless schema test | S: (a) 4 型 × 全 method の schema が headless に列挙・検証可能。(b) default-only graph が全型で有効生成。(c) `affects` 連動の宣言と test。(d) `./tools/test.sh` green |

## Phase G2: canvas / node UI

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `GQM-10_UNTYPED_CANVAS_AND_ADAPTATION_ROWS` | `BACKLOG` | `GQM-01` | canvas を統合 4 ノード・全 port type 0・一色に。type id 割当/valid pair 管理/型別色を削除。`connection_request` で adaptation 既定値確定 + 循環拒否（`_is_node_hover_valid` でも drag 中抑制）。input 行に adaptation dropdown（`floor ▾`/`cells ▾`/`item(key)`）を slot 行 Control として内蔵 | `hex_map_build_graph_canvas.gd`, `tests/test_build_graph_canvas.gd` | S: 任意 node 出力→任意 input が editor で接続でき、循環だけ拒否される。adaptation が edge に保存され run に反映。既存 canvas test を統合ノードへ書き換え。`./tools/test.sh` green |
| `GQM-11_CONSOLIDATED_NODE_INTERNAL_UI` | `BACKLOG` | `GQM-03`, `GQM-10` | ノード内 cascade を schema から描画（Terrain Generation: 台紙⇔壁⇔distribution⇔通路⇔toric、Item Generation: method⇔criteria⇔method別 field）。titlebar に node 名編集 + criteria 資産 chip（RESOURCE_MODEL §4 文法で editor window へ）。method 変更で子要素が名称ごと morph | canvas / inspector / criteria windows | S: 旧 inspector の `_param_*` match 群が消え schema 駆動になる。morph の editor test + 実描画キャプチャ。`./tools/test.sh` green |
| `GQM-12_RESULT_STACK_AND_PROMOTE` | `BACKLOG` | `GQM-10` | Result node = substrate 自動判別行（未使用 terrain の明示）+ overlay 行（接続順・並べ替え・write policy）+ 層ごと promote。stack panel 表示 | canvas / build_screen / promote | S: 基本形で terrain+overlay の promote が層単位で機能。未使用 terrain 表示。実描画キャプチャ + test |

## Phase G3: 導線と資産 UX

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `GQM-13_HEADER_SWEEP_TEMPLATE_GENERATE_UNIFY` | `BACKLOG` | `GQM-11` | Batch N / Seed randomize / Shape randomize / Profile 行 / Generate(Simple) 撤去。Template ▾（bundled graph preset。**基本形 template を筆頭**）。Load Graph / Overwrite selected を graph 資産 operation（§4 文法）へ移設。Generate 一本化（全系譜実行→出力投影。fallback 概念の削除） | build_screen / preset / workspace | S: Build 上部 = Template / Generate / Apply / Revert / status のみ。基本形 template 1 操作で 7 node graph が立ち即 Generate 可能。実描画キャプチャ |
| `GQM-14_RESULT_RESOURCE_SAVE_SWITCH` | `BACKLOG` | `GQM-12`, `GQM-02` | 生成結果の名前付き保存（**出力 data 込み**・park 系 field 不使用）→ リスト → 即時切替（再生成なし）→ promote 導線 | adapter / build_screen / tests | S: 保存→切替→promote が data 込みで即時。リスト表示（thumbnail なし） |
| `GQM-15_LEGACY_GRAPH_LOAD_NORMALIZATION` | `BACKLOG` | `GQM-01`, `GQM-10` | graph resource 読込時の legacy→統合 正規化（Q-DEP-2 (a)）を editor 導線に接続 | graph load 経路 | S: 既存 .tres graph が読込→統合表示→同一出力 |

## Phase G4: 完全性

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `GQM-16_RUNTIME_PARITY_WITH_REFERENCE_ASSETS` | `BACKLOG` | `GQM-01`, `GQM-02` | runtime Map Build が統合 graph + **reference 資産の解決**込みで editor と同一 seed 同一結果（V6） | runtime build + tests | S: reference/embed 双方で parity test green |
| `GQM-17_CRITERIA_WINDOW_DOD` | `BACKLOG` | `GQM-11` | V8: criteria window の完成定義「各パラメータが不快感なく UI に反映」を DoD 化し実描画キャプチャで判定 | windows + captures | S: capture 一式 + DoD チェックリスト |

## Current pointer

`GQM-01` と `GQM-02` が `READY`（独立・並行可）。委譲方針は `ROADMAP.md` §6。
