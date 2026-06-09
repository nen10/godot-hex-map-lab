# Hex Map Kit Feedback Integrated Resource / State / Workspace Refactor Roadmap 2026-06-10

作成日: 2026-06-10  
対象repo: `godot-hex-map-lab-20260610-062348.zip`  
前提roadmap: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`  
主入力feedback:

1. `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/_feedbacks/HEX_TILE_MAP_RESOURCE_REFACTOR_FEEDBACK_2026-06-09.md`
2. `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/_feedbacks/UI_STATE_TRANSITION_REFACTOR_FEEDBACK_2026-06-10.md`
3. `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/_feedbacks/UI_FIRST_IMPRESSION_FEEDBACK_FOR_NEXT_ROADMAP_2026-06-10.md`
4. `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/_feedbacks/UI_WORKSPACE_RESOURCE_FLOW_ROADMAP_EXECUTION_EVALUATION_2026-06-09.md`

目的: 4つのfeedbackをすべて採用し、次のautopilot実装で扱えるように、Resource所有モデル、UI状態遷移、first impression修正、tab別実作業画面化、test/manual/process更新の順に再編する。

---

## 0. 結論

次の開発は、単なる UI polish ではない。

現状の本質課題は、以下の4層がまだ分離し切れていないことである。

```text
HexTileMapLayer node が保持する node-owned Resource
HexMapDocumentResource が保持する authoring map と dependencies
Workspace が表示・編集・復元する Resource context
各tabがユーザーに提示する task surface / state
```

そのため、次のroadmapでは以下の順を基本にする。

```text
1. HexTileMap / Document / dependencies の Resource所有モデルを固定する
2. UIをフラグ合成ではなく state transition model へ移す
3. first impression を壊す label / debug / filepath / no-op button を削る
4. Resource-centric Workspace から task-centric screens へ段階移行する
5. 旧巨大ファイルを「行数」ではなく UX責務境界で分割する
6. tests は UI shape 固定ではなく state / screen contract へ作り直す
7. manual と final dist regeneration は最後に行う
```

ユーザー指定の優先順位は尊重する。

```text
Priority source order:
  1. HexTileMap Resource Refactor feedback
  2. UI State Transition Refactor feedback
  3. UI First Impression feedback
  4. Roadmap Execution Evaluation feedback
```

ただし、実装順では一部を前倒しする。

- `FileDialog` 二重parent疑惑など明確なP0修正は早期に実施する。
- `visible no-op button` の削除は、状態遷移基盤の完了を待たずに進めてよい。
- `dist` freshness はテスト化しない。最終工程で `tools/package_addon.sh` による再生成とmanifest差分確認を行う。
- analog test はまだ作らない。

---

## 1. 採用する主要判断

### 1.1 Resource ownership model

採用案:

```text
HexTileMapLayer node
  -> node-owned / scene-facing な最小Resource参照だけを持つ

HexMapDocumentResource
  -> authoring map の中心Resourceとして terrain / overlay / objects / labels / zones / metadata / dependencies を持つ

HexMapDocumentResource.dependencies
  -> Tile Catalog / Object DB / Label DB / Movement Profile / Validation Suite / Generation Profile / Export Profile など shared project resources を復元する入口にする

Workspace
  -> 選択中 HexTileMapLayer と Document dependencies から context を hydrate するUI
  -> 唯一の保存場所にはしない
```

`HexTileMapLayer` にすべての独自Resourceを直接 `@export` しない。nodeが持つべきものと、document dependenciesから復元すべきものを分ける。

### 1.2 Node exports vs Document dependencies

採用: 案B。

```text
Nodeは Level Document / Layer Stack 中心。
Shared resources は Document dependencies へ。
Workspace は node + document から context を復元する。
```

非採用:

- Nodeに全Resourceをexportする案。
- すぐに `HexTileMapBindingResource` へ飛ぶ案。

`HexTileMapBindingResource` は将来保留。まず現在の node/document/dependencies の責務を清潔にする。

### 1.3 UI state model

採用:

```text
UIはフラグ合成ではなく、state + event + reducer / dispatcher へ移行する。
```

優先対象:

1. Generation run state
2. Asset slot state
3. Workspace selection / binding state
4. Paint interaction state
5. Validation / Export / Sample / Dialog state
6. Root dispatch / screen view state

理由:

- 現状のUI表示問題は「機能不足」だけではなく、状態が複数フラグ・label・debug表示に散っていることに起因する。
- 画面を減らす前に、何を見せるべき状態なのかを固定する必要がある。

### 1.4 First impression修正方針

採用:

```text
案A Minimal UI Repair
  -> 短期修正として採用

案B Resource-Centric Workspace
  -> 中核方針として採用

案C Task-Centric Workspace
  -> 案Bの後に進める

案D State-Machine Driven UI
  -> 必須基盤として採用
