
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
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`

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
- `tests/test_hex_adapter.gd`: HexMapData から TileMapLayer 用 entry、flat-top / pointy-top の offset cell 変換、表示用 local 座標、HexMapResource / HexOverlayResource / HexMapDocumentResource への変換、HexMapDocumentResource canonical terrain / overlay / object placement / label placement / zone / metadata / dependency schema の save/load、CLEAN-51 clean Resource/API contract として canonical document save/load、adapter roundtrip、catalog TileSet / PackedScene Resource reference、PackedScene object definition、dependency Resource type validation、numeric tile fallbackを使わないmissing catalog assignment validation、object placement の object_id / cell / rotation / variant / properties / spawn_condition schema・adapter mutation・削除cell cleanup、HexObjectDatabaseResource の typed definition / PackedScene scene / Texture2D preview / lookup / tag filter / `.tres` roundtrip、HexLabelDatabaseResource の typed definition / lookup / tag filter / `.tres` roundtrip、document summaryのcells / walls / floors / objects / labels / zones / warnings / dependencies count、HexMapValidationResultのserialization、document validation engine の outside map / orphan payload / missing catalog assignment / missing catalog / missing tile / missing dependency resource / dependency type mismatch / object on wall / object scene missing / duplicate unique object rule と各ruleのpass/fail matrix、movement profile reachability validation の opt-in / blocked important point / unreachable important point / profile id metadata、HexMovementProfileResource の保存roundtripと HexGameplayLayerData の map/document/catalog/object blocker抽出、canonical document adapter roundtrip、canonical payload / deleted cell cleanup、HexMapDocumentAdapter の shape / wall / catalog tile assignment / object / label 保存、削除cellに紐づくpayload cleanup、TileMapLayer 再描画、HexTileCatalogResource / HexTileCatalogEntry の logical key / TileSet resource / atlas tile / PackedScene scene tile / placeholder / tags / sample catalog load、sample catalog の debug path 不在 / packaged PackedScene dependency / validator clean、HexTileCatalogValidator の missing TileSet / missing source / invalid atlas coords / missing scene / tag and custom data extraction、catalog key による floor / wall / overlay item / document tile adapter、missing catalog key が numeric fallback ではなく validation issue になること、Adjacency Rule Set の parse / key正規化 / invalid entry report、Overlay Data の apply policy、Overlay item key から TileMapLayer tile への adapter、TileSet の Hexagon/Stacked/OffsetAxis 設定、sample atlas asset と atlas source 作成を検証する。
- `tests/test_hex_tile_map_layer.gd`: `HexTileMapLayer` の `HexMapResource` 適用、ready前 `hex_map` assignment からの visible sample TileSet / used cell 作成、canonical `HexMapDocumentResource` からの tile assignment / overlay tile / object marker / label marker 表示状態、HexLayerStackResource / HexLayerStackEntryResource の terrain / decoration / object / collision / navigation / overlay / debug role template と保存roundtrip、canonical document の terrain / overlay / object role child apply と plain `TileMapLayer` 互換apply、object layer adapter の scene tile prototype / direct instance prototype、custom floor / wall display tile source、Target TileSet export resource の `PackedScene.pack()` / instantiate 永続性、resource orientation に基づく TileMapLayer 反映、display tile size からの `hex_size` 同期、前面overlay child、セル照会、壁/床編集、legacy local/hex 座標往復、内部 `TileMapLayer.map_to_local()` / `local_to_map()` 基準の `hex_to_display_local()` / hit roundtrip、遠端cell display center、runtime click / hover signal、canonical / visual cell hit、toric / infinite loop identity、toric visual representative、visual cell entry schema、loop duplicate 用 `TileMapLayer` の tile copy 表示、壁/床編集後の duplicate tile 同期、anchor 指定付き loop-aware path、経路・ハイライト・連結性 helper、`find_weighted_path()` / `movement_range()` の profile-specific wall passability、movement range overlay の cost/heat state と clear、単一highlight削除を検証する。
- `tests/test_editor_plugin.gd`: Hex Map Workspace の tab/responsibility map、workspace経由の shared session / viewport input routing、Hex Map Edit / Generate Dock の resource selection、FileDialog callback、shared editor session の target / document / selected resource / saved-path metadata、canonical HexMapDocumentResource の load / edit / save / export、button state、Dock scroll container、Copy Debug Report、catalog selector 由来の floor / wall / overlay / object state、typed object placement Undo/Redo、missing assignment validation、Validation dashboard の domain/severity grouped issue rows / focus target / fix suggestion / cell focus / catalog entry focus、debug report の validation summary、Target readiness、Target由来document保存、viewport input / UndoRedo / toric duplicate edit、modeごとの catalog / object / label state、Generation Dock の generation / validation / batch promotion / source registry / mapdata query / history save、normal UI からの numeric fallback control / editable path text / Apply Layer primary action の排除、HexCellButtonLayout / HexCellButtonPanel、Distribution Editor を headless で検証する。旧 path LineEdit や numeric fallback control の存在は test contract にしない。
- `tests/test_editor_plugin.gd` QA-01 coverage: 生成結果の validation suite pass/fail capture、raw validation result保持、auto apply 前の capture order を headless で検証する。
- `tests/test_editor_plugin.gd` QA-02 coverage: 複数seedの batch generation、validation summary / score row、score table sort、batch結果がcurrent mapへpromoteされないことを headless で検証する。
- `tests/test_editor_plugin.gd` QA-03 coverage: batch rowからのseed promotion、canonical document生成、generation snapshot metadata、保存/再読み込みroundtripを headless で検証する。
- CLEAN-40 manual coverage: `docs/manual/MANUAL_EDITOR_PLUGIN.md` / `docs/manual/MANUAL_WORKFLOW.md` / `docs/manual/MANUAL_SCRIPTING.md` / `README.md` が Catalog、Layer Stack、Object Placement、Validation、Generation QA、Copy Debug Report、Resource picker workflow を user goal として説明し、新規アナログテスト文書を追加しないことを self-review と `./tools/test.sh` で確認する。
- `tests/test_editor_plugin.gd` ARCH-02 coverage: `HexMapGenStateEvaluator` の Generate Dock control visibility / disabled state / label text / generation block reason を pure state input で検証し、既存 Generate Dock headless tests が UI delegation の回帰を検証する。
- `tests/test_editor_plugin.gd` ARCH-03 coverage: `HexMapEditMutationBuilder` の document edit / `HexTileMapLayer` command construction と `HexMapEditViewportInputAdapter` の viewport press filtering / local trace / hit editabilityを検証し、既存 viewport hit/edit/undo tests が Edit Dock delegation の回帰を検証する。
- `tests/test_editor_plugin.gd` ARCH-04 coverage: `HexMapDocumentInspector` の document summary / validation summary / validation issue row formatting、Edit Dock inspector integration、既存 Edit / Generate validation debug summary behaviorを headless で検証する。
- `tests/test_editor_plugin.gd` ASSET-10 coverage: `HexMapEditorAssetSlotState` / `HexMapEditorAssetSlotControl` の Not selected / Selected / Invalid / Warning、Resource type mismatch、optional sample source、explicit sample application、compact row layout / collapsed details、state snapshot contractを headless で検証し、private widget 名には依存しない。
- `tests/test_editor_plugin.gd` ASSET-11 coverage: `HexMapWorkspaceAssetContext` が Document / Catalog / Object DB / Label DB / Layer Stack / Movement Profile / Validation Suite / Generation Profile / Export Profile を保持し、`HexMapEditorSessionState` / Workspace / Generate / Paint が同じcontextを参照し、Paintのproject asset選択がcontext経由でGenerateへ共有されることを headless で検証する。
- `tests/test_editor_plugin.gd` ASSET-12 coverage: asset slot の `Create New...` Save As config / selected path signal、`HexMapWorkspaceAssetResourceFactory` による Level Document / Catalog / Object DB / Label DB / Layer Stack / Movement Profile / Validation Suite / Generation Profile / Export Profile の `.tres` 作成、workspace asset context assignment、sample payload 不混入を headless で検証する。
- `tests/test_editor_plugin.gd` ASSET-30 coverage: Workspace asset slot の concrete ResourcePicker base type、tooltip expected type、generic `Resource` filter 不使用、Validation / Generation / Export profile slot の flexible Resource reason を headless で検証する。
- `tests/test_editor_plugin.gd` ASSET-31 coverage: asset slot row の `Select...` / `Open` / `Clear` / `Validate` redundant action button 不在、`Create New...` と explicit sample action の維持を headless で検証する。
- `tests/test_editor_plugin.gd` ASSET-32 coverage: `Create New...` の workspace button path が project resource を作成して asset context / row state を更新すること、explicit sample action の button path が sample source を選択して signal を出すこと、Settings sample row の未実装 `Open` が visible UI から削除されていることを headless で検証する。
- `tests/test_editor_plugin.gd` SAMPLE-10 coverage: Workspace Settings tab の `HexMapSampleSettingsPanel`、sample visibility default OFF、sample mode ON でも Generate/Paint catalog source が自動sampleにならないこと、main UI sample controls hiding、sample mode ON 時の project catalog precedence を headless で検証する。
- `tests/test_editor_plugin.gd` SAMPLE-11 coverage: `HexMapSampleAssetDuplicator` による sample catalog / tile texture / object scene の project path への複製、duplicated catalog の TileSet / scene entry dependency rewrite、workspace asset context assignment、duplicate action 前に sample が silently assigned されないことを headless で検証する。
- `tests/test_editor_plugin.gd` SAMPLE-12 coverage: Workspace の first-run `Learn with bundled samples` CTA visibility、Settings tab routing、dismiss state、same-session non-reappearance、sample mode flag / sample catalog assignment 不変更を headless で検証する。
- `tests/test_editor_plugin.gd` SAMPLE-40 coverage: Settings sample catalog row の functional `Duplicate To Project` button path が save path から catalog / texture / scene の project copy を作成し、Catalog slot を `SOURCE_PROJECT` として更新し、Generate / Paint catalog と Settings status snapshot に反映されること、`Open` は未実装のため absent のままであることを headless で検証する。
- `tests/test_editor_plugin.gd` WORKSPACE-10 coverage: Resources / Catalog / Layers / Validate / QA / Export / Settings の real workspace component mounting、tab-owned asset slot count / slot id、workspace tab root の ScrollContainer 化、shared workspace asset context への同期、Paint tab が setup asset panel を持たないことを headless で検証する。
- `tests/test_editor_plugin.gd` WORKSPACE-11 coverage: `tab_component_ids()` / `tab_asset_slot_ids()` registry contract として Catalog の `catalog_asset_panel` / `tile_catalog`、Validate の `validation_issue_navigator`、QA の `generation_profile` を private node 名に依存せず headless で検証する。
- `tests/test_editor_plugin.gd` NODE-21 coverage: `HexMapEditorSessionState` / Workspace の selected HexTileMap auto-link default ON、`No HexTileMap selected` empty state、Scene Tree selection hook source wiring、`HexTileMapLayer` / internal display layer selection mapping、selected node Layer Stack context sync、runtime mapをLevel Documentとして誤表示しないことを headless で検証する。
- `tests/test_editor_plugin.gd` NODE-22 coverage: selected HexTileMap の missing unique resource snapshot、save directory folder picker config、safe prefix/default file names、missing Level Document / Layer Stack `.tres` 作成、selected node への auto-reference、workspace/session context sync、既存unique resource preservation、SharedResource非作成を headless で検証する。
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
- PERF-60 review coverage: `docs/review/roadmap/GENERATE_UPDATE_PERFORMANCE_PROFILE_2026-06-08.md` が Generate / orientation / document apply / layer-stack apply / tile redraw / validation の重さと UI freeze 原因を分類し、`./tools/test.sh` と self-review で profile document の完了を確認する。
- `tests/test_editor_plugin.gd` PERF-61 coverage: Generate の ProgressBar が Preparing / Generating / Validating / Applying / Ready の current step text と cancellability を示し、orientation/tile settings apply が inline progress completion を表示し、modal busy window を作らないことを headless で検証する。
- `tests/test_editor_plugin.gd` PERF-62 coverage: repeated orientation/tile setting/catalog preview changes が debounce pending state と queued progress を表示し、連続変更を一回の tile settings apply に coalesce して completion progress に戻ることを headless で検証する。
- `tests/test_editor_plugin.gd` INFO-70 coverage: Level Document / TileSet / Tile Catalog / Layer Stack / Object DB / Label DB / Movement Profile / Generation Profile / Validation Suite / Export Profile の tooltip が pick type / Resource type / purpose を持ち、長い purpose を通常表示row textに出さないことを headless で検証する。
- `tests/test_editor_plugin.gd` INFO-71 coverage: Resources / Paint / Catalog / Layers / Validate / QA / Export / Settings の first-run empty state が tab purpose、短い empty text、1-2個の next action、tooltip/help detail を持ち、production tab の primary action が bundled sample で未設定を埋めないことを headless で検証する。
- `tests/test_editor_plugin.gd` INFO-72 coverage: Export tab の active/visible output mode が Runtime Handoff のみで、Data Export / Package Build / Debug Report は分類済みだが active visible output ではないことを headless で検証し、terminology decision は `docs/review/roadmap/EXPORT_TERMINOLOGY_DECISION_2026-06-08.md` に記録する。
- GEN-80 review coverage: `docs/review/roadmap/GENERATION_PIPELINE_GRAPH_REVIEW_2026-06-08.md` が generation preview / QA Seed Lab / overlay query / document metadata の現状を根拠に、immediate UI / backlog Resource/API / graph-editor research を分類し、Generate tab を肥大化させない判断を記録する。
- GEN-81 model coverage: `docs/review/roadmap/GENERATION_PROFILE_RESULT_MODEL_2026-06-08.md` が Generation Profile / Preview / Result / Level Document の境界、QA Seed Lab との整合、document metadata provenance、将来 schema test 条件を定義し、graph editor を out of scope とする。
- DOC-90 manual coverage: `docs/manual/MANUAL_EDITOR_PLUGIN.md` / `docs/manual/MANUAL_WORKFLOW.md` / `README.md` が Resources tab、sample learning flow、selected HexTileMap auto resource sync、Generate output target / Apply to selected Document を説明し、新規アナログテスト文書を追加しないことを self-review と `./tools/test.sh` で確認する。
- `tests/test_editor_plugin.gd` TEST-40 coverage: feature screen completion contract として Resources / Catalog / Layers / Validate / QA / Export の project asset slot が sample mode OFF で `SOURCE_PROJECT` になること、Catalog が任意 TileSet を保持すること、Export destination が user project path であることを headless で検証し、sample mode ON/OFF は Settings / Samples test、bundled sample asset validity は `tools/package_addon.sh --check` と sample catalog adapter test に分離する。
- `tests/test_editor_plugin.gd` CLEANUP-30 coverage: Settings の debug numeric fallback default OFF / explicit opt-in、plain `TileMapLayer` normal apply が missing catalog を numeric fallback で埋めないこと、debug opt-in 時だけ numeric fallback source/atlas を適用すること、missing catalog assignment が validation issue のまま残ることを headless で検証する。
- `tests/test_editor_plugin.gd` CLEANUP-31 coverage: Overlay item key / Label ID / Object variant / Spawn condition / Object property key-value が selector / definition / enum / schema source を持つこと、normal UI で raw overlay key / label id / object variant / spawn condition / raw JSON properties / property table が非表示であることを headless で検証する。
- `tests/test_editor_plugin.gd` TEST-42 coverage: `HexMapEditorAssetSlotState` の required missing / invalid type / selected project / optional sample candidate / explicit sample source warning、sample mode OFF/ON の main selector learning candidate visibility、direct bundled sample Catalog selection の `SOURCE_SAMPLE` warning / Generate-Paint non-use、sample duplicate-to-project 後の Catalog slot `SOURCE_PROJECT` / project path / metadata / Generate-Paint project primary stateを headless で検証する。
- `tests/test_editor_plugin.gd` PKG-70 coverage: package learning sample contract として sample catalog / tile texture / object scene の ResourceLoader accessibility、sample catalog の floor/wall/object scene entry、Settings / Samples の sample asset rows、sample mode OFF/ON の Generate/Paint 非inject、project catalog primary stateを headless で検証し、`tools/package_addon.sh --check` が manifest/zip への sample 同梱を検証する。
- `tests/test_editor_plugin.gd` SAMPLE-41 coverage: sample mode ON でも Generate / Paint が bundled sample catalog を execution fallback にしないこと、direct bundled sample selection が `SOURCE_SAMPLE` warning になり Generate/Paint source にならないこと、duplicated project copy だけが production source になることを headless で検証する。
- `tests/test_editor_plugin.gd` FB-01 coverage: `HexMapEditorPathSelector` の dialog attach helper が未parent dialogだけをattachし、既にtree内にあるdialog nodeをreparent / double-addしないこと、Distribution Editor の Save New / Load dialog contract が FileDialog config として表現され、headless test では実 popup に依存しないことを検証する。
- `tests/test_editor_plugin.gd` FB-02 coverage: Resource row の visible `Details` button 不在、Workspace asset slot の Select/Open/Clear/Validate/Details placeholder action 不在、Export / Missing Unique Resources の disabled action tooltip が unmet condition を説明することを headless で検証する。
- `tests/test_hex_adapter.gd` RES-10 coverage: `HexMapDocumentDependencyService` の shared dependency key、add/find/update/remove、role付き dependency id、Tile Catalog / Object DB / Label DB / Movement Profile / Validation Suite / Generation Profile / Export Profile hydration、required/optional missing validation、Movement Profile type mismatch validationを headless で検証する。
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
