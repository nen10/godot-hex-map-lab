
# TEST.md


## 管理

(コマンド実行のみで完了する)テスト作成時、`tools/test.sh` を合わせて更新する
自動テスト設計は `docs/policy/TEST_DESIGN_POLICY.md` に従う。
interactiveなテスト作成時、実行方法を簡潔にdocumentationする
Editor Plugin 操作で複数機能の結合性を確認する任意検証は、アナログテストとして `docs/policy/ANALOG_TEST_POLICY.md` に従い、操作手順マニュアルを `tests/analog_test/` 以下に作成する。アナログテスト文書は Test path の代替ではなく、ユーザー依頼時の追加検証記録として扱う。

### CLEAN UI再編中のアナログテスト扱い

- 新規アナログテスト文書は CLEAN UI再編中は作成しない。
- 既存 `tests/analog_test/` 文書は history / reference であり、clean UX acceptance ではない。
- NEXT-03-style analog test pack は現在の roadmap queue には scheduled されていない。
- manual-only task は `./tools/test.sh` と self-review で完了確認する。
- UI改善後にユーザーが明示した場合だけ、アナログテスト作成を再開する。

### UI asset selection completion

- No sample-only completion: sample preset success だけで editor-facing feature を complete と判定しない。
- sample だけで成立する UI は `sample-only prototype` として扱い、sample/package integrity task 以外の production acceptance には使わない。
- feature screen の headless test は sample mode OFF の project asset selection state、user-selected Resource、または未設定/validation issue を確認する。
- sample mode ON/OFF と bundled sample asset の妥当性は、main feature completion とは別の sample/package contract として検証する。

### Test path