```

特に以下を強制する。

- 画面に常時出す情報を減らす。
- debug / filepath / node path / internal state は常時表示しない。
- Resource row は compact one-line か narrow adaptive two-line を基本にする。
- `OK / Missing / Optional / Details` などの文字labelは status icon + tooltip へ寄せる。
- no-op button は削除する。
- `Details` button は原則削除し、tooltip / detail drawer / debug reportへ置換する。
- Generate tabの既存表示を不用意に隠さない。状態遷移整理後に安全に修正する。

### 1.5 Execution evaluationから採用する修正

採用するP0/P1:

- FileDialog popup path の二重 `add_child()` 疑惑を修正する。
- Catalog controls を Paint から Catalog tab へ移す。
- Layer / Document / Export controls を Paint から該当tabへ移す。
- selected Document の dependencies から shared resources を復元する。
- Validation / Generation / Export profile を具体Resource class化する。
- Workspace component を UX role 別に抽出する。
- Generate performance budget と chunked apply の見直しを行う。

---

## 2. Autopilot 実行方針

このroadmapは大規模であるため、通常の1 queue連続実装ではなく、**milestone autopilot** として実行する。

### 2.1 Milestone structure

```text
M0: Feedback adoption / safety repair
M1: Resource ownership / hydration model
M2: UI state machine foundation
M3: First impression minimal repair
M4: Workspace screen migration
M5: Component extraction / responsibility split
M6: Tests / manual / final process
M7: Backlog concept docs
```

各milestoneは複数taskを持つ。Codexは各taskを完了するたびに queue を更新し、`repair-now` が残る場合は次taskへ進まない。

### 2.2 Cross-feedback dependency rule

原則の優先順位:

```text
Resource model > State model > First impression UI > Tab migration > Process cleanup
```

ただし、以下は前倒し可。

- no-op buttonの削除
- FileDialog二重parent修正
- debug labelの非表示化
- Scroll / root container の明確なバグ修正

### 2.3 Scheduled task rule

実装中に大きな追加問題を見つけた場合、実装を止めずに Scheduled task を作る。

```text
SCHEDULED-<source-task>-<short-name>
```

ただし以下は scheduled ではなく同task内 repair とする。

- current task acceptance を満たせない問題
- visible no-op button
- state transitionが矛盾して画面が壊れる問題
- sample-only successでproduction completeになっている問題

### 2.4 Dist freshness rule

`dist` freshness は通常テスト化しない。

最終taskでのみ実施する。

```text
PROC-90_FINAL_DIST_REGENERATION
```

実施内容:

- `tools/package_addon.sh`
- generated manifest と committed manifest の差分確認
- summaryへ差分有無を記録

`tools/test.sh` の必須項目には入れない。

---

## 3. Target architecture

### 3.1 Resource ownership

```text
HexTileMapLayer
  exported node-facing refs:
    - level_document_resource: HexMapDocumentResource
    - layer_stack_resource: HexLayerStackResource
    - optional display_tile_set_resource: TileSet
    - optional hex_map snapshot, if retained

HexMapDocumentResource
  canonical authoring:
    - terrain_layers
    - overlay_layers
    - object_placements
    - label_placements
    - zones
    - metadata
    - dependencies

HexMapDocumentDependencyResource
  shared resource entry:
    - dependency_id
    - kind
    - resource
    - role
    - required
    - metadata

WorkspaceContext
  hydrated view:
    - selected HexTileMapLayer source
    - document source
    - dependency-derived resources
    - manual overrides
    - sample learning source, only when enabled
```

### 3.2 Hydration flow

```text
Scene selection changed
  -> resolve selected HexTileMapLayer
  -> read node level_document_resource / layer_stack_resource
  -> read document dependencies
  -> hydrate Tile Catalog / Object DB / Label DB / profiles
  -> update Workspace state
  -> render screen view states
```

Source badge:

```text
Node
Document Dependency
Manual Override
Project Default
Sample Learning
Missing
Invalid
```

### 3.3 Writeback flow

```text
User selects or creates Resource in Workspace
  -> update Workspace state
  -> if selected HexTileMapLayer exists and slot is node-owned, write back to node export
  -> if slot is shared project resource, write/update document dependency
  -> update dirty / validation / source badges
```

Manual link button is not the default. Auto-binding is default.

### 3.4 UI state root

Root state should make these visible to all screens:

```gdscript
WorkspaceRootState
  selected_node_state
  asset_context_state
  active_tab_state
  generation_run_state
  paint_interaction_state
  validation_workflow_state
  export_workflow_state
  sample_learning_state
  dialog_state
```

Screens render `ViewState`; they do not directly combine many flags.

### 3.5 Screen responsibility

```text
Resources
  selected HexTileMap summary / required resources / dependency hydration / bulk create

Generate
  generation profile / parameters / preview / progress / apply-to-document

Paint
  brush / mode / layer / selected cell / viewport edit state

Catalog
  catalog entries / tile preview / scene preview / validation

Layers
  layer roles / visibility / target root / apply policy

Validate
  issue navigator / focus / fix suggestions

QA
  seed table / score / promotion

Export
  runtime handoff / output type / destination / result

Settings
  samples / debug / preferences
