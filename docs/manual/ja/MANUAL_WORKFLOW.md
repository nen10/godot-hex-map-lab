# ワークフローマニュアル

このページは Hex Map Kit の setup、Build graph authoring、Paint finishing、runtime handoff、examples、runtime use をつなぐ作業手順です。

## 1. Setup

アドオンを次の場所にインストールします。

```text
res://addons/hex_map_kit/
```

Godot で有効にします。

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
```

本番制作では、Workspace で次のプロジェクトアセットを用意します。

- 選択済み `HexTileMapLayer` scene node、または Build が作成した `HexTileMapLayer`
- 保存済み `HexMapDocumentResource`
- プロジェクトの `HexTileCatalogResource`
- プロジェクトの `TileSet`
- プロジェクトの Object Database と Label Database
- プロジェクトの Layer Stack と任意の Movement Profile
- プロジェクトの `HexValidationRuleSuiteResource` と `HexGenerationProfileResource`
- プロジェクトの `HexExportProfileResource` と明示的な Runtime Handoff destination

表示用には、プロジェクトの hex `TileSet` を持つ `TileMapLayer` または `HexTileMapLayer` を用意します。

バンドル学習サンプルは Settings / Samples から利用できます。

```text
res://addons/hex_map_kit/assets/sample_hex_tiles.png
res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres
```

sample catalog は自身の `TileSet` resource を持ち、scene-tile entry は package 内の `PackedScene` を参照します。本番向けに変更する前に、sample catalog を project path へ複製してください。

Sample onboarding path:

1. 新しい Workspace で `Learn with bundled samples` を押すと Settings / Samples が開きます。
2. Sample mode は OFF で始まるため、main screen は project asset selection を中心に表示します。
3. `Show bundled samples in asset selectors` は、選択済み project asset を置き換えずに学習候補を表示します。
4. `Duplicate To Project` は catalog、tile texture、object scene dependency の project-owned copy を作成します。
5. 複製後は project copy を Catalog/Build/Paint で通常の project asset と同じように使います。

詳細な setup は `docs/manual/MANUAL_SETUP.md` を参照してください。

## 2. 目的別の Build、Paint、Export

**Hex Map Workspace** を開き、本番制作では次の経路を中心に進めます。

```text
Build graph -> Promote layer -> Paint -> Export handoff
```

Workspace の screen はこの経路を支えます。

1. `Build`: 生成グラフを作成/実行し、中間出力を確認し、有用な出力を Level Document へ昇格します。
2. `Paint`: brush-driven document edit で生成マップを仕上げます。
3. `Export`: runtime data resource、runtime scene、または generation graph resource として Godot runtime へ受け渡します。
4. `Catalog`: Build と Paint が使う tile/object vocabulary を管理します。
5. `Layers`: role layer、visibility、lock state、writable source 境界を確認します。
6. `Resources`: 選択中 map binding と project asset shelves を管理します。
7. `Settings`: sample learning と debug/report controls を扱います。
8. `Validate` / `QA`: 必要に応じて issue review や seed comparison を支援します。主生産経路ではありません。

推奨 workspace pass:

1. Scene ツリーで `HexTileMapLayer` を選択します。または、生成グラフから自己完結した map layer が必要な場合は Build から始めます。Build は missing Level Document / embedded graph context を作れるため、リソース参照不足で run path を隠れたままブロックしません。
2. `Build` で Simple Build を導入として使うか、graph canvas で full pipeline を開きます。Shape、Wall、Connectivity、Region Filter、Item Generator、Promote などの generation pass を接続します。
3. 現在の graph で `Generate` を押します。preview と selected node output で terrain、selection、overlay、result data を確認します。
4. 実マップ内容にする output を promote します。Promote は Level Document の role-aware layer に書き込み、layer writable source boundary を守るため、generated layer と hand-painted document layer を共存できます。
5. `Paint` で brush palette、active layer、selected cell、catalog/object keys を使い、手作業で仕上げや修正を行います。
6. 現在の step で vocabulary、role structure、project asset binding が必要になった時だけ `Catalog`、`Layers`、`Resources` を使います。
7. `Export` で handoff purpose を選びます。runtime data resource、runtime scene、または runtime Map Build API 用 generation graph resource です。

Support shelf responsibilities:

- `Resources`: selected `HexTileMapLayer`、Level Document、graph resource、catalog、object database、label database、layer stack、movement profile、validation profile、generation profile、export profile bindings。
- `Catalog`: catalog key vocabulary、TileSet binding、tile preview、scene entry resource。通常の Build/Paint は raw `source_id` / `atlas_coords` ではなく catalog key を使います。
- `Layers`: terrain、overlay、object、collision、navigation、debug role layer と、writable source (`generated`、`document`、`target`、`readonly`)。
- `Validate`: issue review と focus action。Runtime Handoff 前の support lens として使います。
- `QA`: 代替案比較のための seed comparison と selected-seed preview。Graph-based regeneration が主な control surface です。

Sample/debug/process boundaries:

- Samples は learning/onboarding assets であり、silent production default ではありません。
- `Export` は runtime handoff であり、package build output ではありません。
- Package artifacts は `tools/package_addon.sh` から作る developer process output です。
- Debug overlay rendering は通常 gameplay rendering から分離され、Validate/debug-report flow から扱います。
- 通常の editor selection は Resource picker と FileDialog を使います。保存済み path は読み取り専用 status として表示されることがありますが、path text は primary input workflow ではありません。

`Resources` は Auto-link 有効時に選択中 `HexTileMapLayer` と自動リンクします。ノード未選択でも、workspace はサンプルで埋めるのではなく production asset selection を表示します。

選択中 Level Document が canonical authoring source です。`HexTileMapLayer.hex_map` は preview、target import、Runtime Handoff output のための runtime/display snapshot data であり、保存、検証、継続編集する正本 document を置き換えません。

Fallback、mirror/debug/sample/manual override rules は `docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md` で管理され、各 decision の owner と removal condition が記録されています。

Resource shelf は source badge で ownership を示します。

| Badge | 意味 | 通常の操作 |
|---|---|---|
| `Node` | 選択中 `HexTileMapLayer` がその関係を所有しています。 | `Resources` で作成または選択します。Auto-link 有効時は書き戻されます。 |
| `Project` | project resource が明示的に選択されています。 | production source として使います。 |
| `Document Dependency` | 選択中 Level Document が共有依存関係を hydrate しました。 | document が既に関係を所有しているなら維持します。 |
| `Manual Override` | Workspace selection が document dependency を意図的に上書きしています。 | 現在の session で使い、正本化する場合は書き戻します。 |
| `Sample Learning` | bundled sample asset が学習用に表示されています。 | 編集して使う前に project files へ複製します。 |
| `Missing` | resource が未選択です。 | project asset を作成/選択するか、任意 resource として未選択にします。 |

Build output target:

1. Graph preview は中間 output を確認し、選択中 Level Document は変更しません。
2. 生成 terrain/overlay/object output を canonical document content にする場合は Promote node または promote action を使います。
3. `HexTileMapLayer`、Level Document、graph、generated preview がない場合、Build は missing context を表示するか必要な context を作成し、hidden sample default に依存しません。

QA Seed Lab promotion も support flow として同じ ownership model に従います。Promoted seed は `Resources` の project Level Document 関係を更新し、document save workflow が resource を保存するまで未保存です。

Profile assets は具体的な project resources です。`HexValidationRuleSuiteResource` は validation rule enablement と severity policy、`HexGenerationProfileResource` は generator defaults と parameters、`HexExportProfileResource` は Runtime Handoff output options を保存します。

Sample onboarding は任意であり、この first pass とは分離されています。サンプルを確認または複製した後は、production work のために project asset slots へ戻ります。

## 3. Level Document を作成する

terrain、overlay、object、label、zone、metadata、dependencies を 1 つの resource にまとめる map では `HexMapDocumentResource` を使います。

script construction は次から始めます。

```gdscript
var document = HexMapDocumentResource.new()
```

代表的な authoring fields:

- `terrain_layers`: primary map と terrain tile assignments。
- `overlay_layers`: generated/user item overlays。
- `object_placements`: object ids、cells、variants、runtime properties、spawn conditions。
- `label_placements`: cell に紐づく text labels。
- `metadata`: document id、display name、generation seed/snapshot、custom properties。
- `dependencies`: catalogs、object databases、label databases、TileSets、scripts、scenes などの resource references。

公開 editor workflow sample は、小さな canonical document を作成します。

```gdscript
const HexEditorWorkflowExample = preload("res://examples/editor_workflow/editor_workflow_example.gd")

