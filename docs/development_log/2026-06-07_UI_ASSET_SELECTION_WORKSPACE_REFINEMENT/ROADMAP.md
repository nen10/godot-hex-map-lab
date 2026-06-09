# Hex Map Kit UI Asset Selection / Workspace Refinement Roadmap 2026-06-07

作成日: 2026-06-07  
対象: CLEAN UI 実行後の Hex Map Kit  
前提roadmap: `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`  
前提clean roadmap: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/UX_ROADMAP.md`  
前提評価: `docs/review/roadmap/CLEAN_UI_ROADMAP_EXECUTION_EVALUATION_2026-06-07.md`  
目的: CLEAN UI 実行で得た canonical Resource / Workspace / ResourcePicker の土台を、ゲーム開発者が任意の project asset を選んで使える主導線へ再編し、sample preset 依存の「実装済み」判定を禁止する。

---

## 0. 結論

次のUI改修では、**sample preset が存在することを機能完成の根拠にしてはいけない**。

Sample preset は、使い方を理解するための learning / onboarding 経路としては有用である。しかし、ゲーム開発者の本来の作業は、自分の project の TileSet、Catalog、Object Database、PackedScene、Label Database、Layer Stack、Document、Export destination を選び、検証し、保存し、runtime へ渡すことである。

したがって、UIの標準設計は以下に統一する。

```text
Main game-development path:
  user-selected project asset
  -> visible current selection
  -> validation status
  -> create / select / clear / open / save / validate actions

Sample / preset path:
  Settings or Samples tab
  -> explicit ON/OFF
  -> optional learning mode
  -> never silently counted as the main implementation path
```

今回の改修の最優先は、前回評価で指摘した `Workspace tab content migration` と、今回追加された `asset selection UI` 方針を統合し、**各Workspace tabが任意asset選択を持つ実体画面になること**である。

---

## 1. 上位設計原則

### 1.1 Game asset first

すべての editor-facing 機能は、ユーザーが任意の project asset を指定できることを既定とする。

対象asset:

- Level Document
- TileSet
- Tile Catalog
- Layer Stack template
- Object Database
- Object Definition / PackedScene
- Label Database
- Overlay definitions
- Movement Profile
- Validation Rule Suite
- Generation preset / Generation profile
- Export destination
- Runtime sample scene / target root

UI項目が sample preset だけで動く場合、その機能は **実装済みではなく sample-only prototype** と分類する。

### 1.2 Sample preset is learning path, not production path

Sample preset は削除しない。むしろ、初回理解には役に立つ。

ただし配置場所を変える。

```text
悪い配置:
  Generate / Paint / Catalog の主UIに sample preset button があり、
  それを押せば機能が成立した扱いになる。

良い配置:
  Settings / Samples / Onboarding に sample mode toggle があり、
  ユーザーが明示的に学習用assetを使う。
  Main tabs は常に任意project asset selection を中心にする。