```

---

## 4. Roadmap phases and task queue

### Phase M0: Feedback adoption / safety repair

#### `FB-00_ADOPT_ALL_FEEDBACKS`

status: `READY`  
dependencies: none

目的:

- 4 feedbackをすべて採用する。
- 本roadmapを次の実行 source of truth にする。
- priority source order と調整ルールを明記する。
- analog test deferred と dist final process rule を固定する。

Acceptance:

- `ROADMAP.md` が追加されている。
- 4 feedbackの採用状況が本roadmapに含まれる。
- `dist` freshnessを通常テスト化しない方針が明記される。
- analog test はまだ作らないと明記される。

#### `FB-01_FIX_FILE_DIALOG_POPUP_PATHS`

status: `BACKLOG`  
dependencies: `FB-00_ADOPT_ALL_FEEDBACKS`

目的:

- Workspace / AssetSlot / Sample / Dist などの FileDialog popup 経路を統一する。
- 二重 `add_child()` / reparent / no-op dialog をなくす。

対象:

- `hex_map_workspace.gd`
- `hex_map_editor_path_selector.gd`
- `hex_map_editor_asset_slot_control.gd`
- `hex_map_sample_settings_panel.gd`
- `hex_dist_editor.gd`

Acceptance:

- dialog lifecycle utility が一つに統一される。
- `popup_dialog()` 前に別経路で `add_child()` しない。
- open / commit / cancel が `DialogState` または明確な callback で表現される。
- headless test は直接 dialog popup に依存せず lifecycle contract を見る。

#### `FB-02_VISIBLE_NO_OP_CONTROL_REPAIR`

status: `BACKLOG`  
dependencies: `FB-00_ADOPT_ALL_FEEDBACKS`

目的:

- visible no-op button / placeholder button を消す。

対象例:

- Select
- Open
- Validate
- Details
- Link
- Node
- Sample Open / Duplicate

Acceptance:

- 用途不明な visible button が0。
- 残すbuttonは実状態変化を持つ。
- 結果を一時labelでごまかさない。
- disabledにする場合は tooltip で条件を書く。

---

### Phase M1: Resource ownership / dependency hydration

#### `RES-10_DOCUMENT_DEPENDENCY_SERVICE`

status: `BACKLOG`  
dependencies: `FB-00_ADOPT_ALL_FEEDBACKS`

目的:

- `HexMapDocumentResource.dependencies` を検索・更新・検証する共通serviceを作る。

提案ファイル:

- `addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd`

API候補:

```gdscript
find_dependency(document, kind, role = "")
set_dependency(document, kind, resource, role = "", required = true)
remove_dependency(document, kind, role = "")
hydrate_dependency_map(document)
validate_dependencies(document)
```

Acceptance:

- Tile Catalog / Object DB / Label DB / Movement Profile / Validation Suite / Generation Profile / Export Profile を dependencies から取得できる。
- kind string の直書きを呼び出し側に散らさない。
- dependency の required / role / source badge を扱える。
- tests は dependency add/find/update/remove を確認する。

#### `RES-11_DOCUMENT_DEPENDENCY_HYDRATION`

status: `BACKLOG`  
dependencies: `RES-10_DOCUMENT_DEPENDENCY_SERVICE`

目的:

- selected Document から shared resources を Workspace context に自動hydrateする。

Acceptance:

- Document選択時、dependenciesから Tile Catalog / Object DB / Label DB / profiles がcontextに入る。
- source badge は `Document Dependency` になる。
- manual override は dependency-derived source を一時的に上書きできる。
- missing dependency は sampleで補わず missing state として表示する。

#### `NODE-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE`

status: `BACKLOG`  
dependencies: `RES-11_DOCUMENT_DEPENDENCY_HYDRATION`

目的:

- selected `HexTileMapLayer` と Workspace context の read / write を service に切り出す。

提案ファイル:

- `addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd`

Acceptance:

- Scene selection から HexTileMapLayer を解決する。
- node-owned refs: Level Document / Layer Stack を読む。
- Document dependencies から shared resources を読む。
- Workspaceで選択した node-owned Resource を node export に書き戻す。
- Workspaceで選択した shared Resource を Document dependency に書き戻す。

#### `NODE-21_HEX_MAP_RESOURCE_ROLE_CLARIFICATION`

status: `BACKLOG`  
dependencies: `NODE-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE`

目的:

- `HexTileMapLayer.hex_map` の扱いを整理する。

候補:

```text
A. 廃止
B. runtime/display snapshot として残す
C. simple preview/import用として残すが canonical authoring ではない
```

Acceptance:

- `hex_map` が authoring source of truth ではないことが明確になる。
- UI / docs / tests が `Level Document` を authoring中心に扱う。
- 互換維持のためだけの曖昧な表示を残さない。

#### `NODE-22_MISSING_NODE_RESOURCE_BULK_CREATE_REVIEW`

status: `BACKLOG`  
dependencies: `NODE-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE`

目的:

- Missing UniqueResource 作成flowを node/document/dependency model に合わせて見直す。

Acceptance:

- node-owned Resource と shared Resource を一括作成画面で混ぜない。
- Shared Resource は create or select existing を明示する。
- 作成後、node export / document dependency / workspace context がすべて一致する。

---

### Phase M2: Concrete Resource profile classes

#### `PROFILE-30_CONCRETE_PROFILE_RESOURCES`

status: `BACKLOG`  
dependencies: `RES-10_DOCUMENT_DEPENDENCY_SERVICE`

目的:

- generic `Resource` slot を減らし、ResourcePicker filterを明確にする。

追加候補:

```text
HexValidationRuleSuiteResource
HexGenerationProfileResource
HexExportProfileResource
```

Acceptance:

- Validation Rule Suite picker が具体型になる。
- Generation Profile picker が具体型になる。
- Export Profile picker が具体型になる。
- docs/manual に各profileの目的が説明できる。
- sample-only placeholder Resource は completion proof にしない。

#### `PROFILE-31_PROFILE_DEPENDENCY_INTEGRATION`

status: `BACKLOG`  
dependencies: `PROFILE-30_CONCRETE_PROFILE_RESOURCES`, `RES-11_DOCUMENT_DEPENDENCY_HYDRATION`

目的:

- 具体profile resources を Document dependencies / Workspace context / UI tabs に接続する。

Acceptance:

- profile resources は dependencies から hydrate できる。
- QA / Validate / Export tab が generic Resource ではなく具体Resourceを表示する。
- missing profile は optional/missing としてstate表示される。

---

### Phase M3: UI state transition foundation

#### `STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT`

status: `BACKLOG`  
dependencies: `FB-00_ADOPT_ALL_FEEDBACKS`

目的:

- UIを歪めているフラグ合成を棚卸しする。

成果物:

- `docs/review/roadmap/UI_FLAG_INVENTORY_2026-06-10.md`

対象:

- Generate operation
- Workspace selection / binding
- Asset slot lifecycle
- Paint interaction
- Validation workflow
- Export workflow
- Sample learning flow
- Dialog lifecycle

Acceptance:

- 各領域のフラグ一覧がある。
- state machine化優先度が P0/P1/P2 で分類される。
- 既存UI testを残すか削除するかの方針がある。

#### `STATE-10_GENERATION_RUN_STATE_MACHINE`

status: `BACKLOG`  
dependencies: `STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT`

目的:

- Generate 実行状態を `_generation_running` などの複数フラグから state machine へ移す。

状態候補:

```text
IDLE
PARAMS_DIRTY
PREVIEW_QUEUED
GENERATING
CANCELLING
GENERATED_PREVIEW
APPLYING_TO_DOCUMENT
APPLIED_DIRTY_DOCUMENT
FAILED
```

Acceptance:

- progress / cancel / debounce / apply / dirty state が1つの state から見える。
- Generate tab の表示は state -> ViewState で決まる。
- Orientation切替などの重い操作は state machine に入る。

#### `STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT`

status: `BACKLOG`  
dependencies: `STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT`

目的:

- `HexMapEditorAssetSlotState` の config / runtime / operation result を分ける。

Acceptance:

- slot定義、現在選択、validation結果、sample availability、operation result が別構造になる。
- `OK/Missing/Optional` 文字labelではなく ViewState へ変換される。
- tests は state transition を見る。

#### `STATE-30_WORKSPACE_SELECTION_BINDING_STATE`

status: `BACKLOG`  
dependencies: `NODE-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE`, `STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT`

目的:

- selected node / context hydration / writeback / manual override を state machine 化する。

状態候補:

```text
NO_SCENE_TARGET
NODE_SELECTED_NO_DOCUMENT
NODE_DOCUMENT_READY
DOCUMENT_DEPENDENCIES_HYDRATED
MANUAL_OVERRIDE_ACTIVE
WRITEBACK_PENDING
WRITEBACK_APPLIED
CONFLICT
```

Acceptance:

- Auto-linkの意味が状態として見える。
- manual link button を出さずに通常作業が成立する。
- conflict時だけ明示UIを出す。

#### `STATE-40_PAINT_INTERACTION_STATE_MACHINE`

status: `BACKLOG`  
dependencies: `STATE-30_WORKSPACE_SELECTION_BINDING_STATE`

目的:

- Paint tab の意味を mode + target + document + brush + viewport hit の状態として整理する。

状態候補:

```text
NO_TARGET
TARGET_SELECTED_NO_DOCUMENT
DOCUMENT_READY_NO_BRUSH
BRUSH_READY
VIEWPORT_HOVER
EDIT_APPLYING
EDIT_APPLIED_DIRTY
VALIDATION_FOCUS
BLOCKED_BY_MISSING_ASSET
```

Acceptance:

- 2D viewport編集時に Paint tab の状態が明確に変わる。
- Paint tab がResource参照だけで終わらない。
- selected cell / active brush / layer target が state から表示される。

#### `STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES`

status: `BACKLOG`  
dependencies: `STATE-30_WORKSPACE_SELECTION_BINDING_STATE`

目的:

- Validation / Export / Sample / Dialog lifecycle を状態化する。

Acceptance:

- Validationは not_run / running / clean / warning / error / issue_selected / focus_applied を持つ。
- Exportは no_destination / ready / exporting / exported / failed を持つ。
- Sampleは off / learning_available / duplicated_to_project / sample_source_selected を持つ。
- Dialogは closed / opening / waiting_user / committed / cancelled を持つ。

#### `STATE-60_ROOT_DISPATCHER_AND_VIEWSTATE_INTEGRATION`

status: `BACKLOG`  
dependencies: `STATE-10_GENERATION_RUN_STATE_MACHINE`, `STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT`, `STATE-30_WORKSPACE_SELECTION_BINDING_STATE`, `STATE-40_PAINT_INTERACTION_STATE_MACHINE`, `STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES`

目的:

- root state / event / reducer / dispatcher の統合方針を入れる。

Acceptance:

- screens は直接フラグ合成しない。
- screen rendering は ViewState を受け取る。
- debug report は state snapshot から生成できる。

---

### Phase M4: Minimal first impression repair

#### `UI-00_CREATE_WORKSPACE_UI_CONTRACTS`

status: `BACKLOG`  
dependencies: `STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT`

目的:

- UI修正前に visible contract を文書化する。

成果物:

```text
WORKSPACE_SCREEN_CONTRACT.md
WORKSPACE_STATE_MACHINE.md
VISIBLE_CONTROL_INVENTORY.md
RESOURCE_ROW_SPEC.md
DEBUG_LABEL_POLICY.md
```

Acceptance:

- 各tabの常時表示情報とtooltip情報が分かれる。
- debug / filepath / internal state を通常表示しない方針がある。
- Generate tabについては旧表示を不用意に隠さない注意が書かれる。

#### `UI-01_RESOURCE_ROW_REDESIGN`

status: `BACKLOG`  
dependencies: `STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT`, `UI-00_CREATE_WORKSPACE_UI_CONTRACTS`

目的:

- Resource row を compact / adaptive two-line へ再設計する。

推奨:

```text
Narrow adaptive two-line row を基本。
広いdockでは one-line row に寄せる。
```

Acceptance:

- row label が途中で切れても意味が失われない。
- status text は icon + tooltip へ寄る。
- filepath / node path / debug state は通常表示しない。
- Details button は原則消える。

#### `UI-02_SETTINGS_LABEL_SIMPLIFICATION`

status: `BACKLOG`  
dependencies: `UI-00_CREATE_WORKSPACE_UI_CONTRACTS`

目的:

- Settings tab の `true/false`, `on/off`, debug label を削る。

Acceptance:

- boolean状態は CheckBox / Toggle の状態で表現される。
- text labelで `true/false` を常時表示しない。
- debug payload は copy button / debug report に寄せる。

#### `UI-03_GENERATE_EMPTY_AREA_AND_STATUS_REPAIR`

status: `BACKLOG`  
dependencies: `STATE-10_GENERATION_RUN_STATE_MACHINE`, `UI-00_CREATE_WORKSPACE_UI_CONTRACTS`

目的:

- Generate tab の大きな空白・不可視control・状態不明を修正する。

注意:

- Generate画面は既存ユーザーが丁寧に見てきた領域なので、唐突な大変更をしない。
- 状態遷移整理に基づき、表示が壊れている部分から直す。

Acceptance:

- 画面の大部分が謎領域にならない。
- Generate結果が Document / Preview / Apply / Save のどれに反映されるか分かる。
- Reload button を追加するなら、状態理解のための明確な用途がある。

---

### Phase M5: Resource-centric Workspace and task screens

#### `SCREEN-10_RESOURCES_TAB_AS_CONTEXT_CENTER`

status: `BACKLOG`  
dependencies: `RES-11_DOCUMENT_DEPENDENCY_HYDRATION`, `STATE-30_WORKSPACE_SELECTION_BINDING_STATE`, `UI-01_RESOURCE_ROW_REDESIGN`

目的:

- Resources tab を selected HexTileMap / Document / dependency / missing resources の中心にする。

Acceptance:

- selected HexTileMap summary がある。
- required resources status がある。
- bulk create missing resources がある。
- source badge: Node / Document Dependency / Manual Override / Sample がある。
- Resource rowだけでなく、次の作業行動が分かる。

#### `SCREEN-20_CATALOG_CONTROLS_OUT_OF_PAINT`

status: `BACKLOG`  
dependencies: `SCREEN-10_RESOURCES_TAB_AS_CONTEXT_CENTER`, `UI-01_RESOURCE_ROW_REDESIGN`

目的:

- Catalog詳細操作を Paint から Catalog tab へ移す。

移すもの:

- catalog entry list
- tile preview
- scene preview
- tags/status
- create/edit entry
- validate catalog status

Acceptance:

- Catalog tabだけで catalog editing の主操作ができる。
- Paint tab はcatalog keyを使うだけになる。
- source_id / atlas coords は通常Paint UIに出ない。

#### `SCREEN-21_LAYER_DOCUMENT_EXPORT_CONTROLS_OUT_OF_PAINT`

status: `BACKLOG`  
dependencies: `SCREEN-10_RESOURCES_TAB_AS_CONTEXT_CENTER`

目的:

- Layer / Document / Export control を Paint から該当tabへ移す。

Acceptance:

- Layer roles は Layers tab へ。
- Document save/dependency/dirty は Resources tab へ。
- Export destination/output type は Export tab へ。
- Paint tab に非Paint責務が残らない。

#### `SCREEN-22_PAINT_TAB_BRUSH_SURFACE`

status: `BACKLOG`  
dependencies: `STATE-40_PAINT_INTERACTION_STATE_MACHINE`, `SCREEN-20_CATALOG_CONTROLS_OUT_OF_PAINT`, `SCREEN-21_LAYER_DOCUMENT_EXPORT_CONTROLS_OUT_OF_PAINT`

目的:

- Paint tab を本当の編集作業面にする。

Acceptance:

- empty state がある。
- active brush / target layer / selected cell / last edit が見える。
- viewport editing 時に Paint 状態が更新される。
- Paint tab が Resource参照だけに戻らない。

#### `SCREEN-23_VALIDATE_ISSUE_NAVIGATOR_REFINEMENT`

status: `BACKLOG`  
dependencies: `STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES`, `SCREEN-10_RESOURCES_TAB_AS_CONTEXT_CENTER`

目的:

- Validate tab を issue navigator として完成させる。

Acceptance:

- issue list / severity / scope / focus action がある。
- issue click が cell / Resource / tab focus に繋がる。
- slotごとのValidate buttonではなく、workflowとしてValidateできる。

#### `SCREEN-24_QA_SEED_LAB_AND_PROFILE_SCREEN`

status: `BACKLOG`  
dependencies: `PROFILE-30_CONCRETE_PROFILE_RESOURCES`, `STATE-10_GENERATION_RUN_STATE_MACHINE`

目的:

- QA tab を generation profile / score / promote の画面にする。

Acceptance:

- Generation Profile を使う。
- score table / selected seed / promote target がある。
- Document source of truth と Draft context の境界が説明される。

#### `SCREEN-25_EXPORT_PURPOSE_SCREEN`

status: `BACKLOG`  
dependencies: `PROFILE-30_CONCRETE_PROFILE_RESOURCES`, `STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES`

目的:

- Export tab の目的を明確化する。

Acceptance:

- Runtime handoff / debug export / package support などの export type が整理される。
- output destination と結果用途が見える。
- Export result state がある。

---

### Phase M6: Component extraction by UX role

#### `ARCH-40_WORKSPACE_CONTEXT_HYDRATOR_WRITER_EXTRACTION`

status: `BACKLOG`  
dependencies: `NODE-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE`, `STATE-30_WORKSPACE_SELECTION_BINDING_STATE`

目的:

- Workspaceから context hydration / writeback を分離する。

Acceptance:

- `hex_map_workspace.gd` が直接 node/document/dependency を組み立てすぎない。
- hydration/writeback service がtest可能。
- UIは結果のstateを表示するだけになる。

#### `ARCH-41_SCREEN_COMPONENT_EXTRACTION_BY_UX_ROLE`

status: `BACKLOG`  
dependencies: `SCREEN-20_CATALOG_CONTROLS_OUT_OF_PAINT`, `SCREEN-21_LAYER_DOCUMENT_EXPORT_CONTROLS_OUT_OF_PAINT`, `SCREEN-22_PAINT_TAB_BRUSH_SURFACE`

目的:

- Workspace / EditTool / GenDock の責務を UX screen に合わせて抽出する。

候補:

```text
hex_map_resources_screen.gd
hex_map_catalog_screen.gd
hex_map_layers_screen.gd
hex_map_validate_screen.gd
hex_map_qa_screen.gd
hex_map_export_screen.gd
hex_map_paint_screen.gd
```

Acceptance:

- 分割理由は行数ではなくユーザー作業目的で説明される。
- 各screen scriptがtab内の作業目的に対応する。
- PaintからCatalog/Layer/Export/Document責務が減る。

#### `ARCH-50_HEX_TILE_MAP_LAYER_RESPONSIBILITY_SPLIT`

status: `BACKLOG`  
dependencies: `NODE-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE`, `NODE-21_HEX_MAP_RESOURCE_ROLE_CLARIFICATION`

目的:

- `HexTileMapLayer` の resource binding / document apply / layer stack apply / object display / runtime query / debug overlay を整理する。

候補:

```text
HexTileMapResourceBinding
HexMapDocumentApplier
HexLayerStackApplier
HexObjectLayerApplier
HexGameplayQueryAdapter
HexDebugOverlayAdapter
```

Acceptance:

- `HexTileMapLayer` は coordinator に近づく。
- document apply と resource binding が別責務になる。
- tests は既存 runtime helper の価値を維持する。

---

### Phase M7: Generate performance / pipeline concept

#### `PERF-60_GENERATE_PERFORMANCE_BUDGET_AND_CHUNKED_APPLY_REVIEW`

status: `BACKLOG`  
dependencies: `STATE-10_GENERATION_RUN_STATE_MACHINE`

目的:

- Generate更新のコストを測り、progress / debounce / chunked apply の基準を持つ。

Acceptance:

- map size別の更新時間budgetがある。
- Orientation切替などのglobal updateが分類される。
- budget超過時のprogress/busy/cancel方針がある。
- chunked applyの必要性が評価される。

#### `GENPIPE-80_GENERATION_PIPELINE_STATE_CONCEPT`

status: `BACKLOG`  
dependencies: `PERF-60_GENERATE_PERFORMANCE_BUDGET_AND_CHUNKED_APPLY_REVIEW`

目的:

- intermediate generation data / pass graph / node graph concept を、すぐの実装ではなく設計backlogとして整理する。

Acceptance:

- final Level Document と intermediate map data の違いがある。
- primary / overlay / filter / candidate map の扱いが整理される。
- Resource pass / linear pipeline / node graph の候補比較がある。

---

### Phase M8: Tests / manual / process

#### `TEST-80_EDITOR_TEST_FILE_SPLIT_AND_STATE_CONTRACTS`

status: `BACKLOG`  
dependencies: `STATE-60_ROOT_DISPATCHER_AND_VIEWSTATE_INTEGRATION`, `ARCH-41_SCREEN_COMPONENT_EXTRACTION_BY_UX_ROLE`

目的:

- `tests/test_editor_plugin.gd` の肥大化と UI shape 固定を解消する。

分割候補:

```text
test_workspace_resource_context.gd
test_workspace_state_transitions.gd
test_asset_slot_state.gd
test_generation_run_state.gd
test_paint_interaction_state.gd
test_catalog_screen.gd
test_validate_export_screen.gd
```

Acceptance:

- 旧UI shapeを守るtestを削除・置換する。
- 状態遷移、hydration/writeback、screen contractを確認する。
- analog testはまだ作らない。

#### `DOC-90_WORKSPACE_WORKFLOW_MANUAL_UPDATE`

status: `BACKLOG`  
dependencies: `SCREEN-10_RESOURCES_TAB_AS_CONTEXT_CENTER`, `SCREEN-22_PAINT_TAB_BRUSH_SURFACE`, `SCREEN-25_EXPORT_PURPOSE_SCREEN`

目的:

- manualを現在の Workspace flow に合わせる。

Acceptance:

- selected HexTileMap -> Resources -> Generate -> Paint -> Catalog -> Validate -> QA -> Export が説明される。
- Resource source badge の意味が説明される。
- sample learning flow は別章。
- analog testは追加しない。

#### `PROC-90_FINAL_DIST_REGENERATION`

status: `BACKLOG`  
dependencies: `DOC-90_WORKSPACE_WORKFLOW_MANUAL_UPDATE`, `TEST-80_EDITOR_TEST_FILE_SPLIT_AND_STATE_CONTRACTS`

目的:

- roadmap最終段でdistを再生成する。

Acceptance:

- `tools/package_addon.sh` を実行する。
- committed manifest / zip が現在の addon tree に一致する。
- 差分有無をself-reviewに記録する。
- このチェックは通常test gateへ入れない。

---

## 5. 推奨実行順

```text
1. FB-00_ADOPT_ALL_FEEDBACKS
2. FB-01_FIX_FILE_DIALOG_POPUP_PATHS
3. FB-02_VISIBLE_NO_OP_CONTROL_REPAIR