- `tools/package_addon.sh --check`
- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_workspace_layout_metrics.gd`
- `tests/test_workspace_layout_metric_evaluator.gd`
- `tests/test_workspace_layout_metric_gate.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`

### UI static audit

`UI-METRIC-02` adds a report-only static audit for Workspace UI contract risks:

```sh
python3 tools/ui_static_audit.py
```

The audit reports suspicious button wiring, placeholder button text, debug/raw/path visible text patterns, generic `EditorResourcePicker` usage, and tab scroll-container suspicion. It exits 0 by default because P0/P1 gating is scheduled later. Use `--strict` only when a caller intentionally wants findings to return a nonzero exit code.

### UI metric reports

`UI-METRIC-07` adds the standard runtime Workspace metric gate to `./tools/test.sh`. The gate writes JSON and Markdown reports under:

```text
.godot_user/ui-metrics/<run-id>/
```

The P0 failure count is a standard test gate and must be zero. P1 issue counts are included in the report but remain report-only initially.

### テスト方針

テスト期待値と結果が異なる場合、安易に期待値を修正せず、UnityとGodotでの座標の扱いに違いがあるかなどの移行時の問題に注意を払い、正確な理解のもとで正しいテストを作成する。移行元Unityコード上のバグに由来すると判断できる場合、必ず指摘する。
データ上でのテストはスクリプトコマンドのみで検証を進めるが、幾何学的な問題があればグラフィカルな結果表示を作成し、ユーザーにテスト依頼しても良い。
GodotでのDebug実行によるテストが有用なケースについては、ユーザーにテストを依頼する。
ユーザーに依頼するテストはテストケースごとに表示を切り替えるinteractive性のあるテスト画面を作成する。
エディター機能についてはGodot上での操作によってユーザーがテストする。
座標計算等の視覚的なテストケースで問題が発生した場合、可能な限りグラフィカルなテストケースを追加してGodot上でのデバッグ実行可能な画面を作成したのち、ユーザーのアドバイスを受けます。

### テスト概要

- `tools/package_addon.sh --check`: addon-only package manifest を生成・検証し、`addons/hex_map_kit/` の必須ファイルと sample atlas/catalog/scene dependency が含まれること、`docs/` / `tests/` / `debug/` / `tools/` / `examples/` / `.godot_user/` / `dist/` が含まれないことを検証する。
- `tests/test_hex_core.gd`: HexVector/HexPoint、toric coordinate、近傍・連結・経路、weighted path / movement range の cost-to-enter・budget・blocked cell・legacy unweighted compatibility、movement profile の passability / costs / blocker key / default wall behavior、9分割と対称生成領域タグを検証する。`symmetry_generation_tags()` が radius 1..9 の全 canvas cell を網羅し、`source` は raw draw position、`vector` は wrap 済み canvas position、`moved` は wrap 有無を表すことを検証する。phase2 outer_mod の pair/triple は raw 生成タイミング上の distinct な局所グループとして検証し、phase2 でも outer-to-center wave を通ることを検証する。
- `tests/test_hex_map_generation.gd`: rectangle/hexagon/toric square の生成、Primary Data の `Any` / `Floor` / `Wall` item key、Overlay Data の user item key、Placement Mask / Reference 用 item selector query、Uniform Distribution overlay item generation、Adjacency Reference overlay item generation、generated reference item key の動的参照と toric wrap / cancel、Markov Mesh overlay item generation、Overlay Deductor による item 削除、壁生成、割り込み可能な progress / cancel 付き壁生成と item 生成、shape API の interrupt option、連結性回復、dense/sparse/none の `restore_connectivity_by()`、terminal 接続、対称生成を検証する。dense/sparse 連結性回復は direct restore と生成 API 経由の progress / cancel、`0.35 -> 1.0` の restore progress range、単純 bridge、toric shortcut、Y 字 fixture、1-wall remote bridge、対称 toric square の接続を検証する。連結性回復の方向 seed は同距離 bridge の選択が seed で変わることと、restore / dense / sparse / terminal の各方式に適用できることを検証する。Generation Radius 1 / 2 も larger radius と同じ対称生成フローを通り、radius 3 / 6 / 9 は `DrawAreaCenter -> DrawAreaFromCenter` 後の completion pass で canvas 内・split 分布・protected floor・連結性回復を満たすことを検証する。
- `tests/test_hex_adapter.gd`: HexMapData から TileMapLayer 用 entry、flat-top / pointy-top の offset cell 変換、表示用 local 座標、HexMapResource / HexOverlayResource / HexMapDocumentResource への変換、HexMapDocumentResource canonical terrain / overlay / object placement / label placement / zone / metadata / dependency schema の save/load、CLEAN-51 clean Resource/API contract として canonical document save/load、adapter roundtrip、catalog TileSet / PackedScene Resource reference、PackedScene object definition、dependency Resource type validation、numeric tile fallbackを使わないmissing catalog assignment validation、object placement の object_id / cell / rotation / variant / properties / spawn_condition schema・adapter mutation・削除cell cleanup、HexObjectDatabaseResource の typed definition / PackedScene scene / Texture2D preview / lookup / tag filter / `.tres` roundtrip、HexLabelDatabaseResource の typed definition / lookup / tag filter / `.tres` roundtrip、document summaryのcells / walls / floors / objects / labels / zones / warnings / dependencies count、HexMapValidationResultのserialization、HexGenerationResultResource の scope / replay / save-load、document validation engine の outside map / orphan payload / missing catalog assignment / missing catalog / missing tile / missing dependency resource / dependency type mismatch / object on wall / object scene missing / duplicate unique object rule と各ruleのpass/fail matrix、phase/progress callback と validation summary progress、movement profile reachability validation の opt-in / blocked important point / unreachable important point / profile id metadata、HexMovementProfileResource の保存roundtripと HexGameplayLayerData の map/document/catalog/object blocker抽出、canonical document adapter roundtrip、canonical payload / deleted cell cleanup、HexMapDocumentAdapter の shape / wall / catalog tile assignment / object / label 保存、削除cellに紐づくpayload cleanup、TileMapLayer 再描画、HexTileCatalogResource / HexTileCatalogEntry の logical key / TileSet resource / atlas tile / PackedScene scene tile / placeholder / tags / sample catalog load、sample catalog の debug path 不在 / packaged PackedScene dependency / validator clean、HexTileCatalogValidator の missing TileSet / missing source / invalid atlas coords / missing scene / tag and custom data extraction、catalog key による floor / wall / overlay item / document tile adapter、missing catalog key が numeric fallback ではなく validation issue になること、Adjacency Rule Set の parse / key正規化 / invalid entry report、Overlay Data の apply policy、Overlay item key から TileMapLayer tile への adapter、TileSet の Hexagon/Stacked/OffsetAxis 設定、sample atlas asset と atlas source 作成を検証する。
- `tests/test_hex_tile_map_layer.gd`: `HexTileMapLayer` の `HexMapResource` 適用、ready前 `hex_map` assignment からの visible sample TileSet / used cell 作成、canonical `HexMapDocumentResource` からの tile assignment / overlay tile / object marker / label marker 表示状態、HexLayerStackResource / HexLayerStackEntryResource の terrain / decoration / object / collision / navigation / overlay / debug role template と保存roundtrip、canonical document の terrain / overlay / object role child apply と plain `TileMapLayer` 互換apply、object layer adapter の scene tile prototype / direct instance prototype、custom floor / wall display tile source、Target TileSet export resource の `PackedScene.pack()` / instantiate 永続性、resource orientation に基づく TileMapLayer 反映、display tile size からの `hex_size` 同期、前面overlay child、セル照会、壁/床編集、legacy local/hex 座標往復、内部 `TileMapLayer.map_to_local()` / `local_to_map()` 基準の `hex_to_display_local()` / hit roundtrip、遠端cell display center、runtime click / hover signal、canonical / visual cell hit、toric / infinite loop identity、toric visual representative、visual cell entry schema、loop duplicate 用 `TileMapLayer` の tile copy 表示、壁/床編集後の duplicate tile 同期、anchor 指定付き loop-aware path、経路・ハイライト・連結性 helper、`find_weighted_path()` / `movement_range()` の profile-specific wall passability、movement range overlay の cost/heat state と clear、単一highlight削除を検証する。
- `tests/test_editor_plugin.gd`: Hex Map Workspace の tab/responsibility map、workspace経由の shared session / viewport input routing、Hex Map Edit / Generate Dock の resource selection、FileDialog callback、shared editor session の target / document / selected resource / saved-path metadata、canonical HexMapDocumentResource の load / edit / save / export、button state、Dock scroll container、Copy Debug Report、catalog selector 由来の floor / wall / overlay / object state、typed object placement Undo/Redo、missing assignment validation、Validation dashboard の domain/severity grouped issue rows / focus target / fix suggestion / cell focus / catalog entry focus、debug report の validation summary、Target readiness、Target由来document保存、viewport input / UndoRedo / toric duplicate edit、modeごとの catalog / object / label state、Generation Dock の generation / validation / batch promotion / source registry / mapdata query / history save、normal UI からの numeric fallback control / editable path text / Apply Layer primary action の排除、HexCellButtonLayout / HexCellButtonPanel、Distribution Editor を headless で検証する。旧 path LineEdit や numeric fallback control の存在は test contract にしない。
- `tests/test_editor_plugin.gd` QA-01 coverage: 生成結果の validation suite pass/fail capture、raw validation result保持、auto apply 前の capture order を headless で検証する。
- `tests/test_editor_plugin.gd` QA-02 coverage: 複数seedの batch generation、validation summary / score row、score table sort、batch結果がcurrent mapへpromoteされないことを headless で検証する。
- `tests/test_editor_plugin.gd` QA-03 coverage: batch rowからのseed promotion、canonical document生成、generation snapshot metadata、保存/再読み込みroundtripを headless で検証する。
- CLEAN-40 manual coverage: `docs/manual/MANUAL_EDITOR_PLUGIN.md` / `docs/manual/MANUAL_WORKFLOW.md` / `docs/manual/MANUAL_SCRIPTING.md` / `README.md` が Catalog、Layer Stack、Object Placement、Validation、Generation QA、Copy Debug Report、Resource picker workflow を user goal として説明し、新規アナログテスト文書を追加しないことを self-review と `./tools/test.sh` で確認する。
- `tests/test_editor_plugin.gd` ARCH-02 coverage: `HexMapGenStateEvaluator` の Generate Dock control visibility / disabled state / label text / generation block reason を pure state input で検証し、既存 Generate Dock headless tests が UI delegation の回帰を検証する。
- `tests/test_editor_plugin.gd` ARCH-NEXT-11 coverage: Generate Dock の run / progress / source registry / output target / save-apply / seed lab / result summary controls が dedicated builder scripts 由来の component owner row と mounted metadata を持ち、`HexMapGenDock` が既存 signal / state binding を維持することを headless で検証する。
- `tests/test_editor_plugin.gd` PERF-NEXT-10 coverage: `HexMapTileAdapter.apply_to_tile_map_layer_chunked()` の chunk progress / target scope / cancellation report、`HexTileMapLayer` selected-document apply report、Generate output target snapshot / run state の last chunked apply report を headless で検証する。
- `tests/test_editor_plugin.gd` / `tests/test_hex_adapter.gd` PERF-NEXT-11 coverage: `HexMapDocumentValidator` の phase/progress callback、Validate workflow state / view state / result summary の completed progress、Generate validation の既存 validating progress state 接続を headless で検証する。
- `tests/test_editor_plugin.gd` / `tests/test_hex_adapter.gd` GENPIPE-NEXT-10 coverage: `HexGenerationResultResource` の scope / replay / save-load、Generate batch row の result Resource、QA scored row の result id / replay availability、result Resource 経由 promotion metadataを headless で検証する。
- GENPIPE-NEXT-20 review coverage: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/GENPIPE-NEXT-20_PIPELINE_GRAPH_UI_RESEARCH_AND_SPIKE/PIPELINE_GRAPH_DECISION.md` が Resource pass detail / linear pipeline stepper / node graph editor optionsを比較し、現roadmapでは editable node graphをreject、future UIは `HexGenerationResultResource.scope_snapshot()` 由来の非editable detail surfaceにscopeすることを記録する。
- `tests/test_editor_plugin.gd` GEN-NEXT-10 coverage: Generate tab の Input / Profile-Source / Preview / Apply-Save / Performance section snapshot、component-to-section ownership、source refresh / Apply to Document / Save As action purpose、Workspace generation screen snapshot への layout exposure を headless で検証する。
- `tests/test_editor_plugin.gd` GEN-NEXT-11 coverage: `HexMapPreviewThumbnail` による Generate current candidate / selected Seed Lab row / QA selected seed preview、score row preview payload、preview budget、sample fallback 不使用、Workspace Generate/QA snapshot exposure を headless で検証する。
- `tests/test_editor_plugin.gd` CAT-NEXT-11 coverage: `HexTileCatalogPreviewControl` による Catalog atlas tile texture-region preview / scene resource preview / unavailable badge tooltip、mounted Catalog detail preview snapshot、sample fallback 不使用を headless で検証する。
- `tests/test_editor_plugin.gd` ARCH-03 coverage: `HexMapEditMutationBuilder` の document edit / `HexTileMapLayer` command construction と `HexMapEditViewportInputAdapter` の viewport press filtering / local trace / hit editabilityを検証し、既存 viewport hit/edit/undo tests が Edit Dock delegation の回帰を検証する。
- `tests/test_editor_plugin.gd` ARCH-04 coverage: `HexMapDocumentInspector` の document summary / validation summary / validation issue row formatting、Edit Dock inspector integration、既存 Edit / Generate validation debug summary behaviorを headless で検証する。
- `tests/test_editor_plugin.gd` ASSET-10 coverage: `HexMapEditorAssetSlotState` / `HexMapEditorAssetSlotControl` の Not selected / Selected / Invalid / Warning、Resource type mismatch、optional sample source、explicit sample application、compact row layout / collapsed details、state snapshot contractを headless で検証し、private widget 名には依存しない。
- `tests/test_editor_plugin.gd` ASSET-11 coverage: `HexMapWorkspaceAssetContext` が Document / Catalog / Object DB / Label DB / Layer Stack / Movement Profile / Validation Suite / Generation Profile / Export Profile を保持し、`HexMapEditorSessionState` / Workspace / Generate / Paint が同じcontextを参照し、Paintのproject asset選択がcontext経由でGenerateへ共有されることを headless で検証する。
- `tests/test_editor_plugin.gd` ASSET-12 coverage: asset slot の `Create New...` Save As config / selected path signal、`HexMapWorkspaceAssetResourceFactory` による Level Document / Catalog / Object DB / Label DB / Layer Stack / Movement Profile / Validation Suite / Generation Profile / Export Profile の `.tres` 作成、workspace asset context assignment、sample payload 不混入を headless で検証する。
- `tests/test_editor_plugin.gd` ASSET-30 / PROFILE-30 coverage: Workspace asset slot の concrete ResourcePicker base type、tooltip expected type、generic `Resource` filter 不使用、Validation Rule Suite / Generation Profile / Export Profile が `HexValidationRuleSuiteResource` / `HexGenerationProfileResource` / `HexExportProfileResource` を要求することを headless で検証する。
- `tests/test_editor_plugin.gd` ASSET-31 coverage: asset slot row の `Select...` / `Open` / `Clear` / `Validate` redundant action button 不在、`Create New...` と explicit sample action の維持を headless で検証する。
- `tests/test_editor_plugin.gd` ASSET-32 coverage: `Create New...` の workspace button path が project resource を作成して asset context / row state を更新すること、explicit sample action の button path が sample source を選択して signal を出すこと、Settings sample row の未実装 `Open` が visible UI から削除されていることを headless で検証する。
- `tests/test_editor_plugin.gd` SAMPLE-10 coverage: Workspace Settings tab の `HexMapSampleSettingsPanel`、sample visibility default OFF、sample mode ON でも Generate/Paint catalog source が自動sampleにならないこと、main UI sample controls hiding、sample mode ON 時の project catalog precedence を headless で検証する。
- `tests/test_editor_plugin.gd` SAMPLE-11 coverage: `HexMapSampleAssetDuplicator` による sample catalog / tile texture / object scene の project path への複製、duplicated catalog の TileSet / scene entry dependency rewrite、workspace asset context assignment、duplicate action 前に sample が silently assigned されないことを headless で検証する。
- `tests/test_editor_plugin.gd` SAMPLE-12 coverage: Workspace の first-run `Learn with bundled samples` CTA visibility、Settings tab routing、dismiss state、same-session non-reappearance、sample mode flag / sample catalog assignment 不変更を headless で検証する。
- `tests/test_editor_plugin.gd` SAMPLE-40 coverage: Settings sample catalog row の functional `Duplicate To Project` button path が save path から catalog / texture / scene の project copy を作成し、Catalog slot を `SOURCE_PROJECT` として更新し、Generate / Paint catalog と Settings status snapshot に反映されること、`Open` は未実装のため absent のままであることを headless で検証する。
- `tests/test_editor_plugin.gd` WORKSPACE-10 coverage: Resources / Catalog / Layers / Validate / QA / Export / Settings の real workspace component mounting、tab-owned asset slot count / slot id、workspace tab root の ScrollContainer 化、shared workspace asset context への同期、Paint tab が setup asset panel を持たないことを headless で検証する。
- `tests/test_editor_plugin.gd` WORKSPACE-11 coverage: `tab_component_ids()` / `tab_asset_slot_ids()` registry contract として Catalog の `catalog_asset_panel` / `tile_catalog`、Validate の `validation_issue_navigator`、QA の `generation_profile` を private node 名に依存せず headless で検証する。
- `tests/test_editor_plugin.gd` NODE-21 coverage: `HexMapEditorSessionState` / Workspace の selected HexTileMap auto-link default ON、`No HexTileMap selected` empty state、Scene Tree selection hook source wiring、`HexTileMapLayer` / internal display layer selection mapping、selected node Layer Stack context sync、Level Document が authoring source として表示されること、`hex_map` が runtime display snapshot / target snapshot として扱われること、Edit Tool target status が `authoring=Level Document` と `runtime_snapshot` を分離して表示することを headless で検証する。
- `tests/test_editor_plugin.gd` NODE-22 coverage: selected HexTileMap の missing unique resource snapshot、save directory folder picker config、safe prefix/default file names、missing Level Document / Layer Stack `.tres` 作成、selected node への auto-reference、workspace/session context sync、既存unique resource preservation、SharedResource非作成、既に選択済みの shared project resources が新規 Level Document の dependencies へ同期されることを headless で検証する。
- `tests/test_editor_plugin.gd` NODE-23 coverage: Workspace asset context / ResourcePicker 相当の slot change から selected HexTileMap への Level Document / Layer Stack write-back、Tile Catalog / Object DB / Label DB の shared context policy、node/workspace relationship snapshot、auto-link OFF / no selected node の blocked reason を headless で検証する。
- `tests/test_editor_plugin.gd` NODE-24 coverage: Generate Output target の Preview only / Apply to selected Document 分離、preview が Level Document を変更しないこと、Apply が selected HexTileMap の Level Document / workspace relationship / generation metadata を更新すること、no selected node の blocked reason を headless で検証する。
- `tests/test_editor_plugin.gd` TEST-41 coverage: `workspace_tab_names()` / `component_rows()` / `components_for_tab()` / `tab_component_ids()` / `tab_asset_slot_ids()` / `asset_slot_count()` / `tab_has_component()` / `tab_has_scroll_container()` により全 workspace tab の component id、asset slot id、scroll root、component metadata、Paint tab の非Document責務、未知tabの空結果を private node path 非依存で headless 検証する。
- `tests/test_editor_plugin.gd` SCREEN-20 coverage: Resources tab の Level Document asset slot / dependency slot visibility、project `.tres` create / open / Save As / clear、session saved path sync、structured validation result、sample mode / sample catalog non-injection を headless で検証する。
- `tests/test_editor_plugin.gd` TAB-50 coverage: visible tab label が `Resources` であること、Resources screen の selected HexTileMap snapshot、Unique / Shared / Optional resource groups、resource purpose tooltip、`Create Missing Resources` action presence、legacy `Document` query aliasを headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-21 coverage: Catalog tab の project Tile Catalog create / open / Save As / clear、arbitrary TileSet assignment、TileSet 由来 atlas entry 作成、PackedScene 由来 scene entry 作成、catalog validation、sample mode OFF で sample catalog candidate / fallback が出ないことを headless で検証する。
- `tests/test_editor_plugin.gd` TAB-52 coverage: Catalog entry row/detail snapshot、entry meaning、Tile / Scene preview availability、placeholder preview absence reason、source_id / atlas_coords が primary input ではなく metadata であることを headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-22 / TAB-53 coverage: Layers tab の project Layer Stack create / open / Save As / clear、standard template duplicate-to-project、selected HexTileMap と Layer Stack の relationship、terrain / overlay / object / debug / collision / navigation role rows、visible / locked / writable status、scene root からの HexTileMapLayer target resolution、Create Missing Layers / Apply Document / Clear Role、sample mode OFF で sample template default が出ないことを headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-23 coverage: Resources tab の project Object Database / Label Database create / open / Save As / clear、Paint tool への同期、PackedScene 由来 Object Definition 作成、Object Definition picker 由来 placement payload、typed Label Definition 作成、Label Definition picker 由来 placement payload、sample mode OFF で sample object scene が silent assignment されないことを headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-24 coverage: Paint brush snapshot の terrain / overlay / object / label mode、Catalog/Object/Label asset missing CTA、catalog key / Object Definition / Label Definition 由来 brush ready state、source_id / atlas coords / raw object id / raw label id control 非表示、Object/Label ResourcePicker row 非表示、Zone mode deferred、sample mode OFF を headless で検証する。
- `tests/test_editor_plugin.gd` TAB-51 coverage: viewport edit が Paint tab へ切り替わること、Paint workspace snapshot が active document / active layer / selected cell / last edit / undo hint を持つこと、Paint tab が ResourcePicker asset slot を持たず Object/Label missing CTA が Resources を指すことを headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-25 / TAB-54 coverage: Validate tab の asset slot / issue navigator、purpose / target summary、missing Level Document / Tile Catalog / Object Database / Label Database / Layer Stack / Validation Rule Suite / Generation Profile が sample fallback ではなく route metadata 付き validation issue になること、issue row の severity / domain / focus target / fix suggestion / destination / suggested action、issue 選択で Resources / Catalog / Layers / Paint へ移動すること、last issue rows と sample mode OFF を headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-26 / TAB-55 coverage: QA tab の project Generation Profile / Validation Rule Suite create / open / Save As / clear、built-in generation / validation preset duplicate-to-project、Seed Lab purpose / Generate-vs-QA role / score rows / selected seed / promotion target、promoted seed が Resources の Level Document relationship を更新すること、sample mode OFF を headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-27 / TAB-56 coverage: Export tab の purpose / Runtime Handoff output type / Level Document source / `HexMapResource` target、Level Document / Export Profile asset slot、Export Profile create / open / Save As / clear、Save As FileDialog destination config、user-selected destination / recent destination state、destination 未選択 export refusal、Data Export / Package Build / Debug Report export controls が hidden/backlog/process/diagnostic 分類になること、`HexMapResource` package/runtime handoff、sample destination 不在と sample mode OFF を headless で検証する。
- `tests/test_editor_plugin.gd` TAB-57 coverage: Settings tab が preferences/debug purpose panel と Sample learning controls のみを持ち、production asset slot を持たないこと、Movement Profile が Resources の Optional resource として選択できること、debug numeric fallback が Settings snapshot に隔離され、sample action が functional/removed contract を満たすことを headless で検証する。
- TEST-80 split coverage: `tests/test_workspace_state_transitions.gd` / `tests/test_asset_slot_state.gd` / `tests/test_generation_run_state.gd` / `tests/test_paint_interaction_state.gd` / `tests/test_workspace_screen_contracts.gd` が state transition、hydration/writeback、asset slot ViewState、Generate/Paint state、screen contractを分割検証し、`tests/test_editor_plugin.gd` はintegration-heavy workflow検証に残す。新規analog testは追加しない。
- PERF-60 review coverage: `docs/review/roadmap/GENERATE_PERFORMANCE_BUDGET_2026-06-10.md` が map size別の generation / validation / visual apply budget、orientation等のglobal update分類、budget超過時のprogress / busy / cancel方針、chunked apply必要性を記録し、`./tools/test.sh` と self-reviewでbudget review完了を確認する。
- `tests/test_editor_plugin.gd` PERF-61 coverage: Generate の ProgressBar が Preparing / Generating / Validating / Applying / Ready の current step text と cancellability を示し、orientation/tile settings apply が inline progress completion を表示し、modal busy window を作らないことを headless で検証する。
- `tests/test_editor_plugin.gd` PERF-62 coverage: repeated orientation/tile setting/catalog preview changes が debounce pending state と queued progress を表示し、連続変更を一回の tile settings apply に coalesce して completion progress に戻ることを headless で検証する。
- `tests/test_editor_plugin.gd` INFO-70 coverage: Level Document / TileSet / Tile Catalog / Layer Stack / Object DB / Label DB / Movement Profile / Generation Profile / Validation Suite / Export Profile の tooltip が pick type / Resource type / purpose を持ち、長い purpose を通常表示row textに出さないことを headless で検証する。
- `tests/test_editor_plugin.gd` INFO-71 coverage: Resources / Paint / Catalog / Layers / Validate / QA / Export / Settings の first-run empty state が tab purpose、短い empty text、1-2個の next action、tooltip/help detail を持ち、production tab の primary action が bundled sample で未設定を埋めないことを headless で検証する。
- `tests/test_editor_plugin.gd` INFO-72 coverage: Export tab の active/visible output mode が Runtime Handoff のみで、Data Export / Package Build / Debug Report は分類済みだが active visible output ではないことを headless で検証し、terminology decision は `docs/review/roadmap/EXPORT_TERMINOLOGY_DECISION_2026-06-08.md` に記録する。
- GENPIPE-80 review coverage: `docs/review/roadmap/GENERATION_PIPELINE_STATE_CONCEPT_2026-06-10.md` が final Level Document と intermediate generation data の境界、primary / overlay / filter / candidate map の扱い、Resource pass / linear pipeline / node graph候補比較を記録し、Generate tab を肥大化させない判断を確認する。
- GEN-81 model coverage: `docs/review/roadmap/GENERATION_PROFILE_RESULT_MODEL_2026-06-08.md` が Generation Profile / Preview / Result / Level Document の境界、QA Seed Lab との整合、document metadata provenance、将来 schema test 条件を定義し、graph editor を out of scope とする。
- DOC-90 manual coverage: `docs/manual/MANUAL_EDITOR_PLUGIN.md` / `docs/manual/MANUAL_WORKFLOW.md` / `README.md` が selected HexTileMap -> Resources -> Generate -> Paint -> Catalog -> Validate -> QA -> Export flow、Resource source badges (`Node` / `Project` / `Document Dependency` / `Manual Override` / `Sample Learning` / `Missing`)、sample learning flow、selected HexTileMap auto resource sync、Generate output target / Apply to selected Document を説明し、新規アナログテスト文書を追加しないことを self-review と `./tools/test.sh` で確認する。
- `tests/test_editor_plugin.gd` TEST-40 coverage: feature screen completion contract として Resources / Catalog / Layers / Validate / QA / Export の project asset slot が sample mode OFF で `SOURCE_PROJECT` になること、Catalog が任意 TileSet を保持すること、Export destination が user project path であることを headless で検証し、sample mode ON/OFF は Settings / Samples test、bundled sample asset validity は `tools/package_addon.sh --check` と sample catalog adapter test に分離する。
- `tests/test_editor_plugin.gd` CLEANUP-30 coverage: Settings の debug numeric fallback default OFF / explicit opt-in、plain `TileMapLayer` normal apply が missing catalog を numeric fallback で埋めないこと、debug opt-in 時だけ numeric fallback source/atlas を適用すること、missing catalog assignment が validation issue のまま残ることを headless で検証する。
- `tests/test_editor_plugin.gd` CLEANUP-31 coverage: Overlay item key / Label ID / Object variant / Spawn condition / Object property key-value が selector / definition / enum / schema source を持つこと、normal UI で raw overlay key / label id / object variant / spawn condition / raw JSON properties / property table が非表示であることを headless で検証する。
- `tests/test_editor_plugin.gd` TEST-42 coverage: `HexMapEditorAssetSlotState` の required missing / invalid type / selected project / optional sample candidate / explicit sample source warning、sample mode OFF/ON の main selector learning candidate visibility、direct bundled sample Catalog selection の `SOURCE_SAMPLE` warning / Generate-Paint non-use、sample duplicate-to-project 後の Catalog slot `SOURCE_PROJECT` / project path / metadata / Generate-Paint project primary stateを headless で検証する。
- `tests/test_editor_plugin.gd` PKG-70 coverage: package learning sample contract として sample catalog / tile texture / object scene の ResourceLoader accessibility、sample catalog の floor/wall/object scene entry、Settings / Samples の sample asset rows、sample mode OFF/ON の Generate/Paint 非inject、project catalog primary stateを headless で検証し、`tools/package_addon.sh --check` が manifest/zip への sample 同梱を検証する。
- `tests/test_editor_plugin.gd` SAMPLE-41 coverage: sample mode ON でも Generate / Paint が bundled sample catalog を execution fallback にしないこと、direct bundled sample selection が `SOURCE_SAMPLE` warning になり Generate/Paint source にならないこと、duplicated project copy だけが production source になることを headless で検証する。
- `tests/test_editor_plugin.gd` FB-01 coverage: `HexMapEditorPathSelector` の dialog attach helper が未parent dialogだけをattachし、既にtree内にあるdialog nodeをreparent / double-addしないこと、Distribution Editor の Save New / Load dialog contract が FileDialog config として表現され、headless test では実 popup に依存しないことを検証する。
- `tests/test_editor_plugin.gd` FB-02 coverage: Resource row の visible `Details` button 不在、Workspace asset slot の Select/Open/Clear/Validate/Details placeholder action 不在、Export / Missing Unique Resources の disabled action tooltip が unmet condition を説明することを headless で検証する。
- `tests/test_hex_adapter.gd` RES-10 coverage: `HexMapDocumentDependencyService` の shared dependency key、add/find/update/remove、role付き dependency id、Tile Catalog / Object DB / Label DB / Movement Profile / Validation Suite / Generation Profile / Export Profile hydration、required/optional missing validation、Movement Profile type mismatch validationを headless で検証する。
- `tests/test_editor_plugin.gd` RES-11 coverage: selected Level Document の dependencies から Tile Catalog / Object DB / Label DB / Movement Profile / Validation Suite / Generation Profile / Export Profile が Workspace context へ hydrate され、asset row / source snapshot が `Document Dependency` badge を持つこと、missing dependency が sample fallback なしで missing のまま残ること、manual project override が rehydrate より優先されることを headless で検証する。
- `tests/test_editor_plugin.gd` NODE-20 coverage: `HexMapWorkspaceBindingService` による selected `HexTileMapLayer` / internal `TileMapLayer` 解決、selected node の Level Document / Layer Stack read、selected document dependencies からの shared context hydrate、Workspace の node-owned Resource writeback、Tile Catalog / Object DB / Label DB / Movement Profile / Validation Suite / Generation Profile / Export Profile の document dependency writeback を headless で検証する。
- `tests/test_editor_plugin.gd` PROFILE-30 coverage: Validation Rule Suite / Generation Profile / Export Profile の create / duplicate preset / picker filter / factory output が concrete profile Resource class を使い、sample placeholder Resource を completion proof にしないことを headless で検証する。
- `tests/test_editor_plugin.gd` / `tests/test_hex_adapter.gd` PROFILE-31 coverage: Validation Rule Suite / Generation Profile / Export Profile の document dependency hydration が concrete Resource class と `Document Dependency` source badge を QA / Validate / Export tab state に反映し、missing profile は optional/missing state として残り、generic `Resource` profile dependency は type mismatch validation issue になることを headless で検証する。
- `tests/test_editor_plugin.gd` / `tests/test_hex_adapter.gd` PROFILE-NEXT-10 coverage: Validation Rule Suite / Generation Profile / Export Profile の concrete behavior schema、schema helper / save-load roundtrip、project-created and preset profile defaults、Validate / QA / Export screen context の `behavior_schema` 接続、optional missing state で sample schema を注入しないことを headless で検証する。
- STATE-00 review coverage: `docs/review/roadmap/UI_FLAG_INVENTORY_2026-06-10.md` が Generate / Workspace binding / Asset slot / Paint / Validation / Export / Sample / Dialog の flag inventory、P0/P1/P2 state-machine priority、旧UI test disposition を記録し、`./tools/test.sh` と self-review で完了を確認する。
- `tests/test_editor_plugin.gd` STATE-10 coverage: `HexMapGenerationRunState` が Generate の idle / generated preview / preparing / cancelling / cancelled / tile-setting queued / tile-setting applied state、ViewState source、progress snapshot source、orientation/tile setting heavy update reasonを headless で検証する。
- `tests/test_editor_plugin.gd` STATE-20 coverage: `HexMapEditorAssetSlotState` の config / runtime / validation / sample / operation / ViewState 分離、Missing / Optional / OK / Invalid / Warning status kind、Asset Slot control の ViewState rendering、Create New / Apply Sample operation resultを headless で検証する。
- `tests/test_editor_plugin.gd` STATE-30 coverage: `HexMapWorkspaceBindingService` selection/binding state が no target / selected node without document / hydrated dependencies / manual override / pending writeback / applied writeback / conflict を ViewState付きで headless 検証する。
- `tests/test_editor_plugin.gd` STATE-40 coverage: `HexMapPaintInteractionState` が Paint の missing target / missing document / missing asset / ready brush / viewport hover / selected cell / applied dirty / validation focus state、Workspace Paint ViewState source、active layer / brush / selected cell renderingを headless で検証する。
- `tests/test_editor_plugin.gd` STATE-50 coverage: `HexMapValidationWorkflowState` / `HexMapExportWorkflowState` / `HexMapSampleLearningState` / `HexMapDialogLifecycleState` が Validation の not_run / running / clean / warning / error / issue_selected / focus_applied、Export の no_destination / ready / exporting / exported / failed、Sample の off / learning_available / duplicated_to_project / sample_source_selected、Dialog の closed / opening / waiting_user / committed / cancelled と Workspace ViewState sourceを headless で検証する。
- `tests/test_editor_plugin.gd` STATE-60 coverage: `HexMapWorkspaceRootState` / `HexMapWorkspaceDispatcher` が root snapshot / root ViewState / screen ViewState composition、select-tab / validation / issue-focus / export-destination / sample-learning dispatch envelope、state snapshot由来 debug report を headless で検証する。
- UI-00 coverage: `WORKSPACE_SCREEN_CONTRACT.md` / `WORKSPACE_STATE_MACHINE.md` / `VISIBLE_CONTROL_INVENTORY.md` / `RESOURCE_ROW_SPEC.md` / `DEBUG_LABEL_POLICY.md` が Workspace normal UI、tooltip/detail、debug report、Generate caution、Resource row compact/adaptive contractを定義し、`./tools/test.sh` と self-review で確認する。
- `tests/test_workspace_layout_metrics.gd` UI-METRIC-03 coverage: `HexUILayoutSnapshotCollector` / `HexUIStateScenarioBuilder` が no selected HexTileMap、selected HexTileMap without resources、selected HexTileMap with shared resources のシナリオと複数 viewport size で Workspace を構築し、visible Control の rect / minimum size / text / base_type / tooltip / scroll parent / metadata と JSON serialization を headless で検証する。このテストは collector contract のみを標準検証し、metric WARN/P0/P1 gate は後続 task まで report-only 境界として扱う。
- `tests/test_workspace_layout_metric_evaluator.gd` UI-METRIC-04 coverage: `HexUILayoutMetricEvaluator` が text truncation、resource row geometry、scroll reachability、dead area、debug leakage、no-op action、picker specificity、state contradiction を severity `warn` の report として出し、runtime Workspace snapshot の warning count を fail gate にしないことを headless で検証する。
- `tests/test_workspace_layout_metric_evaluator.gd` UI-METRIC-05 coverage: `HexUILayoutMetricEvaluator.evaluate_p0()` が visible no-op button、missing required scroll、state contradiction、sample fallback in production、debug leakage、required generic Resource picker、unreachable primary action を severity `p0` の failure report として出し、clean synthetic snapshot では `passed=true` になることを headless で検証する。実際の Workspace P0 report を `tools/test.sh` の failure gate に接続する処理は `UI-METRIC-07` で行う。
- `tests/test_workspace_layout_metric_evaluator.gd` UI-METRIC-06 coverage: `HexUILayoutMetricEvaluator.evaluate_p1()` が resource row compression、normal width label truncation、large dead area、disabled action without tooltip、summary-only task tab を severity `p1` の issue report として出し、clean synthetic snapshot では `passed=true` になることを headless で検証する。P1 の標準 test failure integration は `UI-METRIC-07` 以降に分離する。
- `tests/test_workspace_layout_metric_gate.gd` UI-METRIC-07 coverage: no selected HexTileMap、selected HexTileMap without resources、selected HexTileMap with shared resources の runtime Workspace snapshot に対して P0/P1 metric reports を作成し、`.godot_user/ui-metrics/<run-id>/workspace_layout_metrics.json` と `.md` を出力し、P0 failures が 0 であることを標準テストで検証する。P1 issue count は report-only として記録する。
- `tests/test_editor_plugin.gd` UI-01 coverage: `HexMapEditorAssetSlotControl` が adaptive two-line row、visible status word removal、status swatch/icon id、tooltip detail、Details button absence、Create New / explicit sample action visibilityを headless で検証する。
- `tests/test_editor_plugin.gd` UI-02 coverage: Settings / Sample Settings が CheckBoxによるboolean state、debug enabled/disabled label非表示、sample row path非表示、sample duplicate result pathのtooltip/snapshot移動を headless で検証する。
- `tests/test_editor_plugin.gd` UI-03 coverage: Generate screen snapshot / output target snapshot が unblocked empty-state非表示、preview/document/apply/save result summary、blocked ViewState reason、source registry Refresh Source wordingを headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-10 coverage: Resources screen snapshot が selected HexTileMap summary、node path非表示、required/shared/optional readiness count、missing-resource next actions、Node / Document Dependency / Manual Override / Missing source badge説明を headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-NEXT-10 coverage: Resources readiness board、Layers role tree summary、Export runtime handoff readiness summary、mounted summary label、path primary text不使用を headless で検証する。
- `tests/test_editor_plugin.gd` LAYER-NEXT-10 coverage: Layers Role Editor の selected role / visible / locked / z-index / writable source control contract、missing role resource edit、created/existing target role node reflection を headless で検証する。
- `tests/test_editor_plugin.gd` PAINT-NEXT-10 coverage: Paint affordance board の cursor / mode / target / selected cell / last edit row、mounted affordance text、viewport click 後の Workspace Paint snapshot sync を headless で検証する。
- `tests/test_editor_plugin.gd` VAL-NEXT-10 coverage: Validate issue table の severity / domain / scope / target / suggestion / actions columns、real focus action metadata、mounted issue table text、workspace/cell-scoped routingを headless で検証する。
- `tests/test_editor_plugin.gd` QA-NEXT-10 coverage: QA scored table の rank / seed / score / validation / selected / preview / promotion columns、mounted score table row count/text、selected row state、promoted row stateを headless で検証する。
- `tests/test_editor_plugin.gd` SETTINGS-NEXT-10 coverage: Settings の Sample Learning / Debug / Project Defaults / UI Preferences group、CheckBox boolean controls、tooltip detail、sample/debug ownership separationを headless で検証する。
- `tests/test_editor_plugin.gd` SAMPLE-NEXT-10 coverage: Settings Sample detail drawer の asset type / dependencies / duplicate target / learning use / mounted detail text、duplicate 後 project-owned target、production injection 不在を headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-20 coverage: Catalog screen snapshot が entry list/detail/preview/tags/status/create/edit/validate ownershipを持ち、Paint snapshot が catalog entry management非表示、catalog key consumption、raw source/atlas metadata非primaryを headless で検証する。
- `tests/test_editor_plugin.gd` CAT-NEXT-10 coverage: `HexMapCatalogEditorComponent` が Catalog entry list/detail/create/validate の owner row を持ち、Workspace Catalog snapshot / EditTool catalog helper paths が dedicated component 経由で既存 Catalog entry detail と Paint catalog key consumption を維持することを headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-21 coverage: Resources が document save/dependency/dirty、Layers が Layer Stack role/template/action、Export が Runtime Handoff destination/output/run ownershipを持ち、Paint snapshot が document/layer/export management controls非表示かつ active document/target context維持を headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-22 coverage: Paint snapshot が empty state、active brush、target layer、selected cell、last edit、visible surface summary、viewport edit state更新、resource-reference-onlyでないことを headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-23 coverage: Validate snapshot が workflow run action、issue navigator/list、severity/scope/focus action、issue click tab/resource/cell routing、slot-level Validate button不在、Paint validation dashboard非表示を headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-24 coverage: QA snapshot が Generation Profile context、score table、selected seed、promote target、Level Document source-of-truth、draft/promotion boundary、promotion Resources updateを headless で検証する。
- `tests/test_editor_plugin.gd` SCREEN-25 coverage: Export snapshot が Runtime Handoff active output、data/package/debug分類、destination purpose、result usage、Export result state、unsupported export button非表示を headless で検証する。
- `tests/test_editor_plugin.gd` ARCH-40 coverage: `HexMapWorkspaceBindingService` が writeback snapshot、document dependency hydration snapshot、shared dependency sync を所有し、Workspace が service result を表示・反映することを headless で検証する。
- `tests/test_editor_plugin.gd` ARCH-41 coverage: Resources / Paint / Catalog / Layers / Validate / QA / Export の screen role script が tab/workflow/user task に対応し、Workspace/EditTool Paint snapshot が Catalog/Document/Layer/Export責務を delegated owner として扱うことを headless で検証する。
- `tests/test_editor_plugin.gd` ARCH-NEXT-10 coverage: Resources / Catalog / Layers / Validate / QA / Export / Settings の physical Workspace panel construction が screen script builder に移り、component registry / mounted node metadata / screen script owner rows が同じ screen owner を示すことを headless で検証する。
- `tests/test_hex_tile_map_layer.gd` ARCH-50 coverage: `HexTileMapResourceBinding` と `HexMapDocumentApplier` が map/document apply preparation を所有し、`HexTileMapLayer` が coordinator role として既存 runtime helper / display apply behavior を維持することを headless で検証する。
- `tests/test_editor_plugin.gd` PKG-71 coverage: clean project package contract として plugin.cfg / plugin script load、sample mode OFF の非inject、asset selection 前の missing Level Document / Tile Catalog / Object Database validation issue、project Level Document / Tile Catalog / Object Database creation、user TileSet 由来 catalog entry、user PackedScene 由来 Object Definition、selection後の missing asset validation解消、`tools/package_addon.sh --check` PASSを headless で検証する。
- `tests/test_hex_map_generation.gd` QA-04 coverage: `docs/test/fixtures/qa04_golden_seed_previews_2026-06-07.json` の golden seed fixture を読み込み、rectangle / symmetric toric square の summary、deterministic score、wall keys、ASCII preview rows が current generator output と一致することを検証する。
- `tests/test_debug_scenes.gd`: debug scene の生成形状切替、toric 表示 domain、loop path / cell hit / movement range 表示状態、runtime loop duplicate tile copy 状態、runtime helper による canonical `HexMapDocumentResource` resource/path load と terrain / overlay / object / label 適用、`examples/basic_runtime/runtime_query_sample.gd` による document Resource first query / supplemental path helper / weighted path / movement range query / object runtime export copy、`examples/basic_runtime/runtime_query_example.tscn` と `examples/editor_workflow/editor_workflow_example.tscn` の Resource first runtime query / supplemental path helper / runtime-safe preload / sample canonical document builder、対称生成 overlay が toric canvas 全体を網羅すること、phase2 grouping 表示用データを検証する。


