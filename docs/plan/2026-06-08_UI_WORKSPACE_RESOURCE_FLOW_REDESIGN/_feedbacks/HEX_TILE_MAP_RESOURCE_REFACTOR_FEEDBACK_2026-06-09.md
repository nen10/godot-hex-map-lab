# HexTileMap Resource Design / Refactoring Feedback 2026-06-09

作成日: 2026-06-09  
対象repo: `godot-hex-map-lab-20260609-130048.zip`  
関連roadmap: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`  
目的: Godot標準のResource管理に沿って、`HexTileMapLayer` ノードに設定する独自Resourceの最適設計を確認し、次の repository feedback / roadmap 作成に使える refactoring 候補領域を整理する。

---

## 0. 結論

推奨方針は次で固定してよい。

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

つまり、`HexTileMapLayer` にすべての独自Resourceを直接exportするのではなく、**node-owned Resource と document dependency Resource を分ける**。

この方針は、現在のUI/UX要件にも合う。

- 選択中 `HexTileMapLayer` に応じてdockが自動復元される。
- 選択中nodeが持つべき固有Resourceが分かる。
- 複数mapで共有されるCatalog / DB / Profileをnodeごとに複製しない。
- sample resourceがproduction flowに混ざらない。
- Workspace sessionだけに状態を持たず、Scene / Resource fileから復元できる。

---

## 1. Godot標準から見た基本設計

### 1.1 Exported property は scene/resource file に保存される

Godotでは `@export` されたclass memberは、属しているscene/resourceに保存され、Inspectorで編集できる。ResourceやNodeもexport可能で、Resource型を具体化するとInspectorの選択候補も絞れる。

設計への意味:

```gdscript
@export var level_document_resource: HexMapDocumentResource
@export var layer_stack_resource: HexLayerStackResource
```

このようなexportは、`HexTileMapLayer` が作業対象Resourceへの参照を持つ方法として自然である。

ただし、以下は避ける。

```gdscript
@export var generation_profile: Resource
@export var validation_rule_suite: Resource
@export var export_profile: Resource
```

理由:

- `Resource` だけではInspector / ResourcePickerで何を選べばよいか分かりにくい。
- Godot標準でも、Resource型を具体化すれば選択候補を絞れる。
- Hex Map KitのUX方針でも「ユーザーが型を知らなくても迷わない」が重要。

### 1.2 TSCNの `ext_resource` は避けるべきものではない

Scene fileの先頭に `ext_resource` が並ぶのはGodot標準の保存形式である。外部 `.tres` ResourceをNodeが参照すれば、`.tscn` には外部Resource参照が保存される。

これは問題ではない。

問題になるのは、以下である。

```text
- 何をnodeに持たせるべきか曖昧
- shared Resource をnodeごとに重複管理
- document dependenciesとnode exportsが二重管理
- Workspace sessionだけがResource選択を覚えている
- sample Resourceがproduction contextに自動混入
```

### 1.3 SubResource は小さいscene-local設定用に限定する

`HexMapDocumentResource` や `HexTileCatalogResource` のような、大きく編集・保存・検証・runtime loadするResourceを `.tscn` 内の `sub_resource` として埋め込むのは避ける。

推奨:

```text
Level Document         -> external .tres
Layer Stack            -> external .tres
Tile Catalog           -> external .tres
Object Database        -> external .tres
Label Database         -> external .tres
Movement Profile       -> external .tres
Generation Profile     -> external .tres
Validation Rule Suite  -> external .tres
Export Profile         -> external .tres
```

許容:

```text
小さなscene-local one-off editor setting
一時的なdebug subresource
runtime instance用のlocal state
```

### 1.4 Workspaceは保存元ではなく復元・編集UI

Workspace contextは便利だが、唯一の保存場所にしてはいけない。

保存元の優先順位:

```text
1. HexTileMapLayer exported references
2. HexMapDocumentResource.dependencies
3. Project default resources if introduced
4. Workspace manual override
5. Sample learning resource
```

Workspaceはこれを表示・編集・同期するUIである。

---

## 2. 現在repoの観察

### 2.1 主要ファイル規模

静的確認時点の主要ファイル規模:

| file | lines | コメント |
|---|---:|---|
| `addons/hex_map_kit/editor/hex_map_workspace.gd` | 4299 | Workspace shell, asset context, tab UI, resource actions, sample, export, validation/QA summaries が集中。 |
| `addons/hex_map_kit/editor/hex_map_edit_tool.gd` | 5001 | Paintだけでなく catalog/document/layer/object/validation の残責務を持つ。 |
| `addons/hex_map_kit/editor/hex_map_gen_dock.gd` | 5155 | Generate, QA, progress, seed, distribution, profile的処理が集中。 |
| `addons/hex_map_kit/adapter/hex_tile_map_layer.gd` | 1978 | Node resource refs, document apply, layer stack apply, object display, runtime query, overlay drawing が混在。 |
| `tests/test_editor_plugin.gd` | 7901 | Editor contract testが肥大化。 |

重要なのは行数そのものではない。問題は、**ユーザー作業目的とコード責務がまだ一致していない領域がある**ことである。

### 2.2 現在の `HexTileMapLayer` export

現在の `HexTileMapLayer` には、少なくとも以下がある。

```gdscript
@export var hex_map: HexMapResource
@export var level_document_resource: HexMapDocumentResource
@export var display_tile_set_resource: TileSet
@export var layer_stack_resource: HexLayerStackResource
```

評価:

- `level_document_resource`: 採用。node-owned authoring entryとして妥当。
- `layer_stack_resource`: 採用。ただし shared template と node instance stack の区別が必要。
- `display_tile_set_resource`: 条件付き採用。Catalog dependency / display fallback の関係を明確化する。
- `hex_map`: 要整理。authoring sourceではなく runtime/display snapshot または legacy/simple preview state として扱うべき。

### 2.3 現在の `HexMapDocumentResource.dependencies`

現在の `HexMapDocumentResource` は canonical schema になっており、`dependencies: Array[Resource]` を持つ。

`HexMapDocumentDependencyResource` は以下を持つ。

```gdscript
@export var dependency_id: String = ""
@export var kind: String = KIND_OTHER
@export var resource: Resource
@export var role: String = ""
@export var required: bool = true
@export var metadata: Dictionary = {}
```

評価:

- 方針としては良い。
- ただし、現状は `Array[Resource]` + `kind` string なので、検索・更新・hydrateの共通APIが必要。
- WorkspaceがDocument dependenciesを見て shared resources を自動復元するには、依存検索のstandard serviceが必要。

### 2.4 Workspace asset context

`HexMapWorkspaceAssetContext` は以下のslotを持つ。

```text
Level Document
Tile Catalog
Layer Stack
Object Database
Label Database
Movement Profile
Validation Rule Suite
Generation Profile
Export Profile
```

評価:

- editor stateとしてはよい。
- ただし、contextがflatで、sourceが `Node`, `Document dependency`, `Manual override`, `Project default`, `Sample` のどれかを十分に表現していない。
- contextのResourceがどこへ保存されるか、現時点でslotごとに明確化が必要。

### 2.5 Generic Resource slot が残る

`HexMapWorkspaceAssetResourceFactory` では、Generation / Validation / Export系で generic `Resource` が使われている。

```gdscript
var generation_profile = Resource.new()
var export_profile = Resource.new()
```

評価:

- 現段階のplaceholderとしては理解できる。
- ただし、ResourcePicker filterの甘さと「何を選べばよいか分からない」問題の再発源になる。
- 次phaseで具体Resource化するべき。

---

## 3. 推奨アーキテクチャ

### 3.1 Resource ownership model

```text
HexTileMapLayer node
  Node-owned UniqueResource:
    - Level Document
    - Node Layer Stack Instance

  Optional node display/runtime state:
    - HexMapResource snapshot
    - Display TileSet override

