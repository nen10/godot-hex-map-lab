# HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md

## 目的

`HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE` 計画の実装結果について、計画との差分、未達項目、実装上の指摘、UX改善案、不明点を整理する。

## レビュー対象

- Plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_PLAN_2026-06-03.md`
- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_POLICY_2026-06-03.md`
- Review reference: `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_PERFORMANCE_REVIEW_2026-06-03.md`
- Object asset boundary reference: `docs/review/_history/HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md`

主な実装対象:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_hex_tile_map_layer.gd`
- `docs/TEST.md`
- `docs/knowledge/DEV_GODOT.md`
- `tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md`

## 検証結果

- `./tools/test.sh` は成功。
- Godot 4.6.2 headless の実行で、macOS CA certificate warning は出ているが、テスト失敗は確認されなかった。
- `docs/TEST.md` の Test path は、Target由来document、Target TileSet / atlas / sample preset、Overlay Tile mode、内部 `TileMapLayer` 基準座標、Generator target優先度を含む内容へ更新されている。

## 総合判断

計画の主要UXは実装済みとして扱える。特に、Target Reloadだけで `HexTileMapLayer.hex_map` 由来documentを作る経路、通常Target候補を `HexTileMapLayer` 中心に寄せる経路、内部 `TileMapLayer` 基準の座標変換、Tile / Overlay assetをTarget TileSet境界に置く方針は、実装とテストの両方で確認できる。

一方で、完了整理前に残すべき課題がある。大きいものは、cell単位applyが表示更新としては局所化されているものの、内部処理では毎回document全体のduplicate / resource変換 / `_data` 再構築を行っている点、Edit Dockのasset選択がファイル選択UIとしてはまだ粗い点、Target TileSetをscene保存 / reload後に維持できるかが自動テストでは未確認な点である。

## 計画以上の機能

### Target TileSet / atlas 操作がEdit Dockにまとまった

`HexMapEditTool` に Target TileSet picker、Atlas Image入力、sample preset、`Select Display Layer` が追加されている。これは計画の「asset選択UX」を満たすだけでなく、Generation Dockに寄っていたTileSet準備操作をManual Edit側へ寄せる実用的な拡張になっている。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:651`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1452`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1468`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1554`

### internal display layer 選択経路が追加された

`Select Display Layer` により、`HexTileMapLayer` の内部base `TileMapLayer` をEditor selectionへ送れる。標準TileMap / TileSet editorとの接続を、公開APIに強く依存しない形で作っている。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1574`

### Overlay Tile専用の表示layerが追加された

Overlay要Tileはdocument payloadだけでなく、`HexTileMapLayer` 配下のoverlay用internal `TileMapLayer` で表示されるようになっている。front overlay canvasのmarker表示とTileMapLayer tile表示が分離され、floor / wall tileの背面に隠れにくい構成になっている。

該当箇所:

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd:1150`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:771`

### Generator target優先度も同時計画以上に整理された

