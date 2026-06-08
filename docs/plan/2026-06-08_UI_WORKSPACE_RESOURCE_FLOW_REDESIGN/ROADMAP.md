# Hex Map Kit UI Workspace / Resource Flow Redesign Roadmap 2026-06-08

作成日: 2026-06-08  
対象: `godot-hex-map-lab-20260608-073901.zip`  
前提roadmap: `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ROADMAP.md`  
前提評価: `UI_ASSET_SELECTION_ROADMAP_EXECUTION_EVALUATION_2026-06-08.md`  
参照元: `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`

目的: UI Asset Selection 実行後の first impression で見えた問題を、次の実装ロードマップへ落とす。今回の主眼は、**機能が存在すること**ではなく、**ゲーム開発者が dock を配置し、HexTileMap ノードを選び、自分の project asset を選択・作成・編集し、生成/ペイント/検証/Export の関係を迷わず理解できること**である。

---

## 0. 上位方針

### 0.1 UI first impression を評価対象にする

今回のユーザー評価では、機能活用に到達する前に UI の第一印象で詰まった。したがって、この roadmap では「APIで可能」「headless testで確認済み」を完了根拠にしない。

完了根拠は以下に寄せる。

```text
- 画面上で何をすべきか分かる
- dock を狭くしても操作できる
- 任意 project asset を選択・作成できる
- sample は学習導線であり production path を代替しない
- selected HexTileMap ノードと dock の Resource 状態が自動同期する
- 不要なボタン・ラベル・raw text が通常導線に出ない
- 各タブが Resource参照一覧ではなく、そのタブ固有の作業を持つ
```

### 0.2 Sample preset は production workflow ではない

前回 roadmap の方針をさらに強化する。

```text
sample bundle:
  学習 / demo / onboarding / duplicate source

project asset:
  production workflow / main execution source / default UI path
```

採用する候補は、前回評価の推奨案である。

```text
Sample candidates visible but never fallback-selected.
```

つまり、Settings で sample 表示をONにしても、Generate / Paint / Validate / Export の実行元に sample が自動採用されてはいけない。sample は preview / learning / duplicate source に留める。production 実行には、ユーザーが project asset を選択または作成する必要がある。

### 0.3 Dist freshness はテスト化しない

前回評価で `committed dist が古い` ことは妥当な指摘だった。ただし、これは今回の UI roadmap の通常テストには入れない。

扱い:

- roadmap の final process step として `dist` を再生成する。
- release / handoff 前に manifest 差分を人間またはCodex作業ログで確認する。
- `tools/test.sh` の必須テストへは入れない。

理由:

- UI改修中に dist 更新を毎taskへ要求すると、UI設計の速度を下げる。
- dist は公開直前の成果物であり、開発中の実装品質ゲートではない。

### 0.4 Analog test はまだ作らない

UI の印象改善前に analog test を作ると、暫定UIを固定する。したがって、本 roadmap でも新規 analog test は作らない。

ただし、manual / first impression checklist / UI smoke checklist は作ってよい。これは analog test ではなく、画面設計の説明と確認メモである。

---

## 1. 現状first impressionから見た主要課題

### 1.1 ScrollContainer 不足

Generate tab 以外の tab が ScrollContainer を持たない、または狭いdockで下部の機能に届きにくい。Tab構成自体は良いが、dock pane はユーザーが柔軟に配置するため、狭い・低い・縦長・横長の状態に耐える必要がある。

必要方針:

- 各 tab root は原則 `ScrollContainer`。
- Tab 内の主 content は vertical layout。
- 重要な現在選択状態は top summary として短く出す。
- 長い説明や metadata は tooltip / expander / details へ逃がす。
- Resource rows は1行構成を基本にする。

### 1.2 初期状態で Document / Resource 設定が必要なのに、何をどう持つべきか分からない

現在の UI は、Resource を選ばせるが、HexTileMap ノードがどの Resource を持つべきか、dock がどの Resource を参照しているかが分かりにくい。

整理すべき問い:

```text
- 一つの HexTileMap ノードが固有に持つべき Resource は何か？
- 複数 HexTileMap ノードで共有する Resource は何か？
- 選択中 HexTileMap ノードが変わった時、dock はどう同期すべきか？
- dock から Resource を選んだ時、選択中 HexTileMap ノードへ自動リンクすべきか？
- Generate 結果はどの Document / Resource へ関連づくのか？
```

### 1.3 Resource選択UIが過剰かつ曖昧

現状の Resource型選択は filter が甘く、何を選べばよいか分かりにくい。また、ラベル・ボタン・説明が多く、UI が重い。

問題:

- generic `Resource` 選択が残る。
- 必要Resource型をユーザーが知らないと判断できない。
- Clear / Select / Open / Validate / Link / Node などのボタンが多い。
- 押しても反応がない、または目的が不明なボタンがある。
- 反応がないことを status label で説明しても根本解決にならない。

基本方針:

```text
[Title] [ResourcePicker]
```

を基本にし、補足説明は tooltip / warning icon / details に退避する。

### 1.4 Sample bundle の Open / Duplicate が機能しない

Settings / Samples の learning flow は方向性として良いが、`Open` と `Duplicate To Project` が実際の操作として成立しないと、学習から実制作へ移行できない。

方針:

- `Open` は目的が明確で、実動作が保証できる場合だけ残す。
- `Duplicate To Project` は project asset 化の主導線なので必須。
- Duplicate 後、asset slot は `SOURCE_PROJECT` として更新される。
- sample を production execution source にするのではなく、project copy へ移す。