```

Sample mode は次の性質を持つ。

- Default は OFF。ただし first-run guide で一度だけ案内してよい。
- ON の時だけ bundled sample assets を候補や quick apply として表示する。
- sample asset を適用する時は、どの Resource が設定されるかを明示する。
- sample asset は project asset selection を置き換えない。
- `Duplicate Sample To Project...` または `Create Project Copy...` を用意し、学習から実制作へ移れるようにする。

### 1.3 Unconfigured state is valid UI

asset 未選択の状態はエラーではなく、正しい初期状態である。

各 asset slot は以下を表示する。

```text
Current: Not selected
Action: Select existing / Create new / Use project default / Learn with sample
Validation: Missing required asset for <operation>
```

自動で sample を選んで空状態を隠してはいけない。

### 1.4 No sample-only completion

タスクの完了条件に、以下を追加する。

```text
A feature is not complete until a user can select arbitrary project assets for it.
Sample preset support is optional and cannot satisfy the main UX acceptance by itself.
```

### 1.5 UI根拠はtest可能性ではなくUX合理性

`EditorResourcePicker` や FileDialog は headless test が面倒でも採用する。LineEdit や fixed sample path が test しやすいという理由で残してはいけない。

Headless test は後から UI model / selection state / validation state を確認する形に作り直す。

### 1.6 Analog test はまだ保留

UI再編中に analog test を作ると、暫定UIを固定する力になる。今回のroadmapでも、新規 analog test 作成は行わない。

Analog test は、ユーザーが UI 印象の改善を確認し、明示的に指示した後に作る。

---

## 2. 現状の問題整理

### 2.1 Sample preset が主導線に近すぎる

現状では、以下のような sample / preset 導線が主UIに残っている。

- `Use Sample Tiles`
- sample atlas / sample catalog 説明
- target atlas presets
- generation distribution preset
- sample catalog keys を前提にした manual 説明

これらは学習用には有用だが、主導線にあると次の問題を起こす。

- ユーザーが自分の TileSet / Catalog / Object DB を選ぶ経路を見つけにくい。
- sample asset で動いたことを機能完成と誤認する。
- 実制作で必要な customization path が後回しになる。
- tests が sample asset 前提になり、project asset selection の穴を見逃す。

### 2.2 Workspace tabs が実体画面になり切っていない

前回評価の通り、Workspace には以下の tab がある。

```text
Document / Generate / Paint / Catalog / Layers / Validate / QA / Export
```

しかし現実には、多くの操作が `Generate` と `Paint` に寄っている。今回の asset selection 方針を入れるなら、各 tab は **asset slot を持つ first-class screen** になる必要がある。

例:

- `Document` tab: document resource / metadata / dependencies / dirty state
- `Catalog` tab: catalog resource / TileSet / entries / preview / validation
- `Layers` tab: layer stack resource / template / target root / apply policy
- `Paint` tab: brush asset / catalog key / object definition / label definition
- `Validate` tab: validation rules / target document / issue navigator
- `QA` tab: generation profile / validation suite / score table / promotion target
- `Export` tab: export profile / destination / package/runtime handoff
- `Settings` tab: sample mode / project defaults / debug options

### 2.3 Path text問題は改善したが、selection completeness がまだ課題

CLEAN UI で path text 入力はかなり減った。だが、asset選択UXの完了条件は「path textがない」だけでは足りない。

必要な状態:

```text
- 選択中Resourceが分かる
- 未選択状態が分かる
- 任意Resourceを選べる
- 新規Resourceを作れる
- 選択Resourceを開ける
- 選択Resourceをclearできる
- sampleを使う場合は学習modeとして明示される
- validation結果がasset slot単位で出る
```

### 2.4 Raw text / hidden fallback が残る

pathではないが、以下はまだ custom asset / game asset UX として弱い。

- Overlay item raw key
- Label ID raw text
- Object variant raw text
- Spawn condition raw text
- hidden numeric tile fallback
- adapter fallback behavior

これらも、「任意asset選択」または「typed definition selection」として整理する必要がある。

---

## 3. UX target model

### 3.1 Workspace structure

最終的な Workspace は以下にする。

```text
Hex Map Workspace
  Document
  Assets
    Tile Catalog
    Object Database
    Label Database
    Movement Profiles
  Generate
  Paint
  Objects / Labels / Zones
  Layers
  Validate
  QA / Seed Lab
  Export
  Settings / Samples
  Debug Report
```

Godot の dock UI 制約上、物理的には1つの dock + tabs でよい。重要なのは、ユーザー目的に対応した実体 component が存在することである。

### 3.2 Asset slot component

すべての Resource selection は共通の `AssetSlot` UI model を通す。

表示要素:

```text
Label: Tile Catalog
Current: res://project/maps/my_catalog.tres or Not selected
Type: HexTileCatalogResource
Status: Valid / Missing / Invalid type / Has warnings
Actions:
  Select...
  Create New...
  Clear
  Open
  Validate
  Use Project Default
  Learn With Sample  # sample mode ON の時だけ
```

内部model案:

```gdscript
class_name HexMapEditorAssetSlotState
extends RefCounted

var slot_id: String
var display_name: String
var required_type: StringName
var current_resource: Resource
var current_path: String
var is_required: bool
var validation_status: String
var validation_messages: Array[String]
var allows_create_new: bool
var allows_sample: bool
var sample_resource: Resource
var sample_label: String
```

UI component案:

```text
HexMapAssetSlotControl
HexMapAssetSlotRegistry
HexMapWorkspaceAssetContext
HexMapSamplePresetSettings
```

### 3.3 Project asset context

Workspace は「今この project / document で使う asset set」を持つ。

例:

```gdscript
class_name HexMapWorkspaceAssetContext
extends Resource

