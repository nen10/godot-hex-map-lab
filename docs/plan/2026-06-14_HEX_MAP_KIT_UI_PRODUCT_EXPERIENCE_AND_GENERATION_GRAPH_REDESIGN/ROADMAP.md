# Hex Map Kit UI Product Experience / Generation Graph Redesign Roadmap 2026-06-14

作成日: 2026-06-14  
対象: `godot-hex-map-lab-20260614-232609.zip`  
前提roadmap: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ROADMAP.md`  
前提feedback: ユーザー実行による first impression feedback 2026-06-14  
目的: layout metrics / component extraction / queue completion ではなく、ユーザーが dock を開いた瞬間に「この addon でゲーム用hex mapを作りたい」と思える UI へ再設計する。特に、Resourceラベル過多、tab意味不明、生成中間レイヤー/フィルター連鎖の導線欠落、ノードグラフ型生成エディター不在を解消する。

---

## 0. 重大判断

今回の `UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP` 実行は、queue上は完了していても、ユーザー視点の画面体験を改善できなかった。

この状態を次のように扱う。

```text
Process success ≠ Product UX success
Metric pass ≠ Layout design success
Component exists ≠ User can understand the screen
Tab exists ≠ Workflow exists
Resource row exists ≠ Game development path exists
Generation result resource exists ≠ Pipeline editor exists
```

したがって、次のroadmapでは **UI metricsを主目標にしない**。Metrics は回帰検知の補助に下げる。主目標は、以下の3つである。

1. **画面を見て意味が分かること**
2. **作業したくなる主画面があること**
3. **中間生成レイヤーを連鎖させて本当に使うレイヤーを作る導線があること**

---

## 1. 今回の失敗原因

### 1.1 ラベルを減らすはずが、意味のないラベル群になった

現状の多くのtabは、Resourceや状態を説明する `Label` が並ぶ。だが、ゲーム開発者が欲しいのは説明文ではなく、次のどちらかである。

- 作業できる画面
- 何を作っているか分かる視覚的な状態

悪い例:

```text
Resources Context Panel
Selected HexTileMap Resources
Readiness Summary
Shared resources: ...
Next actions: ...
```

良い例:

```text
Map: Dungeon_01        Status: Draft / Unsaved
[Generate from Pipeline] [Paint] [Validate]

Missing for this map:
  Level Document  [Create]
  Tile Catalog    [Choose]
```

ラベルはUIを成立させるための構造ではない。ラベルは、ユーザー行動を補助する最小単位に限定する。

### 1.2 Tabの意味が作業目的になっていない

現在のtabは `Resources / Generate / Paint / Catalog / Layers / Validate / QA / Export / Settings` のように分かれているが、多くのtabが Resource参照や状態メモになっている。

ユーザーにとって重要なのは、tab名ではなく以下である。

```text
今どのmapを作っているか
何を生成するか
どの中間データを使うか
どのレイヤーへ反映するか
どこを手で編集するか
何が壊れているか
どうruntimeへ渡すか
```

### 1.3 Generate pipeline graph が実装対象から外れた

ユーザーが求めていたのは、単発の生成設定や結果Resourceではない。

求めている導線:

```text
中間フィルター座標 / mask / primary / overlay を生成
  -> それを次の生成passの入力にする
    -> 複数passを連鎖させる
      -> 最終的に本当に使う terrain / overlay / object layer を作る
        -> Document / Layer Stack へ promote/apply する