### 1.5 Paint tab が Resource参照だけに見える

Paint tab は「編集作業」の中心であるべきだが、現状の first impression では Resource参照系の項目だけに見え、タブの意味が薄い。

必要方針:

- 2D viewport 上で編集操作が始まったら Paint tab へ自動切替する。
- Paint tab には paint / brush / selected cell / active layer / active catalog key / object brush / label brush / zone brush など、編集作業そのものを出す。
- Resource選択は Resources tab へ寄せ、Paint tab には現在の編集対象サマリだけを短く出す。

### 1.6 各tabがResource参照だけに見える

ユーザー観測では、Generate 以外の多くの tab が Resource参照系項目に偏っている。

```text
Document: Resource参照系の項目のみ
Paint: Resource参照系の項目のみ
Catalog: Resource参照系の項目のみ
Layer: Resource参照系の項目のみ
Validate: Resource参照系 + validateメモ
QA: Resource参照系のみ
Export: Resource参照系 + 不明なExport
Settings: Resource参照系 + 設定
```

この状態なら、`Document` tab という名前は不適切であり、`Resources` または `Project Context` として一括表示した方が自然である。

採用方針:

- `Document` tab を **Resources** tab へ改名する。
- Resources tab は selected HexTileMap と Resource context の管理に集中する。
- 各機能tabには、Resource選択そのものではなく、その機能の作業UIを置く。
- 各tab上部に compact context summary は出してよい。

### 1.7 Generate の全体更新が重い

Orientation切替など、マップ全体の再計算・再描画を伴う操作で待ち時間が出る。

必要方針:

- 全体更新アルゴリズムの計測。
- debounce / incremental update / cache の検討。
- 長い処理には ProgressBar / busy overlay / cancellable operation を出す。
- UIが固まっているように見える状態を避ける。

### 1.8 不明な項目が多い

特に Export が何を何のために export するのか分かりにくい。各Resourceについても、目的や使用タイミングが画面から読み取りにくい。

必要方針:

- Tabごとの目的を1行で表示する。
- 各 Resource slot には tooltip を持たせる。
- Export は何を出すかを分類する。
  - runtime document / runtime scene handoff
  - JSON / external data
  - package / sample / debug support
- 不明な機能は visible UI に置かず、backlog / experimental / details に下げる。

### 1.9 Generation pipeline / intermediate map graph の可能性

生成結果としての final map だけでなく、生成途中の primary / overlay / region filter / parameter pass を扱う可能性がある。

これは UI再編の直近実装には混ぜない。ただし、設計検討を開始する価値がある。

方針:

- 直近は `Generation Profile` と `Generation Result` の関係を明確にする。
- 中間生成グラフは research / backlog とする。
- 既存 Generate UI の肥大化として入れない。

---

## 2. 採用するUIモデル

### 2.1 Workspace tab model

採用する tab 構成:

```text
Hex Map Workspace
  Resources
  Generate
  Paint
  Catalog
  Layers
  Validate
  QA
  Export
  Settings
```

変更点:

- `Document` tab は `Resources` tab へ改名する。
- `Resources` tab が selected HexTileMap と Resource context の中心になる。
- `Settings` tab は sample / debug / defaults / advanced settings を扱う。
- 各tab root は ScrollContainer を持つ。

### 2.2 Resources tab model

Resources tab は以下を表示する。

```text
Selected HexTileMap
  Current node: <NodePath> or Not selected
  Link mode: Auto-link to selected HexTileMap  [default ON]
  Resource bundle: Create missing resources...

Unique resources for selected HexTileMap
  Level Document
  Node Layer Stack Instance
  Optional Runtime Initial State / Generated Snapshot if introduced

Shared project resources
  Tile Catalog
  TileSet
  Object Database
  Label Database
  Movement Profile
  Generation Profile
  Validation Rule Suite
  Export Profile
```

### 2.3 UniqueResource / SharedResource 分類

この roadmap では、Godot標準 Resource の外部/内部保存挙動とは別に、addon UX上の分類として以下を導入する。

#### UniqueResource

一つの HexTileMap ノードに固有である可能性が高い Resource。

候補:

| Resource | 理由 |
|---|---|
| Level Document | map authoring state そのもの。ノードごとに異なることが自然。 |
| Node Layer Stack Instance | template は共有可能だが、実際の child layer role / visibility / writable state はノード固有になりやすい。 |
| Generated Snapshot / Seed Result | 生成結果をそのノードの Document へ紐づけるため。 |

#### SharedResource

複数mapで再利用する可能性が高い Resource。

候補:

| Resource | 理由 |
|---|---|
| TileSet | project asset として共有される。 |
| Tile Catalog | 同じタイル語彙を複数mapで使う。 |
| Object Database | 同じ object definitions を複数mapで使う。 |
| Label Database | ラベル定義・スタイルを共有できる。 |
| Movement Profile | ユニット種別・ゲームルールとして共有される。 |
| Generation Profile | 同じ生成ルールを複数mapへ使う。 |
| Validation Rule Suite | project rule として共有される。 |
| Export Profile | 出力形式・handoff policy として共有される。 |

#### Contextual / OptionalResource

存在するとノイズになり得る Resource。常時は作らない。

候補:

| Resource | 作成タイミング |
|---|---|
| Object Database | Object編集を使う時。 |
| Label Database | Label編集を使う時。 |
| Movement Profile | Gameplay query / validation を使う時。 |
| Generation Profile | Generate / QA を使う時。 |
| Export Profile | Export workflow を使う時。 |

### 2.4 Auto-link model