@export var level_document: HexMapDocumentResource
@export var tile_catalog: HexTileCatalogResource
@export var layer_stack: HexLayerStackResource
@export var object_database: HexObjectDatabaseResource
@export var label_database: HexLabelDatabaseResource
@export var movement_profile: HexMovementProfileResource
@export var validation_rule_suite: Resource
@export var generation_profile: Resource
```

この context は、各 tab が勝手に sample / default を探すのではなく、共通参照する。

### 3.4 Settings / Samples

Sample は `Settings / Samples` tab に隔離する。

Settings項目:

```text
[ ] Show bundled samples in main asset selectors
[ ] Use bundled sample assets for new scratch documents
[ ] Auto-create project copy when applying sample
Sample catalog: sample_hex_tile_catalog.tres  [Open] [Duplicate To Project]
Sample TileSet: sample_hex_tiles.png / embedded TileSet  [Open] [Duplicate To Project]
Sample Object Scene: sample_spawn_marker.tscn  [Open] [Duplicate To Project]
```

Default policy:

- `Show bundled samples in main asset selectors`: OFF
- `Use bundled sample assets for new scratch documents`: OFF
- First-run guide may show `Learn with bundled samples` CTA once.

### 3.5 Main tab policy

各 main tab は、sampleではなく project asset selection を主導線にする。

| Tab | 主asset selection | sampleの扱い |
|---|---|---|
| Document | Level Document | sample document は Settings / Samples から duplicate |
| Catalog | Tile Catalog / TileSet / PackedScene entries | sample catalog は learning asset |
| Layers | Layer Stack / target root | sample layer template は duplicateして使う |
| Paint | Catalog key / Object Definition / Label Definition | sample key は sample mode ON の時だけ候補 |
| Validate | Document / Validation Rule Suite | sample validation suite は learning mode |
| QA | Generation Profile / Validation Suite / Promotion Target | sample seed profile は learning mode |
| Export | Export Profile / Destination | sample export destination はなし |

---

## 4. Definition of Done

### 4.1 Asset selection DoD

任意asset選択を必要とする機能は、以下を満たすまで complete にしない。

```text
- Sample preset なしで利用できる。
- ユーザーが任意Resourceを選択できる。
- 新規Resource作成導線がある、または作成不要な理由が明記されている。
- 選択中assetが画面上で確認できる。
- asset type mismatch が validation で分かる。
- missing asset が sample fallback で隠れない。
- sample を使う経路は Settings / Samples または explicit Learn CTA に隔離されている。
- tests は sample-only success を feature complete と見なさない。
```

### 4.2 Workspace tab DoD

Workspace tab は以下を満たすまで complete にしない。

```text
- Tab が存在するだけでは不可。
- その tab の user goal に対応する実体 component が mount されている。
- Tab内の必須asset slot が見える。
- 未選択状態の説明と次の行動が見える。
- 他tabの長いscroll内に主機能が埋もれていない。
- tests は tab_has_component / asset_slot_state を確認する。
```

### 4.3 Sample preset DoD

Sample preset 機能は以下を満たす。

```text
- Settings / Samples にまとまっている。
- Main flow に silent auto-apply されない。
- ON/OFF がある。
- sample使用時に適用されるResourceが明示される。
- project copy / duplicate 導線がある。
- sample asset 自体は package integrity test で壊れていない。
```

---

## 5. Roadmap phases

```text
Phase A0: Asset selection policy reset
Phase A1: Asset slot inventory and state model
Phase A2: Settings / Samples separation
Phase A3: Workspace tab content migration
Phase A4: Screen-by-screen asset selection implementation
Phase A5: Raw text / fallback cleanup
Phase A6: Test contract rebuild
Phase A7: Manual update
Phase A8: Package / sample integrity
```

Analog test phase は入れない。ユーザー指示まで保留する。

---

## 6. Task queue

### Phase A0: Policy reset

#### `ASSET-00_ASSET_SELECTION_POLICY_RESET`

status: `READY`  
dependencies: none

目的:

- sample preset を主導線から外す方針を文書化する。
- 任意project asset selection が feature completion の必須条件であると明記する。

対象:

- `AGENTS.md`
- `docs/policy/DOMAIN_POLICY.md`
- `docs/policy/IMPLEMENTATION_POLICY.md`
- `docs/policy/TEST_DESIGN_POLICY.md`
- `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ROADMAP.md`

Acceptance:

- `sample-only prototype` という分類が定義される。
- `No sample-only completion` が policy に入る。
- headless test が sample preset success だけで feature complete としない方針が入る。
- analog test は保留と明記される。

#### `ASSET-01_ASSET_SLOT_INVENTORY`

status: `BACKLOG`  
dependencies: `ASSET-00_ASSET_SELECTION_POLICY_RESET`

目的:

- 現行UIの asset slots を棚卸しし、どこが sample / raw path / raw text / hidden fallback に依存しているかを整理する。

成果物:

- `docs/review/roadmap/ASSET_SLOT_INVENTORY_2026-06-07.md`

Inventory項目:

```text
slot_id
screen/tab
current UI
required asset type
current sample dependency
current arbitrary selection path
missing/invalid validation
main flow / sample flow / debug flow classification
cleanup task id
```

Acceptance:

- `Use Sample Tiles`、target atlas presets、sample catalog keys、distribution presets、object scene sample、manual sample references が分類される。
- 各slotに project asset selection があるかどうかが明記される。

---

### Phase A1: Asset slot model

#### `ASSET-10_ASSET_SLOT_STATE_MODEL`

status: `BACKLOG`  
dependencies: `ASSET-01_ASSET_SLOT_INVENTORY`

目的:

- Document / Catalog / Object DB / Label DB / Layer Stack / QA / Export の選択状態を統一する。

対象:

- 新規 `addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd`
- 新規 `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- 既存 `hex_map_resource_selector.gd` または相当component

