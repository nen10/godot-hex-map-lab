# Hex Map Kit UI / Generation Graph Implementation Queue 2026-06-15

作成日: 2026-06-15
Roadmap: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ROADMAP.md`
baseline:
- `docs/design/PRODUCT_DEFINITION.md`（製品定義）
- `docs/design/GENERATION_GRAPH_MODEL.md`（本体＝graph 設計）
Queue design policy: `docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md`
Planning policy: `docs/policy/PLANNING_POLICY.md`
Operation process: `docs/process/QUEUE_OPERATION_RULES.md`
Autopilot process: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
Commit process: `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`

この queue は、改訂 Roadmap を Codex autopilot が実装・検証・self-review・queue update できる task slice に分割したもの。背骨（Generation Graph）の vertical slice を前倒しし、acceptance を二層 DoD にする。

---

## 0. Queue operation notes

- status 更新・dependency sweep・proof 記録は `docs/process/QUEUE_OPERATION_RULES.md` に従う。
- `READY` task は plan files を作成して実装まで進める。Plan 作成は承認ゲートではない。
- **acceptance は二層 DoD（`ADOPT-00` で gate 化）**。UI/graph task は **structural DoD（構造・型・test）と experiential DoD（最初に何が見え何を触ると何が起こるか）の両方**を満たさないと `COMPLETE` 不可。self-review に `What user sees first` / `What user can do` 必須。`label-heavy but metrics pass` は不可。
- **graph task の experiential DoD は「chain が editor（または headless）で通る」を含む**。
- **QA / Validate は `PARK-50`（棚上げ）**。中心化・他tab への波及（侵食）禁止。自律的存続・改修は可。`PRODUCT_DEFINITION.md` §0/§7 準拠。
- metric は**回帰検知のみ**（合格根拠にしない / `PROCESS-60`）。
- 新規 analog test は作らない。`dist` freshness は通常テスト化しない（`PROC-90` のみ再生成）。
- 生成 engine を新規に作らない。core static（`hex_map_generator.gd` 他）を headless pass で再利用（`GENERATION_GRAPH_MODEL.md` §1/§9）。
- screen / wireframe task は `docs/policy/LAYOUT_SKETCH_POLICY.md` に準拠する（§6 チェックリスト）。

plan_dir 規約: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/<TASK-ID>_<slug>/`（READY 化時に作成）。

---

## 1. Phase Y0: baseline 採用 / acceptance gate

| id | status | deps | deliverable | target files | acceptance（S=structural / E=experiential） |
|---|---|---|---|---|---|
| `ADOPT-00_BASELINES_AND_ACCEPTANCE_GATE` | `COMPLETE` | none | baseline を SoT 化、二層 DoD を template/policy へ実装、QA park を policy 化 | `docs/review/autopilot/SELF_REVIEW_TEMPLATE.md`, `docs/process/QUEUE_OPERATION_RULES.md`, `docs/policy/PLANNING_POLICY.md`, this queue | S: self-review template に experiential 欄追加 / park 区分が queue に存在 / `./tools/test.sh`。E: 以降 UI/graph task が二層 DoD なしに `COMPLETE` できないルールが明文化。 |

---

## 2. Phase Y1: screen design before code（背骨タブ限定）

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `DESIGN-10_BACKBONE_WIREFRAMES` | `COMPLETE` | `ADOPT-00` | Build/Paint/Export + 支援 Catalog/Layers/Resources の wireframe（QA/Validate 除外・`docs/policy/LAYOUT_SKETCH_POLICY.md` 準拠） | `<plan_dir>/WIREFRAMES.md` | S: 各画面 ASCII wireframe / Resource 退避先 / primary visual surface 明記 + LAYOUT_SKETCH_POLICY §6 チェックリスト全項目。E: 各 wireframe で「最初に見えるもの」「primary action」がラベル説明なしで成立（normal + empty の2状態）。 |
| `DESIGN-11_TAB_IA_AND_PRIORITY` | `COMPLETE` | `DESIGN-10` | tab IA：`Generate`→`Build`、Primary(Build/Paint)/支援(Catalog/Layers/Resources)/utility(Export/Settings)、QA/Validate は park 表示、top strip | `<plan_dir>/TAB_IA.md` | S: 分類表 + tab 間依存導線。E: top strip に現在の進行が見える設計。 |