4. RES-10_DOCUMENT_DEPENDENCY_SERVICE
5. RES-11_DOCUMENT_DEPENDENCY_HYDRATION
6. NODE-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE
7. NODE-21_HEX_MAP_RESOURCE_ROLE_CLARIFICATION
8. NODE-22_MISSING_NODE_RESOURCE_BULK_CREATE_REVIEW

9. PROFILE-30_CONCRETE_PROFILE_RESOURCES
10. PROFILE-31_PROFILE_DEPENDENCY_INTEGRATION

11. STATE-00_UI_FLAG_INVENTORY_AND_CONTRACT
12. STATE-10_GENERATION_RUN_STATE_MACHINE
13. STATE-20_ASSET_SLOT_CONFIG_RUNTIME_SPLIT
14. STATE-30_WORKSPACE_SELECTION_BINDING_STATE
15. STATE-40_PAINT_INTERACTION_STATE_MACHINE
16. STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES
17. STATE-60_ROOT_DISPATCHER_AND_VIEWSTATE_INTEGRATION

18. UI-00_CREATE_WORKSPACE_UI_CONTRACTS
19. UI-01_RESOURCE_ROW_REDESIGN
20. UI-02_SETTINGS_LABEL_SIMPLIFICATION
21. UI-03_GENERATE_EMPTY_AREA_AND_STATUS_REPAIR