HexMapDocumentResource
  Canonical authoring document:
    - terrain_layers
    - overlay_layers
    - object_placements
    - label_placements
    - zones
    - metadata
    - dependencies

Document dependencies
  Shared project resources:
    - Tile Catalog
    - Object Database
    - Label Database
    - Movement Profile
    - Validation Rule Suite
    - Generation Profile
    - Export Profile
```

### 3.2 Hydration flow

```text
SceneTree selection changes
  -> resolve selected HexTileMapLayer
  -> read node.level_document_resource
  -> read node.layer_stack_resource
  -> read document.dependencies
  -> hydrate workspace asset context
  -> show source badge per slot
```

Source badge候補:

```text
Node-owned
Document dependency
Manual override
Project default
Sample learning resource
Missing
Invalid
```

### 3.3 Writeback flow

```text
User selects/creates Level Document
  -> assign selected_node.level_document_resource
  -> mark scene unsaved
  -> hydrate document dependencies

User selects/creates Layer Stack
  -> assign selected_node.layer_stack_resource
  -> mark scene unsaved

User selects Tile Catalog / Object DB / Label DB / Profile
  -> update workspace context
  -> update selected document.dependencies
  -> mark document unsaved
```

重要:

- SharedResourceをnode exportに増やさない。
- SharedResourceの保存先はDocument dependenciesにする。
- Manual override は一時的に許すが、保存先へ明示的にcommitする。

### 3.4 `HexMapResource` の扱い

現在の `hex_map: HexMapResource` は残してよいが、位置づけを変える。

```text
Primary authoring source: HexMapDocumentResource
Display/runtime snapshot: HexMapResource
Legacy/simple preview import: HexMapResource
```

Roadmap上の名前:

```text
HEXMAP-01_CLARIFY_HEX_MAP_RESOURCE_ROLE
```

目的:

- `hex_map` をauthoring documentの代替として扱わない。
- Generate result preview / runtime initial map / simple importのどれかとして役割を固定する。
- UI上も `Runtime Snapshot` / `Display Snapshot` と呼び、`Level Document` と混同しない。

---

## 4. Refactoring候補領域

### 4.1 Document dependency service

#### 問題

`HexMapDocumentResource.dependencies` はあるが、依存Resourceを検索・追加・置換・hydrateする標準APIが弱い。

現在のままだと、Workspace、Validator、Adapter、Manual/Exportがそれぞれ独自に `dependencies` を解釈し始める。

#### 提案

新規候補:

```text
addons/hex_map_kit/adapter/hex_map_document_dependency_index.gd
addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd
```

役割:

```gdscript
class_name HexMapDocumentDependencyIndex
extends RefCounted