Generation Dock側で、Primary target候補は `HexTileMapLayer` を優先し、Overlay modeではplain `TileMapLayer` を維持する分岐が入っている。Manual Editだけでなく生成UXとの衝突も減っている。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2514`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2543`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2557`

## 計画に関する未達・部分達成項目

### [P2] cell単位applyは表示更新のみ局所化され、document/resource変換は全量のまま

`apply_document_cell()` は対象cellの `_update_tile()` / `_update_overlay_tile()` を呼ぶため、TileMapLayerへの描画反映は局所化されている。一方で、各clickごとに `HexMapDocumentAdapter.duplicate_document()`、`to_map_resource()`、`resource.to_map_data()`、`_normalize_data()` を実行している。

計画は「全Edit Modeのper-click applyがcell / marker / overlay単位になる」ことを完了条件にしているため、性能観点では部分達成として扱う。961 cell程度の現状ではテスト上問題になっていないが、大型mapではdocument全体処理が残る。

該当箇所:

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd:198`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:802`

推奨:

- `apply_document_cell()` に渡すpayloadをcell単位差分へ寄せる。
- `_data` の全量再構築を避け、shape追加 / 削除、wall変更、tile override変更、object / label / overlay変更ごとに必要最小限のcacheだけ更新する。
- Performance Reviewの観点で、大型mapのanalogまたはheadless計測を追加する。

### [P2] Target TileSetのscene保存 / reload永続性が未確認

実装はTarget `HexTileMapLayer` の内部 `_tile_map.tile_set` にTileSetを保持している。runtime testでは、Target TileSetにatlas sourceが作られ、documentへasset pathを書かないことが確認されている。

ただし、内部 `TileMapLayer` は `add_child(..., INTERNAL_MODE_BACK / FRONT)` で生成されるため、scene保存 / reload後に `tile_set` assignmentがどのように永続化されるかは、現行の自動テストでは確認されていない。計画の「Target Reload後の表示継続」に対して、runtime上の継続は確認済みだが、PackedScene保存を跨ぐ継続は未確認である。

該当箇所:

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd:274`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd:1116`
- `tests/test_editor_plugin.gd:736`

推奨:

- `PackedScene.pack()` / reloadまたはeditor analog testで、Target TileSet / atlas source / tile size / source idがscene保存後も復元されることを確認する。
- 内部childへの保存が不安定な場合、`HexTileMapLayer` export propertyまたは明示Resource境界へ寄せる。

### [P3] Godot標準TileMap画面を「開く」操作は選択操作として実装されている

計画は標準TileSet / TileMap画面を開く操作を求めている。現実装は内部display layerをEditor selectionへ送る実装であり、Godot editor側がTileMap panelを表示することに依存している。

これは実装方針としては妥当だが、UX文言としては「開く」より「内部Display Layerを選択する」が正確である。アナログテストで標準panelが期待通り出ることを確認する必要がある。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:680`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1574`

### [P3] Edit DockのAtlas Image指定はファイル選択UIではなくpath入力である

`Atlas Image` は `LineEdit` と `Apply Atlas` で構成されている。計画の「asset画像をユーザーが選択して読み込めるUI」として最低限は成立するが、Generation Dockの `Select Atlas Image` と比べると、ユーザーがファイルを選ぶUXとしては未完成である。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:659`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1468`

推奨:

- `EditorFileDialog` または既存Generation Dockのatlas選択処理を再利用する。
- path入力はadvanced / direct pathとして残し、通常操作はBrowseボタンに寄せる。

### [P3] Overlay Tile payloadがFloor / Wall Tile payloadと同じUI状態を共有している

`Overlay Tile` modeは `_tile_payload` を複製して `kind=overlay` と `item_key` を付けて保存している。実装は簡潔だが、Floor Tile / Wall Tile / Overlay Tileを行き来したとき、source id / atlas coords / alternative tileが同じUI状態として共有される。

これは仕様として許容できるが、Overlay専用のTileSet sourceを使うプロジェクトでは、mode切替時に意図せずpayloadが混ざる可能性がある。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:686`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:771`

推奨:

- Floor / Wall / Overlayごとの最後のpayloadをmode別に保持する。
- `Read Target Tiles` / `Apply Target Tiles` がOverlay payloadへ作用する範囲をUI上で明示する。

## 実装に対する指摘事項

### [P2] `apply_document_cell()` の責務が重い

`apply_document_cell()` は「対象cellの再描画helper」という名前に対して、document duplicate、resource変換、orientation同期、`hex_map`更新、`_data`全量更新、payload cache更新、tile更新までを担当している。

このままでも動作は成立するが、今後Object / scene layerや大規模mapを扱う場合、変更単位が増えるほどこの関数が性能・副作用の集中点になる。

推奨:

- `apply_document_cell()` は差分payload適用へ寄せる。
- 全量document適用は `apply_document()` に閉じる。
- `Shape` のadd / eraseだけはcell集合更新が必要なため、専用helperに分離する。

### [P3] plain `TileMapLayer` 互換経路が内部関数に残っている

Manual Editの通常Target候補は `HexTileMapLayer` に限定されている一方、`_apply_target_tile_set()` と `_apply_target_atlas_path()` にはplain `TileMapLayer` targetの処理が残っている。

これはCore互換 / test互換として残す方針と整合するため不具合ではない。ただし、UI上から到達できない経路と到達できる経路が混在するため、今後の変更時には「legacy plain target」「Generation Overlay」「Manual Edit normal target」を明示的に分けて扱う必要がある。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1452`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1495`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1267`