## 実行

```sh
./tools/test.sh
```

複数 test script を並列実行する場合:

```sh
TEST_JOBS=3 ./tools/test.sh
```

Godot の実行ファイルを明示する場合:

```sh
GODOT_BIN=/path/to/Godot ./tools/test.sh
```

Godot が出す終了コード 0の macOS 証明書関連の非致命的な ERROR は既知であり無視します。

## Debug 実行

Hex Map Workspace の手動確認:

1. Godot Editorで addon を有効にし、`Hex Map Workspace` Dock が表示されることを確認する。
2. Hex Map Workspace の `Resources` で `HexMapDocumentResource` を作成または選択し、必要なら `Create Missing Resources` で選択中 HexTileMap の node-owned resource を作成する。
3. Targetで編集対象の `TileMapLayer` または `HexTileMapLayer` を選ぶ。
4. `Target Status` に target class、TileSet readiness、floor / wall atlas、used cell count、`HexTileMapLayer` の loop state が表示されることを確認する。
5. `Edit Mode` を `Shape` / `Wall / Floor` / `Floor Tile` / `Wall Tile` / `Object` / `Label` に切り替え、viewport上のhex cellをclickする。
6. `Last Edit` に canonical / visual cell、document mutation、target apply、display tile change、tile atlas before / after、target used cell count before / after が表示されることを確認する。
7. Undo / Redoで document と TileMapLayer 表示が同時に戻ることを確認する。
8. `Resources` の Resource picker / `Create New...` で documentを選択または作成し、保存後は Level Document の resource path / Dirty 状態が分かることを確認する。
9. `Export` の Runtime Handoff で `HexMapResource` を作成し、handoff status に path、resource class、cell count、wall count が表示されることを確認する。
10. `HexTileMapLayer` の toric loop表示では、複製表示されたcellが outline だけでなく floor / wall tile として表示されることを確認する。
11. 複製表示されたcellをclickしてcanonical cellが編集され、Undo / Redo 後も canonical cell と duplicate tile が同じ floor / wall 状態へ戻ることを確認する。
12. 連続して別cellを編集したとき、highlight が最後の canonical cell だけに残ることを確認する。
13. `Copy Debug Report` を押し、Target Status / Last Edit / Runtime Handoff status / raw statusを含む報告用textが一括copyできることを確認する。
14. `HexTileMapLayer` targetでは、内部 `TileMapLayer` をScene Treeで選んでも `Target Status` が親 `HexTileMapLayer` として解決されることを確認する。
15. 選択不能cellをclickして `No editable cell.` が出た後、visible cellをclickして編集・highlight・Last Editが更新されることを確認する。
16. `Target TileSet / Atlas` の `Browse` またはsample presetでTarget TileSetを設定し、Target StatusにTileSet path / source count / tile size / overlay payload / overlay visibilityが表示されることを確認する。
17. `Catalog` で Catalog Resource / TileSet / Scene Entry Resource を選択し、entry list に key / type / preview / tags / status が表示されることを確認する。
18. `Add Atlas Entry` / `Add Scene Entry` / `Validate Catalog` を実行し、scene entry が PackedScene resource を保持し、missing entry がstatus issueとして表示されることを確認する。
19. Floor Tile / Wall Tile / Overlay Tile / Object の通常操作では catalog key / object key を選び、source id / atlas coords / object_id を通常paint UIで直接編集しないことを確認する。
20. Object modeで Object Database を選び、definition list、Definition Scene、Object Key、typed Placement Properties が表示され、raw JSON properties textを通常操作で使わないことを確認する。
21. bool / number / string / enum のPlacement Propertiesを変更し、配置後のdocument object placement propertiesに反映されることを確認する。
22. `Layer Stack` で template、role list、visible / locked / z / writable を確認し、HexTileMapLayer targetで `Create Missing Layers` / `Apply Document` / `Clear Role` が動作することを確認する。
23. Generate Dockの `Seed Lab` で複数seed batchを実行し、score table、selected seed preview、`Promote to Document`、Dirty/metadata statusが表示されることを確認する。
24. `Select Internal TileMapLayer` を押し、内部表示layerが選択されてもAuto targetが親 `HexTileMapLayer` に戻ることを確認する。
25. Floor Tile / Wall Tile / Overlay Tileを切り替え、各modeのpayloadが混ざらないことを確認する。
26. Sceneを保存して開き直し、Target TileSet / atlas sourceが維持されることを確認する。
27. Godot Output Dockに `EditorUndoRedoManager.add_do_method` errorが出ないことを確認する。