```

この導線は、単なる `GenerationResultResource` や replay API だけでは実現できない。**Graph / Pipeline editor が必要**である。

### 1.4 Resource-first になりすぎた

Resource選択は必要だが、画面の先頭に Resource row が並ぶと、ユーザーは「ゲームのmapを作る画面」ではなく「設定ファイル管理画面」と感じる。

Resourceは主役ではない。主役は以下である。

- map preview
- generation graph
- paint brush
- layer stack visual
- issue navigator
- seed comparison

Resourceは、必要に応じて右側drawer / top context chip / collapsed Resources shelf に下げる。

### 1.5 Metrics-driven UI がUXを改善しなかった

label count、scroll、component ownership、layout snapshot は補助として有用である。ただし、これらを満たしても「楽しい」「分かる」「作業したい」には届かない。

今後は、metrics gate より先に **layout concept / wireframe / screen intent** を作る。

---

## 2. 新しいUI設計原則

### 2.1 Visual work surface first

各主要tabは、先頭に作業面を持つ。

| Tab | 主役にするもの | Resourceの位置 |
|---|---|---|
| Build | Generation graph / map preview | 右drawer / context chips |
| Paint | Brush toolbar / selected layer / viewport edit status | drawer |
| Catalog | tile preview grid / entry cards | top context |
| Layers | role stack visual tree | top context |
| Check | validation issue board / map focus | context chips |
| Export | export purpose cards | destination drawer |
| Resources | selected HexTileMap / document / shared asset overview | ここだけ主役でよい |
| Settings | samples / debug / preferences | ここだけ設定主役でよい |

### 2.2 Important tabs must be visually distinguished

すべてのtabを同列に並べると、重要度が分からない。

推奨構造:

```text
Primary tabs:
  Build
  Paint
  Check

Secondary tabs:
  Catalog
  Layers
  Resources

Utility tabs:
  Export
  Settings
```

Godotの標準TabContainerでグループ表示が難しい場合でも、tab内の first screen / workspace home / command strip で重要度を見せる。

### 2.3 Resources are context, not the whole product

Resources tabは必要。ただし、他tabの先頭に Resource row を大量に並べない。

各tab先頭の表示は、次のような context chip にする。

```text
Map: Dungeon_01   Catalog: tactical_basic   Target: HexTileMapLayer
```

詳細選択や作成は `Resources` drawer / tab に送る。

### 2.4 Empty state must invite action

未設定状態は説明ラベルを並べるのではなく、次の行動を示す。

悪い:

```text
No Level Document.
Tile Catalog: Not selected.
Layer Stack: Not selected.
Object Database: Not selected.
...
```

良い:

```text
Start a map
[Create Level Document]
[Choose Tile Catalog]
[Open sample as tutorial]
```

### 2.5 Label budget is qualitative, not numeric

label数だけを数えても意味がない。

許されるlabel:

- heading
- primary actionの説明
- selected target chip
- warning / error
- tooltipに逃がせない短いstatus

避けるlabel:

- Resourceの型説明
- policy説明
- debug state
- implementation ownership
- queue/test由来の内部語彙
- user actionに直結しない readiness summary

### 2.6 Generation pipeline graph is first-class

生成機能は、次の2層に分ける。

```text
Simple Build:
  初心者/単発生成用。Profileを選んでGenerate。

Pipeline Graph:
  中間生成レイヤー / filter / mask / overlay / object placement を連鎖させる。