### [P3] Target Reloadによる未保存documentの扱いは明確だが、保存導線の説明がまだ弱い

Target由来documentは `_document_source=target` としてdebug reportに残る。これは良い。一方で、ユーザーがこの未保存documentを編集した後、Save / Export / scene保存のどれを選ぶべきかはUIから読み取りにくい。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1165`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1177`
- `tests/test_editor_plugin.gd:328`

推奨:

- Target由来documentの場合、statusに `Unsaved target document` 相当の短い状態を追加する。
- Save / Export成功後に `document_source` をpath由来へ変えるか、target由来編集を維持するかを仕様として固定する。

## UX改善案

### Asset選択UI

- `Atlas Image` にBrowseボタンを追加する。
- `Apply Sample` はsample選択と実行が分かれているため、preset option内に「Apply」状態が見えるようにする。
- Target TileSetがない、targetがない、atlas pathが無効、tile sizeが不明の場合は、該当buttonをdisabledにして原因をstatusへ出す。
- Target Statusに、TileSet resource path、source数、tile size、floor / wall / overlay payloadの現在値をまとめて出す。

### 標準TileMap / TileSet editor連携

- `Select Display Layer` の文言は、標準TileMap panelを直接開く保証がない場合、`Select Internal TileMapLayer` の方が正確である。
- ボタン押下後、Target Autoが親 `HexTileMapLayer` に戻ることをstatusで明示する。
- 標準TileMap画面でTileSetを編集した後、Dock側の `Read Target Tiles` が何を読み取るのかを短いlabelで示す。

### Overlay Tile編集

- Overlay item keyはfree textだけでなく、既存document内のitem key候補を選べるとよい。
- Overlay専用payloadをmode別に記憶し、Floor / Wall Tileのpayloadと混ざりにくくする。
- Overlay Tileのz-index / visibilityをTarget Statusに出すと、floor / wall tileに隠れた場合の診断がしやすい。

### Target由来document編集

- Target Reload後にdocumentが自動生成された場合、Import / Load不要で編集可能になったことはUXとして大きく改善している。
- ただし、未保存documentであることは明確に出す必要がある。Save / Exportのどちらがproject assetとして残るのか、Targetの `hex_map` へだけ反映されているのかを誤認しやすい。

## その他の不明点・任意指摘

### Object assetは今回計画から切り離されている

Object表示を画像atlasとして扱う計画は外れており、現在のObject modeはdocument payload / marker表示として維持されている。Node / scene配置、`TileSetScenesCollectionSource`、object専用layerは別計画で扱うのが妥当である。

参照:

- `docs/review/_history/HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md`

### analog testは更新済みだが、実行結果文書は未確認

`tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md` は、Target Reload、sample / preset asset、Overlay Tile、遠端cell、reaction speedを確認する内容へ更新されている。今回レビュー時点では、analog testの実行結果文書は確認していない。

### tactics atlasはsample / presetとして扱われている

