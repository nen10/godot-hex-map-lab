# HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_REVIEW_2026-06-02.md

## 目的

`Hex Map Edit` Dock の実Editor確認で発生した、debug報告困難、viewport click停止、表示座標ずれ、編集結果不可視、UndoRedo error、debug fixture不足を整理する。

## ユーザー確認結果

1. Dock上の実行結果表示・Debug表示項目はdragで文字選択できず、Debug報告が難しい。
2. Edit Modeで選択不能なviewport地点を一度clickすると、その後任意地点のclickが反応しなくなる。
   - `HexMapResource` をImportし直すと回復する。
   - `HexMapDocumentResource` をReadしても回復しない。
3. Click後のhighlightがGodot共通 `TileMapLayer` の表示の裏に出る。
   - `TileMapLayer` のcell表示が欠落した時だけ `HexTileMapLayer` のhighlightが見える。
   - highlight cell sizeが `TileMapLayer` のcell sizeより小さい。
   - `TileMapLayer` の特定cellを狙ってclickすると、`HexTileMapLayer` の別座標cellがclickされる。
4. Click後、Debug表示上は `wall -> floor` などが出ても、`TileMapLayer` のcellが編集されていない。
5. Debug用リソースを明確に整備したい。
6. Click後、Godot Outputに次のerrorが出る。
   - `ERROR: res://addons/hex_map_kit/editor/hex_map_edit_tool.gd:699 - Invalid call to function 'add_do_method' in base 'EditorUndoRedoManager'. Expected 2 argument(s).`

## 対応調査

### 1. Dock debug表示の文字選択

`HexMapEditTool` のstatus / target status / Last Edit / Save Exportは `Label` で表示されている。Godot EditorのDock上では通常の `Label` はdrag選択できないため、ユーザーがtraceを転記しにくい。

対応候補:

- `Label` のselectable設定を有効化できる場合は、status/detail labelに適用する。
- selectable `Label` がEditor Dockで安定しない場合、read-only `TextEdit` またはreadonly `LineEdit` をdebug/detail表示用に使う。
- 長文traceはcopy buttonまたはsingle-line compact summary + multiline detailsに分ける。

判定:

- Debug報告は開発体験の中心なので、selectable/read-only form化を採用候補にする。

### 2. 選択不能地点click後の反応停止

`HexMapEditTool.apply_local_position()` は、`Shape` 以外で存在しないcellをclickした場合 `false` を返す。`EditorPlugin._forward_canvas_gui_input()` も `false` を返すため、そのclickはGodot Editor本体のselection処理へ流れる可能性がある。

現在のTarget `Auto` はlive editor selectionを優先する。したがって、無効clickによってEditor selectionが内部 `TileMapLayer` や別 `CanvasItem` に移ると、以降のAuto targetが変わる可能性がある。

`HexMapResource` importで回復し、document readで回復しない観察は、`import_map_resource_from_path()` だけがtargetをEditor selectionへ同期している挙動と整合する。

判定:

- 無効click時もEditorへeventを流しすぎない設計が必要。
- Auto targetは「操作中target」と「Editor selection候補」を分け、click中に内部表示nodeへ奪われないようにする必要がある。
- 内部 `TileMapLayer` をtarget候補やEditor selection候補から除外する必要がある。

### 3. 表示裏のhighlightとcell size / coordinateずれ

`HexTileMapLayer` は内部child `TileMapLayer` にtileを置き、highlightは親 `HexTileMapLayer._draw()` で描いている。GodotのCanvasItem描画順では親の `_draw()` はchildより背面に出やすく、tile表示の裏にhighlightが隠れる。

また `HexTileMapLayer` のclick hitとhighlightは `hex_size` から独自計算される。一方、内部 `TileMapLayer` の表示は `TileSet.tile_size` とGodotのhex tile layoutに従う。現在 `configure_display_tiles_from_texture()` / `ensure_display_tiles()` は `TileSet.tile_size` を設定するが、`hex_size` を同期していない。sample tile size `64 x 57` に対して `hex_size = 24` のままだと、独自座標のcell間隔はtile表示より小さくなる。

判定:

- `HexTileMapLayer` の視覚表示、hit判定、highlight、payload markerは同一座標系へ統一する必要がある。
- `hex_size` は `TileSet.tile_size` から同期するか、内部 `TileMapLayer.map_to_local()` を主座標として使う必要がある。
- highlight / markerは親 `_draw()` ではなく、tile layerより前面のoverlay childで描く設計が安全。

### 4. 編集結果が可視化されない

`HexMapEditTool._commit_document_change()` は `_undo_redo` がある場合、UndoRedo actionにdo/undo methodを登録してcommitする。Plugin側は `_edit_tool.set_undo_redo(EditorInterface.get_editor_undo_redo())` を渡している。

Godotの `EditorUndoRedoManager.add_do_method()` は `UndoRedo.add_do_method(Callable)` と異なるAPIを持つ。現在の実装は `Callable(self, "...")` 形式を渡しており、Editor実行では `Expected 2 argument(s)` errorになる。

このerrorが出ると、document replace / target apply が期待通り実行されず、Dock traceだけが一部更新される状態になりうる。

判定:

- UndoRedoは今回のユーザー価値では低優先であり、問題の温床になっている。
- 実装候補は `EditorUndoRedoManager` adapterを書くか、Editor UndoRedo連携を一旦廃止して直接applyに戻す。
- UndoRedoを維持する場合も、Editor APIとheadless `UndoRedo` APIを分けてtestする必要がある。

### 5. Debug用リソース

既存には以下がある。

- `tools/debug_generated_map.sh`
- `tools/debug_hex_orientation.sh`
- `tests/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md`
- `tests/analog_test/MANUAL_LOOP_DUPLICATE_EDIT_ANALOG_TEST_DRAFT_2026-06-01.md`

ただし今回の問題は「manual edit targetとして `HexTileMapLayer` と内部 `TileMapLayer` を意識的に区別しない」ことに集中しており、専用のfixture / analog手順が不足している。

判定:

- manual edit visibility専用のdebug sceneまたはfixture resourceを作る。
- target選択、invalid click、highlight前面表示、cell hit一致、Last Edit copy可能性を観察項目にする。

## 分類

| 項目 | 種別 | 対応方針 |
| --- | --- | --- |
| Dock debug文字選択不可 | Debug UX不足 | selectable labelまたはread-only form表示へ置換する。 |
| 無効click後の反応停止 | Editor event / target解決bug | 無効click eventの扱い、Auto target固定、内部node除外を見直す。 |
| highlightがtile裏に出る | 表示layering bug | overlay child / z order設計へ変更する。 |
| cell size / click座標ずれ | 座標系bug | `hex_size` と `TileSet.tile_size` または `map_to_local()` に基づく統一座標へ変更する。 |
| 編集結果不可視 | apply path bug | EditorUndoRedoManager errorを解消し、target display applyを確実化する。 |
| Debug用リソース不足 | 開発体験不足 | manual edit専用fixture / analog testを追加する。 |

## 計画化

- UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_UX_2026-06-02.md`
- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_POLICY_2026-06-02.md`
- Implementation Plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_PLAN_2026-06-02.md`
- Plan Review: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_PLAN_REVIEW_2026-06-02.md`