採用方針:

```text
Default: Auto-link to selected HexTileMap node
```

ユースケース:

- 開発者が Scene Tree で HexTileMap node を選択する。
- Workspace がその node の Document / Resource context を自動表示する。
- 選択 node が変わると Workspace も切り替わる。
- Workspace で Document / Resource を選択または作成すると、選択中 HexTileMap node に自動で参照が入る。
- Generate 結果は、選択中 node の Level Document / Layer Stack / TileMap 表示へ関連づく。

独立した Link button は原則不要。

例外として、明確なユースケースがある場合だけ `Preview without linking` を Resources tab の advanced option として検討する。

現時点では以下を採用する。

```text
Resource選択はするが、選択中HexTileMapへリンクしない通常ユースケースは未定義。
したがって、link button は削除または auto-link status indicator へ置換する。
```

### 2.5 Resource row model

基本表示:

```text
[Level Document] [EditorResourcePicker]
```

補足情報:

- required type: tooltip
- purpose: tooltip
- current status: small status icon / color / short text
- invalid reason: hover tooltip / details expander
- create new: pickerの隣ではなく、Resources tab の `Create missing resources...` と各 row の context menu へ寄せる
- clear: Godot標準 ResourcePicker の clear 操作に任せる。独自 Clear ボタンは削除。

過剰なボタンは削除する。

| 現ボタン | 採用判断 |
|---|---|
| Clear | 削除。ResourcePicker の標準 clear に寄せる。 |
| Select | ResourcePicker で代替できるなら削除。必要なら picker focus のみにする。 |
| Open | 実際に Inspector / FileSystem focus できるなら残す。できないなら削除。 |
| Validate | Resource row ではなく Validate tab / automatic status に寄せる。 |
| Link | Auto-link status indicator へ置換。手動link操作は原則削除。 |
| Node | 目的不明なら削除。`Select bound HexTileMap` としてのユースケースが合理的な場合はUI設計から検討・再編する。 |

---

## 3. Task queue

### Phase U0: Roadmap adoption / policy reset

#### `UIR-00_ADOPT_FIRST_IMPRESSION_FEEDBACK`

status: `COMPLETE`  
dependencies: none

目的:

- この roadmap を導入し、前回 feedback とユーザー first impression を次の実行queueへ採用する。
- sample fallback と dist freshness の扱いを明確化する。

対象:

- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`
- `AGENTS.md`
- `docs/policy/IMPLEMENTATION_POLICY.md`
- `docs/policy/TEST_DESIGN_POLICY.md`

Acceptance:

- sample は execution fallback ではなく learning / duplicate source と明記される。
- committed dist freshness は final process step とし、通常テスト化しないと明記される。
- UI first impression を headless API より優先する方針が入る。

#### `UIR-01_CURRENT_VISIBLE_UI_INVENTORY`

status: `COMPLETE`  
dependencies: `UIR-00_ADOPT_FIRST_IMPRESSION_FEEDBACK`

目的:

- 現状の各tab表示内容を実画面ベースで棚卸しする。
- 「実装されているが表示されていない」バグと「そもそも設計されていない」不足を分ける。

成果物:

- `docs/review/roadmap/WORKSPACE_VISIBLE_UI_INVENTORY_2026-06-08.md`

Inventory項目:

```text
tab_name
visible_sections
scroll_container_present
resource_rows
primary_actions
buttons_without_effect
resource_picker_filters
main_feature_controls
empty_state_text
tooltip_presence
suspected_hidden_functionality
next_task
```

Acceptance:

- ユーザー観測の Document / Paint / Catalog / Layer / Validate / QA / Export / Settings の見え方を再現して分類する。
- 表示バグと設計不足を分ける。

---

### Phase U1: Layout / Scroll / Dock resilience

#### `LAYOUT-10_SCROLL_CONTAINER_FOR_ALL_TABS`

status: `COMPLETE`  
dependencies: `UIR-01_CURRENT_VISIBLE_UI_INVENTORY`

目的:

- Generate 以外の tab でも、狭いdock / 低いdock で下部機能にアクセスできるようにする。

対象:

- `HexMapWorkspace`
- per-tab content containers
- `HexMapWorkspaceAssetPanel`
- `HexMapSampleSettingsPanel`
- existing Generate/Paint panels if needed

Acceptance:

- 各 tab root が ScrollContainer または同等の scrollable content を持つ。
- Document/Resources header と main content が狭いdockで切れない。
- Tab switching 後も scroll position / focus が破綻しない。
- UI上の主要操作にスクロールで到達できる。

#### `LAYOUT-11_COMPACT_RESOURCE_ROW_LAYOUT`

status: `COMPLETE`  
dependencies: `LAYOUT-10_SCROLL_CONTAINER_FOR_ALL_TABS`

目的:

- ラベル過多・メタ情報過多を削減し、Resource row を1行構成へ統一する。

方針:

```text
[Title] [ResourcePicker] [status icon]
```

Tooltipへ移すもの:

- Resourceの目的
- required type
- selected path
- validation detail
- sample warning
- linked node detail

Acceptance:

- Resource row は基本1行。
- 長い説明labelを通常表示しない。
- 未選択状態は短く表示する。
- 詳細は tooltip / expander にある。

---

### Phase U2: HexTileMap node binding / Resource lifecycle

#### `NODE-20_HEX_TILE_MAP_RESOURCE_OWNERSHIP_POLICY`

status: `READY`  
dependencies: `UIR-00_ADOPT_FIRST_IMPRESSION_FEEDBACK`

目的:

- HexTileMap node が保持すべき UniqueResource と、共有する SharedResource を設計する。

成果物:

- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE_RESOURCE_OWNERSHIP_POLICY.md`