flat-top/pointy-top の視覚的な近傍配置確認:

```sh
./tools/debug_hex_orientation.sh
```

この画面は `HexMapTileAdapter.hex_to_local()` の結果をそのまま表示する手動確認用です。`Both` / `Flat` / `Pointy` / `Parity` / `Custom` で表示ケースを切り替えます。`Parity` は Unity の `HexPoint.coord()` 相当の offset 変換を経由し、中心点の R 偶奇が違う場合の近傍配置を比較します。`Custom` は flat-top/pointy-top と中心座標 `q/s/r` を入力して近傍配置を確認します。

生成マップの視覚確認:

```sh
./tools/debug_generated_map.sh
```

この画面は `HexMapGenerator` の rectangle / hexagon / toric square 生成結果を `HexMapTileAdapter.hex_to_local()` で描画する手動確認用です。`Space` で seed 更新、`Tab` で形状切り替え、`R` で連結性回復の切り替え、`O` で flat-top/pointy-top、`P` で中心から代表 floor への経路表示、`L` で toric loop path 表示、`C` でクリック/hover cell hit 表示、`S` で toric square の 9 分割 overlay、`Y` で対称生成の外周から中心へ進む領域 overlay、`D` で toric square の square/hex domain 表示、`U` で同一 toric cell を糊代として複数配置する展開表示、`N` で toric square の一辺サイズを切り替え、`G` で toric square の通常ランダム生成 / 対称生成を切り替えます。サイズは `7` / `8` / `9` / `11` / `13` / `19` を確認します。`7` / `13` / `19` は Generation Radius `3` / `6` / `9` に対応する `radius % 3 == 0` の目視確認に使います。

対称 toric square 版の機能:

- toric square の生成結果表示: `G` で `mode=symmetric` にして確認する
- 連結性回復と経路表示: `R` / `P` で通常 toric と同様に確認する
- 9 分割 overlay: odd N で `S` を有効にして確認する
- 対称生成領域 overlay: odd N で `Y` を有効にして、生成結果と外周から中心への領域を重ねて確認する
- square/hex domain 表示: `D` で通常 toric と同様に確認する
- 糊代つき展開表示: `U` で通常 toric と同様に確認する