func tile_catalog() -> HexTileCatalogResource
func object_database() -> HexObjectDatabaseResource
func label_database() -> HexLabelDatabaseResource
func movement_profile() -> HexMovementProfileResource
func validation_rule_suite() -> HexValidationRuleSuiteResource
func generation_profile() -> HexGenerationProfileResource
func export_profile() -> HexExportProfileResource

func set_dependency(kind: String, role: String, resource: Resource, required := true) -> void
func remove_dependency(kind: String, role: String) -> void
func missing_required() -> Array[HexMapDocumentDependencyResource]
func source_summary() -> Dictionary
```

#### Acceptance

- Workspace hydrate は dependency index を使う。
- Validator は dependency index を使う。
- Export / QA / Generate は dependency index を使う。
- 手書きDictionary探索を増やさない。

---

### 4.2 Workspace asset hydration / writeback service

#### 問題

`HexMapWorkspace` が巨大化し、selection同期、Resource作成、FileDialog、sample、export、validation、QA summaryなどを多く抱えている。

#### 提案

新規候補:

```text
addons/hex_map_kit/editor/hex_map_workspace_context_hydrator.gd
addons/hex_map_kit/editor/hex_map_workspace_context_writer.gd
addons/hex_map_kit/editor/hex_map_workspace_node_binding.gd
```

責務:

```text
ContextHydrator:
  selected node + document dependencies -> workspace context

ContextWriter:
  workspace slot change -> node export or document dependencies

NodeBinding:
  SceneTree selection -> selected HexTileMapLayer resolution
```

#### Acceptance

- `HexMapWorkspace` はUI composition中心になる。
- node selection / document dependency hydrate / writeback のtestをUIなしで書ける。
- `Document dependency`, `Node-owned`, `Manual override` source badgeを出せる。

---

### 4.3 Concrete profile Resource classes

#### 問題

以下がgeneric `Resource` になっている。

```text
Validation Rule Suite
Generation Profile
Export Profile
Generation Result
```

これはResourcePicker filterが甘くなり、ユーザーが何を選ぶべきか分からなくなる。

#### 提案

新規候補:

```text
HexValidationRuleSuiteResource
HexGenerationProfileResource
HexGenerationResultResource
HexGenerationPassSnapshotResource
HexExportProfileResource
```

初期は最小でよい。

```gdscript
@tool
class_name HexGenerationProfileResource
extends Resource