22. SCREEN-10_RESOURCES_TAB_AS_CONTEXT_CENTER
23. SCREEN-20_CATALOG_CONTROLS_OUT_OF_PAINT
24. SCREEN-21_LAYER_DOCUMENT_EXPORT_CONTROLS_OUT_OF_PAINT
25. SCREEN-22_PAINT_TAB_BRUSH_SURFACE
26. SCREEN-23_VALIDATE_ISSUE_NAVIGATOR_REFINEMENT
27. SCREEN-24_QA_SEED_LAB_AND_PROFILE_SCREEN
28. SCREEN-25_EXPORT_PURPOSE_SCREEN

29. ARCH-40_WORKSPACE_CONTEXT_HYDRATOR_WRITER_EXTRACTION
30. ARCH-41_SCREEN_COMPONENT_EXTRACTION_BY_UX_ROLE
31. ARCH-50_HEX_TILE_MAP_LAYER_RESPONSIBILITY_SPLIT

32. PERF-60_GENERATE_PERFORMANCE_BUDGET_AND_CHUNKED_APPLY_REVIEW
33. GENPIPE-80_GENERATION_PIPELINE_STATE_CONCEPT

34. TEST-80_EDITOR_TEST_FILE_SPLIT_AND_STATE_CONTRACTS
35. DOC-90_WORKSPACE_WORKFLOW_MANUAL_UPDATE
36. PROC-90_FINAL_DIST_REGENERATION
```

### 順番調整ルール

- `FB-01` と `FB-02` は明確なUXバグ修正なので最初に進める。
- `STATE-00` は早く実施してよいが、本格実装は Resource ownership の骨格後が望ましい。
- `UI-01` は AssetSlot state split の後に行う。
- `Generate` tab の大改修は、GenerationRunStateが入るまで控える。
- `Catalog / Layer / Export` のtab移行は、Resources tabのcontextが安定してから行う。
- `dist` 再生成は最後。

---

## 6. Definition of Done

このroadmapの完了条件:

```text
Resource model:
  - HexTileMapLayerはnode-owned最小Resourceを持つ
  - Shared resourcesはDocument dependenciesから復元される
  - Workspaceは保存元ではなくhydrate/writeback UIになる