検討項目:

- Godot Resource の external resource / subresource / shared reference の扱い。
- HexTileMap node の export field に持たせるべき Resource。
- `Resource` が存在することでノイズになる optional feature。
- scene reload 時に Workspace が何を復元すべきか。

採用候補:

```text
UniqueResource:
  Level Document
  Node Layer Stack Instance
  Generated Snapshot / Authoring State if introduced

SharedResource:
  TileSet
  Tile Catalog
  Object Database
  Label Database
  Movement Profile
  Generation Profile
  Validation Rule Suite
  Export Profile
```

仕様矛盾や誤解が見つかった場合:

- 実装を止めず、`NODE-20-BACKLOG_GODOT_RESOURCE_OWNERSHIP_REVIEW` を追加する。
- 公式/既存 docs 参照メモを成果物に書く。

Acceptance:

- UniqueResource / SharedResource / OptionalResource が分類される。
- 常時保持するとノイズになる Resource が明記される。
- Resources tab の表示分類に反映できる。

#### `NODE-21_SELECTED_HEX_TILE_MAP_AUTO_BINDING`

status: `BACKLOG`  
dependencies: `NODE-20_HEX_TILE_MAP_RESOURCE_OWNERSHIP_POLICY`

目的:

- Scene Tree で選択中の HexTileMap node と Workspace を自動同期する。

ユースケース:

1. 既存 HexTileMap node を選択する。
2. node が参照している Document / Catalog / Layer Stack を Workspace が自動表示する。
3. 別 HexTileMap node を選択すると Workspace も切り替わる。
4. Dock から Resource を選択・新規作成すると、選択中 node へ自動で参照が入る。

Acceptance:

- node selection change で Workspace context が更新される。
- selected node がない場合は `No HexTileMap selected` empty state を表示する。
- auto-link が default ON。
- 手動 Link button は不要になるか、status indicator に変わる。
- `Resource選択はするがリンクしない` ユースケースが未定義なら通常UIに出さない。

#### `NODE-22_CREATE_MISSING_UNIQUE_RESOURCES_FLOW`

status: `BACKLOG`  
dependencies: `NODE-21_SELECTED_HEX_TILE_MAP_AUTO_BINDING`

目的:

- 選択中 HexTileMap node が必要な UniqueResource を持っていない時、一括作成できるようにする。

UI:

```text
Resources tab
  Missing resources for Selected HexTileMap
  Save directory: [Choose Folder...]
  Resource prefix: <NodeName>
  [Create Missing Resources]

Creates:
  <NodeName>_document.tres
  <NodeName>_layer_stack.tres
  optional <NodeName>_generation_snapshot.tres if introduced
```

Acceptance:

- 保存先directoryを選べる。
- 既定名で UniqueResource を作る。
- 作成後、選択中 HexTileMap node に自動参照される。
- SharedResource は勝手に作らず、必要な場合だけ選択/作成する。
- 作成された Resource の関係が Resources tab に表示される。

#### `NODE-23_DOCK_SELECTION_WRITES_BACK_TO_NODE`

status: `BACKLOG`  
dependencies: `NODE-21_SELECTED_HEX_TILE_MAP_AUTO_BINDING`

目的:

- Dock パネルで Resource を選択または作成した時、選択中 HexTileMap node 側に自動保存されるようにする。

Acceptance:

- Document slot で Resource を選ぶと selected HexTileMap に document reference が入る。
- Catalog / Layer Stack / Object DB / Label DB も policy に従って node または workspace context に入る。
- node と workspace の状態差分が画面で分かる。
- 自動リンクできない状態では理由を empty state / tooltip に出す。

#### `NODE-24_GENERATE_RESULT_RESOURCE_RELATIONSHIP`

status: `BACKLOG`  
dependencies: `NODE-22_CREATE_MISSING_UNIQUE_RESOURCES_FLOW`

目的:

- Generate 機能による生成結果が、どの Document / Resource に関連づくかを明確にする。

仕様:

- Generate preview / scratch result / committed document update を分ける。
- `Generate` 実行後、選択中 HexTileMap node の Level Document へ apply するか、preview のままにするかを明示する。
- promoted seed / generation profile / output document の関係を表示する。

Acceptance:

- Generate tab に `Output target` がある。
- `Preview only` と `Apply to selected Document` が区別される。
- Apply 後、Resources tab に Document / generated metadata の関係が見える。
- 選択中 node がない時は apply できず、理由が分かる。

---

### Phase U3: Asset Slot UI simplification / button semantics

#### `ASSET-30_STRICT_RESOURCE_TYPE_FILTERS`

status: `BACKLOG`  
dependencies: `NODE-20_HEX_TILE_MAP_RESOURCE_OWNERSHIP_POLICY`

目的:

- ResourcePicker が generic Resource ではなく、必要な具体型を選ばせるようにする。

対象:

- Level Document
- Tile Catalog
- TileSet
- Layer Stack
- Object Database
- Label Database
- Movement Profile
- Generation Profile
- Validation Rule Suite
- Export Profile
- PackedScene slots

Acceptance:

- 型が明確なslotで generic `Resource` を要求しない。
- 何を選べば良いか tooltip に出る。
- type mismatch は警告ではなく picker段階で避けられる。
- 柔軟性が必要なslotは、なぜ generic なのかを docs に明記する。