---

## 3. Phase Y2: Generation Graph 背骨（本体・vertical slice・runtime）

> 参照: `docs/design/GENERATION_GRAPH_MODEL.md`。新 engine を作らない。

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `GRAPH-10_MODEL_AND_HEADLESS_PASSES` | `COMPLETE` | `ADOPT-00` | Node/Port/Edge の Dictionary model + 型検証 + 各 node type の headless pass + Source ノード | `addons/hex_map_kit/generation/`（新規）, `tests/test_generation_graph.gd` | S: port 4型(terrain/selection/overlay/result) / invalid edge 検証 / 新 generation engine 無し(core static 再利用)。E(headless): `Shape→Wall→Connectivity` run→連結 floor の `HexMapData`、`Filter→ItemGen` run→selection 限定の `HexOverlayData`。`./tools/test.sh`。 |
| `GRAPH-11_BUILD_TAB_GRAPH_CANVAS` | `COMPLETE` | `GRAPH-10`, `DESIGN-10` | Build tab に graph canvas / node palette / selected node inspector / output preview / run | `addons/hex_map_kit/editor/`（build canvas）, tests | S: inspector が Resource ref 参照 / canvas が主・Resource row 非主役。E: Build tab を開いた最初が graph canvas / 3 node を接続 / 中間 output を preview。 |
| `GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN` ★ | `COMPLETE` | `GRAPH-11` | `Shape→Wall→Connectivity →Region Filter→ Item Generator →Promote` が editor で1本通る | editor + generation + tests | S: 中間 selection を次 node 入力へ接続 / Promote 後に Document 層が実在。E: 「floor∩spawn距離≤3」→weighted item→中間preview→Promote→Document に使える層。**これが動くまで Graph を `COMPLETE` にしない**。 |
| `GRAPH-12A_BUILD_CONTEXT_BOOTSTRAP` | `COMPLETE` | `GRAPH-12` | Build tab が graph 新規作成と graph-less HexTileMapLayer の UI 実行 context を作る | editor + adapter + tests | S: default で新規/選択中 HexTileMapLayer に embedded graph + Level Document を付与し、既存 tracking が owner。E: 未構成 layer から Build→Generate→Preview→Promote が Resource 参照不足なしで通る。 |
| `GRAPH-13_RUN_UX` | `COMPLETE` | `GRAPH-12A` | run engine（DAG topo+cache+dirty）/ Generate(N=1) 頭出し / N・randomize 降格 | editor + generation + tests | S: topo 実行 + 中間 cache + dirty 伝播 / N default 1。E: primary `Generate` が上部明白 / 束生成(N>1) 副次 / 失敗 node 可視。 |
| `GRAPH-14_GRAPH_RESOURCE` | `COMPLETE` | `GRAPH-12A` | `HexGenerationGraphResource`(Node/Port/Edge) 化 | `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd`, tests | S: Dictionary から移行 / save-load round-trip test。 |
| `RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API` | `COMPLETE` | `GRAPH-14` | runtime Map Build API（graph resource を実行時に読み込み map を build） | `addons/hex_map_kit/adapter/` or `generation/`, `examples/basic_runtime/`, tests | S: editor 非依存の graph→map headless path / embed semantics で自己完結。E: 完全ランダム生成ユースで保存 graph を runtime から build して map が出る。 |
| `RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP` | `COMPLETE` | `GRAPH-14` | graph load の O2-UX（`GENERATION_GRAPH_MODEL.md` §10） | `addons/hex_map_kit/editor/`（workspace binding / asset factory）, tests | S: default=新規 HexTileMapLayer 生成(embed) / opt-in=既存へ overwrite(default off, reference・merge, `writable source` 準拠で `generated` 層のみ置換) / 既存選択追跡を再利用・独立 context-owner 無し。E: graph 開く→新 node に復元編集 / overwrite off 時 Paint 手編集保持。 |

