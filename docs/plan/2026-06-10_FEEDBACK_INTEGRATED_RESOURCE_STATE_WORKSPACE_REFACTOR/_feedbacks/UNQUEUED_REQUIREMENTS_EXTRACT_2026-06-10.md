# Unqueued Requirements Extract 2026-06-10

評価対象: `godot-hex-map-lab-20260610-152614.zip`  
対象roadmap: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/`  
補助評価: `ROADMAP_EXECUTION_PROCESS_EVALUATION_2026-06-10.md`  
作成日: 2026-06-10

---

## 0. 目的

前回の process 評価で指摘した「defer / future / mirror compatibility が prose に残り、queue化されないことがある」問題について、実行後リポジトリ内の `SUB_TASKS.md`、`UX.md`、`POLICY.md`、`IMPLEMENTATION_PLAN.md`、および `docs/review/autopilot/*_SELF_REVIEW_2026-06-10.md` を確認し、**未queue化要件**を抽出する。

この文書の目的は、次回roadmapで拾うべき要件を明確化し、`No follow-up` や `later` のまま散逸しないようにすることである。

---

## 1. 判定基準

### 1.1 未queue化要件の定義

この文書では、次を **未queue化要件** と呼ぶ。

```text
計画文書・self-review・process評価の中で、
今後必要な機能、設計、除去、安定化、抽出、polish として言及されているが、
現在の `IMPLEMENTATION_QUEUE.md` に独立した task id として存在しないもの。
```

### 1.2 除外するもの

以下は、単語として `deferred` や `later` が出ていても、この文書では未queue化要件として扱わない。

| 種別 | 扱い | 例 |
|---|---|---|
| 既存queueで明示回収済み | 除外 | `FB-01` が `STATE-50` に送った DialogState など |
| ユーザー方針で保留 | 台帳化のみ | analog test は UI印象改善後まで作らない |
| 人間リリース作業 | queue外processとして明記 | public package upload |
| 通常test化しない方針 | queue外processとして明記 | committed dist freshness test化はしない |
| 単なる互換維持説明 | 除外 | addon未公開なので snapshot field 追加可、など |

### 1.3 判定ラベル

| label | 意味 |
|---|---|
| `UNQUEUED_ACTION` | 次roadmapに task 化すべき実装・設計要件 |
| `PROCESS_ACTION` | 開発プロセス改善として task 化すべき要件 |
<!-- | `LEDGER_ONLY` | 今は実装しないが、台帳化・removal condition が必要 | -->対応不要
| `POLICY_DEFERRED` | ユーザー方針・release方針により queue化しない |
| `ALREADY_COVERED` | 既存queueに対応先があり、未queueではない |

---

## 2. 抽出サマリ

| 区分 | 件数 | 備考 |
|---|---:|---|
| `UNQUEUED_ACTION` | 23 | 実装・UX・architecture・performance・screen polish |
| `PROCESS_ACTION` | 4 | 前回process評価で提案済みだが現在queueに未反映 |
<!-- | `LEDGER_ONLY` | 4 | fallback / mirror / debug / manual override の明示化 | -->対応不要
| `POLICY_DEFERRED` | 4 | analog test / public upload / dist testization 等 |
| `ALREADY_COVERED` | 8 | 誤検出防止のため記録 |

次roadmapへ優先的に入れるべきものは、`UNQUEUED_ACTION` と `PROCESS_ACTION` である。

---

## 3. 未queue化実装・UX要件

### UQ-01 Physical Workspace UI node construction extraction

label: `UNQUEUED_ACTION`  
priority: P0  
source:

- `ARCH-41_SCREEN_COMPONENT_EXTRACTION_BY_UX_ROLE/SUB_TASKS.md`: `Move actual UI node construction out of Workspace. | Defer`
- `ARCH-41.../UX.md`: `Physical UI node construction remains in existing files for now.`
- `ARCH-41_SELF_REVIEW_2026-06-10.md`: `Larger physical UI node construction extraction remains out of scope for this slice.`

問題:

`ARCH-41` は screen role scripts を導入したが、実際の UI node construction は既存 `HexMapWorkspace` / screen host 側に残っている。これは「role contract」は進んだが、画面構築責務の実体分割が未完了という状態である。

queue化案:

```text
ARCH-NEXT-10_PHYSICAL_WORKSPACE_UI_NODE_EXTRACTION
```

acceptance:

- Workspace は tab host / context / dispatcher に寄せる。
- 各 screen の UI node construction は screen component class に移る。
- `HexMapWorkspace` に screen固有の詳細UI構築が残らない。
- tests は `tab_component_class` と `screen_contract` を見る。

---

### UQ-02 Generate Dock internals split

label: `UNQUEUED_ACTION`  
priority: P0  
source:

- `ARCH-41.../SUB_TASKS.md`: `Split HexMapGenDock internals. | Defer`
- `ARCH-41.../UX.md`: `Generate/Settings role extraction is deferred...`
- `UI-03.../UX.md`: `Full Generate tab layout redesign is deferred.`

問題:

Generate は現在も最も大きな機能塊であり、run state / preview / apply / output / profile / performance / source reload が混在しやすい。`STATE-10` と `UI-03` で状態と表示の一部は整理されたが、内部構造の分割は未queueである。

queue化案:

```text
ARCH-NEXT-11_GENERATE_DOCK_INTERNAL_COMPONENT_SPLIT
```

acceptance:

- Generate run controls、profile/source controls、preview/result summary、output/apply/save controls を component 分割する。
- `HexMapGenDock` は orchestration と state binding に寄せる。
- `generation_run_view_state()` を画面 component の主入力にする。
- full layout redesign はこの task または `GEN-NEXT-10` と依存づける。

---

### UQ-03 Full Generate tab layout redesign

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `UI-03_GENERATE_EMPTY_AREA_AND_STATUS_REPAIR/UX.md`: `Full Generate tab layout redesign is deferred.`
- `UI-03.../SUB_TASKS.md`: `Redesign all generation parameters into a new component | Reject | Too broad...`

問題:

`UI-03` は empty-area と result-status を直したが、Generate tab 全体の情報設計、parameter group、preview/apply/save の配置は未解決である。

queue化案:

```text
GEN-NEXT-10_GENERATE_TAB_LAYOUT_REDESIGN
```

acceptance:

- Input / Profile / Preview / Apply / Save / Performance state が視覚的に分離される。
- Reload / Save As / Apply の目的が初見で分かる。
- 重い global update と preview-only state の区別が表示される。
- `ARCH-NEXT-11` と依存関係を明示する。

---

### UQ-04 Rich preview thumbnails for Generate / QA

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `UI-03.../UX.md`: `Rich preview thumbnails are deferred to later Generate/QA work.`
- `GENPIPE-80.../UX.md`: generation pipeline state concept also depends on visible intermediate/output state.

問題:

Generate/QA は candidate / seed / promotion を扱うが、現在は state/summary 中心であり、視覚的な map preview / thumbnail は task 化されていない。

queue化案:

```text
GEN-NEXT-11_GENERATE_QA_PREVIEW_THUMBNAILS
```

acceptance:

- Generate candidate preview thumbnail を表示する。
- QA score row と preview を関連づける。
- thumbnail が重い場合は cache / size budget を持つ。
- sample-only preview ではなく project document / candidate data から生成する。

---

### UQ-05 Catalog editor component extraction

label: `UNQUEUED_ACTION`  
priority: P0  
source:

- `SCREEN-20_CATALOG_CONTROLS_OUT_OF_PAINT/UX.md`: `Full Catalog editor component extraction is deferred to later architecture work.`
- `SCREEN-20.../SUB_TASKS.md`: `Remove EditTool catalog helper methods immediately | Reject`

問題:

Catalog ownership は Paint から外れたが、Catalog editor の UI component と旧 helper の分離はまだ残っている。

queue化案:

```text
CAT-NEXT-10_CATALOG_EDITOR_COMPONENT_EXTRACTION
```

acceptance:

- Catalog entry list / detail / create / validate が専用 component に入る。
- Paint / EditTool の catalog helper は normal UI responsibility から外れる。
- Catalog screen が entry state の source of truth になる。

---

### UQ-06 Rich tile / scene visual thumbnails in Catalog

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `SCREEN-20.../UX.md`: `Rich visual tile/scene thumbnails are deferred.`
- earlier screen reviews mention direct TileSet editor opening / richer preview UI remaining deferred.

問題:

Catalog が asset identity screen になるには、key text だけでなく tile / scene preview が必要。現在の screen contract は state を表現するが、視覚的選択支援は未queueである。

queue化案:

```text
CAT-NEXT-11_CATALOG_TILE_SCENE_PREVIEW_UI
```

acceptance:

- Atlas tile preview と scene preview を Catalog entry detail に表示する。
- Missing preview / invalid entry は badge と tooltip で出す。
- direct TileSet editor / selected tile linking を検討する。

---

### UQ-07 Rich visual redesign for Resources / Layers / Export tabs

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `SCREEN-21_LAYER_DOCUMENT_EXPORT_CONTROLS_OUT_OF_PAINT/UX.md`: `Rich visual redesign of each tab is deferred beyond this task.`

問題:

`SCREEN-21` は Paint から責務を移したが、Resources / Layers / Export が「分かりやすい作業画面」として完成する UI redesign は未queueである。

queue化案:

```text
SCREEN-NEXT-10_RESOURCES_LAYERS_EXPORT_VISUAL_REDESIGN
```

acceptance:

- Resources は selected node / Level Document / dependencies / writeback state を視覚的に整理する。
- Layers は role tree / visibility / writable state を表で扱う。
- Export は output type / source / destination / last result が一目で分かる。

---

### UQ-08 Fine-grained Layer role editing

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `ARCH-50` keeps layer coordination in node.
- Earlier self-review lineage records fine-grained role editing for lock, z-index, writable source, richer visual role presentation as deferred.
- `SCREEN-21` only moved ownership out of Paint; role editing remains minimal.

問題:

Layer Stack は role visibility / apply / context はあるが、lock / z-index / writable source / role policy の UI は本格化していない。

queue化案:

```text
LAYER-NEXT-10_LAYER_ROLE_EDITOR
```

acceptance:

- roleごとの visible / locked / z-index / writable source を編集できる。
- selected HexTileMap child layers と LayerStack Resource の関係を表示する。
- role変更は Document/LayerStack/source state に反映される。

---

### UQ-09 Paint viewport affordance polish

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `SCREEN-22_PAINT_TAB_BRUSH_SURFACE/UX.md`: `Additional viewport affordance polish is deferred beyond this task.`

問題:

Paint は brush surface として状態が出るようになったが、viewport 上の affordance、選択セル、brush cursor、layer feedback、mode switching の visual polish は未queueである。

queue化案:

```text
PAINT-NEXT-10_VIEWPORT_AFFORDANCE_POLISH
```

acceptance:

- Brush cursor / selected cell / target layer / last edit feedback を viewport と Paint tab で同期する。
- 2D viewport edit 開始時に Paint tab 状態が自然に追従する。
- editing mode が分かる visual state を持つ。

---

### UQ-10 Rich Validate issue table and per-issue actions

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `SCREEN-23_VALIDATE_ISSUE_NAVIGATOR_REFINEMENT/UX.md`: `Rich table widgets and per-issue buttons are deferred.`
- `SCREEN-23.../SUB_TASKS.md`: current scope only exposes issue list/focus metadata.

問題:

Validate は issue navigator になったが、table widget / per-issue fix / focus buttons / grouped action は未queueである。

queue化案:

```text
VAL-NEXT-10_VALIDATE_RICH_ISSUE_TABLE_ACTIONS
```

acceptance:

- severity / domain / scope / target / suggestion の列表示を持つ。
- issueごとの focus / open resource / switch tab / fix candidate action を設計する。
- no-op button を出さない。実装できない action は表示しない。

---

### UQ-11 QA scored table visual redesign

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `SCREEN-24_QA_SEED_LAB_AND_PROFILE_SCREEN/UX.md`: `Visual redesign of the scored table widget is deferred unless a later component extraction task touches QA layout.`

問題:

QA は score table state と profile context を持つが、比較・選択・promotion の視覚的 table UI は未queueである。

queue化案:

```text
QA-NEXT-10_SCORE_TABLE_VISUAL_REDESIGN
```

acceptance:

- seed rows / score columns / validation status / promote target を比較しやすく表示する。
- selected seed と preview / promotion state を関連づける。
- visual redesign は `ARCH-NEXT-10` または QA component extraction と結合する。

---

### UQ-12 Settings grouping / toggle styling

label: `UNQUEUED_ACTION`  
priority: P2  
source:

- `UI-02_SETTINGS_LABEL_SIMPLIFICATION/UX.md`: `Larger Settings grouping/toggle styling is deferred.`

問題:

Settings は debug label の削減や sample row path非表示が進んだが、Sample / Debug / Project Defaults / Preferences の grouping と toggle styling は未queueである。

queue化案:

```text
SETTINGS-NEXT-10_SETTINGS_GROUPING_TOGGLE_STYLING
```

acceptance:

- Sample Learning / Debug / Project Defaults / UI Preferences が分かれる。
- Boolean state は toggle/checkとして分かり、説明は tooltip へ寄る。
- sample は production flow に混ざらない。

---

### UQ-13 Sample detail drawer

label: `UNQUEUED_ACTION`  
priority: P2  
source:

- `UI-02.../UX.md`: `Sample detail drawer is deferred unless a later task needs richer sample inspection.`

問題:

Sample path は通常表示から消えたが、学習用sampleを理解・duplicateするための detail surface は未設計である。

queue化案:

```text
SAMPLE-NEXT-10_SAMPLE_DETAIL_DRAWER
```

acceptance:

- Sample asset の種類、依存、duplicate先、learning use を detail drawer で確認できる。
- Settings normal UI は簡潔に保つ。
- sample mode OFF では production flow に注入されない。

---

### UQ-14 Chunked apply implementation

label: `UNQUEUED_ACTION`  
priority: P0/P1  
source:

- `PERF-60.../SUB_TASKS.md`: `Implement chunked apply now. | Reject`
- `PERF-60.../SUB_TASKS.md`: `Chunked apply implementation is recorded as a future requirement...`
- `PERF-60.../UX.md`: large apply is a candidate for chunking.

問題:

Performance budget は作られたが、実際の chunked scene-tree apply は未queueである。大きいmapで main-thread write/redraw が残る。

queue化案:

```text
PERF-NEXT-10_CHUNKED_TILEMAP_APPLY_IMPLEMENTATION
```

acceptance:

- direct TileMap apply / `HexTileMapLayer` apply / layer-stack apply のうち、対象範囲を明示する。
- apply を chunk 単位で進め、progress/busy state と接続する。
- cancel可否と中断時の整合性を定義する。

---

### UQ-15 Large-map validation progress

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `PERF-60.../UX.md`: `Large-map validation progress is not implemented in this task.`

問題:

Generate core や apply だけでなく、validation traversal も大規模mapで長くなる可能性がある。progress state は概念化されたが validation progress は未実装である。

queue化案:

```text
PERF-NEXT-11_LARGE_MAP_VALIDATION_PROGRESS
```

acceptance:

- validation rule traversal を progress可能な単位に分ける。
- Validate tab / Generate flow の busy state と接続する。
- cancelできない場合も現在のphaseを表示する。

---

### UQ-16 GenerationResultResource / replay API

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `GENPIPE-80.../SUB_TASKS.md`: `Future implementation should begin with a concrete GenerationResultResource / replay API task...`
- `GENPIPE-80.../POLICY.md`: `A future Generation Result model is the right home...`

問題:

Generation pipeline concept は作られたが、最初に実装するべき concrete `GenerationResultResource` / replay API が queue にない。

queue化案:

```text
GENPIPE-NEXT-10_GENERATION_RESULT_RESOURCE_AND_REPLAY_API
```

acceptance:

- primary / overlay / filter / candidate / validation map の保持範囲を決める。
- seed / generation profile / pass summary / score / promotion source を保存できる。
- QA / Generate から replay / promote できる。
- graph UI より先に実装する。

---

### UQ-17 Generation pipeline graph / pass graph UI

label: `UNQUEUED_ACTION`  
priority: P2  
source:

- `GENPIPE-80.../POLICY.md`: `graph concepts remain backlog/research.`
- `GENPIPE-80.../SUB_TASKS.md`: node graph UI rejected from this slice.

問題:

中間生成 / pass graph / node graph は概念整理されたが、研究backlogとしてqueue化されていない。

queue化案:

```text
GENPIPE-NEXT-20_PIPELINE_GRAPH_UI_RESEARCH_AND_SPIKE
```

dependencies:

- `GENPIPE-NEXT-10_GENERATION_RESULT_RESOURCE_AND_REPLAY_API`

acceptance:

- linear pipeline / Resource pass / node graph の候補比較を更新する。
- immediate implementation する最小UIを決める。
- pass graph が不要なら明確に破棄する。

---

### UQ-18 Object layer extraction from HexTileMapLayer

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `ARCH-50.../SUB_TASKS.md`: `Extract gameplay query, object layer, and debug overlay adapters now. | Defer`
- `ARCH-50.../UX.md`: `Object layer rendering remains through the existing HexObjectLayerAdapter.`

問題:

`HexTileMapLayer` の責務分割は resource binding / document apply preparation まで進んだが、object layer rendering の責務はまだ本格分離されていない。

queue化案:

```text
ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION
```

acceptance:

- object placement rendering / object layer adapter / runtime instancing boundary を分ける。
- `HexTileMapLayer` は coordinator に寄せる。
- object layer tests を分離する。

---

### UQ-19 Gameplay query extraction from HexTileMapLayer

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `ARCH-50.../SUB_TASKS.md`: gameplay query extraction deferred.
- `ARCH-50.../UX.md`: gameplay query extraction deferred.

問題:

Path / range / movement profile などの gameplay query は `HexTileMapLayer` の runtime helper として価値があるが、長期的には専用 helper / service に分けるべき領域として残っている。

queue化案:

```text
ARCH-NEXT-21_GAMEPLAY_QUERY_SERVICE_EXTRACTION
```

acceptance:

- path/range/connectivity query を `HexTileMapLayer` から service に委譲する。
- 既存 public helper は facade として維持するか、clean APIへ更新する。
- runtime sample が service path を使う。

---

### UQ-20 Debug overlay extraction from HexTileMapLayer

label: `UNQUEUED_ACTION`  
priority: P2  
source:

- `ARCH-50.../SUB_TASKS.md`: debug overlay extraction deferred.
- `ARCH-50.../UX.md`: debug overlay extraction deferred.

問題:

debug overlay は runtime helper / editor debug / validation issue focus と混ざりやすい。独立 component 化が未queueである。

queue化案:

```text
ARCH-NEXT-22_DEBUG_OVERLAY_RENDERER_EXTRACTION
```

acceptance:

- validation/debug overlay 描画と `HexTileMapLayer` core apply を分ける。
- debug overlay は normal gameplay rendering と混ざらない。
- Copy Debug Report / Validate issue focus と接続する。

---

### UQ-21 Further mechanical split of `test_editor_plugin.gd`

label: `UNQUEUED_ACTION`  
priority: P2  
source:

- `TEST-80.../SUB_TASKS.md`: `Further mechanical splitting can continue later...`
- `TEST-80_SELF_REVIEW_2026-06-10.md`: `No dynamic queue item is added...`

問題:

主要 state/screen contract tests は分割されたが、monolithic `test_editor_plugin.gd` の完全整理は未queueである。

queue化案:

```text
TEST-NEXT-10_CONTINUE_EDITOR_TEST_FILE_SPLIT
```

acceptance:

- feature family 別に残りの editor integration tests を分割する。
- old private widget shape tests を増やさない。
- `test_editor_plugin.gd` は full workflow smoke に寄せる。

---

### UQ-22 Root reducer / event model expansion

label: `UNQUEUED_ACTION`  
priority: P1/P2  
source:

- `STATE-60.../UX.md`: `Root reducer/event model can expand later; this task establishes the boundary.`

問題:

Dispatcher boundary と root state snapshot はできたが、本格的な reducer/event model は未queueである。

queue化案:

```text
STATE-NEXT-10_ROOT_REDUCER_EVENT_MODEL
```

acceptance:

- Workspace events を typed event として定義する。
- reducer結果、side effect、UI state更新を分ける。
- Debug report / tests は event history または reducer result を確認できる。

---

### UQ-23 Private generation flags mirror removal

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `STATE-10.../SUB_TASKS.md`: `_generation_*` private fields immediate replacement rejected.
- `STATE-10.../POLICY.md`: `Existing private fields may remain as mirrors during this task...`
- process評価: mirror compatibility の後始末taskが明示backlog化されていない。

問題:

`HexMapGenerationRunState` が導入されたが、旧 private flags が mirror として残る。これは正しい移行策だが、removal condition が queue にない。

queue化案:

```text
STATE-NEXT-11_GENERATION_PRIVATE_FLAG_MIRROR_RETIREMENT
```

acceptance:

- `_generation_*` private flags の inventory を作る。
- run state / ViewState に置換済みの field を削除または read-only mirror に落とす。
- removal condition と tests を明記する。

---

### UQ-24 Concrete profile behavior semantics

label: `UNQUEUED_ACTION`  
priority: P1  
source:

- `PROFILE-30.../POLICY.md`: concrete classes are intentionally minimal until later profile behavior tasks define deeper schemas.
- `PROFILE-31_SELF_REVIEW_2026-06-10.md`: later QA / Validate / Export screen tasks still own deeper workflow redesign.
- earlier review lineage notes dedicated schemas/editors for Generation Profile and Validation Rule Suite remain deferred.

問題:

Validation Rule Suite / Generation Profile / Export Profile は concrete Resource になったが、具体的な挙動・schema・editor はまだ最小である。

queue化案:

```text
PROFILE-NEXT-10_CONCRETE_PROFILE_BEHAVIOR_SCHEMAS
```

acceptance:

- `HexValidationRuleSuiteResource` に rule set / severity / enabled state を持たせる。
- `HexGenerationProfileResource` に generator parameters / scoring config / batch defaults を持たせる。
- `HexExportProfileResource` に output type / destination policy / runtime handoff options を持たせる。
- Profile editor / QA / Validate / Export との接続を設計する。

---

### UQ-25 Package build UI decision

label: `UNQUEUED_ACTION`  
priority: P3 / decision required  
source:

- `SCREEN-25_EXPORT_PURPOSE_SCREEN/UX.md`: `Package build UI remains deferred to process/final packaging work.`
- `SCREEN-25.../POLICY.md`: package build classified but not exposed as normal Export action.

問題:

現時点では package build は process-owned として正しい。ただし、将来 Export tab に package build UI を出すかどうかの product decision は queue化されていない。

queue化案:

```text
EXPORT-NEXT-10_PACKAGE_BUILD_UI_DECISION
```

acceptance:

- package build を editor UI に出すか、process-only に固定するかを判断する。
- 出す場合は Export tab の output type に組み込む。
- 出さない場合は manual/process で完結させ、Export screen からは明確に外す。

---

## 4. 未queue化 process 要件

以下は、前回 process 評価で明示的に提案されたが、現在の repo queue にはまだ存在しない process 改善 task である。

### PRQ-01 Complexity class for task plans

label: `PROCESS_ACTION`  
priority: P0  
source:

- `ROADMAP_EXECUTION_PROCESS_EVALUATION_2026-06-10.md`: `PROCESS-10_COMPLEXITY_CLASS_FOR_TASK_PLANS`

queue化案:

```text
PROCESS-10_COMPLEXITY_CLASS_FOR_TASK_PLANS
```

acceptance:

- `PLANNING_POLICY.md` に C1〜C5 complexity class を追加する。
- `SUB_TASKS.md` template に complexity header を追加する。
- C4/C5 task では candidate matrix / fallback table / state table を必須にする。

---

### PRQ-02 Phase review matrix

label: `PROCESS_ACTION`  
priority: P0  
source:

- `ROADMAP_EXECUTION_PROCESS_EVALUATION_2026-06-10.md`: `PROCESS-11_PHASE_REVIEW_MATRIX`

queue化案:

```text
PROCESS-11_PHASE_REVIEW_MATRIX
```

acceptance:

- phase完了時に phase review matrix を作る。
- phaseごとの task score / debt / evidence / next readiness を記録する。
- phase中の prose-only defer を次queueに変換する。

---

### PRQ-03 Fallback ledger

label: `PROCESS_ACTION`  
priority: P0  
source:

- `ROADMAP_EXECUTION_PROCESS_EVALUATION_2026-06-10.md`: `PROCESS-12_FALLBACK_LEDGER`

queue化案:

```text
PROCESS-12_FALLBACK_LEDGER
```

acceptance:

- `docs/review/roadmap/FALLBACK_LEDGER_<date>.md` を作る。
- fallback / mirror / legacy / debug / sample / manual override を一覧化する。
- owner / status / removal condition / test proof を持つ。
- self-review が ledger を参照する。

---

### PRQ-04 Plan / execution boundary

label: `PROCESS_ACTION`  
priority: P1  
source:

- `ROADMAP_EXECUTION_PROCESS_EVALUATION_2026-06-10.md`: `PROCESS-13_PLAN_EXECUTION_BOUNDARY`

queue化案:

```text
PROCESS-13_PLAN_EXECUTION_BOUNDARY
```

acceptance:

- `IMPLEMENTATION_PLAN.md` は事前計画を保持する。
- 実行済み checklist / changed files / deviations は self-review または `EXECUTION_LOG.md` へ寄せる。
- 既存 queue proof との整合を保つ。

---

## 5. Ledger-only 要件

以下は今すぐ実装queueにしなくてもよいが、台帳化しないと「自明なfallback」になりにくい。

### LG-01 Manual override precedence

label: `LEDGER_ONLY`  
source:

- `RES-11_DOCUMENT_DEPENDENCY_HYDRATION/UX.md`: manual project override remains selected when hydration runs again.
- `SCREEN-10` / manual docs: `Manual Override` badge is documented.

必要処理:

- `FALLBACK_LEDGER` に `manual override` を登録する。
- owner: Resource/Workspace binding service。
- removal condition: なし。これは fallback ではなく explicit source state として固定する可能性が高い。
- test proof: dependency hydration / manual override precedence tests。

### LG-02 Sample learning vs production fallback

label: `LEDGER_ONLY`  
source:

- 多数の tasks で `sample-only completion` を禁止。
- `DOC-90`, `UI-02`, `SCREEN-*` self-review が sample learning を確認。

必要処理:

- `FALLBACK_LEDGER` に `sample learning source` を登録する。
- owner: Settings/Samples / AssetSlot state。
- condition: sample mode OFF main flow passes。
- sample が production source に昇格しないことを継続確認する。

### LG-03 Debug / raw path / numeric fallback normal UI exclusion

label: `LEDGER_ONLY`  
source:

- `UI-00` policy: debug, filepath, node path, raw JSON, numeric fallback, internal state are not normal UI.
- `DOC-90` policy: raw paths / raw JSON / numeric fallback language not main workflow.

必要処理:

- `FALLBACK_LEDGER` に `debug/raw detail surface` を登録する。
- owner: UI contracts / Debug Report。
- condition: normal UI screen contracts assert absence; debug report may contain detail。

### LG-04 Compatibility mirror fields

label: `LEDGER_ONLY`  
source:

- `STATE-10` policy: existing private fields may remain as mirrors.
- process評価: mirror後始末taskが未queue。

必要処理:

- `FALLBACK_LEDGER` に mirror fields を登録する。
- これは `STATE-NEXT-11` に昇格すべきため、ledger + implementation task の両方が必要。

---

## 6. Policy-deferred / queue化しない項目

以下は意図的に queue化しない、または別の条件まで待つ。

### PD-01 Analog tests

label: `POLICY_DEFERRED`  
source:

- 多数の UX / SUB_TASKS / self-review で `new analog tests are deferred`。

判定:

ユーザー方針により、UI印象改善後まで作らない。未queue化は問題ではない。

再開条件:

```text
User explicitly requests analog test creation after UI impression is acceptable.
```

### PD-02 Public package upload

label: `POLICY_DEFERRED`  
source:

- `PROC-90_SELF_REVIEW_2026-06-10.md`: `Public package upload remains a manual release step.`

判定:

自動roadmap queueには入れない。release human check として残す。

### PD-03 Dist freshness testization

label: `POLICY_DEFERRED`  
source:

- user指示: committed dist が古い問題はテスト化しない。
- `PROC-90` は final process task として実施。

判定:

通常 `tools/test.sh` には入れない。`PROC-90` の process step で十分。

### PD-04 UI screenshot / visual manual tests

label: `POLICY_DEFERRED`  
source:

- `DOC-90` / `TEST-80`: no analog/manual visual test is added.

判定:

analog test と同じく、今はqueue化しない。

---

## 7. 既存queueで回収済みだったもの

以下は検索上 `deferred` と出るが、既存queueに対応先があるため未queue化扱いしない。

| requirement | source | existing queue |
|---|---|---|
| DialogState / dialog lifecycle state | `FB-01` | `STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES` |
| Resource row compact/adaptive redesign | `STATE-20`, `FB-02` | `UI-01_RESOURCE_ROW_REDESIGN` |
| Settings label simplification | `UI-00`, `STATE-50` | `UI-02_SETTINGS_LABEL_SIMPLIFICATION` |
| Generate empty area / status repair | `UI-00`, `STATE-10` | `UI-03_GENERATE_EMPTY_AREA_AND_STATUS_REPAIR` |
| Validate issue navigator base | `STATE-50`, `SCREEN-21` | `SCREEN-23_VALIDATE_ISSUE_NAVIGATOR_REFINEMENT` |
| Export purpose base | `STATE-50`, `SCREEN-21` | `SCREEN-25_EXPORT_PURPOSE_SCREEN` |
| Workspace screen role contracts | `ARCH-40`, `STATE-60` | `ARCH-41_SCREEN_COMPONENT_EXTRACTION_BY_UX_ROLE` |
| HexTileMapLayer resource/apply helper split | `NODE-21` | `ARCH-50_HEX_TILE_MAP_LAYER_RESPONSIBILITY_SPLIT` |

---

## 8. 推奨 next queue

次roadmapへ入れるなら、優先順は以下がよい。

### P0

```text
ARCH-NEXT-10_PHYSICAL_WORKSPACE_UI_NODE_EXTRACTION
ARCH-NEXT-11_GENERATE_DOCK_INTERNAL_COMPONENT_SPLIT
CAT-NEXT-10_CATALOG_EDITOR_COMPONENT_EXTRACTION
PERF-NEXT-10_CHUNKED_TILEMAP_APPLY_IMPLEMENTATION
```

理由:

- process系を先に入れることで、今回のような未queue化を次回から減らせる。
- UI node construction / Generate internals / Catalog editor は first impression と保守性の両方に効く。
- chunked apply は performance budget 上の future requirement で、現時点では最も明確な performance debt。

### P1

```text
GEN-NEXT-10_GENERATE_TAB_LAYOUT_REDESIGN
GEN-NEXT-11_GENERATE_QA_PREVIEW_THUMBNAILS
VAL-NEXT-10_VALIDATE_RICH_ISSUE_TABLE_ACTIONS
QA-NEXT-10_SCORE_TABLE_VISUAL_REDESIGN
LAYER-NEXT-10_LAYER_ROLE_EDITOR
PAINT-NEXT-10_VIEWPORT_AFFORDANCE_POLISH
PROFILE-NEXT-10_CONCRETE_PROFILE_BEHAVIOR_SCHEMAS
STATE-NEXT-10_ROOT_REDUCER_EVENT_MODEL
STATE-NEXT-11_GENERATION_PRIVATE_FLAG_MIRROR_RETIREMENT
PERF-NEXT-11_LARGE_MAP_VALIDATION_PROGRESS
```

### P2 / concept

```text
SETTINGS-NEXT-10_SETTINGS_GROUPING_TOGGLE_STYLING
SAMPLE-NEXT-10_SAMPLE_DETAIL_DRAWER
ARCH-NEXT-20_OBJECT_LAYER_RENDERING_EXTRACTION
ARCH-NEXT-21_GAMEPLAY_QUERY_SERVICE_EXTRACTION
ARCH-NEXT-22_DEBUG_OVERLAY_RENDERER_EXTRACTION
TEST-NEXT-10_CONTINUE_EDITOR_TEST_FILE_SPLIT
GENPIPE-NEXT-10_GENERATION_RESULT_RESOURCE_AND_REPLAY_API
GENPIPE-NEXT-20_PIPELINE_GRAPH_UI_RESEARCH_AND_SPIKE
EXPORT-NEXT-10_PACKAGE_BUILD_UI_DECISION
PROCESS-13_PLAN_EXECUTION_BOUNDARY
```


---

## 10. 最終結論

今回、未queue化されていた要件は主に3種類だった。

```text
1. 実装スライスではなく「後で」扱いにされた UI / architecture / performance 要件
2. mirror / fallback / debug / manual override のような遷移期要件
3. 前回process評価で提案されたが、まだ active queue へ入っていない process改善要件
```

最も大きい漏れは以下である。

```text
- physical UI node construction extraction
- Generate Dock internals split
- Catalog editor component extraction
- chunked apply implementation
- GenerationResultResource / replay API
- root reducer/event model expansion
- private generation mirror retirement
- process complexity / phase review / fallback ledger
```

この文書の提案 task を次roadmapへ入れれば、`later` / `future` / `deferred` が prose に残る問題はかなり減らせる。