Acceptance:

- `Not selected / Selected / Invalid / Warning` 状態を表現できる。
- Resource type mismatch を表現できる。
- sample option は state model 上で optional source として表現されるが、default source ではない。
- tests は state model を見る。具体的な LineEdit / Button node 名に依存しない。

#### `ASSET-11_WORKSPACE_ASSET_CONTEXT_RESOURCE`

status: `BACKLOG`  
dependencies: `ASSET-10_ASSET_SLOT_STATE_MODEL`

目的:

- Workspace全体で使う project asset set を一元管理する。

対象:

- 新規 `HexMapWorkspaceAssetContext`
- `HexMapEditorSessionState`
- `HexMapWorkspace`

Acceptance:

- Catalog / Object DB / Label DB / Layer Stack / Movement Profile / Validation Suite / Generation Profile を共通contextで保持できる。
- Generate / Paint / Validate / QA が同じ context を参照する。
- 各tabが独自に sample asset を探しに行かない。

#### `ASSET-12_CREATE_NEW_RESOURCE_ACTIONS`

status: `BACKLOG`  
dependencies: `ASSET-10_ASSET_SLOT_STATE_MODEL`

目的:

- 任意asset選択だけでなく、必要Resourceを新規作成する導線を提供する。

対象Resource:

- Level Document
- Tile Catalog
- Object Database
- Label Database
- Layer Stack
- Movement Profile
- Generation Profile / Validation Suite if implemented

Acceptance:

- Asset slot から `Create New...` が呼べる。
- 作成先は FileDialog / Save As で選ぶ。
- 作成後、その Resource が asset context に入る。
- sample asset は自動で作成対象に混ざらない。

---

### Phase A2: Settings / Samples separation

#### `SAMPLE-10_SAMPLE_MODE_SETTINGS_TAB`

status: `BACKLOG`  
dependencies: `ASSET-10_ASSET_SLOT_STATE_MODEL`

目的:

- sample preset / bundled assets を `Settings / Samples` tab へ隔離する。

対象:

- `HexMapWorkspace`
- 新規 `HexMapSampleSettingsPanel`
- sample catalog / sample tiles / sample scene references

UI:

```text
Settings / Samples
  [ ] Show bundled samples in asset selectors
  [ ] Use bundled sample assets for scratch documents
  [ ] Create project copies when applying samples

  Bundled Sample Catalog      [Open] [Duplicate To Project]
  Bundled Sample TileSet      [Open] [Duplicate To Project]
  Bundled Sample Object Scene [Open] [Duplicate To Project]
```

Acceptance:

- sample controls が Generate / Paint の主UIから外れる。
- sample mode OFF では main asset selectors に sample candidates が出ない。
- sample mode ON でも user-selected project asset が主である。
- tests は sample mode OFF/ON の selector source を確認する。

#### `SAMPLE-11_DUPLICATE_SAMPLE_TO_PROJECT`