---

## 4. Phase Y3: Build / Paint / Export 作業面（slice 後）

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `SCREEN-30_BUILD_TAB_FULL` | `COMPLETE` | `GRAPH-13` | Simple Build(入口) と Graph(本体) を1画面で両立 / preview・promote・dirty | editor, tests | E: 初心者は Profile→Generate、上級者は graph、両方が最初の画面から辿れる。 |
| `SCREEN-31_PAINT_AS_DESIGN_WORKSPACE` | `COMPLETE` | `DESIGN-10` | Paint を brush 作業面（純ランダムを補うデザイン管理） | `addons/hex_map_kit/editor/hex_map_edit_tool.gd`, tests | S: brush palette / active layer / selected cell / last edit / viewport 同期。E: Paint 先頭に Resource row 無し・編集面が主。 |
| `SCREEN-32_EXPORT_AS_HANDOFF` | `COMPLETE` | `DESIGN-10`, `RUNTIME-50` | handoff 3形態を purpose card 化 | `addons/hex_map_kit/editor/hex_map_export_screen.gd`, tests | S: 3形態 card（(a) data resource(.tres) / (b) scene(.tscn) / (c) graph resource）+ Debug Report / JSON / Package(process-only)。E: 目的から選べる / gameplay framework 化しない。 |

---

## 5. Phase Y4: Catalog / Layers / Resources を context 棚に

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `SCREEN-40_CATALOG_VISUAL_BOARD` | `COMPLETE` | `DESIGN-10` | tile/object を1つの視覚 asset board に統合 | `addons/hex_map_kit/editor/hex_map_catalog_screen.gd` 他, tests | S: tile/object preview を1画面。E: board が主役 / raw source_id・atlas 非表示 / sample は tutorial source 分離。 |
| `SCREEN-41_LAYERS_STACK_VISUAL` | `COMPLETE` | `DESIGN-10` | role stack の視覚化（現状テキスト要約） | `addons/hex_map_kit/editor/hex_map_layers_screen.gd`, tests | S: writable/visibility/lock を chip/toggle。E: role stack が視覚的に並ぶ。 |
| `RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS` | `COMPLETE` | `DESIGN-10` | Resources を資産棚化 + 各 work tab 先頭を context chip に | `addons/hex_map_kit/editor/hex_map_resources_screen.gd` 他, tests | S: Unique/Shared/Optional / work tab 先頭は chip。E: 現 readiness/next-actions ラベル列を撤去 / `Create missing` は大 CTA。 |

---

## 6. Phase Y5: QA / Validate — parked autonomous track（隔離）

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `PARK-50_QA_VALIDATE_HOLD` | `PARKED` | none | QA/Validate を隔離トラックに保持 | （現状維持） | 中心化・他tab への波及禁止 / 主線を律速しない / UX 投資を集中しない / screen redesign の優先対象にしない。自律的存続・改修は可。`PRODUCT_DEFINITION.md` §0/§7 準拠。 |

---

## 7. Phase Y6: process guard / metric 降格

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `PROCESS-60_METRIC_AS_REGRESSION_ONLY` | `COMPLETE` | `ADOPT-00` | label count metric を回帰検知へ降格 | `docs/policy/UI_LAYOUT_METRIC_TEST_PROCESS_AND_ACCEPTANCE_POLICY_2026-06-10.md`, `tools/test.sh` | S: metric は回帰検知扱い。E(基準): 合格根拠は experiential DoD（work surface / primary action / context chips / preview の有無）。 |

---

