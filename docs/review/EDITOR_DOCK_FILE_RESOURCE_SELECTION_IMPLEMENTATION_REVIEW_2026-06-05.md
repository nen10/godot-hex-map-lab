# EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05

## 対象

- UX: `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/UX.md`
- Policy: `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/POLICY.md`
- Implementation Plan: `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/IMPLEMENTATION_PLAN.md`
- Plan Review: `docs/review/plan/EDITOR_DOCK_FILE_RESOURCE_SELECTION_PLAN_REVIEW_2026-06-05.md`
- Source Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md`

主な実装対象:

- `addons/hex_map_kit/editor/hex_map_editor_path_selector.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_hex_tile_map_layer.gd`
- `docs/TEST.md`
- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md`
- `docs/knowledge/DEV_GODOT.md`

## 検証結果

- `./tools/test.sh` は成功。
- Godot 4.6.2 headlessでmacOS CA certificate warningは出ているが、テスト失敗は確認されなかった。
- `tests/test_hex_tile_map_layer.gd` はTarget TileSet export resourceの `PackedScene.pack()` / instantiate永続性を確認している。
- `tests/test_editor_plugin.gd` はfile selected handler、button disabled state、Target Status detail、mode別payload、Generation Dock path action label / failure statusを確認している。

## 総合判断

`EDITOR_DOCK_FILE_RESOURCE_SELECTION` 計画は、自動テストで確認できる主要項目について実装済みとして扱える。前回レビューで残っていた以下の項目は、この計画で完了側へ移動できる。

- Edit DockのDocument / Import Map / Export / Atlas ImageにBrowse / Save As経路を追加する。
- `Select Display Layer` を `Select Internal TileMapLayer` へ改名し、操作実態に合わせたstatusを出す。
- Target StatusにTileSet path、source count、tile size、Overlay payload、overlay visibilityを出す。
- Target由来documentの保存状態を `document_source` / path表示へ反映する。
- Target TileSet / atlas sourceを `PackedScene.pack()` / instantiateで維持する。
- Floor / Wall / Overlay Tile payloadをmode別に保持する。

任意tile sizeのcustom atlasは、Godot標準TileSet画面でTileSetを作成・調整し、そのTileSetをTargetへ接続する流れを主経路とする。この前提に立つと、Edit Dockの `Atlas Image` Browseはsample / preset互換の簡易適用入口であり、任意atlas作成機能そのものではない。したがって、tile size入力をEdit Dockへ追加することは必須目標ではなく、直接画像importを主経路へ格上げする場合だけ検討する。

残る改善点は、UX上の自明性が高いものに絞る。特に `Save As` の文言と挙動、Target Statusの読みやすさ、Editor上のactual dialog / standard panel確認を次の判断材料にする。

## UX前提の確認

### 任意custom atlasの主経路

任意tile sizeのatlasは、Godot標準TileSet画面でTileSetのtile sizeとatlas sourceを設定し、Edit DockのTarget TileSet pickerまたは内部 `TileMapLayer` 選択経由で `HexTileMapLayer` に接続する。この流れであれば、Edit Dock側がtile size入力UIを持たなくても任意atlasは扱える。

### Edit DockのAtlas Browseの位置づけ

Edit Dockの `Atlas Image` Browse / `Apply Atlas` は、sample / preset互換画像をすばやくTarget TileSetへ設定する補助操作である。任意tile size atlasを作る正式な入口ではないため、固定sample tile size前提は計画未達ではなく、操作の役割をstatus / manualで明示すれば十分である。

## Findings

### [P2] `Save As` buttonがpath設定済み時にdialogを開かず上書き保存する

Document rowのbutton textは `Save As` だが、`_document_path` が空でない場合はdialogを開かず `save_document()` を実行する。機能としては便利だが、labelの期待とはズレる。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:600`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1014`

影響:

- ユーザーは `Save As` を押したつもりで既存pathへ上書き保存する可能性がある。
- Export rowは `Export` と `Save As` が分かれているため、Document rowだけ挙動が異なる。

推奨:

- Document rowも `Save` と `Save As` を分ける。
- 1 buttonのままなら、labelを `Save` に戻し、path空時だけSave dialogへfallbackする挙動をstatusで示す。

### [P3] Target Status labelが長く、通常操作中に読み取りにくい

Target StatusはTileSet path、source count、tile size、floor / wall / overlay payload、overlay visibilityなどの診断情報を1行にまとめている。debug用途としては有用だが、通常操作中のstatusとしては情報量が多い。

影響:

- ユーザーが今知りたい「編集できるか」「保存済みか」「どのTileSetを使っているか」を拾いにくい。
- 詳細診断は `Copy Debug Report` にあるため、status labelへすべて出す必要は薄い。

推奨:

- Target Status labelはready状態、document source、TileSet path、tile size程度に絞る。
- payload詳細、overlay visibility、z-index相当情報はdebug reportへ残す。

### [P3] invalid resourceの原因表示は押下後status中心である

`_refresh_action_button_states()` はpath空、documentなし、targetなしをdisabledにしている。一方、存在しないpath、型が違う `.tres`、textureとして読めない画像、tile grid不一致などは押下後のstatusで判明する。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:2323`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:331`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:191`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1135`

影響:

- 計画の「invalid stateでbuttonがdisabledになるか、押下前に原因Statusが見える」は、空入力系では満たしているが、invalid resource系では部分達成である。