status: `BACKLOG`  
dependencies: `SAMPLE-10_SAMPLE_MODE_SETTINGS_TAB`

目的:

- 学習用 sample から実制作assetへ移る導線を作る。

Acceptance:

- sample catalog を project path へ複製できる。
- sample scene / tile texture / embedded TileSet の依存が維持される。
- 複製後は project asset として asset context に入る。
- duplicate なしで sample を main project default に silent assign しない。

#### `SAMPLE-12_FIRST_RUN_LEARNING_CTA`

status: `BACKLOG`  
dependencies: `SAMPLE-10_SAMPLE_MODE_SETTINGS_TAB`

目的:

- 初回ユーザーに sample 学習導線を示す。ただし主導線にしない。

Acceptance:

- 初回のみ `Learn with bundled samples` CTA を表示できる。
- CTA は `Settings / Samples` に移動する。
- CTA を閉じると通常の project asset selection が表示される。

---

### Phase A3: Workspace tab content migration

#### `WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION`

status: `BACKLOG`  
dependencies: `ASSET-11_WORKSPACE_ASSET_CONTEXT_RESOURCE`

目的:

- 前回評価の最重要指摘である「タブ名だけでなく実体UIを載せる」を実施する。

移動方針:

| Tab | 移す内容 |
|---|---|
| Document | document asset slot, metadata, dependencies, dirty state, save/load |
| Catalog | catalog asset slot, TileSet slot, entry list, preview, entry validation |
| Layers | layer stack slot, target root, layer roles, create/apply/visibility |
| Paint | brush, terrain/object/label/zone painting only |
| Validate | validation rules, issue navigator, focus actions |
| QA | generation profile, batch runner, score table, promotion target |
| Export | export profile, destination, package/runtime handoff |
| Settings | sample mode, debug options, project defaults |

Acceptance:

- `Document / Catalog / Layers / Validate / QA / Export / Settings` tab が空でない。
- 各tabに asset slot がある。
- `Paint` tab から非Paint責務が減る。
- tests は `tab_has_component()` と `asset_slot_count()` を見る。

#### `WORKSPACE-11_TAB_COMPONENT_REGISTRY_CONTRACT`

status: `BACKLOG`  
dependencies: `WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION`

目的:

- headless test が private node 名ではなく、Workspace component registry contract を確認できるようにする。

Acceptance:

```text
workspace.tab_component_ids("Catalog") includes "catalog_asset_panel"
workspace.tab_component_ids("Validate") includes "validation_issue_navigator"
workspace.tab_asset_slot_ids("Catalog") includes "tile_catalog"
workspace.tab_asset_slot_ids("QA") includes "generation_profile"
```

---

### Phase A4: Screen-by-screen asset selection

#### `SCREEN-20_DOCUMENT_ASSET_SCREEN`

status: `BACKLOG`  
dependencies: `WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION`, `ASSET-12_CREATE_NEW_RESOURCE_ACTIONS`

目的:

- Document tab を project document の入口にする。

UI:

```text
Level Document [Select] [Create New] [Clear] [Open] [Save As] [Validate]
Metadata summary
Dependencies summary
Dirty / saved status
```

Acceptance:

- Document作成に sample が不要。
- sample document は Settings/Samples 経由のみ。
- dependencies は asset slots として見える。

#### `SCREEN-21_CATALOG_ASSET_SCREEN`

status: `BACKLOG`  
dependencies: `WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION`

目的:

- Catalog tab を asset identity の主画面にする。

UI:

```text
Tile Catalog [Select] [Create New] [Clear] [Open] [Validate]
TileSet      [Select] [Create New or Open TileSet Editor]
Entry List
Entry Detail
Tile Preview / Scene Preview
Missing / Warning badge
```

Acceptance:

- 任意 catalog と任意 TileSet を選べる。
- sample catalog がなくても catalog authoring ができる。
- sample catalog は sample mode ON の時だけ候補になる。
- Entry作成は TileSet / PackedScene 選択から行える。

#### `SCREEN-22_LAYER_STACK_ASSET_SCREEN`

status: `BACKLOG`  
dependencies: `WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION`

目的:

- Layer stack を target scene 操作ではなく asset / template として管理する。

UI:

```text
Layer Stack [Select] [Create New] [Clear]
Target Root [Pick from scene]
Roles: terrain / overlay / object / debug / collision / navigation
Actions: Create Layers / Apply Document / Clear / Validate
```

