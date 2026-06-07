
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

Hex Map Edit Dock の手動確認:

1. Godot Editorで addon を有効にし、`Hex Map Edit` Dock が生成Dockとは別に表示されることを確認する。
2. Generate Dockで `HexMapResource` を作成するか、既存 `.tres` を用意し、Hex Map Editで `New Document` / `Open...` / `Convert` により編集用documentを用意する。
3. Targetで編集対象の `TileMapLayer` または `HexTileMapLayer` を選ぶ。
4. `Target Status` に target class、TileSet readiness、floor / wall atlas、used cell count、`HexTileMapLayer` の loop state が表示されることを確認する。
5. `Edit Mode` を `Shape` / `Wall / Floor` / `Floor Tile` / `Wall Tile` / `Object` / `Label` に切り替え、viewport上のhex cellをclickする。
6. `Last Edit` に canonical / visual cell、document mutation、target apply、display tile change、tile atlas before / after、target used cell count before / after が表示されることを確認する。
7. Undo / Redoで document と TileMapLayer 表示が同時に戻ることを確認する。
8. `Open...` で documentを読み込み、`Save` / `Save As...` でTarget由来documentを保存できることを確認する。保存後はDocument表示で Saved / Dirty 状態が分かることを確認する。
9. Advanced convert の `Browse...` / `Convert` と `Export...` / `Export As...` で `HexMapResource` を入出力し、`Save / Export` detail に path、resource class、cell count、wall count が表示されることを確認する。
10. `HexTileMapLayer` の toric loop表示では、複製表示されたcellが outline だけでなく floor / wall tile として表示されることを確認する。
11. 複製表示されたcellをclickしてcanonical cellが編集され、Undo / Redo 後も canonical cell と duplicate tile が同じ floor / wall 状態へ戻ることを確認する。
12. 連続して別cellを編集したとき、highlight が最後の canonical cell だけに残ることを確認する。
13. `Copy Debug Report` を押し、Target Status / Last Edit / Save Export / raw statusを含む報告用textが一括copyできることを確認する。
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