#### `ASSET-31_REMOVE_REDUNDANT_RESOURCE_ACTION_BUTTONS`

status: `BACKLOG`  
dependencies: `LAYOUT-11_COMPACT_RESOURCE_ROW_LAYOUT`, `ASSET-30_STRICT_RESOURCE_TYPE_FILTERS`

目的:

- Clear / Select / Open / Validate / Link / Node など、目的が曖昧またはGodot標準操作と重複するボタンを整理する。

判断:

| Button | 方針 |
|---|---|
| Clear | 削除。ResourcePicker 右クリック/標準clearに寄せる。 |
| Select | ResourcePickerで代替できるなら削除。 |
| Open | Inspector/FileSystem focus として実装できる場合のみ残す。不能なら削除。 |
| Validate | Resource row から削除。Validate tab / auto status に寄せる。 |
| Link | auto-link status indicator に置換。 |
| Node | `Select bound HexTileMap` として機能するなら残す。no-opなら削除。 |

Acceptance:

- 押しても反応がないボタンが残らない。
- no-op を label/status で説明して誤魔化さない。
- UIの実行経路が一つに整理される。
- Godot標準操作で可能なものを独自ボタンで重複させない。

#### `ASSET-32_WIRE_REMAINING_ACTIONS_OR_DELETE`

status: `BACKLOG`  
dependencies: `ASSET-31_REMOVE_REDUNDANT_RESOURCE_ACTION_BUTTONS`

目的:

- 残すと決めた action は必ず実動作に接続する。

対象:

- Settings sample Open / Duplicate
- Resource Open if kept
- Create New
- Select bound node if kept

Acceptance:

- button press から observable result までつながる。
- 実動作が定義できないボタンは削除される。
- headless test は API直叩きだけでなく、button action signal -> workspace state change を確認する。

---

### Phase U4: Sample learning flow repair

#### `SAMPLE-40_SETTINGS_SAMPLE_BUTTONS_FUNCTIONAL`

status: `BACKLOG`  
dependencies: `ASSET-32_WIRE_REMAINING_ACTIONS_OR_DELETE`

目的:

- Settings / Samples の `Open` と `Duplicate To Project` を機能させる。

Acceptance:

- `Open` は sample resource の Inspector focus / FileSystem focus / preview のいずれかを行う。
- 実装できない場合は Open を削除する。
- `Duplicate To Project` は保存先を選び、project copy を作り、asset slot へ `SOURCE_PROJECT` として入れる。
- duplicate 後に何が変わったか画面で分かる。

#### `SAMPLE-41_REMOVE_SAMPLE_FROM_MAIN_EXECUTION_FALLBACK`

status: `BACKLOG`  
dependencies: `SAMPLE-40_SETTINGS_SAMPLE_BUTTONS_FUNCTIONAL`

目的:

- sample mode ON でも sample を Generate / Paint の execution fallback にしない。

Acceptance:

- project catalog 未選択時に Generate / Paint が sample catalog を自動使用しない。
- sample は Settings / Samples で open / preview / duplicate できる。
- duplicated project copy だけが production execution source になる。
- bundled sample path を直接選んだ場合は `SOURCE_SAMPLE` として警告する。

---

### Phase U5: Tab-specific functional screens

#### `TAB-50_RESOURCES_TAB_RENAME_AND_CONTEXT_SCREEN`

status: `BACKLOG`  
dependencies: `NODE-23_DOCK_SELECTION_WRITES_BACK_TO_NODE`, `LAYOUT-10_SCROLL_CONTAINER_FOR_ALL_TABS`

目的:

- Document tab を Resources tab へ改名し、HexTileMap node と Resource context 管理に集中させる。

Acceptance:

- Tab label が `Resources` になる。
- selected HexTileMap node が見える。
- UniqueResource / SharedResource / OptionalResource が分類表示される。
- `Create Missing Resources` がある。
- 各Resourceの目的は tooltip で分かる。

#### `TAB-51_PAINT_TAB_REAL_BRUSH_WORKSPACE`

status: `BACKLOG`  
dependencies: `TAB-50_RESOURCES_TAB_RENAME_AND_CONTEXT_SCREEN`

目的:

- Paint tab を Resource参照一覧ではなく、編集作業の中心にする。

必要UI:

- Active document summary
- Active layer / role
- Terrain brush
- Object brush
- Label brush
- Zone brush if available
- Catalog key selector
- Brush shape: single / line / ring / disc / fill / scatter backlog if not implemented
- Selected cell / hover cell summary
- Last edit / undo hint

Acceptance:

- 2D viewport で編集操作が始まると Paint tab へ切り替わる。
- Paint tab 内で現在何を編集しているか分かる。
- Resource選択だけのtabではない。
- Object/Labelが未設定なら、必要な Resource への短い誘導だけ出す。

#### `TAB-52_CATALOG_TAB_DETAIL_EDITOR`

status: `BACKLOG`  
dependencies: `TAB-50_RESOURCES_TAB_RENAME_AND_CONTEXT_SCREEN`

目的:

- Catalog tab を Resource参照だけでなく、catalog entry を編集・理解する画面にする。

必要UI:

- Catalog resource picker summary
- TileSet picker summary
- Entry list
- Entry detail
- Tile preview / scene preview
- Missing asset warning
- Create entry from selected tile / scene
- Tags / role / movement metadata details

Acceptance:

- Catalog entry の意味が画面で分かる。
- source_id / atlas_coords を主UIで直接入力しない。
- preview がない場合は理由が分かる。

#### `TAB-53_LAYERS_TAB_ROLE_EDITOR`