## 8. Phase Y7: manual / dist

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `DOC-70_WORKFLOW_MANUAL` | `COMPLETE` | `GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN`, `SCREEN-31_PAINT_AS_DESIGN_WORKSPACE` | workflow manual を新導線に | `docs/manual/MANUAL_WORKFLOW.md`, `README.md` | 手順が `Build graph → Promote layer → Paint → Export handoff`。Resource 一覧でなく作業目的ベース。analog test は作らない。 |
| `PROC-90_FINAL_DIST_REGEN` | `COMPLETE` | `DOC-70_WORKFLOW_MANUAL` | dist 再生成 | `tools/package_addon.sh`, `dist/` | manifest/zip が現 addon tree と一致。通常 test gate にしない。 |

---

## 9. Dynamic follow-up area

Codex は self-review で nonblocking work を見つけたらここに `follow-up-ready` task を追記する（テンプレは `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md` §8 参照）。

### 2026-06-22 Build Generate viewport repair track

Design index: `REPAIR_TRACK_DESIGN_INDEX.md`

| id | status | deps | deliverable | target files | acceptance |
|---|---|---|---|---|---|
| `REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY` | `COMPLETE` | completed roadmap main route | Build `Generate` / `Generate (Simple)` projects to a real `HexTileMapLayer` viewport preview with Apply/Revert; handoff uncertainty matrix and diagnostic proof | `addons/hex_map_kit/editor/hex_map_build_screen.gd`, `addons/hex_map_kit/editor/hex_map_workspace.gd`, `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`, `addons/hex_map_kit/generation/hex_generation_preset.gd`, tests, `tools/build_generate_viewport_probe.gd`, `<plan_dir>/REPAIR-10.../` | S: synchronous context provider / Result-priority projection / projection report / targeted tests + `./tools/test.sh`. E: pressing top Generate shows generated result in the Godot viewport on selected/new `HexTileMapLayer`; Apply keeps it, Revert restores previous display. |
| `REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT` | `COMPLETE` | `REPAIR-10` | Result owns `1 required terrain + overlay_0..2`, each overlay preserved as separate generated overlay layer | generation + adapter + tests | S: multi-overlay graph output/promote semantics + `./tools/test.sh`. E: multiple overlay outputs remain inspectable and separately applied as generated overlay layers. |
| `REPAIR-12_INTERMEDIATE_OUTPUT_CHILD_NODES` | `BACKLOG` | `REPAIR-10` | Intermediate generated terrain/overlay outputs are run-replaced child nodes, not mixed into main scene node data | editor scene ownership + tests | S: one child node per intermediate output. E: user can inspect intermediate output without corrupting main target layer. |
| `REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT` | `BACKLOG` | `REPAIR-10` | Graph-wide generation state model, old Generate mapping, Terrain Filter / Overlay Filter split | generation/editor inspector + tests | S: state constraints are explicit and testable. E: Region/Filter controls match incoming data and planned item keys. |
| `REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING` | `COMPLETE` | `REPAIR-13` | Move `Add Node` + node buttons below the graph and group them by layer-generation role; make `Source` output type explicit so it fits Terrain Filter / Overlay Filter split | `hex_map_build_screen.gd`, `hex_map_build_graph_canvas.gd`, inspector/docs/tests | S: grouped Add Node row + typed Source proof + `./tools/test.sh`. E: user can add Source Terrain / Source Overlay from the grouped row under the graph; Source output type is visible in node title and matches connection validation. |
| `REPAIR-14_GRAPH_CANVAS_EDGE_DELETE` | `COMPLETE` | `REPAIR-10` | Edge deletion interaction works and is visibly discoverable | `hex_map_build_graph_canvas.gd`, screen tests | S: edge selection/delete proof + `./tools/test.sh`. E: user can select and delete an edge via visible Delete Edge action without deleting nodes or relying on context-menu behavior. |
| `REPAIR-15_OLD_GENERATE_STATE_MIGRATION_AUDIT` | `COMPLETE` | `REPAIR-13` | Audit and organize the **whole** state-management migration from the old Generate tab into the Build graph, and define the optimal UI design for the migrated state (covers limited item count wiring, symmetric adjacency scan, markov/adjacency parity, and any other unmigrated old-Generate behavior) | generation state docs/code/tests | S: a migration coverage matrix (old Generate behavior -> Build graph node/state/UI) plus prioritized gaps. E: every old Generate state/behavior is either migrated with an optimal UI or explicitly recorded as dropped, with correctness tests for the migrated pieces. |
| `REPAIR-16_REGION_FILTER_NODE_TYPING_REDESIGN` | `COMPLETE` | `REPAIR-13A` | Split Terrain Filter / Overlay Filter into editor-real typed ports, not only button labels | graph node schema + canvas port tests | S: overlay output can be connected to Overlay Filter in GraphEdit drag layer; terrain output cannot. E: editor connection behavior matches UI labels and no longer relies on hidden multi-accept claims. |
| `REPAIR-17_ADJACENCY_RULES_WINDOW` | `BACKLOG-REDESIGN` | `REPAIR-15` | Replace probability_rules text field with structured Adjacency Rules window/presets | inspector/modal + rules resource/tests | S: hex-direction toggles, wall count/component count controls, preset dropdown, structured rules passed to generator. E: user configures adjacency rules visually without raw text. |
| `REPAIR-18_MARKOV_DISTRIBUTION_WINDOW` | `BACKLOG-REDESIGN` | `REPAIR-15` | Restore Markov Mesh custom distribution editor for Wall node and wire custom_distribution state | inspector/modal + wall generator params/tests | S: markov_mesh shows edit-distribution action and passes custom_distribution to core. E: graph Wall Field can use preset or custom Markov distribution like old Generate intent. |