Acceptance:

- sample layer template がなくても作れる。
- Tactics/Roguelike等の template は sample/preset扱いで、duplicateしてproject assetにできる。

#### `SCREEN-23_OBJECT_LABEL_ASSET_SCREEN`

status: `BACKLOG`  
dependencies: `WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION`

目的:

- Object / Label authoring を raw text から asset selection にする。

UI:

```text
Object Database [Select] [Create New] [Open]
Object Definition List
PackedScene selector
Preview Texture selector
Variant list editor
Property schema editor

Label Database [Select] [Create New] [Open]
Label Definition List
```

Acceptance:

- object placement は object_id raw text ではなく Object Definition picker から行う。
- label placement は label id raw text ではなく Label Definition picker から行う。
- sample object scene は Settings/Samples へ。

#### `SCREEN-24_PAINT_BRUSH_ASSET_SCREEN`

status: `BACKLOG`  
dependencies: `SCREEN-21_CATALOG_ASSET_SCREEN`, `SCREEN-23_OBJECT_LABEL_ASSET_SCREEN`

目的:

- Paint tab を「現在のbrushでmapを編集する」画面に絞る。

UI:

```text
Mode: Terrain / Overlay / Object / Label / Zone
Brush shape
Current asset:
  Terrain: catalog key / tile preview
  Overlay: overlay definition / catalog key
  Object: object definition
  Label: label definition
  Zone: zone type
Selected cell summary
Last edit summary
```

Acceptance:

- source_id / atlas_coords は通常Paint画面に出ない。
- object/label raw ID 入力が通常Paint画面に出ない。
- asset 未選択時は `Select in Catalog/Object/Label tab` へのCTAを出す。

#### `SCREEN-25_VALIDATE_ASSET_SCREEN`

status: `BACKLOG`  
dependencies: `WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION`

目的:

- Validate tab が、document と asset dependencies を検査する画面になる。

UI:

```text
Target Document [from context]
Validation Rule Suite [Select] [Create New]
Run Validate
Issue Navigator
Fix suggestions
Focus target
```

Acceptance:

- missing user asset は sample fallback ではなく issue になる。
- issue は Document / Catalog / Object / Layer / QA のどこを直すべきか示す。

#### `SCREEN-26_QA_ASSET_SCREEN`

status: `BACKLOG`  
dependencies: `WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION`

目的:

- QA / Seed Lab の preset依存を、任意 Generation Profile と Validation Suite selection に置き換える。

UI:

```text
Generation Profile [Select] [Create New] [Duplicate Preset]
Validation Rule Suite [Select] [Create New]
Batch settings
Score table
Promotion target document
```

Acceptance:

- Built-in distribution preset だけでなく、custom generation profile を選べる。
- Preset は `Duplicate Preset...` で project asset 化できる。
- score table は selected profile / validation suite を明示する。

#### `SCREEN-27_EXPORT_ASSET_SCREEN`

status: `BACKLOG`  
dependencies: `WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION`

目的:

- Export tab を runtime / package / document output の整理画面にする。

UI:

```text
Export Profile [Select] [Create New]
Destination [Choose]
Runtime sample target
Package check
Dependency summary
```

Acceptance:

- Export destination は text input ではなく FileDialog / recent destinations。
- sample export は存在しない。ユーザー指定が必須。

---

### Phase A5: Raw text / fallback cleanup

#### `CLEANUP-30_DEBUG_NUMERIC_FALLBACK_QUARANTINE`

status: `BACKLOG`  
dependencies: `SCREEN-21_CATALOG_ASSET_SCREEN`, `SCREEN-24_PAINT_BRUSH_ASSET_SCREEN`

目的:

- numeric fallback を通常adapter / UIからさらに隔離する。

Acceptance:

- normal apply path は missing catalog を numeric fallback で黙って補わない。
- debug fallback は Settings / Debug で明示ONの時だけ。
- tests は missing catalog が validation issue になることを見る。

#### `CLEANUP-31_RAW_TEXT_AUTHORING_FIELD_REPLACEMENT`

status: `BACKLOG`  
dependencies: `SCREEN-23_OBJECT_LABEL_ASSET_SCREEN`, `SCREEN-24_PAINT_BRUSH_ASSET_SCREEN`

目的:

- raw text が authoring の主入力になっている field を typed selection へ置換する。