status: `BACKLOG`  
dependencies: `TAB-50_RESOURCES_TAB_RENAME_AND_CONTEXT_SCREEN`

目的:

- Layers tab を layer stack の role と selected HexTileMap child layers を管理する画面にする。

必要UI:

- Layer Stack Resource
- Target HexTileMap node
- role list: terrain / overlay / object / debug / collision / navigation
- Create missing child layers
- Apply document to layer stack
- visibility / locked / writable status

Acceptance:

- Layer tab だけで layer stack の状態が理解できる。
- Resource参照だけで終わらない。
- selected node と layer stack の関係が表示される。

#### `TAB-54_VALIDATE_TAB_ISSUE_NAVIGATOR`

status: `BACKLOG`  
dependencies: `TAB-50_RESOURCES_TAB_RENAME_AND_CONTEXT_SCREEN`

目的:

- Validate tab を Resource選択ではなく、issue navigator と修正導線にする。

必要UI:

- Run Validate
- Severity filter
- Document / Catalog / Layer / Object / Cell grouping
- Issue list
- Click issue -> focus cell/resource
- Suggested action / target tab link

Acceptance:

- Validate の対象と目的が分かる。
- Asset slotごとの Validate button は不要になる。
- クリックして修正先へ移動できる。

#### `TAB-55_QA_TAB_SEED_LAB_SCREEN`

status: `BACKLOG`  
dependencies: `NODE-24_GENERATE_RESULT_RESOURCE_RELATIONSHIP`

目的:

- QA tab を generation profile / score / seed promotion の画面にする。

必要UI:

- Generation Profile
- Validation Rule Suite
- Batch count / seed range
- Score table
- Preview summary
- Promote to selected Document
- Output target summary

Acceptance:

- QA tab で seed比較と採用が理解できる。
- Generate tab と役割が分かれる。
- Promote 後に Resources tab の Document 関係が更新される。

#### `TAB-56_EXPORT_TAB_PURPOSE_REDESIGN`

status: `BACKLOG`  
dependencies: `TAB-50_RESOURCES_TAB_RENAME_AND_CONTEXT_SCREEN`

目的:

- Export が何を何のために出力するのかを明確にする。

分類候補:

```text
Runtime handoff:
  Current Level Document / Layer Stack / Gameplay metadata を runtime scene/API から使う

Data export:
  JSON / external format / debug report

Package support:
  addon/package/sample integrity は developer process へ
```

Acceptance:

- Export tab に目的説明が1行で表示される。
- Export target と output type が明確。
- 不明な export 機能は backlog / experimental に下げる。
- 使えないボタンを出さない。

#### `TAB-57_SETTINGS_TAB_SIMPLIFICATION`

status: `BACKLOG`  
dependencies: `SAMPLE-41_REMOVE_SAMPLE_FROM_MAIN_EXECUTION_FALLBACK`

目的:

- Settings tab を sample / debug / preferences へ限定し、Resource参照一覧にしない。

Acceptance:

- Settings tab には Sample learning controls がある。
- Debug numeric fallback はここに隔離されるか削除される。
- Production asset selection は Resources tab にある。
- Settings の sample actions は機能するか削除される。

---

### Phase U6: Generate performance / progress

#### `PERF-60_GENERATE_GLOBAL_UPDATE_PROFILE`

status: `READY`  
dependencies: `UIR-01_CURRENT_VISIBLE_UI_INVENTORY`

目的:

- Orientation切替など、全体更新の重さを計測する。

対象:

- orientation change
- map regenerate
- document apply
- layer stack apply
- tile redraw
- validation run if expensive

成果物:

- `docs/review/roadmap/GENERATE_UPDATE_PERFORMANCE_PROFILE_2026-06-08.md`

Acceptance:

- どの操作が重いか分類される。
- UI freeze の原因が redraw / generation / apply / validation のどれか分かる。
- 改善候補が優先度付きで出る。

#### `PERF-61_PROGRESS_AND_BUSY_UI`

status: `BACKLOG`  
dependencies: `PERF-60_GENERATE_GLOBAL_UPDATE_PROFILE`

目的:

- 長い処理中に UI が固まって見えないようにする。

必要UI:

- ProgressBar
- busy overlay
- current step text
- cancel if feasible
- delayed operation / debounce status

Acceptance:

- 長い処理は開始/進行/完了が見える。
- orientation切替など全体更新で無反応に見えない。
- 進捗表示のためにUXを歪めない。必要なら概算 progress でもよい。

#### `PERF-62_INCREMENTAL_UPDATE_AND_DEBOUNCE`

status: `BACKLOG`  
dependencies: `PERF-60_GENERATE_GLOBAL_UPDATE_PROFILE`

目的:

- 全体更新が不要な操作を incremental にする。

候補:

- orientation切替時の preview debounce
- TileSet / Catalog変更時の apply遅延
- map全体再描画とdocument metadata更新の分離
- visible region apply if feasible

Acceptance:

- 体感待ち時間が下がる。
- 連続変更で毎回重い処理を走らせない。
- Progress UI と整合する。

---

### Phase U7: Tooltip / terminology / unknown item cleanup

#### `INFO-70_RESOURCE_PURPOSE_TOOLTIPS`

status: `READY`  
dependencies: `LAYOUT-11_COMPACT_RESOURCE_ROW_LAYOUT`

目的:

- 各Resourceが何のためのものかを tooltip で理解できるようにする。

対象:

- Level Document
- TileSet
- Tile Catalog
- Layer Stack
- Object Database
- Label Database
- Movement Profile
- Generation Profile
- Validation Rule Suite
- Export Profile