推奨:

- path未存在、resource type違い、texture load失敗をstatusで区別する。
- 押下前validationを過度に増やすより、失敗時statusの明瞭さを優先する。

## 計画以上の機能

### Path dialog helperがGeneration Dockにも展開された

`HexMapEditorPathSelector` が追加され、Edit DockだけでなくGeneration DockのSource Registry、History Dir、Save As、Atlas Imageにも利用されている。計画の「Edit DockのAtlas ImageだけではなくEditor Plugin全体へ寄せる」方針と整合している。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_editor_path_selector.gd:1`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:1195`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:1759`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:1846`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:1872`

### Target TileSet persistenceが仕様として実装された

`HexTileMapLayer.display_tile_set_resource` が追加され、内部 `TileMapLayer.tile_set` と同期される。これにより、内部childの保存挙動に依存せず、Target側にTileSetを保存する境界が明確になった。

該当箇所:

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd:55`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd:282`
- `tests/test_hex_tile_map_layer.gd:223`

### Overlay payload UXが前回レビューから進んだ

Floor / Wall / Overlay Tile payloadがmode別stateになり、Overlay item key候補もdocument内の既存overlay entryから出せるようになっている。前回レビューの「payload混在」指摘は、自動テストで確認できる範囲では解消済みである。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:60`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:756`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1279`
- `tests/test_editor_plugin.gd:1012`

## 計画に関する未達・部分達成項目

- `EditorFileDialog` の実際のpopup操作はheadless testでは確認できない。analog test手順は更新済みだが、実行結果文書は未確認。
- `Select Internal TileMapLayer` 押下後にGodot標準TileMap panelが期待通り出るかは、Godot editor UI依存のためanalog確認が必要。
- `HexMapEditorPathSelector` は計画上の「selector row Control」ではなくdialog factory / utilityとして実装されている。計画内に「共有helperが過剰ならfactoryだけ共有」とあるため許容範囲だが、row単位のvalidation共通化は未実装。
- `Apply Sample` の「選択と適用状態が分かる表示」は明確なapplied indicatorまでは追加されていない。ただし、statusで成功 / 失敗が分かるため次計画の主題にはしない。

## 実装に対する指摘事項

- 実装上の大きな阻害事項は見当たらない。
- 低優先の整理として、`HexMapEditorPathSelector.resource_path_text()` と `tile_set_source_count()` は現時点で未使用。今後Target Status formattingへ使わないなら削除してよい。
- `load_mapdata_source()` は `ResourceLoader.exists(path)` がfalseの場合に即 `-1` を返すようになった。失敗statusは改善しているが、resource type mismatchとmissing pathは同じstatusになりやすい。

## UX改善案

- Document rowは `Save` / `Save As` を分ける。Export rowと同じ構造にするとユーザーの予測が揃う。
- Target Status labelは、`ready/missing`、document source、TileSet path、tile size程度に絞る。payload詳細とz-indexはdebug reportへ残す。
- invalid resource pathは、失敗時statusを分かりやすくする。入力直後の重いvalidationは必須にしない。
- Source Registry失敗statusは `missing path` / `unsupported resource type` / `load failed` に分ける。
- `Atlas Image` Browseはsample / preset互換の簡易適用であることをmanualまたはstatusに書く。任意tile size atlasはGodot標準TileSet画面を使う。

## その他の不明点・任意指摘

- Object Node / scene layer、`TileSetScenesCollectionSource`、object専用layerは今回も未着手で妥当。`docs/review/HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md` を元に別Planning Flowで扱う。
- `apply_document_cell()` の全量document duplicate / resource変換 / `_data` 再構築は今回計画から分離されており、未解決のまま残る。これは次のperformance / state差分適用計画の中心にする。
- plain `TileMapLayer` legacy helperの内部到達経路整理も今回計画外のまま残る。Editor通常UX、Generation Overlay、Core互換testの境界整理として別扱いがよい。

## 既存レビューからの完了整理

`docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md` の後続アクション候補について、今回の計画での状態は以下。

完了扱い:

- Target TileSet / atlas sourceのPackedScene保存 / reload test。
- Edit DockのAtlas Image Browse UI。
- `Select Display Layer` 文言とstatus改善。
- Overlay Tile payloadのmode別保持。
- Target由来documentの未保存 / 保存済み状態表示。

残す:

- `apply_document_cell()` の差分適用化と大型map計測。
- Object Node / scene layer計画。
- plain `TileMapLayer` legacy helperの境界整理。
- Editor上のactual dialog / standard panel / scene save-reload analog result。
- Direct Atlas Browseを任意tile size importへ拡張するかどうかのUX判断。標準TileSet画面を主経路にする限り、次計画にはしない。

## 完了整理

`EDITOR_DOCK_FILE_RESOURCE_SELECTION` Planning Flowは、自動テストで確認できる範囲では完了扱いにできる。計画文書を `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/` に移動した整理も妥当である。

次のPlanning Flow候補は以下に絞る。

1. Document Save / Save As の操作体系整理。
2. Target Statusの通常表示 / debug report分担整理。
3. `apply_document_cell()` の差分適用とlarge map performance。
4. Editor analog resultの記録。

任意候補:

- Direct Atlas BrowseをGodot標準TileSet画面とは別のatlas import主経路にする場合のみ、tile size selectorやatlas validationを追加する。