対象:

- Overlay item key
- Label ID
- Object variant
- Spawn condition
- Object property key/value

Acceptance:

- 各fieldに user asset / definition / enum / property schema の選択元がある。
- raw text は advanced/debug へ移すか削除する。

---

### Phase A6: Test contract rebuild

#### `TEST-40_NO_SAMPLE_ONLY_COMPLETION_TESTS`

status: `BACKLOG`  
dependencies: `ASSET-10_ASSET_SLOT_STATE_MODEL`

目的:

- sample asset だけで通るテストを feature complete の根拠にしない。

Acceptance:

- 各 feature screen test は sample mode OFF で任意 project asset selection state を確認する。
- sample mode ON/OFF の挙動を別にテストする。
- sample asset が packageとして壊れていないことは package integrity test の責務にする。

#### `TEST-41_WORKSPACE_TAB_CONTENT_CONTRACT_TESTS`

status: `BACKLOG`  
dependencies: `WORKSPACE-11_TAB_COMPONENT_REGISTRY_CONTRACT`

目的:

- 空タブを見逃さない。

Acceptance:

- 各tabの component ids と asset slot ids を確認する。
- private child node 名ではなく public-ish query method を使う。

#### `TEST-42_ASSET_SLOT_STATE_MODEL_TESTS`

status: `BACKLOG`  
dependencies: `ASSET-10_ASSET_SLOT_STATE_MODEL`

目的:

- Asset selection UI の意味を headless で確認する。

Acceptance:

- required asset missing
- invalid type
- selected project asset
- sample mode off hides sample
- sample mode on shows learning candidates
- duplicate sample creates project asset state

### Analog tests

作らない。ユーザー指示まで保留。

---

### Phase A7: Manual update

#### `DOC-50_ASSET_SELECTION_WORKFLOW_MANUAL`

status: `BACKLOG`  
dependencies: `SCREEN-20_DOCUMENT_ASSET_SCREEN`, `SCREEN-21_CATALOG_ASSET_SCREEN`, `SCREEN-23_OBJECT_LABEL_ASSET_SCREEN`, `SCREEN-26_QA_ASSET_SCREEN`

目的:

- manual を「sampleで試す」ではなく「project asset を選んで制作する」流れに更新する。

対象:

- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MANUAL_PACKAGE.md`
- `README.md`

Acceptance:

- 各章で任意asset選択が主導線になる。
- sample は `Learning with bundled samples` 章へ隔離される。
- `Use Sample Tiles` を通常setupとして説明しない。
- analog test は追加しない。

#### `DOC-51_SAMPLE_MODE_ONBOARDING_DOCS`

status: `BACKLOG`  
dependencies: `SAMPLE-10_SAMPLE_MODE_SETTINGS_TAB`, `SAMPLE-11_DUPLICATE_SAMPLE_TO_PROJECT`

目的:

- sample mode の役割を明確にする。

Acceptance:

- sample mode は learning / onboarding と明記される。
- production workflow は project asset selection と明記される。
- sample duplicate から project asset 化する流れを説明する。

---

### Phase A8: Package / sample integrity

#### `PKG-70_SAMPLE_AS_LEARNING_PACKAGE_CHECK`

status: `BACKLOG`  
dependencies: `SAMPLE-10_SAMPLE_MODE_SETTINGS_TAB`, `SAMPLE-11_DUPLICATE_SAMPLE_TO_PROJECT`

目的:

- bundled sample assets が learning path として壊れていないことを確認する。

Acceptance:

- sample catalog / sample tiles / sample scene が package に含まれる。
- sample mode ON で参照できる。
- sample mode OFF で main selectors に silent injection されない。

#### `PKG-71_PROJECT_ASSET_CLEAN_PACKAGE_CHECK`

status: `BACKLOG`  
dependencies: `DOC-50_ASSET_SELECTION_WORKFLOW_MANUAL`, `TEST-40_NO_SAMPLE_ONLY_COMPLETION_TESTS`

目的:

- 新規 project で sample に依存せず任意assetを設定できることを確認する。

Acceptance:

- plugin load
- new document create
- new catalog create
- user TileSet select
- user object scene select
- validation detects missing assets before selection
- package check passes

Analog操作確認はまだ作らない。

---

## 7. Autopilot prompt

Codex へ渡す標準指示:

```md
Read docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ROADMAP.md.