@export var profile_id: String = ""
@export var display_name: String = ""
@export var generator_settings: Dictionary = {}
@export var validation_rule_suite: HexValidationRuleSuiteResource
```

#### Acceptance

- ResourcePicker base type が具体化される。
- Workspace factory が `Resource.new()` を返さない。
- docs/manualで「何を選ぶResourceか」を説明できる。

---

### 4.4 HexTileMapLayer responsibility split

#### 問題

`HexTileMapLayer` は約2000行で、次の責務を同時に持つ。

- Node export / ready lifecycle
- Map apply
- Document apply
- Layer stack apply
- Object scene tile apply
- Direct object instance apply
- Runtime query
- Viewport hit detection
- Overlay drawing
- Movement range overlay
- Toric/loop display
- Edit command application

これは「行数が多いから悪い」のではなく、**Resource ownership設計の変更を入れにくい**ことが問題である。

#### 提案

分割候補:

```text
HexTileMapLayerResourceBinding
  - level_document_resource / layer_stack_resource / display snapshotの同期

HexTileMapDocumentApplier
  - apply_document / apply_document_cell

HexLayerStackApplier
  - apply_document_to_layer_stack / role layer sync

HexTileMapObjectPresenter
  - object scene tile / direct instance apply

HexTileMapRuntimeQuery
  - path / range / gameplay query helper

HexTileMapOverlayPresenter
  - highlights / movement range / debug overlay
```

先に `ResourceBinding` と `DocumentApplier` を切り、順次分割の計画を立てて進める。

#### Acceptance

- `HexTileMapLayer` にResource exportは残る。
- Resource同期・apply処理を単体でtestできる。
- Document dependencies hydrateと衝突しない。

---

### 4.5 Workspace screen extraction by UX role

#### 問題

`HexMapWorkspace` は約4300行で、tab shellだけでなく各tabの中身も抱えている。

#### 提案

UX責務ごとにscreen scriptへ分ける。

```text
HexMapResourcesScreen
HexMapCatalogScreen
HexMapLayersScreen
HexMapValidationScreen
HexMapQaScreen
HexMapExportScreen
HexMapSettingsScreen
```

分割理由はコード量ではない。

```text
Resources screen: selected node / document / dependencies / missing unique resources
Catalog screen: catalog entries / TileSet / preview / validation
Layers screen: layer roles / visibility / write policy / apply
Validation screen: issue navigator / focus / fix suggestions
QA screen: seed lab / score table / promote
Export screen: runtime handoff / destination / profile
Settings screen: samples / debug / project defaults
```

#### Acceptance

- 各screenは自分のuser taskを完結できる。
- `Paint` tabからCatalog/Layer/Document/Validation/Export詳細を減らす。
- testはprivate node名ではなくscreen contractを見る。

---

### 4.6 Asset slot control simplification

#### 問題

`HexMapEditorAssetSlotControl` は整理されたが、まだ次を持つ。

- create/open signals
- sample action
- details
- fallback button fields
- resource picker state

今後screenごとの行が増えると、再び万能slot control化する可能性がある。

#### 提案

2層に分ける。

```text
HexMapResourcePickerRow
  - title + EditorResourcePicker + status icon + tooltip
  - Godot標準操作中心

HexMapAssetActionPanel
  - Create New / Duplicate Sample / Save As / Focus owner など明示action
  - screen側が必要な時だけ置く