Acceptance:

- 各Resource row に目的 tooltip がある。
- 必要な型を知らなくても選択対象が分かる。
- 長い説明labelは通常表示しない。

#### `INFO-71_TAB_PURPOSE_EMPTY_STATES`

status: `BACKLOG`  
dependencies: `TAB-50_RESOURCES_TAB_RENAME_AND_CONTEXT_SCREEN`

目的:

- 各tabが何をする場所か、未設定時に何をすべきかを表示する。

Acceptance:

- 未選択時に sample で埋めない。
- `Next action` が一つか二つに絞られている。
- 説明は短く、詳細は tooltip / help link に退避する。

#### `INFO-72_EXPORT_TERMINOLOGY_DECISION`

status: `BACKLOG`  
dependencies: `TAB-56_EXPORT_TAB_PURPOSE_REDESIGN`

目的:

- Exportの意味を決め、UI用語を統一する。

候補:

| 候補 | 意味 | 採用判断 |
|---|---|---|
| Save Document | authoring Resource保存 | Exportではない |
| Runtime Handoff | runtimeで使うResourceセット作成 | Export tab候補 |
| Data Export | JSON/CSV/外部形式 | backlogでもよい |
| Package Build | addon配布物作成 | developer processであり通常UIから外す候補 |
| Debug Report | support情報コピー | Debug / Validate補助 |

Acceptance:

- Export tab に置くものと置かないものが決まる。
- manual 用語が統一される。

---

### Phase U8: Generation pipeline graph research

#### `GEN-80_GENERATION_INTERMEDIATE_DATA_USE_CASE_REVIEW`

status: `BACKLOG`  
dependencies: `NODE-24_GENERATE_RESULT_RESOURCE_RELATIONSHIP`

目的:

- primary / overlay / region filter など、中間生成データを持つユースケースを整理する。

検討するユースケース:

- primary terrain map を作り、overlay generation の filter に使う。
- region / biome / room map を中間データとして持つ。
- 手動編集済み領域を lock し、未編集領域だけ再生成する。
- generation parameter / pass result をノードグラフ的に管理する。
- ある中間生成マップをfilterとして使用した(overlay)マップ生成の連鎖をノードグラフ的に管理する。
- final Level Document と generation intermediate data を分ける。

成果物:

- `docs/review/roadmap/GENERATION_PIPELINE_GRAPH_REVIEW_2026-06-08.md`

Acceptance:

- 直近UIに入れるもの、backlogにするものが分かれる。
- Generate tab をさらに肥大化させない。
- Graph editor を作る前に Resource model を検討する。

#### `GEN-81_GENERATION_PROFILE_AND_RESULT_MODEL`

status: `BACKLOG`  
dependencies: `GEN-80_GENERATION_INTERMEDIATE_DATA_USE_CASE_REVIEW`

目的:

- Generation Profile、Generation Result、Level Document の関係を設計する。

Acceptance:

- Generate preview / intermediate / committed document の違いが定義される。
- QA / Seed Lab / Document metadata と整合する。
- graph editor はまだ実装しない。

---

### Phase U9: Manual / process / final packaging

#### `DOC-90_WORKSPACE_UI_MANUAL_UPDATE`

status: `BACKLOG`  
dependencies: `TAB-57_SETTINGS_TAB_SIMPLIFICATION`, `INFO-72_EXPORT_TERMINOLOGY_DECISION`

目的:

- manual を new Workspace / Resources tab / auto-link / sample learning flow に合わせる。

対象:

- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/TEST.md`
- `README.md`

Acceptance:

- Document tab ではなく Resources tab として説明する。
- sample は Settings / Samples learning flow として説明する。
- HexTileMap node selection -> auto resource sync を説明する。
- Generate output target / Apply to Document を説明する。
- analog test はまだ追加しない。

#### `PROCESS-91_FINAL_DIST_REGENERATION_STEP`

status: `BACKLOG`  
dependencies: `DOC-90_WORKSPACE_UI_MANUAL_UPDATE`

目的:

- roadmap最終段で committed dist を再生成する。これは通常テストではなく process step とする。

作業:

```sh
tools/package_addon.sh
```

Acceptance:

- `dist/hex_map_kit-0.3.0.manifest.txt` が現在の addon tree を反映する。
- `dist/hex_map_kit-0.3.0.zip` が更新される。
- 作業ログに dist 更新を記録する。
- このstepを `tools/test.sh` の必須テストにはしない。

---

## 4. 実行優先順位

最優先:

```text
1. UIR-00_ADOPT_FIRST_IMPRESSION_FEEDBACK
2. UIR-01_CURRENT_VISIBLE_UI_INVENTORY
3. LAYOUT-10_SCROLL_CONTAINER_FOR_ALL_TABS
4. LAYOUT-11_COMPACT_RESOURCE_ROW_LAYOUT
5. NODE-20_HEX_TILE_MAP_RESOURCE_OWNERSHIP_POLICY
6. NODE-21_SELECTED_HEX_TILE_MAP_AUTO_BINDING
7. ASSET-31_REMOVE_REDUNDANT_RESOURCE_ACTION_BUTTONS
8. ASSET-32_WIRE_REMAINING_ACTIONS_OR_DELETE
9. SAMPLE-40_SETTINGS_SAMPLE_BUTTONS_FUNCTIONAL
10. SAMPLE-41_REMOVE_SAMPLE_FROM_MAIN_EXECUTION_FALLBACK
```

次点:

```text
11. NODE-22_CREATE_MISSING_UNIQUE_RESOURCES_FLOW
12. NODE-23_DOCK_SELECTION_WRITES_BACK_TO_NODE
13. NODE-24_GENERATE_RESULT_RESOURCE_RELATIONSHIP
14. TAB-50_RESOURCES_TAB_RENAME_AND_CONTEXT_SCREEN
15. TAB-51_PAINT_TAB_REAL_BRUSH_WORKSPACE
16. TAB-52_CATALOG_TAB_DETAIL_EDITOR
17. TAB-53_LAYERS_TAB_ROLE_EDITOR
18. TAB-54_VALIDATE_TAB_ISSUE_NAVIGATOR
19. TAB-55_QA_TAB_SEED_LAB_SCREEN
20. TAB-56_EXPORT_TAB_PURPOSE_REDESIGN
21. TAB-57_SETTINGS_TAB_SIMPLIFICATION
```

仕上げ:

```text
22. PERF-60_GENERATE_GLOBAL_UPDATE_PROFILE
23. PERF-61_PROGRESS_AND_BUSY_UI
24. PERF-62_INCREMENTAL_UPDATE_AND_DEBOUNCE
25. INFO-70_RESOURCE_PURPOSE_TOOLTIPS
26. INFO-71_TAB_PURPOSE_EMPTY_STATES
27. INFO-72_EXPORT_TERMINOLOGY_DECISION
28. GEN-80_GENERATION_INTERMEDIATE_DATA_USE_CASE_REVIEW
29. GEN-81_GENERATION_PROFILE_AND_RESULT_MODEL
30. DOC-90_WORKSPACE_UI_MANUAL_UPDATE
31. PROCESS-91_FINAL_DIST_REGENERATION_STEP
```

---

## 5. Autopilot 実行指示

Codex に渡す標準指示:

```md
Read docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md.