生成済みtactics assetは固定defaultではなく、sample / presetとして選択するUIに入っている。これはPolicyの候補M不採用と整合している。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1554`
- `tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md:45`

## 後続アクション候補

1. `apply_document_cell()` を差分適用へ分割し、大型mapでのper-click処理時間を測る。
2. Target TileSet / atlas sourceのPackedScene保存 / reload testを追加する。
3. Edit DockのAtlas ImageにBrowse UIを追加する。
4. `Select Display Layer` の文言とstatusを、実際の挙動に合わせて調整する。
5. Overlay Tile payloadをFloor / Wall Tile payloadから分離する。
6. Target由来documentの未保存状態とSave / Export後の状態遷移をUIに出す。

## 完了整理に関する判断

自動テストで確認できる範囲では、計画の主要実装は完了している。`complete_on_test` へ移動する場合は、以下を残課題として別計画またはreview backlogへ残すのが妥当である。

- `apply_document_cell()` の全量document/resource処理の軽量化。
- Target TileSetのscene保存 / reload永続性確認。
- Edit Dockのasset file browse UX。
- Overlay Tile payloadのmode別保持。
- Target由来documentの保存導線明確化。

## Planning Flow反映 2026-06-05

ユーザー指摘により、asset項目単体ではなく、Editor Plugin全体のファイルpath / resource選択UXとして新しいPlanning Flowへ切り出した。

新Planning Flow:

- `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/UX.md`
- `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/POLICY.md`
- `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/IMPLEMENTATION_PLAN.md`
- `docs/review/plan/EDITOR_DOCK_FILE_RESOURCE_SELECTION_PLAN_REVIEW_2026-06-05.md`

新Planning Flowに含めた項目:

- `Atlas Image` だけでなく、Document Load / Save、Import Map、Export、Source Registry、Generate History、Generation Save、Select Atlas Imageを含むpath / resource選択UX。
- `EditorFileDialog` / `EditorResourcePicker` / direct path入力の役割分担。
- invalid path、targetなし、TileSetなしなどのbutton disabled / status表示。
- Target StatusにTileSet resource path、source数、tile size、floor / wall / overlay payload、overlay visibilityを出す改善。
- Target TileSet / atlas sourceのPackedScene保存 / reload永続性確認。
- `Select Display Layer` を内部 `TileMapLayer` 選択操作として正確に表現する文言 / status改善。
- Overlay Tile payloadのmode別保持と、Overlay item key候補UI。
- Target由来documentの未保存状態とSave / Export後の状態遷移。

新Planning Flowに含めない残り項目:

- `apply_document_cell()` の全量document duplicate / resource変換 / `_data` 再構築を避ける性能改善。これはpath選択UXではなく、document差分適用とlarge map performanceの別計画で扱う。
- `apply_document_cell()` / `apply_document()` の責務分割。性能改善と同じくstate適用境界の別計画で扱う。
- Object Node / scene layer、`TileSetScenesCollectionSource`、object専用layer。`docs/review/_history/HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md` を元に別Planning Flowで扱う。
- plain `TileMapLayer` legacy helperの内部到達経路整理。Editor通常UX、Generation Overlay、Core互換testの境界整理として別に扱う。

完了扱い:

- `HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE` 計画は、自動テストで主要実装が確認済みであり、上記残項目を分離したため完了扱いにする。

## `EDITOR_DOCK_FILE_RESOURCE_SELECTION` 実装後の整理 2026-06-05

追加レビュー:

- `docs/review/_history/EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`

この実装で完了扱いに移す項目:

- Target TileSet / atlas sourceの `PackedScene.pack()` / instantiate永続性確認。
- Edit DockのDocument / Import Map / Export / Atlas Image Browse / Save As経路。
- `Select Display Layer` の `Select Internal TileMapLayer` への改名とstatus改善。
- Overlay Tile payloadのFloor / Wall Tile payloadからのmode別分離。
- Target由来documentの未保存 / 保存済み状態表示。
- Target StatusのTileSet path、source count、tile size、Overlay payload、overlay visibility表示。

引き続き残す項目:

- `apply_document_cell()` の全量document duplicate / resource変換 / `_data` 再構築を避ける差分適用。
- 大型mapでのper-click処理時間計測。
- Object Node / scene layer、`TileSetScenesCollectionSource`、object専用layer。
- plain `TileMapLayer` legacy helperの内部到達経路整理。
- Editor上のactual dialog / standard TileMap panel / scene save-reload analog result。
- Direct Atlas Browseを任意tile size importへ拡張するかどうかのUX判断。標準TileSet画面を主経路にする限り、tile size入力は残課題にしない。