```

今回のユーザー要求は Pipeline Graph に属する。これは後回しの研究ではなく、UI価値の中心である。

---

## 3. 推奨する新しいWorkspace IA

### 3.1 タブ案

現在のタブ群を、作業目的が見える形に再設計する。

```text
Build       # Generate + Pipeline Graph + Preview
Paint       # Direct edit / brush / cell edit
Check       # Validate + QA summary
Catalog     # Tile/Object visual catalog editor
Layers      # Layer stack / roles / visibility
Resources   # Selected HexTileMap + asset context
Export      # Runtime handoff / package/debug export
Settings    # Samples / debug / preferences
```

`QA` は standalone tab ではなく、`Build` の seed比較 / `Check` の品質評価として分割する案を推奨する。`Validate` も単独tab名ではなく `Check` の方がユーザーに伝わりやすい。

### 3.2 Layout sketch: Build tab

```text
┌──────────────────────────────────────────────────────────────┐
│ Build Map: Dungeon_01                              [Generate] │
├──────────────────────────────────────────────────────────────┤
│ Pipeline Graph                                  │ Preview     │
│                                                │             │
│ [Shape] -> [Primary Terrain] -> [Room Mask]    │   map view   │
│                    │                           │             │
│                    v                           │             │
│              [Treasure Overlay] -> [Validate]  │             │
│                                                │             │
├────────────────────────────────────────────────┴─────────────┤
│ Selected node: Room Mask                                      │
│ Inputs: Primary Terrain                                       │
│ Outputs: mask.rooms                                           │
│ [Promote output to Layer] [Use as Filter Input]                │
└──────────────────────────────────────────────────────────────┘
```

### 3.3 Layout sketch: Paint tab

```text
┌──────────────────────────────────────────────────────────────┐
│ Paint: Terrain layer       Brush: Floor     Cell: q=2 r=-1   │
├──────────────────────────────────────────────────────────────┤
│ [Terrain] [Overlay] [Object] [Label] [Zone]                  │
│ Brush palette:  floor  wall  water  door  treasure           │
│ Shape: single / line / disc / flood                          │
│                                                              │
│ Last edit: painted 12 cells on Terrain                       │
└──────────────────────────────────────────────────────────────┘
```

### 3.4 Layout sketch: Check tab

```text
┌──────────────────────────────────────────────────────────────┐
│ Check Map: 3 errors, 7 warnings                    [Run Check]│
├──────────────────────────────────────────────────────────────┤
│ Errors                                                       │
│  ● Missing catalog entry: overlay.secret_door    [Open Catalog]│
│  ● Spawn unreachable from exit                   [Show Path]   │
│                                                              │
│ Warnings                                                     │
│  ○ QA score low: branch_count                                │
└──────────────────────────────────────────────────────────────┘
```

### 3.5 Layout sketch: Resources tab

```text
┌──────────────────────────────────────────────────────────────┐
│ Selected HexTileMap: Dungeon_01                              │
│ [Create Missing Map Resources] [Save All]                    │
├──────────────────────────────────────────────────────────────┤
│ Unique to this map                                           │
│  Level Document      dungeon_01_document.tres                │
│  Layer Stack         dungeon_01_layers.tres                  │
│                                                              │
│ Shared project assets                                        │
│  Tile Catalog        tactical_basic_catalog.tres             │
│  Object Database     dungeon_objects.tres                    │
│                                                              │
│ Optional                                                    │
│  Generation Profile  not selected                           │
└──────────────────────────────────────────────────────────────┘
```

---

## 4. Generation Pipeline Graph MVP

### 4.1 目的

中間フィルター座標や中間生成レイヤーを作り、それを次の生成処理へ入力できるようにする。

これは `Generate` の副機能ではなく、**Build tab の中心機能**である。

### 4.2 Core concept

```text
Pipeline Graph
  Node = generation pass / filter / transform / validation / promote
  Edge = output layer/selection/mask/result -> input port
  Output = intermediate layer or final document layer