```

#### Acceptance

- asset rowは常に一行で軽い。
- actionはslot行に詰め込まず、screen目的に応じて配置する。
- Clear/Select/Openなどの重複buttonが再発しない。

---

### 4.7 Sample duplication and dependency copy policy

#### 問題

sampleはlearning pathに隔離されたが、`Duplicate To Project` は単一Resourceだけでなく依存Resourceの扱いが重要である。

#### 提案

新規候補:

```text
HexMapSampleProjectDuplicator
HexMapResourceCopyPlan
```

責務:

```text
- sample catalog をproject pathへcopy
- sample TileSet / Texture / PackedScene の扱いを決定
- dependenciesをproject assetへ向ける
- copy結果をdocument dependencies / workspace contextへ反映
```

注意:

GodotのResource deep duplicateには制約があるため、sample duplicationは専用copy planで扱う。

#### Acceptance

- `Duplicate Sample To Project...` でproduction resourcesが作られる。
- sample pathがproduction document dependenciesに残らない。
- copy plan summaryを表示できる。

---

### 4.8 Editor FileDialog / PathSelector consolidation

#### 問題

前回評価で、Workspace側が `EditorFileDialog` を `add_child()` した後、`HexMapEditorPathSelector.popup_dialog()` に渡すと二重parent追加になり得る箇所が見えた。

#### 提案

`HexMapEditorPathSelector` を唯一のpopup管理者にする。

```text
Never add_child(dialog) before popup_dialog(dialog)
popup_dialog() handles parent / popup / cleanup
```

また、保存系dialogはscreen別に散らさず、共通helperを通す。

#### Acceptance

- FileDialogのparent管理が一箇所。
- Export destination / create missing resources / create new Resource が同じdialog policyを使う。
- 実クリック経路のsmoke testを持つ。

---

### 4.9 Test architecture refactor

#### 問題

`tests/test_editor_plugin.gd` は約7900行で、Editor全体のcontractを抱えている。

#### 提案

feature contractごとに分ける。

```text
tests/test_editor_workspace_resources.gd
tests/test_editor_workspace_catalog.gd
tests/test_editor_workspace_layers.gd
tests/test_editor_workspace_validation.gd
tests/test_editor_workspace_qa_export.gd
tests/test_editor_workspace_samples.gd
tests/test_hex_tile_map_resource_binding.gd
tests/test_document_dependency_service.gd
```

#### Acceptance

- 既存test意味は保つが、巨大test fileを増やさない。
- UI node shapeではなく、screen contract / state / resource persistenceを見る。
- Godot実行環境での `tools/test.sh` は維持。

---

## 5. 比較検討: Node exports vs Document dependencies vs BindingResource

### 案A: Nodeに全Resourceをexport

評価: 非推奨。

良い点:

- node選択だけで全部復元できる。
- 実装が単純。

悪い点:

- InspectorがResourceだらけになる。
- shared resourcesとnode-owned resourcesが混ざる。
- Document dependenciesと二重管理。
- 複数mapでCatalog/DBを共有する感覚が弱くなる。

### 案B: NodeはDocument/LayerStack中心、sharedはDocument dependencies

評価: 推奨。

良い点:

- node identityが軽い。
- Document中心のauthoring modelになる。
- shared resourcesをdependenciesから復元できる。
- Workspaceのsource badge設計と相性がよい。

悪い点:

- dependency serviceとhydrate処理が必要。
- dependencies未設定時のmissing state UIが必要。

### 案C: `HexTileMapBindingResource` をnodeに1個持たせる

評価: 保留。

良い点:

- node exportが1行にまとまる。
- workspace contextを保存Resource化できる。

悪い点:

- Level Documentとの責務が重なる。
- ユーザーが「Documentを選ぶ」のか「Bindingを選ぶ」のか迷う。
- 現状は解決より概念増加の方が大きい。

採用条件:

```text
Node-owned resourcesが増えすぎて、Document + LayerStackだけでは説明できなくなった場合のみ検討する。
```

---

## 6. Roadmap候補

### Phase R0: Feedback / policy adoption

#### `RESOURCE-00_ADOPT_NODE_DOCUMENT_DEPENDENCY_MODEL`

目的:

- 本資料の推奨案を正式採用する。
- Node export最小化 / Document dependencies中心 / Workspace hydrate の方針をpolicy化する。

成果物:

- `docs/policy/DOMAIN_POLICY.md` 追記
- `docs/plan/<date>_RESOURCE_OWNERSHIP_REFACTOR/ROADMAP.md`

Acceptance:

- Node-owned / Shared / Optional / Sample の分類がpolicyに入る。
- `HexTileMapLayer` に全Resourceをexportしない方針が明記される。
- Workspace-only persistence禁止が明記される。

---

### Phase R1: Document dependency standardization

#### `RESOURCE-10_DOCUMENT_DEPENDENCY_SERVICE`

目的:

- `dependencies: Array[Resource]` を安全に扱うserviceを作る。

対象:

- `HexMapDocumentDependencyResource`
- `HexMapDocumentResource`
- new dependency service/index

Acceptance:

- kind / role / required / resource typeで依存を検索できる。
- set/remove/updateが標準化される。
- emit_changed / dirty通知方針がある。

#### `RESOURCE-11_DOCUMENT_DEPENDENCY_HYDRATION`

目的:

- Document dependencies から Workspace asset context を復元する。

Acceptance:

- selected document -> tile catalog/object db/label db/profile がhydrateされる。
- source badgeが `Document Dependency` になる。
- missing required dependenciesがResources/Validateに出る。

---

### Phase R2: Node resource binding

#### `NODEBIND-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE`

目的:

- selected node export refsとworkspace contextの同期をUIから分離する。

Acceptance:

- selected `HexTileMapLayer` 解決をservice化。
- `level_document_resource` / `layer_stack_resource` のread/writeをservice化。
- `HexMapWorkspace` から直接setter logicを減らす。

#### `NODEBIND-21_HEX_MAP_RESOURCE_ROLE_CLARIFICATION`

目的:

- `hex_map: HexMapResource` の位置づけを明確化する。

Acceptance:

- `hex_map` は authoring document source ではないとdocs/APIに明記。
- UI上は `Runtime/Display Snapshot` または `Simple Map Snapshot` として扱う。
- Generate結果のcommit先がDocumentかSnapshotか分かる。

---

### Phase R3: Concrete profile resources

#### `PROFILE-30_CONCRETE_VALIDATION_GENERATION_EXPORT_RESOURCES`

目的:

- generic `Resource` slot を具体Resource化する。

追加候補:

- `HexValidationRuleSuiteResource`
- `HexGenerationProfileResource`
- `HexGenerationResultResource`
- `HexExportProfileResource`

Acceptance:

- ResourcePickerが具体型に絞られる。
- Workspace factoryが `Resource.new()` placeholderを返さない。
- docs/manualに各profileの目的が書ける。

---

### Phase R4: Workspace refactor by UX screen

#### `WORKSPACE-40_CONTEXT_HYDRATOR_WRITER_EXTRACTION`

目的:

- Workspaceからcontext hydrate/writeback logicを分離する。

Acceptance:

- `HexMapWorkspaceContextHydrator`
- `HexMapWorkspaceContextWriter`
- `HexMapWorkspaceNodeBinding`
- Unit/headless testsがUIなしで書ける。

#### `WORKSPACE-41_SCREEN_COMPONENT_EXTRACTION`

目的:

- `HexMapWorkspace` をUX screen単位に分ける。

候補:

- `HexMapResourcesScreen`
- `HexMapCatalogScreen`
- `HexMapLayersScreen`
- `HexMapValidationScreen`
- `HexMapQaScreen`
- `HexMapExportScreen`
- `HexMapSettingsScreen`

Acceptance:

- 各screenがtab内の作業を完結できる。
- `Paint` に非Paint責務を残さない。
- `HexMapWorkspace` はtab shell / coordination中心になる。

---

### Phase R5: HexTileMapLayer responsibility split

#### `LAYER-50_RESOURCE_BINDING_AND_DOCUMENT_APPLIER_SPLIT`

目的:

- `HexTileMapLayer` からresource binding / document applyを分離する。

Acceptance:

- Resource binding serviceでnode export refsを扱う。
- Document apply helperを切る。
- 既存runtime APIは維持。

#### `LAYER-51_OBJECT_AND_LAYER_STACK_APPLIER_SPLIT`

目的:

- object presenter / layer stack applyを分ける。

Acceptance:

- layer stack role applyを単体でtest可能。
- object scene tile / direct instance applyを単体でtest可能。

---

### Phase R6: Sample project duplication

#### `SAMPLE-60_PROJECT_DUPLICATION_PLAN`

目的:

- sampleからproduction project assetへのcopy planを標準化する。

Acceptance:

- sample catalog copy時に dependencies をどう扱うか明示。
- copy結果がDocument dependenciesへ入る。
- sample pathがproduction dependenciesに残らない。

---

### Phase R7: Test refactor

#### `TEST-70_EDITOR_TEST_FILE_SPLIT`

目的:

- `test_editor_plugin.gd` をscreen/resource contractごとに分ける。

Acceptance:

- `tools/test.sh` は維持。
- UI node shapeではなく contract/state/resource persistenceを確認する。
- resource binding / dependency service testsがある。

---

## 7. 推奨実行順

```text
1. RESOURCE-00_ADOPT_NODE_DOCUMENT_DEPENDENCY_MODEL
2. RESOURCE-10_DOCUMENT_DEPENDENCY_SERVICE
3. RESOURCE-11_DOCUMENT_DEPENDENCY_HYDRATION
4. NODEBIND-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE
5. NODEBIND-21_HEX_MAP_RESOURCE_ROLE_CLARIFICATION
6. PROFILE-30_CONCRETE_VALIDATION_GENERATION_EXPORT_RESOURCES
7. WORKSPACE-40_CONTEXT_HYDRATOR_WRITER_EXTRACTION
8. WORKSPACE-41_SCREEN_COMPONENT_EXTRACTION
9. LAYER-50_RESOURCE_BINDING_AND_DOCUMENT_APPLIER_SPLIT
10. LAYER-51_OBJECT_AND_LAYER_STACK_APPLIER_SPLIT
11. SAMPLE-60_PROJECT_DUPLICATION_PLAN
12. TEST-70_EDITOR_TEST_FILE_SPLIT
```

この順序の理由:

- 先にDocument dependenciesを標準化しないと、Workspace refactorが保存先不明になる。
- 先にnode bindingを切らないと、HexTileMapLayerとWorkspaceが密結合し続ける。
- Concrete profile Resourceを作らないと、ResourcePicker filter問題が残る。
- Workspace screen分割は、context hydrate/writebackが分離してから行う方が安全。
- HexTileMapLayer分割は、node binding方針が固まってから行う方がよい。

---

## 8. Definition of Done

このfeedbackを元にしたroadmapの成功状態:

```text
Resource ownership:
  - HexTileMapLayerは最小のnode-owned refsを持つ
  - Shared resourcesはDocument dependenciesから復元できる
  - Workspace-only persistenceがない
  - sampleはproduction contextに自動混入しない

