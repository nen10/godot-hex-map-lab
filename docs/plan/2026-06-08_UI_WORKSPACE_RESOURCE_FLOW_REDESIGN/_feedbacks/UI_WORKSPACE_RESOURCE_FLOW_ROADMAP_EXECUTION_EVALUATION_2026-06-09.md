# UI Workspace / Resource Flow Roadmap 実行評価 2026-06-09

評価対象: `godot-hex-map-lab-20260609-130048.zip`  
対象Roadmap: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`  
対象Queue: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`  
作成日: 2026-06-09

---

## 0. 総合結論

今回の `UI_WORKSPACE_RESOURCE_FLOW_REDESIGN` 実行は、**前回の UI Asset Selection 実行で残っていた「Resource行だけのWorkspace」「sample依存」「ボタン過多」「dist不整合」に対して、かなり明確に前進している**。

特に良い点は以下である。

- Generate以外のtabにも `ScrollContainer` が導入され、狭いdockでも下部機能へ到達できるようになった。
- `Document` ではなく `Resources` tab として、選択中 `HexTileMapLayer` と作業Resource群を扱う方向へ寄った。
- 選択中 `HexTileMapLayer` から `Level Document` と `Layer Stack` を自動取得し、dock側Contextへ同期する導線ができた。
- 不足している `UniqueResource` を選択中ノード向けにまとめて作成する導線ができた。
- Resource選択行は一行構成へかなり近づき、`Clear / Select / Open / Validate / Link` のような冗長ボタン群は整理された。
- sample bundle は production path からさらに分離され、`Settings / Samples` の学習導線として扱われている。
- `Paint` tab は単なるResource参照行ではなくなり、viewport入力時の自動tab切替や active brush / selected cell / last edit state を持つ方向へ進んだ。
- `Generate` の重い更新について、profile、progress、busy state、debounce の改善が入った。
- `Export` の目的が runtime handoff として整理され、manual上の説明も前より明確になった。
- `dist` 再生成が最終process stepとして実施され、今回のaddon treeとcommitted manifestの差分は解消されている。

一方で、**UI/UXとしてはまだ完成ではない**。最大の残課題は、`Resources / Catalog / Layers / Validate / QA / Export / Settings` のtabが増えた一方で、実際の詳細編集機能の多くがまだ `Paint` tab の旧 `HexMapEditTool`、または `Generate` tab の旧 `HexMapGenDock` に残っていることである。

つまり今回の到達は、次のように評価できる。

```text
前回状態:
  tabはあるが、多くがResource参照行だけに見える

今回状態:
  tabごとのsummary / status / action / purposeはかなり増えた
  ただし、Catalog/Layers/Document/Validate/QA/Exportの詳細操作はまだPaint/Generate側に混在している
```

総合評価は以下とする。

| 観点 | 評価 | コメント |
|---|---:|---|
| Queue実行 | A | 32 task すべて `COMPLETE`。self-review / test result も揃っている。 |
| Scroll / dock耐性 | A- | 全tab ScrollContainer化は良い。ヘッダー部の折りたたみは今後検討余地。 |
| Resource ownership / auto-binding | B+ | selected HexTileMapからDocument/LayerStack同期は良い。shared resourcesの復元方針は未完。 |
| Resource選択UI | B+ | compact row、button削減、typed pickerは良い。generic Resource slotがまだ残る。 |
| Sample分離 | A- | sample fallbackのmain path混入は大きく改善。Settings UIはまだ簡略化余地あり。 |
| Paint workspace | B | viewport編集との関連は良い。まだ非Paint責務が多い。 |
| Tab別実作業画面 | B- | 空Resource行状態からは改善。ただし一部tabはsummary中心で詳細編集が外部に残る。 |
| Generate performance UX | B+ | progress/debounce/profileは良い。大規模mapの実測budgetは次段階。 |
| Manual / docs | A- | first impression課題に沿って更新されている。analog testは方針どおり保留。 |
| Package / process | A | dist manifest freshness問題は今回解消。 |

結論:

```text
Roadmap実行としては成功。
First impression改善としても大きく前進。
ただし、次は「tabごとの本当の操作画面化」と「shared resource復元」を詰める段階。
```

---

## 1. 評価方法

確認対象は主に以下。

- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/*/IMPLEMENTATION_PLAN.md`
- `docs/review/autopilot/*_SELF_REVIEW_2026-06-08.md`
- `docs/review/autopilot/*_TEST_RESULT_2026-06-08.md`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd`
- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd`
- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/plugin.gd`
- `tests/test_editor_plugin.gd`
- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/TEST.md`
- `dist/hex_map_kit-0.3.0.manifest.txt`

こちらの評価環境では Godot 実行ファイルが存在しないため、`./tools/test.sh` の再実行はできなかった。

```text
Godot executable not found. Set GODOT_BIN=/path/to/Godot.
```

そのため、テスト結果については、同梱された `docs/review/autopilot/*_TEST_RESULT_2026-06-08.md` のPASS記録と静的確認を分けて扱う。

---

## 2. Queue実行状態

`IMPLEMENTATION_QUEUE.md` 上の対象taskは 32件で、すべて `COMPLETE` になっている。

対象群:

```text
UIR-00, UIR-01
LAYOUT-10, LAYOUT-11
NODE-20, NODE-21, NODE-22, NODE-23, NODE-24
ASSET-30, ASSET-31, ASSET-32
SAMPLE-40, SAMPLE-41
TAB-50, TAB-51, TAB-52, TAB-53, TAB-54, TAB-55, TAB-56, TAB-57
PERF-60, PERF-61, PERF-62
INFO-70, INFO-71, INFO-72
GEN-80, GEN-81
DOC-90, PROCESS-91
```

同梱test resultでは、多くのtaskで以下がPASSしている。

```text
tools/package_addon.sh --check
tests/test_hex_core.gd
tests/test_hex_map_generation.gd
tests/test_hex_adapter.gd
tests/test_hex_tile_map_layer.gd
tests/test_editor_plugin.gd
tests/test_debug_scenes.gd
```

`PROCESS-91` では、committed `dist` artifacts と一時生成manifest/zipの一致まで確認されている。静的にも、現在の `addons/hex_map_kit` file count と `dist/hex_map_kit-0.3.0.manifest.txt` の entries は一致しており、前回問題だった committed dist の古さは解消済みである。

---

## 3. 課題別評価

### 3.1 課題1: Generate以外のtabがScrollできない

評価: **解消**

`HexMapWorkspace` の tab page 作成で、各tab rootに `ScrollContainer` が使われている。`tests/test_editor_plugin.gd` でも `Resources / Generate / Paint / Catalog / Layers / Validate / QA / Export / Settings` すべてのtabについて scroll root を確認している。

これは非常に良い。dockを狭く配置したときに下部機能へ到達できない、という first impression 上の問題に正しく対応している。

改善余地:

- Workspace上部の sample CTA / selected HexTileMap context header は tab scroll の外側にある。極端に狭いdockでは、このヘッダー領域も折りたたみ可能にするとさらによい。
- ScrollContainerを入れただけでは、情報密度が高いtabの読みやすさは保証されない。次はtabごとの折りたたみsectionやprimary actionの配置が重要になる。

### 3.2 課題2: Document / Resource と選択中 HexTileMap の関係

評価: **かなり前進。ただし shared resources の復元方針が未完**

良い点:

- `plugin.gd` がGodot Editorのselection changeを監視し、選択中 `HexTileMapLayer` を Workspace に伝える。
- `HexTileMapLayer` またはその内部child tile mapを選んでも、親の `HexTileMapLayer` へ解決する処理がある。
- `HexTileMapLayer` 側に `level_document_resource` と `layer_stack_resource` がexportされている。
- Workspaceは選択中ノードから `Level Document` と `Layer Stack` を読み込み、asset contextへ反映する。
- 不足しているnode-owned resourcesを保存先指定つきで一括新規作成する導線がある。
- dock側でDocument/LayerStackを選択・作成した場合に、選択中 `HexTileMapLayer` へ適用するAPIがある。

これは、ユーザーが提案した以下のユースケースにかなり対応している。

```text
選択している HexTileMap ノードが変われば、
そのノードが参照している Document / Resource データに切り替わる
```

残課題:

- 現状、選択中 `HexTileMapLayer` から自動復元されるのは主に `Level Document` と `Layer Stack` である。
- `Tile Catalog / Object Database / Label Database / Movement Profile / Generation Profile / Export Profile` は workspace context 側の shared resources として扱われており、HexTileMapノードからの自動復元は弱い。
- `Level Document.dependencies` から shared resources を復元する設計がまだ不十分に見える。

つまり、次の問いが残っている。

```text
HexTileMapを選択したとき、dockはDocument/LayerStackだけ復元すればよいのか？
それともDocument.dependenciesからCatalog/ObjectDB/LabelDB等も復元すべきか？
```

推奨:

- `Level Document` を選択したら、その dependencies から `Tile Catalog / Object Database / Label Database / Movement Profile` を workspace context に自動hydrateする。
- ただし、ユーザーが明示的に別Resourceを選んだ場合は override として扱う。
- Workspace上に `Loaded from selected HexTileMap`, `Loaded from document dependency`, `Manually selected` のsource badgeを出す。

### 3.3 課題3: Resource参照・選択・新規作成UI

評価: **大きく改善。まだprofile系Resourceの型が弱い**

良い点:

- Resource行はかなり一行構成に近づいた。
- 主構成は `Title / EditorResourcePicker / status / Details / Create New / Learn With Sample` 程度に整理された。
- `Clear / Select / Open / Validate / Link / Node` のような冗長ボタン群は通常行から消えた。
- clearはGodot標準のResourcePicker操作へ寄せる方向になっている。
- Linkは基本的にauto-bindingへ寄せられ、いちいち押す操作ではなくなっている。
- Validateはasset rowの個別ボタンではなく、Validate tabや状態表示へ移った。
- tooltip / detail / status で説明する方向へ進んでいる。

これは、今回のfirst impression指摘にかなり合っている。

残課題:

- `Validation Rule Suite / Generation Profile / Export Profile` など、一部slotのResource picker base typeがまだ generic `Resource` になっている。
- これは、現時点で対応する専用Resource classが未定義であるためだと思われる。
- ユーザー指摘のとおり、柔軟性が必要なほど曖昧な運用がまだ存在しないなら、専用Resource classを定義する方がUX品質は上がる。

推奨:

```text
HexValidationRuleSuiteResource
HexGenerationProfileResource
HexExportProfileResource
```

を追加し、generic `Resource` slot を減らす。

また、実クリック経路について一点重大な懸念がある。

`HexMapWorkspace._popup_export_destination_dialog()` と `_popup_missing_unique_resources_directory_dialog()` は、`EditorFileDialog` を `add_child(dialog)` してから `HexMapEditorPathSelector.popup_dialog(dialog)` を呼んでいる。`popup_dialog()` 側も base control へ `add_child(dialog)` する設計であるため、実クリック時に二重add / reparent 系のエラーが出る可能性がある。

これは headless test で直接 method path を通していると見逃されやすい。

優先修正:

```text
- Workspace側の add_child(dialog) を削除し、popup_dialog に委譲する
または
- popup_dialog 側で parent 済みなら add_child しない
```

これは `P0` 修正候補である。

### 3.4 課題4: 学習用 sample bundle

評価: **かなり改善**

良い点:

- sample mode は default OFF。
- sample CTAは Settings / Samples へ誘導される。
- `Open` のような曖昧なno-opボタンは消えた。
- `Duplicate To Project` は実装され、sample catalog を project copy として使う方向になった。
- `SAMPLE-41` で main execution path から sample fallback を外している。
- sampleから直接使う状態は `SOURCE_SAMPLE` として警告/learning扱いに分類される。

これは、今回の設計指針である以下に合っている。

```text
sample preset = learning / onboarding / demo
project asset selection = production workflow / main UX
```

改善余地:

- Settings内の sample関連設定が少し多い。`Show bundled samples in asset selectors`、`Use bundled sample assets for scratch documents`、`Create project copies when applying samples` は、初見では関係が分かりにくい可能性がある。
- まずは `Learning Samples` の一つの折りたたみsectionにまとめ、主actionを `Duplicate sample catalog to project` に絞る方が分かりやすい。
- sample catalog 以外の sample dependencies がどうcopyされるかを、UI上でもう少し明示するとよい。

### 3.5 課題5: Paint tab がシンプルすぎる / 意味がわからない

評価: **前進。ただしまだ非Paint責務が混ざる**

良い点:

- `Paint` tab は asset slots を持たなくなった。
- viewport edit が消費されたタイミングで `Paint` tab へ自動切替する処理がある。
- Paint workspace snapshot として、active document、active layer、brush、selected cell、last edit などの状態を見られる。
- これは「2D viewport上の編集」と「Paint tab」が結びつくため、UXとして自然である。

残課題:

`Paint` tab に載っている `HexMapEditTool` は、まだ多くの非Paint責務を持っている。

具体的には以下が残る。

- document new/open/save/import/export 系
- layer stack controls
- catalog resource / TileSet / scene picker
- catalog entry editor
- default target tile controls
- object / label / property controls
- validation/debug/report 系の一部

そのため、`Paint` tab の意味は改善したが、まだ「本当にPaint作業だけに集中できるtab」ではない。

推奨:

- Catalog entry editor は `Catalog` tab へ移す。
- Layer stack作成・適用・role管理は `Layers` tab へ移す。
- Document open/save/import/export は `Resources` / `Export` tab へ移す。
- Paint tab には、brush、mode、selected cell、selected layer、selected catalog key、edit history、viewport操作だけを残す。

### 3.6 課題6: 各tabがResource参照だけに見える

評価: **かなり改善。ただしtabごとの実作業画面としてはまだ薄い**

今回の実装で、各tabは前より内容を持つようになった。

確認できる改善:

- `Resources`: selected HexTileMap context / asset context / missing unique resources
- `Catalog`: catalog status / entry count / validation summary / resource context
- `Layers`: layer stack role summary / role list
- `Validate`: issue navigator / validation status
- `QA`: seed lab summary / generation snapshot
- `Export`: export purpose / destination / runtime handoff
- `Settings`: sample settings / workspace preferences

これは「Resource参照だけに見える」状態からは大きく進んでいる。

ただし、多くのtabはまだ summary / status / snapshot 中心であり、詳細編集の主操作が別tabに残っている。特に `Catalog / Layers / Validate / QA / Export` は、次に first-class screen として育てる必要がある。

判断:

```text
Resource参照だけ問題 = ある程度解消
本当の作業tab化 = 未完
```

### 3.7 課題7: Generate更新の重さ / progressbar

評価: **改善あり。次は実測budget**

良い点:

- Generate処理に progress state / busy state が追加された。
- threaded generation cancel や validation/apply/finalize の段階表示がある。
- tile settings apply に debounce / coalescing が入った。
- orientation/tile setting の変更が即座に全体更新を連発しにくくなった。
- performance profile docs が追加されている。

改善余地:

- まだ「実測上どのmap sizeで何ms以内」という performance budget は薄い。
- orientation変更やlarge map applyは、debounceだけでなく incremental apply / chunked apply / preview-only update へ進める余地がある。
- ProgressBarは良いが、ユーザーに「何を待っているか」「キャンセルできるか」「変更が反映待ちか」をさらに明示するとよい。

推奨:

- `Generate Apply Performance Budget` を定める。
- map size別に `generate / validate / apply / preview` の時間を計測する。
- budget超過時だけprogress / busy / cancelを出すのではなく、常に軽いstatusを表示する。

### 3.8 課題8: 不明な項目が多い / Exportが不明

評価: **改善**

良い点:

- Resource slotに目的説明とtooltipが追加されている。
- tab empty state / purpose text が追加されている。
- Exportは `Runtime Handoff Resource` という目的に寄せて説明されている。
- manualでも Export tab の目的が以前より明確になっている。

改善余地:

- `Validation Rule Suite / Generation Profile / Export Profile` が generic Resource である限り、tooltipだけでは不十分。
- Exportについては、`何をexportするか`、`何に使うか`、`通常Saveと何が違うか` を画面上の短い説明でさらに出した方がよい。

推奨:

- Export tab に以下のような短い説明を入れる。

```text
Export creates a runtime handoff resource from the current Level Document.
Use Save for authoring. Use Export for runtime/loading handoff.
```

日本語UIにするなら:

```text
Save: 編集用Level Documentを保存
Export: 実行時ロード用Resourceを書き出し
```

### 3.9 課題9: 中間生成データ / ノードグラフ的管理

評価: **妥当にbacklog化されている**

`GEN-80` / `GEN-81` は、Generation Intermediate Data と Generation Profile / Result Model の調査・設計として扱われている。これは正しい。

ここを今の UI改修に混ぜると、Workspace整理と generation graph editor が同時に膨らんで破綻する。

次に進めるなら、いきなりgraph editorではなく以下から始めるべきである。

```text
HexGenerationProfileResource
HexGenerationResultResource
HexGenerationPassSnapshotResource
```

その後に、Node graph / pipeline editor を検討する。

---

## 4. 重要な実装懸念

### 4.1 P0: FileDialog popup 経路の二重add疑惑

前述の通り、`_popup_export_destination_dialog()` と `_popup_missing_unique_resources_directory_dialog()` は、dialogをWorkspaceへ `add_child` してから `HexMapEditorPathSelector.popup_dialog(dialog)` を呼ぶ。

一方、`popup_dialog()` は base control へ dialog を `add_child` する設計である。Godotではすでにparentを持つNodeを再度 `add_child` するとエラーになる可能性がある。

これは `Export destination` や `Create missing unique resources` の実クリック導線で表面化しやすい。

優先修正:

```text
UIRF-NEXT-01_FIX_FILE_DIALOG_POPUP_PATHS
```

Acceptance:

- Workspace側は `add_child(dialog)` しない。
- または `popup_dialog()` が parent 済みNodeを検出する。
- 実ボタン経路の smoke test を追加する。

### 4.2 P0/P1: 詳細操作のtab migrationが未完

Workspaceはtab構造を持ち、各tabにsummary/panelが入った。しかし、詳細操作の多くは旧 `HexMapEditTool` / `HexMapGenDock` に残る。

このままだと、ユーザーは `Catalog` tab を見ても、実際に catalog entry を追加/編集するには `Paint` tab 側の旧UIを探す可能性がある。

優先修正:

```text
UIRF-NEXT-02_MIGRATE_CATALOG_CONTROLS_OUT_OF_PAINT
UIRF-NEXT-03_MIGRATE_LAYER_AND_DOCUMENT_CONTROLS_OUT_OF_PAINT
```

### 4.3 P1: shared resources の復元が弱い

選択中 `HexTileMapLayer` から `Level Document` と `Layer Stack` は復元されるが、shared resources は workspace session 側に残る。

開発者の期待はおそらく以下である。

```text
HexTileMapを選択
  -> そのDocumentを読む
  -> Document dependenciesからCatalog/ObjectDB/LabelDB等をdockに復元
  -> そのmapをすぐ編集できる
```

この復元がないと、project reload 後にResource選択をもう一度やる必要が出る。

優先修正:

```text
UIRF-NEXT-04_SHARED_RESOURCE_RESTORE_FROM_SELECTED_DOCUMENT
```

### 4.4 P1: Generic Resource slot の専用型化

以下はまだ generic Resource slot になりやすい。

- Validation Rule Suite
- Generation Profile
- Export Profile

専用 class がないため、Resource pickerのfilterが甘くなる。

優先修正:

```text
UIRF-NEXT-05_CONCRETE_PROFILE_RESOURCES
```

候補:

```text
HexValidationRuleSuiteResource
HexGenerationProfileResource
HexGenerationResultResource
HexExportProfileResource
```

### 4.5 P1/P2: Workspace が新しい巨大責務になりつつある

これは「行数が多いから悪い」という話ではない。ユーザーの上位指針どおり、コード量ではなくUX責務で判断する。

現状の `HexMapWorkspace` は、tab shell、asset context、sample settings、resource creation、export destination、validation snapshot、QA summary、paint snapshot など、多くのUX責務を直接持っている。

今後の分割基準はこうするべきである。

```text
分割理由:
  ファイルが大きいからではない
  ユーザー作業目的が別だから分ける
```

候補:

- `HexMapResourcesScreen`
- `HexMapCatalogScreen`
- `HexMapLayersScreen`
- `HexMapValidationScreen`
- `HexMapQaScreen`
- `HexMapExportScreen`
- `HexMapSettingsScreen`

これにより、各tabが本当の意味でfirst-classになる。

---

## 5. 自動テストと手動確認

### 5.1 自動テスト

自動テストは非常に厚く、今回のroadmap実行を支えている。

特に良い確認:

- all tabs have ScrollContainer
- asset row layout is compact
- redundant buttons removed
- sample mode default OFF
- sample does not fallback into generation/paint main path
- selected HexTileMap auto-binding
- missing unique resources creation
- Paint tab auto-select from viewport edit
- Export purpose / destination state
- Generate progress / debounce
- package artifact regeneration

弱い確認:

- FileDialog 実クリック経路のpopup安全性
- 各tabで実際に編集操作が完結できるか
- Document dependenciesからshared resourcesを復元できるか
- 実際のnarrow dockでの視認性
- large mapでの実測 performance

### 5.2 手動確認

manualは更新されている。`docs/manual/MANUAL_EDITOR_PLUGIN.md` は、Resources / Generate / Paint / Catalog / Layers / Validate / QA / Export / Settings の流れを説明しており、前回より現実的である。

ただし、analog test はユーザー方針どおりまだ追加しないのが正しい。

次の状態になってから analog test を作るべきである。

```text
- Catalog tabでCatalog作業が完結する
- Layers tabでLayer Stack作業が完結する
- Validate tabでissue確認とfocusが自然にできる
- QA tabでSeed比較とPromoteが自然にできる
- Export tabでSaveとの違いが明確に分かる
```

---

## 6. 推奨する次のRoadmap task

### UIRF-NEXT-01: Fix FileDialog popup paths

Priority: P0

目的:

- 実クリック導線の `EditorFileDialog` popup で二重add / no-op / invisible dialog が起きないようにする。

対象:

- `_popup_export_destination_dialog()`
- `_popup_missing_unique_resources_directory_dialog()`
- `HexMapEditorPathSelector.popup_dialog()`

Acceptance:

- dialog parent管理が一箇所に統一される。
- Export destination button と missing unique resource directory button の実経路が smoke test される。

### UIRF-NEXT-02: Migrate Catalog controls out of Paint

Priority: P0/P1

目的:

- Catalog tabを summary ではなく実Catalog editorにする。

移動候補:

- catalog resource picker
- TileSet picker
- scene picker
- entry tree
- Add Atlas Entry
- Add Scene Entry
- selected entry detail
- validate catalog status

Acceptance:

- Catalog tabだけで catalog entry を追加/編集/確認できる。
- Paint tab は catalog keyを選んで塗ることに集中する。

### UIRF-NEXT-03: Migrate Layer / Document / Export controls out of Paint

Priority: P1

目的:

- Paint tabから非Paint責務を外す。

移動候補:

- Document open/save/import/export -> Resources / Export
- Layer Stack create/apply/clear -> Layers
- validation report -> Validate

Acceptance:

- Paint tabは brush / layer target / selected cell / edit action に絞られる。

### UIRF-NEXT-04: Restore shared resources from selected document

Priority: P1

目的:

- project reload / node selection時に、document dependencies から workspace asset context を復元する。

Acceptance:

- selected HexTileMap -> Level Document -> dependencies -> Tile Catalog/Object DB/Label DB/Movement Profile が自動hydrateされる。
- source badge が `Node`, `Document Dependency`, `Manual` を区別する。
- manual override が可能。

### UIRF-NEXT-05: Concrete profile resources

Priority: P1

目的:

- generic `Resource` picker を減らす。

候補:

- `HexValidationRuleSuiteResource`
- `HexGenerationProfileResource`
- `HexGenerationResultResource`
- `HexExportProfileResource`

Acceptance:

- ResourcePickerのbase typeが具体化される。
- ユーザーが「何を選ぶべきか」を型から理解できる。

### UIRF-NEXT-06: Workspace component extraction by UX role

Priority: P1/P2

目的:

- `HexMapWorkspace` を行数基準ではなく、UX責務ごとに分ける。

候補:

- `HexMapResourcesScreen`
- `HexMapCatalogScreen`
- `HexMapLayersScreen`
- `HexMapValidationScreen`
- `HexMapQaScreen`
- `HexMapExportScreen`
- `HexMapSettingsScreen`

Acceptance:

- 各screen script がtab内の作業目的に対応する。
- 分割理由がUX責務で説明できる。

### UIRF-NEXT-07: Generate performance budget and chunked apply review

Priority: P2

目的:

- progress/debounce の次に、実測budgetとchunking方針を作る。

Acceptance:

- map size別の generate / validate / apply 時間が記録される。
- budget超過時のprogress/cancel/preview動作が定義される。
- orientation変更やTileSet変更時の更新戦略が明確になる。

---

## 7. 最終評価

今回の実行は、前回のfirst impressionで出た問題にかなり正面から対応している。

特に、以下は成功と見てよい。

```text
- 全tab ScrollContainer化
- Resources tabへの再定義
- selected HexTileMap auto-binding
- UniqueResource一括作成
- Resource rowの簡略化
- no-op / redundant button削減
- sampleをSettings / learning pathへ隔離
- Paint tabとviewport編集の関連づけ
- Generate progress / busy / debounce
- Export目的の明確化
- dist再生成process
```

ただし、次の段階では「tabがある」「summaryがある」だけでは足りない。

最終的に必要なのは、**各tabがその作業を本当に完結できる画面になること**である。

本feedbackにおける課題:

```text
Catalog tabでCatalog編集が完結する
Layers tabでLayer Stack編集が完結する
Resources tabでDocument/Node Resource管理が完結する
Validate tabでissue確認とfocusが完結する
QA tabでSeed比較とPromoteが完結する
Export tabでSave/Exportの違いが明確に操作できる
Paint tabから非Paint責務を外す
```

この方向で進めれば、Hex Map Kit は「機能はあるが探しにくいaddon」から、**HexTileMapノードを中心に、制作作業の流れが見えるEditor Workspace** へ近づく。
