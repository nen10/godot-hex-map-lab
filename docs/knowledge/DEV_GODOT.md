# DEV_GODOT.md

Godotでの開発ノウハウを随時追加します。
実装後、レビュー結果を受けてノウハウの有効性を再検討してください。

## TileMapLayer と EditorPlugin viewport input

- Godotの `TileMapLayer` は `Node2D` 派生だが、Editor上では標準TileMap editorの対象にもなる。Scene Treeでplain `TileMapLayer` を選択した状態では、addonの `_forward_canvas_gui_input()` と標準atlas paint操作が競合しやすい。
- addon専用のmanual edit targetを作る場合、plain `TileMapLayer` を直接選択対象にするより、`Node2D` wrapperを選択対象にして内部 `TileMapLayer` を表示実装として隠す方が入力責務を分けやすい。
- `TileMapLayer.set_cell()` はsource id、atlas coords、alternative tileで表示tileを決める。cellを書いても、対応する `TileSet` source / atlas tileが存在しなければEditor viewport上では表示確認できない。
- `@tool` nodeでresourceをready前に受け取る場合、setterではresourceを保持し、`_ready()` でinternal child作成後にredrawする。redraw時にはTileSet shapeだけでなくvisible atlas sourceの存在も確認する。
- `Node.add_child(..., INTERNAL_MODE_BACK)` で作るinternal childを後で再検出する場合、`get_children(true)` を使う。defaultの `get_children()` だけだとinternal childを走査できない。

## Editor Dock UI と target 解決

- `add_control_to_dock()` で表示される Dock tab 名は、対象 `Control.name` の設定漏れに影響される。Dockへ追加する前に明示的な `name` を設定し、testでは plugin source または dock instance name を確認する。
- Dock が縦に長くなる場合、root `Control` へ直接 `VBoxContainer` を置くのではなく、`ScrollContainer` の内側に内容用 `VBoxContainer` を置く。Dockへ渡す `Control` 自体は `Container` ではないため、`ScrollContainer` には `PRESET_FULL_RECT` anchorを設定する。内容用 `VBoxContainer` は横を `SIZE_EXPAND_FILL`、縦を `SIZE_SHRINK_BEGIN` にして、最小高さがscroll対象として残るようにする。
- `Auto: Selected / first scene layer` のような target option は cached target を返すとlabelと挙動がずれる。Autoは live editor selection を第一候補、scene scan結果を第二候補にし、explicit targetとは別の解決経路にする。
- Last Edit trace は `document changed`、`target applied`、`display changed` だけでは不足する。tile atlasが変わらない edit mode では、renderer kind と display unavailable reason を別項目にし、成功したdocument更新と表示対象外を区別する。
- Edit Dock の default tile settings は atlas自動読み取りだけに依存させない。Floor / Wall の source id、atlas coords、alternative tileをUIから明示設定できるようにし、`Read Target Tiles` は現在targetの状態を読む操作、`Apply Target Tiles` はtargetとredraw optionsへ設定を反映する操作として分ける。
- `HexTileMapLayer` を manual edit target にする場合、`HexMapDocumentResource` から map本体だけを `HexMapResource` に変換すると tile override / object / label の表示が落ちる。`apply_document()` のような helperで map apply 後に document payload display state を反映する。
- Dock上でユーザーがDebug報告する文字列は、通常の `Label` だけに置くとdrag選択できず転記が難しい。status / Last Edit / Target Status / Save Exportのような報告用textは、selectable Labelが使えるか確認し、安定しない場合はread-only `TextEdit` / `LineEdit` またはCopy buttonを使う。
- Debug情報を一括報告させたい場合、`DisplayServer.clipboard_set(text)` でCopy buttonを作れる。headless testではOS clipboardの実内容を読むより、生成したreport textと直近copy用に保持した文字列を照合する方が安定する。
- Godot 4.6.2では `PackedStringArray.join()` を使えないため、複数行debug reportを作る場合は手動join helperか利用可能なString側APIを確認してから使う。
- `EditorUndoRedoManager` は `UndoRedo` と `add_do_method()` のAPIが異なる。headless testで `UndoRedo.new()` が通っても、Editor Pluginで `EditorInterface.get_editor_undo_redo()` に `Callable` を渡すとerrorになる。Editor UndoRedo連携を使う場合はAPI adapterを作り、不要なら直接applyへ戻す。
- `CanvasItem` の親 `_draw()` はchild `TileMapLayer` の背面に出る。TileMap上のhighlightやmarkerを確実に見せたい場合、親 `_draw()` ではなく前面overlay child、z index、またはchild orderを使う。
- `HexTileMapLayer` の表示tileはGodot `TileMapLayer` / `TileSet.tile_size` に従い、click hitやhighlightは `hex_size` に従う。両者を別々に更新すると、見えているcellとhit対象がずれる。display tile size変更時は `hex_size` を同期するか、hit / overlayの中心座標を内部 `TileMapLayer.map_to_local()` から取得する。
- `Hex Map Edit` のviewport入力はTargetだけでなく編集対象documentにも依存する。`HexTileMapLayer` が `hex_map` を持ってreadyでも、Edit Dock側の `_document` が空ならviewport editは始まらない。Target Reloadを編集開始操作にする場合、選択中 `HexTileMapLayer.hex_map` から未保存 `HexMapDocumentResource` を作る入口が必要。
- `TileMapLayer.local_to_map()` / `map_to_local()` はGodot側のmap cellとlocal座標の基準APIである。`TileSet.tile_shape = HEXAGON`、`TILE_LAYOUT_STACKED`、`tile_offset_axis`、`tile_size` を使う表示では、独自hex数式だけをhit / overlay中心の根拠にすると遠端cellでずれが蓄積しやすい。Editor上で見えているcell操作は内部 `TileMapLayer` の変換APIに寄せる。
- `HexMapDocumentResource` を1clickごとにbefore / after全量複製し、さらに `HexTileMapLayer.apply_document()` で全量redrawすると、大きいmapではEditor操作が重くなる。`Wall / Floor` やtile overrideのような単一cell変更は、document state更新と内部 `TileMapLayer.set_cell()` のincremental applyを優先する。
- `HexTileMapLayer` を `TileMapLayer` 継承にするとGodot標準TileMap editorの選択・paint対象とaddon独自manual edit targetが同じnodeになり、入力責務が混ざりやすい。GodotのTileMap機能を使う目的には、`Node2D` wrapperが内部 `TileMapLayer` と前面overlay childを管理するcompositionの方が扱いやすい。
- Image生成モデルで作ったsprite sheetは、最終的にGodot `TileSetAtlasSource.texture_region_size` に合う厳密なpixel寸法へ整形する。ImageMagickやPillowがない環境でも、Godot headlessの `Image` APIでchroma key透明化、subject bbox検出、resize、atlas保存ができる。今回の再利用toolは `tools/process_generated_tactics_assets.gd`。