```

### 4.3 Node types

MVPで扱う node:

| Node | 役割 | Output |
|---|---|---|
| Shape | map bounds / orientation / base cells | cells |
| Primary Terrain | floor/wall/base terrain生成 | primary layer |
| Region Filter | 条件に合うcell集合を作る | mask / selection |
| Overlay Generator | maskに対してoverlay候補を生成 | overlay layer |
| Object Placement | mask/terrainに対してobject配置 | object placements |
| Validate | input結果を検査 | validation result |
| Promote | intermediate outputをLevel Documentへ反映 | document layer |

### 4.4 Intermediate output model

```text
HexGenerationGraphResource
HexGenerationNodeResource
HexGenerationPortResource
HexGenerationEdgeResource
HexIntermediateMapLayerResource
HexCellSelectionResource
HexGenerationGraphResultResource
```

ただし、MVPでは全Resourceを一気に作らない。最初は graph model と UI affordance を優先し、内部は Dictionary / existing result objects でもよい。公開APIへ出す前に Resource 化する。

### 4.5 User flow

```text
1. Build tabを開く。
2. Shape node を作る。
3. Primary Terrain node をつなぐ。
4. Region Filter node で「floor cells only」や「distance from spawn」などを作る。
5. Overlay Generator node に Filter output をつなぐ。
6. Previewで中間結果を見る。
7. Promote nodeで本当に使う overlay layer へ反映する。
8. Documentに保存する。
```

### 4.6 Graph UI MVP

Godot `GraphEdit` / `GraphNode` を使うかは実装調査で決める。ただし、UI要件は固定する。

```text
- Node palette
- Graph canvas
- Selected node inspector
- Output preview
- Promote output action
- Run selected node
- Run graph
- Dirty / last run status
```

### 4.7 Acceptance

```text
- Build tabに graph canvas が存在する。
- 少なくとも3 node chainを作れる。
- 中間outputを選択してpreviewできる。
- 中間outputを次node inputへ使える。
- 中間outputをfinal document layerへpromoteできる。
- これができない限り、Generation Pipeline Graphは COMPLETE にしない。
```

---

## 5. Roadmap phases

```text
X0. UX reset / failure adoption
X1. Screen design before implementation
X2. Navigation / tab information architecture
X3. Label purge / visual surface redesign
X4. Build tab / Generation pipeline graph MVP
X5. Paint / Catalog / Layers / Check screen redesign
X6. Resources as context shelf
X7. Process guard against metric-only completion
X8. Implementation proof / manual update
```

---

## 6. Task queue

### Phase X0: UX reset / failure adoption

#### `UXR-00_ADOPT_USER_FAILURE_FEEDBACK`

status: `READY`  
dependencies: none

目的:

- `UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP` は queue完了でもユーザー体験改善に失敗したと明記する。
- metrics-only completion を禁止する。
- Generation graph を first-class requirement に昇格する。

成果物:

- `docs/plan/2026-06-14_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ROADMAP.md`
- `docs/review/roadmap/UI_LAYOUT_METRICS_FAILURE_REVIEW_2026-06-14.md`

Acceptance:

- `Process success != Product UX success` がpolicy化される。
- Generation pipeline graph が backlog ではなく active roadmap に入る。
- Label-heavy tabs are unacceptable と明記される。

#### `UXR-01_CURRENT_SCREEN_FIRST_IMPRESSION_AUDIT`

status: `BACKLOG`  
dependencies: `UXR-00_ADOPT_USER_FAILURE_FEEDBACK`

目的:

- 現在の各tabを、内部componentではなく first impression で評価する。

評価項目:

```text
tab
first visible thing
primary action visible within 3 seconds
label density impression
visual work surface exists
resource rows before work surface count
unclear labels
fun / not fun note
what user wants to do next
```

Acceptance:

- 各tabの「なぜつらいか」がユーザー語彙で書かれる。
- component ownershipやtest名ではなく、画面体験で評価される。

---

### Phase X1: Screen design before implementation

#### `DESIGN-10_WORKSPACE_WIREFRAMES_BEFORE_CODE`

status: `BACKLOG`  
dependencies: `UXR-01_CURRENT_SCREEN_FIRST_IMPRESSION_AUDIT`

目的:

- 実装前に Build / Paint / Check / Catalog / Layers / Resources / Export / Settings の wireframe を作る。

成果物:

- `docs/plan/<date>_WORKSPACE_WIREFRAMES/WIREFRAMES.md`

Acceptance:

- 各画面に ASCII wireframe がある。
- 各画面で Resource row がどこに退くかが明記される。
- 各画面に primary visual surface がある。
- wireframeがない画面実装taskを作らない。

#### `DESIGN-11_TAB_PRIORITY_AND_DEPENDENCY_MAP`

status: `BACKLOG`  
dependencies: `DESIGN-10_WORKSPACE_WIREFRAMES_BEFORE_CODE`

目的:

- 重要tab / 補助tab / utility tab を整理し、tab間の作業依存関係を画面に出す。

Acceptance:

- Primary / Secondary / Utility tab 分類がある。
- `Build -> Paint -> Check -> Export` の主導線が見える。
- `Catalog / Layers / Resources` は支援面として位置づけられる。
- Workspace home / top strip に現在の進行状態が出る。

#### `DESIGN-12_VISUAL_LANGUAGE_GUIDE`

status: `BACKLOG`  
dependencies: `DESIGN-10_WORKSPACE_WIREFRAMES_BEFORE_CODE`

目的:

- 楽しくないラベルUIから、カード・チップ・プレビュー・ステータスバッジ中心のUIへ移す。

Acceptance:

- Heading / chip / card / badge / warning / tooltip の使用ルールがある。
- `readiness summary label` のような内部説明を禁止する。
- Resource type説明はtooltipへ移す。
- primary action button の配置ルールがある。

---

### Phase X2: Navigation / tab information architecture

#### `NAV-20_RENAME_AND_REORDER_TABS`

status: `BACKLOG`  
dependencies: `DESIGN-11_TAB_PRIORITY_AND_DEPENDENCY_MAP`

推奨:

```text
Build
Paint
Check
Catalog
Layers
Resources
Export
Settings
```

Acceptance:

- `Generate` は `Build` へ改名、または Build concept を上位に置く。
- `Validate` と `QA` は `Check` へ統合する案を実装判断する。
- 重要tabが前に来る。
- tab間の依存関係が top strip / workspace home に表示される。

#### `NAV-21_WORKSPACE_HOME_OR_TOP_STRIP`

status: `BACKLOG`  
dependencies: `NAV-20_RENAME_AND_REORDER_TABS`

目的:

- どこから始めればいいか分からない問題を解消する。

UI:

```text
Map: Dungeon_01   Step: Build → Paint → Check → Export
Missing: Tile Catalog
[Create Pipeline] [Paint Terrain] [Run Check]
```

Acceptance:

- 全tab共通の context strip がある。
- Resource一覧ではなく、作業ステップが見える。
- 未設定時に行動CTAが出る。

---

### Phase X3: Label purge / visual surface redesign

#### `VIS-30_LABEL_PURGE_PASS`

status: `BACKLOG`  
dependencies: `DESIGN-12_VISUAL_LANGUAGE_GUIDE`

目的:

- 見ていて楽しくないラベル群を削除し、カード / チップ / preview / action へ置換する。

対象:

- Resources tab
- Catalog tab
- Layers tab
- Check tab
- Export tab
- Settings tab

Acceptance:

- 先頭にラベルだけが3行以上並ぶtabがない。
- `status summary` は chip / badge / compact card に置換される。
- 内部用語はdebug drawerに退く。
- tabを開いた最初の画面に、作業面またはCTAがある。

#### `VIS-31_RESOURCE_ROWS_TO_CONTEXT_DRAWER`

status: `BACKLOG`  
dependencies: `VIS-30_LABEL_PURGE_PASS`

目的:

- Resource row を各tabの主役から外す。

Acceptance:

- Work tab の先頭は Resource row ではない。
- Resource詳細は drawer / Resources tab / context chips に移る。
- Resource未設定はCTAとして出る。

---

### Phase X4: Build tab / Generation pipeline graph MVP

#### `GRAPH-40_GENERATION_GRAPH_PRODUCT_DECISION`

status: `BACKLOG`  
dependencies: `DESIGN-10_WORKSPACE_WIREFRAMES_BEFORE_CODE`

目的:

- GraphEditを使うか、簡易node boardから始めるかを決める。

候補:

| 案 | 内容 | 評価 |
|---|---|---|
| A | Godot GraphEdit / GraphNode | 本命。ノードグラフとして自然。 |
| B | Linear pass stack + input dropdown | 実装容易だが、連鎖理解が弱い。 |
| C | Card board with edges drawn later | 中間案。 |

推奨:

- Aを採用する。ただし最初は node数とport種別を限定する。

Acceptance:

- 採用案と却下案が明記される。
- MVP node types が固定される。
- UI wireframe がある。

#### `GRAPH-41_GENERATION_GRAPH_MODEL_MVP`

status: `BACKLOG`  
dependencies: `GRAPH-40_GENERATION_GRAPH_PRODUCT_DECISION`

目的:

- 中間生成outputを扱う graph model を作る。

MVP model:

```text
Graph
Node
Port
Edge
Intermediate Output
Run Result
Promote Target
```

Acceptance:

- node output を別node inputへ接続できる。
- output type が `cells / mask / primary_layer / overlay_layer / object_candidates / validation_result` で区別される。
- invalid edge を validation できる。

#### `GRAPH-42_BUILD_TAB_GRAPH_CANVAS`

status: `BACKLOG`  
dependencies: `GRAPH-41_GENERATION_GRAPH_MODEL_MVP`

目的:

- Build tab に graph canvas を表示する。

Acceptance:

- Build tab の主画面が graph canvas になる。
- Node palette がある。
- Selected node inspector がある。
- Output preview がある。
- Resource row が主役ではない。

#### `GRAPH-43_THREE_NODE_FILTER_CHAIN_MVP`

status: `BACKLOG`  
dependencies: `GRAPH-42_BUILD_TAB_GRAPH_CANVAS`

目的:

- ユーザー要望の「中間フィルター座標を使って本当に使いたいレイヤーを生成する」をMVPで実現する。

MVP chain:

```text
Primary Terrain
  -> Region Filter
    -> Overlay Generator
      -> Promote to Document Overlay Layer