State model:
  - Generate / AssetSlot / Workspace selection / Paint / Validation / Export / Sample / Dialog が状態遷移で説明できる
  - UIは散らばったフラグで表示を決めない
  - ViewStateに変換してscreenへ渡す

First impression:
  - visible no-op buttonがない
  - filepath / debug / internal stateが常時表示されない
  - Resource rowはcompactでtooltip中心
  - Generate/Paint/Catalog/Validate/QA/Exportの目的が見える

Workspace screens:
  - Resources tabがcontext中心として機能する
  - Catalog操作がPaintから移る
  - Layer/Document/Export操作がPaintから移る
  - Paint tabは編集作業面になる

Architecture:
  - Workspace / GenDock / EditTool / HexTileMapLayer がUX責務境界で分割される
  - 行数削減ではなく、作業目的に対応した分離で説明できる

Tests:
  - old widget shape testを守らない
  - state transition / hydration / screen contractを見る
  - analog testは追加しない

Process:
  - final dist regeneration は最後に実施
  - dist freshnessは通常テスト化しない
```

---

## 7. Codex autopilot prompt

```md
Read docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/ROADMAP.md.

Goal:
Implement the next task in the feedback-integrated roadmap, using Resource ownership, state transition, and first-impression UX rationality as the source of truth.

