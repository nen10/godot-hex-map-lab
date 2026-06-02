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
- `EditorUndoRedoManager` は `UndoRedo` と `add_do_method()` のAPIが異なる。headless testで `UndoRedo.new()` が通っても、Editor Pluginで `EditorInterface.get_editor_undo_redo()` に `Callable` を渡すとerrorになる。Editor UndoRedo連携を使う場合はAPI adapterを作り、不要なら直接applyへ戻す。
- `CanvasItem` の親 `_draw()` はchild `TileMapLayer` の背面に出る。TileMap上のhighlightやmarkerを確実に見せたい場合、親 `_draw()` ではなく前面overlay child、z index、またはchild orderを使う。
- `HexTileMapLayer` の表示tileはGodot `TileMapLayer` / `TileSet.tile_size` に従い、click hitやhighlightは `hex_size` に従う。両者を別々に更新すると、見えているcellとhit対象がずれる。display tile size変更時は `hex_size` を同期するか、hit / overlayの中心座標を内部 `TileMapLayer.map_to_local()` から取得する。
