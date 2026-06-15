# Hex Map Kit UI / Generation Graph Roadmap

作成日: 2026-06-15（canonical。改訂版を正とする）
baseline（参照元・判定基準）:
- `docs/design/PRODUCT_DEFINITION.md`（製品定義）
- `docs/design/GENERATION_GRAPH_MODEL.md`（本体＝graph 設計）
継承元 draft: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ROADMAP_DRAFT_2026-06-14.md`（履歴保全）
（draft の失敗診断・UI原則・wireframe先行規律はそのまま継承。本書は差分是正版。）

---

## 0. この改訂で変えたこと（draft からの差分）

| # | draft の状態 | 是正 |
|---|---|---|
| D1 | QA/Validate を `Check` として主導線・screen redesign に格上げ | **park 化**。主導線・screen task から除外。自律トラックへ隔離（§Y5）。 |
| D2 | Graph で新 Resource を大量定義（NodeResource/PortResource/IntermediateLayerResource…） | **既存プリミティブの orchestration に縮小**。MVPは Dictionary + `HexMapData`/`HexOverlayData`/`HexGenerationResultResource` 再利用。Resource化は後（§Y2）。 |
| D3 | Source（既存層を filter 入力にする）が無い | **Source ノード必須化**。primary結果・既存Documentタイル配置・既存map placement を filter 入力に。 |
| D4 | 生成方式が UI(gen_dock)結合のまま | **headless pass 原則**を必須要件化（core static 呼び出し・Resource参照・UI非依存）。gen_dock 結合の authoring を retire。 |
| D5 | 水平分割（1 task=1 screen）中心。proof は存在/test 型 | **vertical slice（3-node chain 通し）を中核・前倒し**。acceptance を**二層（structural + experiential）**に。 |
| D6 | 設計→wireframe→graph→screens の順で graph が後段 | **graph 背骨を前倒し**。screen は slice 後の支援面に。 |

---

## 1. 不変の前提（draft §0–§2 を継承）

- Process success ≠ Product UX success / Metric pass ≠ Design success / Tab exists ≠ Workflow exists。
- Visual work surface first / Label purge / Resources are context, not the product。
- wireframe なしに screen 実装へ入らない。
- metric は**回帰検知のみ**（合格根拠にしない）。

主導線（製品定義 §4）: **Build(graph) → Paint(デザイン管理) → Export(Godot handoff)**。QA/Validate は park。

`map semantics` = { Catalog(語彙) / Layers(構造) / Resources(束縛) } を支援面の総称とする。Build と Paint は同じ map semantics を消費して同じ Level Document に書き、**Build=手続き(`generated`層へ promote) / Paint=手作業(`document`層へ direct)** を `writable source` で共存させる（PRODUCT_DEFINITION §5.1）。

---

## 2. Acceptance 二層モデル（全 UI/graph task に適用）

draft の失敗（存在/test を満たして UX 未改善）の再発防止。**両方**満たさないと COMPLETE 不可。

- **Structural DoD**: 構造・型・test（従来型）。
- **Experiential DoD**: 「**開いた最初に何が見え、何を触ると何が起こるか**」をユーザー語彙で記述し、その通りに動く。graph task は「**chain が editor 上で通る**」を含む。
- self-review に `What user sees first` / `What user can do` 必須。`label-heavy but metrics pass` は COMPLETE 不可。

---

## 3. Phase 構成（改訂）

```
Y0. baseline 採用 / acceptance gate / QA park 宣言
Y1. screen design before code（背骨タブに限定）
Y2. Generation Graph 背骨（本体・vertical slice・graph resource / runtime Map Build API）   ← 最重要・前倒し
Y3. Build / Paint / Export 作業面（slice の後、支援）
Y4. Catalog / Layers / Resources を context 棚に
Y5. QA/Validate parked autonomous track（隔離・低優先）
Y6. process guard / metric 降格
Y7. manual / dist 最終化
```

---

## 4. Task queue（改訂・二層 DoD 付き）

### Phase Y0: baseline 採用 / gate

#### `ADOPT-00_BASELINES_AND_ACCEPTANCE_GATE` — status: READY
- 成果: 2 baseline を source-of-truth 化。§2 二層 DoD を self-review template / queue policy へ実装。QA/Validate park を policy 化。
- DoD(structural): template に experiential 欄追加。park 区分が queue に存在。
- DoD(experiential): 以降の UI/graph task が二層 DoD なしに COMPLETE できない。

### Phase Y1: screen design before code（背骨タブ限定）

#### `DESIGN-10_BACKBONE_WIREFRAMES` — dep: ADOPT-00
- 対象: **Build / Paint / Export + 支援 Catalog / Layers / Resources**（QA/Validate は除外）。
- 準拠: `docs/policy/LAYOUT_SKETCH_POLICY.md`（§6 チェックリスト全項目）。
- DoD(structural): 各画面 ASCII wireframe。Resource row の退避先明記。primary visual surface 明記。
- DoD(experiential): 各 wireframe で「最初に見えるもの」「primary action」がラベル説明なしで成立（normal + empty の2状態）。

#### `DESIGN-11_TAB_IA_AND_PRIORITY` — dep: DESIGN-10
- DoD: `Generate`→`Build` 改名/上位化。Primary(Build/Paint) / 支援(Catalog/Layers/Resources) / utility(Export/Settings) 分類。QA/Validate は park 表示。top strip に進行状態。

### Phase Y2: Generation Graph 背骨（本体）

> 参照: `docs/design/GENERATION_GRAPH_MODEL.md`。新エンジンを作らない。

#### `GRAPH-10_MODEL_AND_HEADLESS_PASSES` — dep: ADOPT-00
- 成果: Node/Port/Edge の Dictionary model + 型検証。各 node type の **headless pass** `run(inputs, params, context)->output`（core static 呼び出し・Resource参照・UI非依存）。**Source ノード**（既存 Document/map 層の取り込み）。
- DoD(structural): port 4型（terrain/selection/overlay/result）。invalid edge を検証。新 generation engine を追加していない（core static 再利用）。
- DoD(experiential): headless test で `Shape→Wall→Connectivity` を組んで run → 連結 floor を持つ `HexMapData`。`Filter→ItemGen` を run → selection に限定された `HexOverlayData`。**＝UI前に連鎖が成立**。

#### `GRAPH-11_BUILD_TAB_GRAPH_CANVAS` — dep: GRAPH-10, DESIGN-10
- 成果: Build tab に graph canvas / node palette / selected node inspector / output preview / run。
- DoD(structural): inspector が Resource ref を参照。canvas が主、Resource row は主役でない。
- DoD(experiential): **Build tab を開いた最初が graph canvas**。3 node を置いて繋げる。中間 output を preview できる。

#### `GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN` — dep: GRAPH-11 ★背骨の証明
- 成果: `Shape→Wall→Connectivity →Region Filter→ Item Generator →Promote` が **editor 上で1本通る**。Region Filter の output が Item Generator の input になる。Promote が Document の overlay/object 層へ role 指定で書き込む。
- DoD(structural): 中間 selection を次 node 入力に接続。Promote 後に Document 層が実在。
- DoD(experiential): ユーザーが「floor ∩ spawnから距離≤3」を作り → weighted item を配置 → 中間 selection を preview → Promote → **Document に本当に使える層ができる**。**これが動くまで Graph 機能を COMPLETE にしない**。

#### `GRAPH-13_RUN_UX` — dep: GRAPH-12
- 成果: run engine（DAG topo + 中間 cache + dirty 伝播）。Generate(N=1) を頭出し。N 入力(default 1)・seed/shape randomize を下方へ降格。
- DoD(experiential): primary action `Generate` が上部で明白。束生成(N>1/randomize)は視覚的に副次。失敗時にどの node が悪いか分かる。

#### `GRAPH-14_GRAPH_RESOURCE` — dep: GRAPH-12
- 成果: slice 安定後に `HexGenerationGraphResource`(Node/Port/Edge) 化。公開API前提。MVP の Dictionary から移行。

#### `RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API` — dep: GRAPH-14
- 成果: `HexGenerationGraphResource` を出荷可能化し、**runtime Map Build API**（graph resource を実行時に読み込み map を生成）を提供。製品定義 §0 runtime 境界の「graph からの実行時生成」拡張（依然 map 生成・gameplay ではない）。
- DoD(structural): editor 非依存で graph→map を build する headless path。embed semantics で自己完結。
- DoD(experiential): 完全ランダム生成ユースで、保存した graph を runtime から build して map が出る。

#### `RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP` — dep: GRAPH-14
- 成果: graph load の O2-UX（GENERATION_GRAPH_MODEL §10）。**default=新規 HexTileMapLayer 生成**（semantics embed）。**opt-in=既存 HexTileMapLayer へ overwrite**（checkbox default off / reference・merge / `writable source` 準拠で `generated` 層のみ置換・Paint 層保持）。
- DoD(structural): 既存の選択追跡を再利用。独立 context-owner を新設しない。
- DoD(experiential): graph を開く→新 node に復元され編集できる。overwrite off の時 Paint 手編集が保持される。

### Phase Y3: Build / Paint / Export 作業面（slice 後）

#### `SCREEN-30_BUILD_TAB_FULL` — dep: GRAPH-13
- Simple Build(入口) と Graph(本体) を1画面で両立。preview/promote/dirty が見える。
- DoD(experiential): 初心者は Profile 選んで Generate、上級者は graph。両方が最初の画面から辿れる。

#### `SCREEN-31_PAINT_AS_DESIGN_WORKSPACE` — dep: DESIGN-10
- Paint を「純ランダムを補うデザイン管理面」に。brush palette / active layer / selected cell / last edit / viewport 同期。先頭に Resource row を並べない。

#### `SCREEN-32_EXPORT_AS_HANDOFF` — dep: DESIGN-10, RUNTIME-50
- 製品定義の handoff 境界に厳密化。**handoff 3形態**を purpose card 化：**(a) data resource(.tres)** / **(b) scene(layer node tree .tscn)** / **(c) generation graph resource（runtime Map Build API 用）**。加えて Debug Report / JSON Snapshot / Package(process-only)。「遊べる」ではなく「Godotで読み込み・座標問い合わせできる状態で渡す」。
- DoD: gameplay framework 化しない（境界 utility までと明記）。3形態が選べる。

### Phase Y4: Catalog / Layers / Resources を context 棚に

#### `SCREEN-40_CATALOG_VISUAL_BOARD` — dep: DESIGN-10
- tile/object の視覚 board。raw source_id/atlas は通常非表示。sample は tutorial source 分離。

#### `SCREEN-41_LAYERS_STACK_VISUAL` — dep: DESIGN-10
- role stack の**視覚化**（現状はテキスト要約のみ）。writable/visibility/lock を chip/toggle。

#### `RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS` — dep: DESIGN-10
- Resources を「選択中 map の資産棚」(Unique/Shared/Optional)。各 work tab 先頭は詳細 row でなく context chip。`Create missing resources` は大 CTA。
- 是正: 現 Resources 先頭の readiness/next-actions ラベル列（U1/U6）を撤去。

### Phase Y5: QA / Validate — parked autonomous track（隔離）

#### `PARK-50_QA_VALIDATE_HOLD` — status: PARKED
- QA/Validate は**製品目標でない**。自律的存続・改修は可だが、主導線・他tab へ価値を波及（侵食）させない。慣習基準の PoC レンズとしてのみ任意。
- 制約: これらに UX 投資を集中しない。screen redesign の優先対象にしない。`docs/design/PRODUCT_DEFINITION.md` §0/§7 準拠。

### Phase Y6: process guard / metric 降格

#### `PROCESS-60_METRIC_AS_REGRESSION_ONLY` — dep: ADOPT-00
- label count metric を回帰検知へ降格。合格根拠は §2 experiential DoD（work surface / primary action / context chips / preview の有無）。

### Phase Y7: manual / dist

#### `DOC-70_WORKFLOW_MANUAL` — dep: GRAPH-12, SCREEN-31
- 手順を `Build graph → Promote layer → Paint → Export handoff` に。Resource 一覧でなく作業目的ベース。analog test は作らない。

#### `PROC-90_FINAL_DIST_REGEN` — dep: DOC-70
- 最終段で dist 再生成。通常 test gate にしない。

---

## 5. 実行順（vertical slice を早期に）

```
1. ADOPT-00            (gate を先に固定)
2. DESIGN-10 / DESIGN-11
3. GRAPH-10            (headless で連鎖を先に証明)
4. GRAPH-11
5. GRAPH-12 ★          (背骨の vertical slice = 最初の「動く製品価値」)
6. GRAPH-13
7. SCREEN-30/31/32
8. SCREEN-40/41 / RESCTX-42
9. GRAPH-14 / RUNTIME-50 / RUNTIME-51 / PROCESS-60 / DOC-70 / PROC-90
（PARK-50 は常時隔離・主線を律速しない）
```

---

## 6. Completion definition（製品定義 §8 準拠）

```
Backbone:
  - Build tab 先頭が graph canvas
  - 3-node chain（Filter中間出力→次node→Promote）が editor で通る
  - 同一 graph を別 shape/seed に適用でき、一貫基準の配置が出る
  - 生成 pass は headless（gen_dock 非依存）

Workflow / Visual:
  - Build → Paint → Export の主導線が見える
  - 各 work tab 先頭が作業面（ラベル列でない）
  - Resources は context 棚、Catalog/Layers は支援面

Handoff:
  - handoff 3形態（data resource / scene / graph resource）で書き出せる
  - graph resource から runtime Map Build API で map を生成できる
  - graph load は新規 node 生成（default）/ 既存へ overwrite(opt-in, Paint層保持)
  - Godot runtime scene で読み込み・表示・座標問い合わせできる状態で書き出せる
  - gameplay framework 化しない

Process:
  - 二層 DoD なしに UI/graph task を COMPLETE にしない
  - metric は回帰検知のみ
  - QA/Validate を中心化・波及させない
  - analog test はまだ作らない
```