---

## 10. Current pointer

Current recommended next task: `REPAIR-18_MARKOV_DISTRIBUTION_WINDOW` (redesign).

理由:
- `REPAIR-10` は `COMPLETE`：Build `Generate` / `Generate (Simple)` が selected/new `HexTileMapLayer` へviewport projectionし、Apply/Revert契約とprojection reportを持つ。`HexMapPreviewThumbnail` は secondary proof扱い。proof は `PROOF_LOG.md`。
- `REPAIR-11` は `COMPLETE`：Result multi-overlay contract は実装済み。次の未解決 repair は `REPAIR-12` intermediate output child nodes。
- `ADOPT-00` は `COMPLETE`：二層 DoD gate を self-review template / queue rules / planning policy へ実装し、QA park を規則化（proof は `PROOF_LOG.md`）。
- `GRAPH-10` は `COMPLETE`：headless graph backbone の proof 済み（proof は `PROOF_LOG.md`）。
- `GRAPH-11` は `COMPLETE`：Build graph canvas / palette / inspector / preview / run の proof 済み（proof は `PROOF_LOG.md`）。
- `GRAPH-12` は `COMPLETE`：Shape→Wall→Connectivity→Region Filter→Item Generator→Promote の editor/headless proof 済み（proof は `PROOF_LOG.md`）。
- `GRAPH-12A` は `COMPLETE`：graph 新規作成 / graph-less HexTileMapLayer の Build context bootstrap proof 済み（proof は `PROOF_LOG.md`）。
- `GRAPH-13` は `COMPLETE`：run cache / dirty propagation / Generate(N=1) primary / failure node visibility の proof 済み（proof は `PROOF_LOG.md`）。
- `GRAPH-14` は `COMPLETE`：HexGenerationGraphResource の nodes/edges/promote_targets/semantics_snapshot 化、Dictionary 相互変換、save/load round-trip、runner 互換の proof 済み（proof は `PROOF_LOG.md`）。
- `RUNTIME-50` は `COMPLETE`：runtime Map Build API、embed/reference semantics、seed 再現性、Layer 適用の proof 済み（proof は `PROOF_LOG.md`）。
- `RUNTIME-51` は `COMPLETE`：graph load default=new node embed copy、overwrite opt-in/generated-only merge、既存選択追跡再利用の proof 済み（proof は `PROOF_LOG.md`）。
- Phase Y2 は `COMPLETE`：phase review matrix は `docs/review/roadmap/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN_Y2_PHASE_REVIEW_2026-06-15.md`。
- `SCREEN-30` は `COMPLETE`：Simple Profile→preset graph→Generate→terrain promote、graph-less selected layer の UI button bootstrap、dirty/last run/state visibility の proof 済み（proof は `PROOF_LOG.md`）。
- `SCREEN-31` は `COMPLETE`：Paint workspace chips、brush palette、shape controls、empty CTA、viewport selected cell / last edit 同期の proof 済み（proof は `PROOF_LOG.md`）。
- `SCREEN-32` は `COMPLETE`：Runtime Map Resource / Runtime Scene / Generation Graph の 3 purpose card、Debug Report / JSON Snapshot / Package(process-only) secondary row、scene/graph/json/debug action proof 済み（proof は `PROOF_LOG.md`）。
- Phase Y3 は `COMPLETE`：phase review matrix は `docs/review/roadmap/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN_Y3_PHASE_REVIEW_2026-06-15.md`。
- `SCREEN-40` は `COMPLETE`：Catalog visual board、tile/object 統合 card、raw source/atlas tooltip 退避、sample tutorial source 分離の proof 済み（proof は `PROOF_LOG.md`）。
- `SCREEN-41` は `COMPLETE`：Layers first surface role stack、visible/locked toggle、writable source chip、empty CTA の proof 済み（proof は `PROOF_LOG.md`）。
- `RESCTX-42` は `COMPLETE`：Resources shelf、Unique/Shared/Optional card、work tab context chip、Map chip 非重複の proof 済み（proof は `PROOF_LOG.md`）。
- `DESIGN-10` は `COMPLETE`：6タブ normal/empty wireframe と §6 self-check 済み（proof は `PROOF_LOG.md`）。
- `DESIGN-11` は `COMPLETE`：tab IA / priority / top strip の proof 済み（proof は `PROOF_LOG.md`）。
- Phase Y4 は `COMPLETE`：phase review matrix は `docs/review/roadmap/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN_Y4_PHASE_REVIEW_2026-06-15.md`。次の backlog 候補は `PROCESS-60`。
- `PROCESS-60` は `COMPLETE`：UI layout metric は regression signal、P0 は標準テスト上の regression failure、合格根拠は experiential DoD と明文化（proof は `PROOF_LOG.md`）。
- Phase Y6 は `COMPLETE`：phase review matrix は `docs/review/roadmap/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN_Y6_PHASE_REVIEW_2026-06-15.md`。次の READY は `DOC-70`。
- `DOC-70` は `COMPLETE`：manual / README を `Build graph → Promote layer → Paint → Export handoff` の作業目的ベースに更新（proof は `PROOF_LOG.md`）。
- `PROC-90` は `COMPLETE`：`dist/hex_map_kit-0.3.0.manifest.txt` と `dist/hex_map_kit-0.3.0.zip` を現 addon tree から再生成（proof は `PROOF_LOG.md`）。
- Phase Y7 は `COMPLETE`：phase review matrix は `docs/review/roadmap/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN_Y7_PHASE_REVIEW_2026-06-15.md`。
- Roadmap queue は main route COMPLETE。`PARK-50` は queue 設計どおり parked autonomous track として保持。

実行順（Roadmap §5）:
```
ADOPT-00 → DESIGN-10/11 → GRAPH-10 → GRAPH-11 → GRAPH-12★ → GRAPH-12A → GRAPH-13
→ GRAPH-14 → RUNTIME-50 / RUNTIME-51
→ SCREEN-30/31/32 → SCREEN-40/41 / RESCTX-42
→ PROCESS-60 / DOC-70 / PROC-90
（PARK-50 は常時隔離）
```

---

## 11. Proof log

proof entry は完了時に `PROOF_LOG.md`（本 queue と同階層）へ `### <TASK-ID>` で追記する。