Dependency service:
  - Dependenciesをkind/role/typeで検索・更新できる
  - Workspace / Validate / Generate / Export が同じserviceを使う

Workspace:
  - selected node -> document -> dependencies -> context のhydrateが動く
  - slotごとに source badge が出る
  - screenごとに責務が分かれる

Profiles:
  - Validation / Generation / Export が具体Resource classを持つ
  - generic Resource pickerが減る

HexTileMapLayer:
  - authoring document apply, layer stack apply, object display, runtime queryの責務が整理される
  - `hex_map` の役割が明確

Tests:
  - resource binding / dependency hydrate / writeback のcontract testがある
  - 巨大editor testがscreen別に分かれ始める
```

---

## 9. 最終提案

次のroadmapは、UI見た目の次段ではなく、**Resource ownership / dependency hydration / workspace persistence の土台整理**として切るのがよい。

理由:

- 現在のWorkspace UIは、選択中nodeとResource群を表示する方向へ進んだ。
- しかし、shared resourcesをどこから復元し、どこへ保存するかがまだ弱い。
- このままscreen UIを増やすと、Workspace contextが一時状態として肥大化し、project reload時の復元不整合が残る。

最初に切るべきtaskはこれ。

```text
RESOURCE-10_DOCUMENT_DEPENDENCY_SERVICE
RESOURCE-11_DOCUMENT_DEPENDENCY_HYDRATION
NODEBIND-20_HEX_TILE_MAP_RESOURCE_BINDING_SERVICE
```

この3つが入れば、以後のCatalog / Layers / Validate / QA / Export screenは、単なるUIではなく、**Godot標準のScene + external Resource参照 + Document dependenciesに乗った編集環境**として安定する。