var document = HexEditorWorkflowExample.build_authoring_document()
var info = HexEditorWorkflowExample.workflow_summary(document)
```

エディターでは `Resources` から Level Document を作成または選択します。生成グラフ実行に必要な context が欠けている場合、Build が missing context を作成することもできます。Auto-link が有効なら、Level Document の選択または作成は選択中 `HexTileMapLayer` へリソース関係を書き戻します。共有 project resources はその document dependencies に書き込まれ、Build、Paint、Export の support flow で Workspace context に hydrate されます。

## 4. Catalog Key を使う

通常の authoring flow では raw `source_id` / `atlas_coords` ではなく catalog key を使います。

Example catalog keys:

- `terrain.floor`
- `terrain.wall`
- `overlay.treasure`
- `object.spawn_marker`

Catalog-backed terrain layer は default を設定できます。

```gdscript
terrain_layer.default_floor_key = "terrain.floor"
terrain_layer.default_wall_key = "terrain.wall"
```

個別 payload も `catalog_key` を持てます。Catalog assignment が欠けている場合は validation issue です。document apply は numeric tile を暗黙代替しません。

エディターでは `Catalog Resource`、`TileSet`、`Scene Entry Resource`、`Add Atlas Entry`、`Add Scene Entry`、`Validate Catalog` を使います。Build と Paint の controls は tile coordinates ではなく catalog keys を選択します。

## 5. Layer Stack を使う

`HexLayerStackResource.standard_template()` は authoring roles を定義します。

- terrain
- decoration
- object
- collision
- navigation
- overlay
- debug

1 つの document を複数の child layer へ適用する場合は layer stack を使います。Build Promote は generated output を role-aware document layers に書き込み、Paint は hand-authored document intent を書き込みます。single-layer path は簡単な scene または advanced debugging 用に限定します。

```gdscript
var stack = HexLayerStackResource.standard_template()
hex_tile_map_layer.apply_document_to_layer_stack(document, stack)
```

エディターでは `HexTileMapLayer` target に対して `Create Missing Layers`、`Apply Document`、`Clear Role` を使います。

## 6. Runtime Object を配置する

Object authoring は typed object database を使います。

- `Object DB`: `HexObjectDatabaseResource`。
- definition list: object key selection。
- `Definition Scene`: `PackedScene` reference。
- `Placement Properties`: bool、number、string、enum の typed controls。

script-side runtime object export は section 10 で扱います。

## 7. Validate を support lens として使う

Runtime Handoff 前に issue review が必要な map では validation を使います。Validation は Build/Paint/Export route を支える support lens であり、workflow の中心ではありません。

```gdscript
var result = HexMapDocumentValidator.validate_document(document, {
	"tile_catalog": tile_catalog,
	"tile_set": tile_set,
	"object_database": object_database,
})