Source feedback priority:
1. HexTileMap Resource Refactor feedback
2. UI State Transition Refactor feedback
3. UI First Impression feedback
4. UI Workspace Resource Flow execution evaluation

Rules:
- Do not preserve old UI shape tests if they block the roadmap.
- Do not add analog tests.
- Do not add dist freshness to normal test gates.
- Fix visible no-op buttons immediately.
- Treat Workspace as hydrate/writeback UI, not the only storage location.
- Prefer Document dependencies for shared project resources.
- Prefer state machines over scattered flag composition.
- Hide debug/filepath/internal state from normal UI unless explicitly requested.
- Do not make sample success count as production completion.

Execution:
1. Select the next READY/BACKLOG task in roadmap order.
2. Create UX.md, POLICY.md, IMPLEMENTATION_PLAN.md if task planning is needed.
3. Implement without stopping for approval.
4. Update tests to state/screen contracts.
5. Run ./tools/test.sh if environment supports Godot.
6. Repair repair-now issues.
7. Write self-review/test-result and update queue/proof if using an implementation queue.
```

---

## 8. 最終結論

次の開発は、見た目の小修正だけでは足りない。

現在のUI問題は、Resource所有、Workspace復元、状態遷移、画面情報設計が互いに絡んでいるために起きている。

したがって、次のroadmapでは以下を一体として進める。

```text
Resource ownershipを固定する
  -> Document dependenciesからshared resourcesをhydrateする
    -> Workspace binding/writebackをservice化する
      -> UI state machineへ移行する
        -> Resource rowとdebug表示を削る
          -> Catalog/Paint/Validate/QA/Exportを本当の作業画面にする
            -> tests/manual/processを最後に更新する
```

この順で進めれば、既存のCLEAN UI成果を壊さず、first impressionと大規模保守性の両方を改善できる。
