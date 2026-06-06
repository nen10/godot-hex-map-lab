
# TEST.md


## 管理

(コマンド実行のみで完了する)テスト作成時、`tools/test.sh` を合わせて更新する
自動テスト設計は `docs/policy/TEST_DESIGN_POLICY.md` に従う。
interactiveなテスト作成時、実行方法を簡潔にdocumentationする
Editor Plugin 操作で複数機能の結合性を確認する任意検証は、アナログテストとして `docs/policy/ANALOG_TEST_POLICY.md` に従い、操作手順マニュアルを `tests/analog_test/` 以下に作成する。アナログテスト文書は Test path の代替ではなく、ユーザー依頼時の追加検証記録として扱う。

### Test path

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

- `tests/test_hex_core.gd`: HexVector/HexPoint、toric coordinate、近傍・連結・経路、weighted path / movement range の cost-to-enter・budget・blocked cell・legacy unweighted compatibility、movement profile の passability / costs / blocker key / default wall behavior、9分割と対称生成領域タグを検証する。`symmetry_generation_tags()` が radius 1..9 の全 canvas cell を網羅し、`source` は raw draw position、`vector` は wrap 済み canvas position、`moved` は wrap 有無を表すことを検証する。phase2 outer_mod の pair/triple は raw 生成タイミング上の distinct な局所グループとして検証し、phase2 でも outer-to-center wave を通ることを検証する。
- `tests/test_hex_map_generation.gd`: rectangle/hexagon/toric square の生成、Primary Data の `Any` / `Floor` / `Wall` item key、Overlay Data の user item key、Placement Mask / Reference 用 item selector query、Uniform Distribution overlay item generation、Adjacency Reference overlay item generation、generated reference item key の動的参照と toric wrap / cancel、Markov Mesh overlay item generation、Overlay Deductor による item 削除、壁生成、割り込み可能な progress / cancel 付き壁生成と item 生成、shape API の interrupt option、連結性回復、dense/sparse/none の `restore_connectivity_by()`、terminal 接続、対称生成を検証する。dense/sparse 連結性回復は direct restore と生成 API 経由の progress / cancel、`0.35 -> 1.0` の restore progress range、単純 bridge、toric shortcut、Y 字 fixture、1-wall remote bridge、対称 toric square の接続を検証する。連結性回復の方向 seed は同距離 bridge の選択が seed で変わることと、restore / dense / sparse / terminal の各方式に適用できることを検証する。Generation Radius 1 / 2 も larger radius と同じ対称生成フローを通り、radius 3 / 6 / 9 は `DrawAreaCenter -> DrawAreaFromCenter` 後の completion pass で canvas 内・split 分布・protected floor・連結性回復を満たすことを検証する。
- `tests/test_hex_adapter.gd`: HexMapData から TileMapLayer 用 entry、flat-top / pointy-top の offset cell 変換、表示用 local 座標、HexMapResource / HexOverlayResource / HexMapDocumentResource への変換、HexMapDocumentResource v2 の terrain / overlay / object placement / label placement / zone / metadata / dependency schema とv1 fixture互換、v1 -> v2 migrationのlegacy field/source version保持・roundtrip・missing field処理、HexObjectDatabaseResource v2 の typed definition / legacy objects array migration / lookup / tag filter / `.tres` roundtrip、document summaryのcells / walls / floors / objects / labels / zones / warnings / dependencies count、HexMapValidationResultのserialization、document validation engine の outside map / orphan payload / missing catalog / missing tile / missing dependency / object on wall rule と各ruleのpass/fail matrix、movement profile reachability validation の opt-in / blocked important point / unreachable important point / profile id metadata、HexMovementProfileResource の保存roundtripと HexGameplayLayerData の map/document/catalog/object blocker抽出、v2 document adapter roundtrip、v2 payload / deleted cell cleanup、HexMapDocumentAdapter の shape / wall / tile override / object / label 保存、削除cellに紐づくpayload cleanup、TileMapLayer 再描画、HexTileCatalogResource / HexTileCatalogEntry の logical key / atlas tile / scene tile / tags / fallback field / sample catalog load、HexTileCatalogValidator の missing TileSet / missing source / invalid atlas coords / missing scene / tag and custom data extraction、catalog key による floor / wall / overlay item / v2 document tile adapter と numeric fallback、既存v1/v2 document の catalogless numeric fallback 表示と compatibility warning、Adjacency Rule Set の parse / key正規化 / invalid entry report、Overlay Data の apply policy、Overlay item key から TileMapLayer tile への adapter、TileSet の Hexagon/Stacked/OffsetAxis 設定、sample atlas asset と atlas source 作成を検証する。
- `tests/test_hex_tile_map_layer.gd`: `HexTileMapLayer` の `HexMapResource` 適用、ready前 `hex_map` assignment からの visible sample TileSet / used cell 作成、v1 / v2 `HexMapDocumentResource` からの tile override / overlay tile / object marker / label marker 表示状態、HexLayerStackResource / HexLayerStackEntryResource の terrain / decoration / object / collision / navigation / overlay / debug role template と保存roundtrip、v2 document の terrain / overlay role child apply と plain `TileMapLayer` 互換apply、custom floor / wall display tile source、Target TileSet export resource の `PackedScene.pack()` / instantiate 永続性、resource orientation に基づく TileMapLayer 反映、display tile size からの `hex_size` 同期、前面overlay child、セル照会、壁/床編集、legacy local/hex 座標往復、内部 `TileMapLayer.map_to_local()` / `local_to_map()` 基準の `hex_to_display_local()` / hit roundtrip、遠端cell display center、runtime click / hover signal、canonical / visual cell hit、toric / infinite loop identity、toric visual representative、visual cell entry schema、loop duplicate 用 `TileMapLayer` の tile copy 表示、壁/床編集後の duplicate tile 同期、anchor 指定付き loop-aware path、経路・ハイライト・連結性 helper、`find_weighted_path()` / `movement_range()` の profile-specific wall passability、movement range overlay の cost/heat state と clear、単一highlight削除を検証する。
- `tests/test_editor_plugin.gd`: Hex Map Edit Dock の document path / target / edit mode / Import / Save / Export controls、Browse / Save As file-selected handler、Generate Dock / Edit Dock 間の shared editor session target / document / path state、v2 HexMapDocumentResource のload / edit / save / exportでtyped terrain / overlay / object / label payloadを保持すること、button disabled state、Dock scroll container、Copy Debug Report buttonと報告文字列、Default Floor / Wall tile settings、catalog selector による Edit Dock default floor / wall・Floor / Wall / Overlay payload・Object assignment と Generate Dock floor / wall / overlay item pool tile mapping、既存catalogless documentのnumeric fallback表示とwarning report、Validation dashboard の Validate button / grouped issue rows / cell-scoped issue focus、Edit / Generate debug report の validation summary と通常status非肥大化、Target TileSet / atlas / sample preset controls、生成済み HexMapResource の document import / export、Target Status の plain `TileMapLayer` / `HexTileMapLayer` readiness、TileSet path / source count / tile size / overlay payload / overlay visibility、Target Reloadによる `HexTileMapLayer.hex_map` 由来document初期化、Target由来documentのSave後source状態、plain `TileMapLayer` 再描画時の既存 floor / wall tile settings 維持、Edit Dock Target Auto の `HexTileMapLayer` editor selection 解決、`HexTileMapLayer` 内部 `TileMapLayer` selection からwrapper targetへの解決、plain `TileMapLayer` を通常Target候補にしないこと、EditorPlugin viewport input eligibility、viewport transform 経由の local click、viewport click からの wall / shape edit、選択不能cell clickのevent消費と次のvalid click復帰、Floor Tile / Wall Tile / Object / Label / Overlay Tile mode の `HexTileMapLayer` cell / marker / overlay単位表示反映、Floor / Wall / Overlay Tile payload のmode別保持、Last Edit trace による document mutation / target apply / display tile / marker / overlay change / target resolution reason の切り分け、Save / Export checkpoint の path / resource class / cell count / wall count、失敗時 status、headless `UndoRedo` による HexMapDocumentResource と TileMapLayer の同期復元、EditorUndoRedoManagerをpluginから渡さないsource検査、HexTileMapLayer の toric visual duplicate から canonical cell を編集する loop-aware hitと `hex_map` resource更新、loop duplicate tile の編集後 refresh、last-only highlight、mode ごとの payload controls 表示、生成ドックの stable tab name、対称 Hexagon / Generation Radius 1 / 2、symmetric Square の toric connection UI 連動と `cyclic_size`、Generate ボタン限定実行、Overlay mode の button / controls 表示、Primary floor cells を候補にした Uniform Overlay generation、Uniform Overlay Item Pool の Add Item / weight / limit / item tile mapping / Floor-Wall tile copy、Placement Mask、Deductor Floor Source、Adjacency Reference、Generated Item Reference snapshot / 生成結果反映、Adjacency Rule Editor、Adjacency Rules validation status、Item Num Limit、Overlay Apply Policy、OverlayResource save target、Dock 内 progress UI の Generate 時表示と成功時の最短表示時間後の非表示、modal progress window を生成しないこと、Core callback 由来の progress / cancel wiring、cancel 時に partial data を current map へ反映しないこと、orientation とApply Writeを含む TileMapLayer apply 設定、HexTileMapLayer primary apply / Target list / sample TileSet setup / Generate後auto apply、orientation 変更時の Tile Size swap、Target の Auto / 短い layer 名 / HexTileMapLayer class表示 / `Add new layer...` 表示、Refresh 後の Auto 維持、Scene Tree 選択中 TileMapLayerまたはHexTileMapLayerだけへの設定即時 apply、共有 `TileSet` の選択中レイヤー側複製、atlas image selection、sample TileSet setup、Generate Dock の Browse / Save As / History Dir文言と失敗Status、Generate 後の自動 apply、Apply Layer button の手動再反映、HexCellButtonLayout / HexCellButtonPanel の flat-top / pointy-top layout・padding minimum size・polygon hit・custom / ring / disc shape hook・press / hover / label state / disabled / keyboard操作、Distribution Editor のプリセット値表示、`.tres` 読み込み、recent custom distribution、preset 複製保存、SpinBox 値に基づく色、共通HexCellButtonLayoutによるpattern配置 / draw接続、window close の cancel flow、Source Registry のLoad / reload / Clear / item cell count表示 / empty status、Mapdata Query Row のAND/OR・Contain/Exclude・source label / ItemKey combo・offset・toric wrap・toric sourceのShape universe内代表展開・HexCellButtonPanel offset control・center tooltip・共通cell radius / gap / padding変更、Mask Query Row 0行時のShape universe全通過、Mask Query Row空結果時のGenerate停止、Crop resultとCrop Off連動、Crop Off source stackとstatus表示、Generate HistoryのPrimary保存・Overlay差分保存・`overlay-combination`命名・cancel時非保存を headless で検証する。
- `tests/test_debug_scenes.gd`: debug scene の生成形状切替、toric 表示 domain、loop path / cell hit / movement range 表示状態、runtime loop duplicate tile copy 状態、runtime helper による v2 `HexMapDocumentResource` path load と terrain / overlay / object / label 適用、`examples/basic_runtime/runtime_query_sample.gd` による document path load / weighted path / movement range query、対称生成 overlay が toric canvas 全体を網羅すること、phase2 grouping 表示用データを検証する。


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
2. Generate Dockで `HexMapResource` を作成するか、既存 `.tres` を用意し、Hex Map Editで documentへimportまたは保存済み `HexMapDocumentResource` をLoadする。
3. Targetで編集対象の `TileMapLayer` または `HexTileMapLayer` を選ぶ。
4. `Target Status` に target class、TileSet readiness、floor / wall atlas、used cell count、`HexTileMapLayer` の loop state が表示されることを確認する。
5. `Edit Mode` を `Shape` / `Wall / Floor` / `Floor Tile` / `Wall Tile` / `Object` / `Label` に切り替え、viewport上のhex cellをclickする。
6. `Last Edit` に canonical / visual cell、document mutation、target apply、display tile change、tile atlas before / after、target used cell count before / after が表示されることを確認する。
7. Undo / Redoで document と TileMapLayer 表示が同時に戻ることを確認する。
8. `Browse` / `Load` で documentを読み込み、`Save As` でTarget由来documentを保存できることを確認する。保存後はDocument表示とdebug reportで保存pathとsource状態が分かることを確認する。
9. `Import Map` の `Browse` と `Export` / `Save As` で `HexMapResource` を入出力し、`Save / Export` detail に path、resource class、cell count、wall count が表示されることを確認する。
10. `HexTileMapLayer` の toric loop表示では、複製表示されたcellが outline だけでなく floor / wall tile として表示されることを確認する。
11. 複製表示されたcellをclickしてcanonical cellが編集され、Undo / Redo 後も canonical cell と duplicate tile が同じ floor / wall 状態へ戻ることを確認する。
12. 連続して別cellを編集したとき、highlight が最後の canonical cell だけに残ることを確認する。
13. `Copy Debug Report` を押し、Target Status / Last Edit / Save Export / raw statusを含む報告用textが一括copyできることを確認する。
14. `HexTileMapLayer` targetでは、内部 `TileMapLayer` をScene Treeで選んでも `Target Status` が親 `HexTileMapLayer` として解決されることを確認する。
15. 選択不能cellをclickして `No editable cell.` が出た後、visible cellをclickして編集・highlight・Last Editが更新されることを確認する。
16. `Target TileSet / Atlas` の `Browse` またはsample presetでTarget TileSetを設定し、Target StatusにTileSet path / source count / tile size / overlay payload / overlay visibilityが表示されることを確認する。
17. `Select Internal TileMapLayer` を押し、内部表示layerが選択されてもAuto targetが親 `HexTileMapLayer` に戻ることを確認する。
18. Floor Tile / Wall Tile / Overlay Tileを切り替え、各modeのpayloadが混ざらないことを確認する。
19. Sceneを保存して開き直し、Target TileSet / atlas sourceが維持されることを確認する。
20. Godot Output Dockに `EditorUndoRedoManager.add_do_method` errorが出ないことを確認する。

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