```

Acceptance:

- Region Filter の output を Overlay Generator の input にできる。
- Region Filter output を preview できる。
- Overlay output を Document overlay layer へ promote できる。
- このflowができるまで Graph機能は COMPLETE にしない。

#### `GRAPH-44_GRAPH_RUN_AND_PREVIEW_STATUS`

status: `BACKLOG`  
dependencies: `GRAPH-43_THREE_NODE_FILTER_CHAIN_MVP`

目的:

- Run selected node / Run graph / dirty / invalid / last output を見えるようにする。

Acceptance:

- 実行状態が見える。
- 失敗時にどのnodeが悪いか分かる。
- 中間previewとfinal document applyの違いが分かる。

---

### Phase X5: Paint / Catalog / Layers / Check screen redesign

#### `SCREEN-50_PAINT_AS_BRUSH_WORKSPACE`

status: `BACKLOG`  
dependencies: `NAV-21_WORKSPACE_HOME_OR_TOP_STRIP`

目的:

- Paint tab を Resource参照ではなく、編集作業面にする。

Acceptance:

- Brush palette がある。
- Active layer / selected cell / brush shape / last edit が見える。
- 2D viewport編集とtab状態が同期する。
- Paint tab先頭に Resource row が並ばない。

#### `SCREEN-51_CATALOG_AS_VISUAL_ASSET_BOARD`

status: `BACKLOG`  
dependencies: `VIS-31_RESOURCE_ROWS_TO_CONTEXT_DRAWER`

目的:

- Catalog tab を tile/objectの視覚的なboardにする。

Acceptance:

- Tile preview grid / entry cards が主役。
- missing entry は warning badge。
- raw source_id / atlas_coords は通常表示しない。
- sample catalog は tutorial source として分離。

#### `SCREEN-52_LAYERS_AS_STACK_VISUAL`

status: `BACKLOG`  
dependencies: `VIS-31_RESOURCE_ROWS_TO_CONTEXT_DRAWER`

目的:

- Layers tab を role stack の可視化にする。

Acceptance:

- terrain / overlay / object / debug roles が視覚的に並ぶ。
- writable source / visibility / lock がchipやtoggleで分かる。
- Documentとtarget sceneの関係が見える。

#### `SCREEN-53_CHECK_AS_ISSUE_BOARD`

status: `BACKLOG`  
dependencies: `NAV-20_RENAME_AND_REORDER_TABS`

目的:

- Validate / QA を、問題発見と品質判断のboardにする。

Acceptance:

- Error / Warning / Score がカード/リストで見える。
- Issue clickで対象tab/cell/resourceへ移動する。
- QA seed score は Build/Check のどちらに属するか整理される。

#### `SCREEN-54_EXPORT_AS_PURPOSE_CARDS`

status: `BACKLOG`  
dependencies: `NAV-21_WORKSPACE_HOME_OR_TOP_STRIP`

目的:

- Exportが何を何のために行うかをカードで見せる。

Cards:

```text
Runtime Handoff
Debug Report
JSON Snapshot
Package Build (process-only if still not editor feature)
```

Acceptance:

- Export destinationだけが表示される画面ではない。
- 目的から選べる。
- 未実装カードは出さないか、disabled + tooltip。

---

### Phase X6: Resources as context shelf

#### `RESCTX-60_RESOURCES_TAB_REDESIGN`

status: `BACKLOG`  
dependencies: `VIS-31_RESOURCE_ROWS_TO_CONTEXT_DRAWER`

目的:

- Resources tabを「Resourceラベル一覧」ではなく「選択中mapの資産棚」にする。

Acceptance:

- Unique / Shared / Optional がカードで分かれる。
- `Create missing resources` は大きいCTA。
- 選択中HexTileMapが分かる。
- 他tabのResource詳細をここへ逃がせる。

#### `RESCTX-61_CONTEXT_CHIPS_FOR_ALL_WORK_TABS`

status: `BACKLOG`  
dependencies: `RESCTX-60_RESOURCES_TAB_REDESIGN`

目的:

- Work tab先頭には詳細Resource rowではなく context chip を出す。

例:

```text
Map: Dungeon_01  Catalog: tactical_basic  Layer: Terrain
```

Acceptance:

- Build/Paint/Check/Catalog/Layers/Export が compact context chip を持つ。
- 詳細はResourcesへリンクする。

---

### Phase X7: Process guard against metric-only completion

#### `PROCESS-70_PRODUCT_UX_PROOF_REQUIRED`

status: `BACKLOG`  
dependencies: `UXR-00_ADOPT_USER_FAILURE_FEEDBACK`

目的:

- UI task は metric/testだけでは完了できないようにする。

Acceptance:

- C4/C5 UI task は `SCREEN_INTENT.md` または `WIREFRAME.md` 必須。
- self-review に `What user sees first` が必須。
- `Label-heavy but metrics pass` は complete不可。

#### `PROCESS-71_LAYOUT_ACCEPTANCE_REPLACES_LABEL_METRICS`

status: `BACKLOG`  
dependencies: `PROCESS-70_PRODUCT_UX_PROOF_REQUIRED`

目的:

- label count metricsを補助へ下げ、画面構造DoDを主にする。

Acceptance:

- Work surface / primary action / context chips / visual preview の有無が評価される。
- label count はwarningであり、合格根拠にしない。

---

### Phase X8: Manual / final packaging

#### `DOC-80_WORKFLOW_MANUAL_AFTER_SCREEN_REDESIGN`

status: `BACKLOG`  
dependencies: `GRAPH-43_THREE_NODE_FILTER_CHAIN_MVP`, `SCREEN-50_PAINT_AS_BRUSH_WORKSPACE`, `SCREEN-53_CHECK_AS_ISSUE_BOARD`

目的:

- manualを新しい作業導線に合わせる。

Acceptance:

- Build graph -> promote layer -> Paint -> Check -> Export の手順がある。
- Resource設定一覧ではなく、作業目的ベース。
- analog test はまだ作らない。

#### `PROC-90_FINAL_DIST_REGENERATION`

status: `BACKLOG`  
dependencies: `DOC-80_WORKFLOW_MANUAL_AFTER_SCREEN_REDESIGN`

目的:

- 最終段でdist再生成する。

Acceptance:

- 通常test gateにはしない。
- process final stepとして実施する。

---

## 7. 実行順

最優先:

```text
1. UXR-00_ADOPT_USER_FAILURE_FEEDBACK
2. UXR-01_CURRENT_SCREEN_FIRST_IMPRESSION_AUDIT
3. DESIGN-10_WORKSPACE_WIREFRAMES_BEFORE_CODE
4. DESIGN-11_TAB_PRIORITY_AND_DEPENDENCY_MAP
5. DESIGN-12_VISUAL_LANGUAGE_GUIDE
6. NAV-20_RENAME_AND_REORDER_TABS
7. NAV-21_WORKSPACE_HOME_OR_TOP_STRIP
8. GRAPH-40_GENERATION_GRAPH_PRODUCT_DECISION
9. GRAPH-41_GENERATION_GRAPH_MODEL_MVP
10. GRAPH-42_BUILD_TAB_GRAPH_CANVAS
11. GRAPH-43_THREE_NODE_FILTER_CHAIN_MVP
```

その後:

```text
12. VIS-30_LABEL_PURGE_PASS
13. VIS-31_RESOURCE_ROWS_TO_CONTEXT_DRAWER
14. SCREEN-50_PAINT_AS_BRUSH_WORKSPACE
15. SCREEN-51_CATALOG_AS_VISUAL_ASSET_BOARD
16. SCREEN-52_LAYERS_AS_STACK_VISUAL
17. SCREEN-53_CHECK_AS_ISSUE_BOARD
18. SCREEN-54_EXPORT_AS_PURPOSE_CARDS
19. RESCTX-60_RESOURCES_TAB_REDESIGN
20. RESCTX-61_CONTEXT_CHIPS_FOR_ALL_WORK_TABS
21. PROCESS-70_PRODUCT_UX_PROOF_REQUIRED
22. DOC-80_WORKFLOW_MANUAL_AFTER_SCREEN_REDESIGN
23. PROC-90_FINAL_DIST_REGENERATION
```

---

## 8. Completion definition

このroadmapは、以下を満たすまで完了ではない。

```text
Visual:
  - tabを開いた先頭に意味不明なlabel列がない
  - primary visual work surface がある
  - Resource row は主役ではない
  - 重要tabと補助tabの違いが分かる