Goal:
Refine Hex Map Kit UI so every production feature has a user-selected project asset path. Sample presets are learning aids only and must not satisfy feature completion.

Principles:
- Game development UX rationality is the basis of UI/API design.
- Sample preset support is optional and must live in Settings/Samples or explicit onboarding.
- Main tabs must default to arbitrary project asset selection.
- Do not auto-assign bundled sample assets to hide missing user configuration.
- Do not preserve tests that force sample-only or old widget-shape UI.
- Do not create new analog tests until the user asks.

Task selection:
1. Start from ASSET-00.
2. Create/update plan files for the selected task if needed.
3. Implement the task.
4. Update tests only to confirm new UX state/model, not old widget shapes.
5. Run ./tools/test.sh if Godot is available.
6. If tests fail because they encode old sample/default behavior, rewrite them.
7. Update docs and queue status.
```

---

## 8. Priorities

### Immediate P0

1. `ASSET-00_ASSET_SELECTION_POLICY_RESET`
2. `ASSET-01_ASSET_SLOT_INVENTORY`
3. `ASSET-10_ASSET_SLOT_STATE_MODEL`
4. `ASSET-11_WORKSPACE_ASSET_CONTEXT_RESOURCE`
5. `SAMPLE-10_SAMPLE_MODE_SETTINGS_TAB`
6. `WORKSPACE-10_REAL_TAB_CONTENT_MIGRATION`

### P1

7. `SCREEN-20_DOCUMENT_ASSET_SCREEN`
8. `SCREEN-21_CATALOG_ASSET_SCREEN`
9. `SCREEN-23_OBJECT_LABEL_ASSET_SCREEN`
10. `SCREEN-24_PAINT_BRUSH_ASSET_SCREEN`
11. `SCREEN-25_VALIDATE_ASSET_SCREEN`
12. `SCREEN-26_QA_ASSET_SCREEN`

### P2

13. `CLEANUP-30_DEBUG_NUMERIC_FALLBACK_QUARANTINE`
14. `CLEANUP-31_RAW_TEXT_AUTHORING_FIELD_REPLACEMENT`
15. `TEST-40_NO_SAMPLE_ONLY_COMPLETION_TESTS`
16. `TEST-41_WORKSPACE_TAB_CONTENT_CONTRACT_TESTS`
17. `DOC-50_ASSET_SELECTION_WORKFLOW_MANUAL`
18. `PKG-70_SAMPLE_AS_LEARNING_PACKAGE_CHECK`

---

## 9. Acceptance summary

このroadmapの成功状態:

```text
Asset selection:
  - すべてのproduction機能に任意project asset選択導線がある
  - sample presetなしで機能が使える
  - 未選択状態が明確で、次の行動が分かる

Sample presets:
  - Settings / Samples に隔離されている
  - ON/OFFがある
  - Learn / Duplicate To Project の導線になる
  - sample-onlyで実装済み扱いにしない

Workspace:
  - 各tabが実体componentとasset slotsを持つ
  - Paint/Generateに多責務が集まり続けない
  - Catalog / Layers / Validate / QA / Export が発見可能

Tests:
  - sample mode OFF の production asset selection を確認する
  - sample mode ON は別テスト
  - old widget shapeやsample-only successを守らない
  - analog test はまだ追加されない

Docs:
  - project asset workflow が主
  - sampleはlearning/onboarding章
  - manualは実際のWorkspace tabと一致する
```

---

## 10. 最終結論

CLEAN UI 実行で、path text と v1/v2 compatibility の大きな問題はかなり整理された。次の問題は、**sample preset や暫定defaultで動くことを、ゲーム開発者のproduction workflowと混同してしまうこと**である。

今後のUI改修では、sampleを排除するのではなく、役割を正しく下げる。

```text
sample preset = learning / onboarding / demo
project asset selection = production workflow / main UX
```

この分離ができれば、Workspace tab の実体化、Catalog editor、Object/Label authoring、QA screen、Export screen は、いずれも「ユーザーが自分のassetで制作する」流れとして成立する。

逆に、この分離をしないまま screen を増やすと、sample asset で動くが実制作でカスタマイズしにくい UI が増え、UX品質は下がる。

したがって、次の最初の一手は `ASSET-00` と `ASSET-01` で方針と棚卸しを固定し、その後 `ASSET-10` / `SAMPLE-10` / `WORKSPACE-10` に進むのがよい。