if result.error_count() > 0:
	print(result.issues)
```

Validation は map 外 payload、orphan objects/labels、missing catalog or tile entries、missing dependencies、objects on walls、missing object scenes、duplicate unique objects、movement-profile reachability rules などを確認します。

エディターでは validation dashboard で domain/severity rows、focus targets、fix suggestions を確認します。Support report として target status、last edit、save/export status、validation summary、raw details が必要な場合は Debug Report を使います。現在の workspace debug report は Export の secondary action からコピーできます。

## 8. Runtime Handoff を作成する

runtime code が現在の Level Document または generation graph から作られた handoff を必要とする場合は、エディターの `Export` タブを使います。

現在の Export タブは 3 つの handoff purpose を提示します。

1. `Runtime Map Resource`: runtime-friendly な `HexMapResource` を書き出します。
2. `Runtime Scene`: runtime layer node tree を含む scene を書き出します。
3. `Generation Graph`: runtime Map Build API で実行できる graph resource を保存します。

共通 handoff steps:

1. 現在の Level Document または graph context を確認します。
2. 必要に応じて `HexExportProfileResource` を選択します。
3. FileDialog で明示的な destination を選びます。
4. 選択した handoff action を実行します。

この workflow は Save Document ではありません。Authoring save は `HexMapDocumentResource` を維持します。また Package Build や Debug Report でもありません。Package artifacts は process-only (`tools/package_addon.sh`, `docs/manual/MANUAL_PACKAGE.md`) で、debug reports は support/diagnostic text です。

Debug overlay rendering は通常 gameplay rendering から分離され、Validate/debug-report path から扱います。

## 9. Runtime Query

canonical document Resource を runtime query helper に渡します。

```gdscript
const HexRuntimeQuerySample = preload("res://examples/basic_runtime/runtime_query_sample.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexEditorWorkflowExample = preload("res://examples/editor_workflow/editor_workflow_example.gd")

var profile = HexMovementProfileResource.new()
profile.profile_id = "player"
profile.wall_passable = false
var document = HexEditorWorkflowExample.build_authoring_document()

var result = HexRuntimeQuerySample.query_document(
	document,
	HexVector.zero(),
	HexVector.q_axis(),
	4.0,
	profile
)
```

`result` は次を含みます。

- `loaded`
- `error`
- `profile_id`
- `start`
- `goal`
- `path`
- `path_count`
- `range`
- `range_count`

runtime code が保存済み resource を先に load する必要がある場合は、`HexRuntimeQuerySample.query_document_path()` または scene wrapper の path helper を使います。

scene wrapper は次を開きます。

```text
res://examples/basic_runtime/runtime_query_example.tscn
```

## 10. Runtime Object Export

gameplay code が authoring placement を変更せずに object を instantiate する場合、script-side runtime object export を使います。この API helper は、エディター `Export` タブの Runtime Handoff workflow とは別です。

```gdscript
var export = HexRuntimeQuerySample.export_runtime_objects(document, object_database)
for item in export["runtime_objects"]:
	print(item["object_id"], item["scene"], item["properties"])
```

戻り値の dictionaries は copy です。runtime-only changes は `document.object_placements` へ書き戻されません。

## 11. Reference

- API surface: `docs/api/API_REFERENCE.md`
- Runtime example: `examples/basic_runtime/`
- Editor workflow example: `examples/editor_workflow/`
- Scripting basics: `docs/manual/MANUAL_SCRIPTING.md`
- Editor operation details: `docs/manual/ja/MANUAL_EDITOR_PLUGIN.md`
- English editor operation details: `docs/manual/MANUAL_EDITOR_PLUGIN.md`