Generation graph:
  - 中間filter/mask/outputを作れる
  - 中間outputを次node inputへつなげる
  - Promoteして本当に使うlayerを生成できる

Workflow:
  - Build -> Paint -> Check -> Export の主導線が見える
  - Catalog / Layers / Resources が支援画面として分かる
  - tab間依存が top strip / home で分かる

Process:
  - UI metricsだけでCompleteにしない
  - wireframeなしにscreen実装へ入らない
  - analog test はまだ作らない
```

---

## 9. Codex prompt

```md
Read docs/plan/2026-06-14_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ROADMAP.md.

Goal:
Recover from the previous metric-complete but user-failed UI roadmap. Prioritize visible product UX, not internal component completion.

Rules:
- Do not mark UI work complete because metrics or tests pass.
- Do not create more label-heavy tabs.
- Do not put Resource rows before the main work surface in work tabs.
- Build tab must move toward a generation pipeline graph where intermediate outputs can feed later nodes.
- Create wireframes before code for screen redesign tasks.
- Treat Generation Pipeline Graph as active roadmap, not research-only backlog.
- Analog tests remain deferred.

Done for a UI task:
- It has a screen intent.
- It has a wireframe or updated visual layout description.
- It has a primary visual work surface.
- It has a primary action.
- It does not rely on labels to explain itself.
```

---

## 10. 最終結論

前回のroadmapは、内部的には多くの部品を作った。しかし、ユーザーがdockを開いた瞬間の体験は改善しなかった。

次のroadmapでは、以下を最優先にする。

```text
- 楽しくないラベル画面をやめる
- 何をするtabなのか一目で分かるようにする
- Build tab に generation pipeline graph を置く
- 中間filter/mask/layer を連鎖して最終レイヤーを作る導線を作る
- Resourceは主役ではなくcontextへ下げる
- UI metricsを合格根拠にしない
```

この切り替えをしない限り、queueをどれだけ完了しても、ユーザー視点では「何も進んでいない」状態が続く。