## TileSet / TileMap editor と asset 選択

- このprojectは `project.godot` でGodot `4.6` featureを指定している。TileSet / TileMap editor連携を調査する場合はGodot 4.6公式docsを基準にする。
- Godot標準TileMap editorは、`TileMapLayer` nodeを選択してからbottom panelのTileMap panelを開く流れで使う。addonのユーザー向けTargetを `HexTileMapLayer` wrapperに寄せる場合、内部 `TileMapLayer` を標準TileMap panel対象として選択させる操作と、wrapperをmanual edit targetにする操作が衝突しないか確認する。
- Godot標準TileSet editorでは、tilesheet画像から `TileSetAtlasSource` を作り、TileSetのtile sizeに基づいてtileを自動作成できる。複数画像を1つのTileSetに使う場合は追加atlasを作る方針が公式docs上の自然な経路である。
- `TileSetAtlasSource` はtexture、margins、separation、`texture_region_size`、alternative tile、TileDataを持つ。addon側でatlas画像を選択する場合も、source id、atlas coords、alternative tileだけでなく、TileSet側のsource構成とregion sizeを明示的に扱う必要がある。
- `TileMapLayer.set_cell()` は `source_id`、`atlas_coords`、`alternative_tile` をcellに保存する。asset選択UXではTarget / TileSet境界を採用し、documentはこの3値をpayloadとして持ち、asset path / TileSet referenceは持たない。
- `EditorPlugin._handles()` がtrueを返す対象では `_edit()` / `_make_visible()` / `_forward_canvas_gui_input()` が呼ばれる。標準TileMap editorとaddon manual editの入力が同じ2D viewportで競合する場合、addon側はeventを消費する条件を限定する必要がある。
- addonは標準TileMap panelの現在選択tileに依存せず、Target TileSet resourceと `source_id` / `atlas_coords` / `alternative_tile` を境界にする。標準TileMap画面はTileSet編集の補助操作として開き、manual edit payloadはDock側の明示設定から作る。
- 現在のaddon実装では、Generation Dockに `Select Atlas Image` / `Use Sample Tiles` があり、選択画像を `HexTileMapLayer` またはplain `TileMapLayer` のTileSetへ反映する経路がある。Edit Dockはsource id / atlas coords / alternative tileの数値設定と `Read Target Tiles` / `Apply Target Tiles` を持つが、画像atlas選択UIはまだ持たない。
- Edit Dockへasset選択UIを足す場合、Generation Dockの画像選択処理を再利用できる。選択assetはTarget `HexTileMapLayer` の内部 `TileMapLayer.tile_set` へ設定し、documentへasset pathを保存しない。
- 生成済みtactics atlasは固定defaultではなく、ユーザーが選択できるsample / preset assetとして扱う。Object用画像atlasはTile / Overlay asset計画から外し、Node / scene配置の検討としてreview側へ分離する。

参照:

- Godot 4.6 Using TileSets: https://docs.godotengine.org/en/4.6/tutorials/2d/using_tilesets.html
- Godot 4.6 Using TileMaps: https://docs.godotengine.org/en/4.6/tutorials/2d/using_tilemaps.html
- Godot 4.6 TileMapLayer: https://docs.godotengine.org/en/4.6/classes/class_tilemaplayer.html
- Godot 4.6 TileSetAtlasSource: https://docs.godotengine.org/en/4.6/classes/class_tilesetatlassource.html
- Godot 4.6 EditorPlugin: https://docs.godotengine.org/en/4.6/classes/class_editorplugin.html
- Godot 4.6 EditorInterface: https://docs.godotengine.org/en/4.6/classes/class_editorinterface.html
