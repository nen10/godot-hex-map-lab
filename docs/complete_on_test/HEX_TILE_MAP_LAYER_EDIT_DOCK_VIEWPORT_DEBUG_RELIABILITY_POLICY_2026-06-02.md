# HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_POLICY_2026-06-02.md

## 目標UX

- `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_UX_2026-06-02.md`

## 採用候補

### 候補A: Debug表示をselectable Labelにする

条件付き採用。

内容:

- Godotの `Label` がDock上でselectableとして安定する場合、status / Target Status / Last Edit / Save Exportにselectable設定を付ける。
- 既存layoutを大きく変えずに済む。

Escalation条件:

- selectable LabelがEditor Dockでdrag copyできない場合、候補Bへ切り替える。

### 候補B: Debug表示をread-only formへ置換する

採用。

内容:

- `TextEdit` またはreadonly `LineEdit` をdebug/detail表示に使う。
- 多行traceはread-only `TextEdit`、短文statusはreadonly `LineEdit` で扱う。
- 必要なら `Copy` buttonを追加する。

理由:

- ユーザーがDebug報告を直接copyできることを成功条件にできる。

### 候補C: 親 `HexTileMapLayer._draw()` のままhighlightを強い色にする

不採用。

理由:

- 親CanvasItemの描画はchild `TileMapLayer` の背面に出るため、色だけでは根本解決しない。

### 候補D: 前面overlay childでhighlight / markerを描く

採用。

内容:

- `HexTileMapLayer` 内に前面表示用 overlay nodeを持つ。
- highlight、object marker、label marker、pathなどの非tile visual feedbackをoverlay childへ移す。
- z orderまたはchild orderで内部 `TileMapLayer` より前面に出す。

### 候補E: `hex_size` を `TileSet.tile_size` から同期する

採用。

内容:

- `ensure_display_tiles()`、`configure_display_tiles_from_texture()`、Generation Dock apply時に `hex_size` をtile sizeから更新する。
- flat-top / pointy-topで変換式を明示する。

注意:

- 既存debug/testで明示的に `hex_size` を設定しているケースは維持する。

### 候補F: hit / overlay座標を内部 `TileMapLayer.map_to_local()` に寄せる

採用候補。

内容:

- display tileの中心位置を `HexMapTileAdapter.vector_to_map_cell()` + `_tile_map.map_to_local()` から取得する。
- 独自 `hex_to_local()` を維持する場合でも、表示中心との一致テストを追加する。

判断:

- 実装時にGodot hex layoutとの一致を優先するなら候補Fを優先する。
- Core座標式の継続利用を優先するなら候補E + 一致テストを優先する。

### 候補G: 無効clickでもEditorへeventを流さない

採用。

内容:

- Edit Dockがactiveでtarget/documentがある時、選択不能cellのclickでもevent consumedとして扱う。
- statusに `No editable cell` を出し、Editor selectionを変えない。

理由:

- 無効clickがAuto targetやEditor selectionを壊すことを防ぐ。

### 候補H: 内部 `TileMapLayer` をtarget候補から除外する

採用。

内容:

- `_collect_target_layers_recursive()` は `HexTileMapLayer` 配下のinternal `TileMapLayer` を候補に入れない。
- Auto selectionでも内部 `TileMapLayer` をtargetとして採用しない。

理由:

- ユーザーが親 `HexTileMapLayer` と内部表示layerを区別しないUXにする。

### 候補I: Editor UndoRedoを正しくadapter化する

条件付き採用。

内容:

- `UndoRedo` と `EditorUndoRedoManager` のAPI差異を吸収するhelperを作る。
- headless `UndoRedo` testとEditorUndoRedoManager source検査またはEditor analog testを追加する。

### 候補J: Editor UndoRedo連携を廃止する

採用候補。

内容:

- Pluginから `EditorInterface.get_editor_undo_redo()` を渡さない。
- Manual editは直接document replace + target applyを実行する。
- UndoRedo testは削除またはplain `UndoRedo` helper単体に限定する。

判断:

- ユーザー価値は低く、問題の温床であるため、実装を短く安定させるなら候補Jを優先する。
- Undo/Redo維持が必要になった場合だけ候補Iを採用する。

### 候補K: Debug fixture / analog testを追加する

採用。

内容:

- manual edit専用のdebug scene、resource fixture、または analog testを整備する。
- 既存 `tools/debug_generated_map.sh` / `tests/analog_test/GENERATED_MAP_MANUAL_EDIT...` を参照し、`HexTileMapLayer` targetに特化した観察項目を作る。

## 破壊的変更

- `HexTileMapLayer` の非tile visual feedbackの描画経路を親 `_draw()` から前面overlayへ変更する。
- `HexTileMapLayer` 配下の内部 `TileMapLayer` をtarget選択対象から除外する。
- Editor UndoRedo連携を廃止する場合、Godot EditorのUndo/Redoでmanual editを戻すUXは削除される。
- 無効click時にEditor selectionへeventを流さないため、Edit Dock active中のviewport click挙動が変わる。

## fallback扱い

- atlas missingでtile表示が欠ける状態はdebug観察手段にしない。
- Importし直してtarget反応を回復する状態はfallback扱いにしない。
- Debug textを目視転記する運用はfallback扱いにしない。

## UX Escalation

- Debug表示をread-only formにするとDockがさらに縦に長くなる場合、section fold / compact detail / copy button中心のUXへ戻す。
- UndoRedo廃止が操作上困ると判明した場合、EditorUndoRedoManager adapterを別計画または同計画の採用候補に戻す。
- `hex_size` 同期だけではGodot `TileMapLayer` 表示中心と一致しない場合、hit / overlay座標を内部 `TileMapLayer.map_to_local()` 主導へ変更する。