Goal:
Continue the next READY task from this roadmap.

Important principles:
- UI first impression matters before feature depth.
- Do not treat headless API availability as UI completion.
- All tabs must remain usable in narrow/short docks.
- Sample bundle is learning/demo only; never execution fallback for production tabs.
- User-selected or user-created project assets are the default path.
- Resource rows should be compact: title + picker + status; details go to tooltip.
- Remove buttons that have no clear user purpose or no implementation.
- Prefer auto-link to the selected HexTileMap node over manual link buttons.
- If Godot Resource ownership semantics create uncertainty, document it and add a backlog item instead of guessing.
- Do not add analog tests yet.
- Do not add dist freshness to tools/test.sh; regenerate dist only in final process step.

Process:
1. Pick the first READY task.
2. Create or update UX/POLICY/IMPLEMENTATION_PLAN if needed.
3. Implement UI changes according to game-development UX rationality.
4. Rewrite tests that preserve old UI shape.
5. Run ./tools/test.sh if Godot is available.
6. Update ROADMAP status/proof or leave next task clear.
```

---

## 6. Definition of Done

### 6.1 UI tab DoD

```text
- Tab content scrolls.
- Tab has a visible purpose.
- Tab has a main action beyond Resource references, unless it is Resources/Settings.
- Empty state tells the next action.
- Resource rows are compact and typed.
- Buttons either work or are removed.
```

### 6.2 Resource selection DoD

```text
- Exact Resource type is clear.
- User can select arbitrary project asset.
- Sample is not silently selected.
- Tooltip explains purpose.
- Clear uses Godot standard ResourcePicker behavior when available.
- Open/Validate/Link/Node buttons are not present unless their use case is necessary and implemented.
```

### 6.3 HexTileMap binding DoD

```text
- Selecting a HexTileMap node updates Workspace resources.
- Changing selection switches context.
- Selecting/creating Resource in dock writes back to selected node when auto-link is enabled.
- Missing UniqueResources can be created in bulk with default names.
- Generate result has explicit output relationship to selected Document/Resource.
```

### 6.4 Sample flow DoD

```text
- Sample controls are in Settings/Samples.
- Open works or is removed.
- Duplicate To Project works and visibly updates project asset slots.
- Sample paths are classified as SOURCE_SAMPLE.
- Main execution source requires project asset selection.
```

### 6.5 Process DoD

```text
- New analog tests are not created.
- Dist is regenerated only in final process step.
- UI manual is updated after UI layout stabilizes.
```

---

## 7. 結論

前回までの roadmap 実行により、Resource/API と asset slot model はかなり整った。しかし、ユーザーの first impression では、まだ「何を選び、何がノードに紐づき、どのタブで何をするのか」が画面から十分に伝わっていない。

次の UI 改修では、以下を中心にする。

```text
1. 全tabをScroll可能にする。
2. Document tabをResources tabへ再編する。
3. selected HexTileMap node と dock Resource context を自動同期する。
4. UniqueResource / SharedResource / OptionalResource を整理する。
5. Resource rowを一行構成へ簡略化し、tooltipへ情報を逃がす。
6. no-op / redundant buttonsを削除または実装する。
7. sampleはSettings/Samplesの学習導線に限定する。
8. Paint / Catalog / Layers / Validate / QA / Export をResource参照だけでない実作業画面へ育てる。
9. Generateの重い全体更新にprogressと性能改善を入れる。
10. Generation pipeline graph は直近実装ではなく、調査backlogとして扱う。
```

この順序で進めれば、現在の「機能はあるが使う前に迷う」状態から、ゲーム開発者が HexTileMap node を中心に Resource を管理し、生成・編集・検証・出力の関係を自然に理解できる UI へ近づけられる。
