# HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY Implementation Review

## 対象

- Review: `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_REVIEW_2026-06-02.md`
- UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_UX_2026-06-02.md`
- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_POLICY_2026-06-02.md`
- Implementation Plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_PLAN_2026-06-02.md`
- Analog Test: `tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md`

## 実装結果

1. `Hex Map Edit` Dockに `Copy Debug Report` buttonを追加した。
   - Target Status / Last Edit / Save Export / raw status / target resolution reason / target apply reasonを1つのtextへ整形する。
   - clipboardへの書き込みは `DisplayServer.clipboard_set()` を使う。
   - headless testではOS clipboard内容ではなく、生成reportと直近copy textの一致を確認した。

2. Editor UndoRedoManager連携をPluginから外した。
   - `EditorInterface.get_editor_undo_redo()` を `HexMapEditTool` に渡さない。
   - headless `UndoRedo` を使う既存単体テストは維持した。
   - Editor実行時の `EditorUndoRedoManager.add_do_method` API mismatch errorを回避する。

3. invalid viewport click後も編集状態を壊さないようにした。
   - `forward_canvas_gui_input()` はtarget local positionへ変換できたmanual edit clickを常に消費する。
   - 存在しないcellは `No editable cell.` を表示し、Editor selectionへclickを流さない。
   - invalid click後のvalid clickでdocumentが更新されるtestを追加した。

4. `HexTileMapLayer` の内部 `TileMapLayer` をtarget UXから隠した。
   - target scanでは親 `HexTileMapLayer` を候補にし、内部display layerを候補にしない。
   - Editor selectionが内部 `TileMapLayer` の場合も親 `HexTileMapLayer` へ解決する。

5. `HexTileMapLayer` の表示とhit / highlightの座標ずれを抑えた。
   - display tile size変更時に `hex_size` を同期する。
   - flat-topはtile widthの半分、pointy-topはtile heightの半分を使う。
   - display tile centerへのclick hitが同じhexへ戻るtestを追加した。

6. highlight / path / object marker / label markerを前面overlay childへ移した。
   - 内部 `OverlayLayer` を `INTERNAL_MODE_FRONT` で作成する。
   - 親 `_draw()` はoverlayが存在する場合は描画せず、fallbackだけにする。
   - overlayはbase `TileMapLayer` より高い `z_index` を持つ。

## Test

- `Godot --headless --log-file .godot_user/test_hex_tile_map_layer.reliability.log --path . --script res://tests/test_hex_tile_map_layer.gd`
  - Result: pass
- `Godot --headless --log-file .godot_user/test_editor_plugin.reliability.log --path . --script res://tests/test_editor_plugin.gd`
  - Result: pass
- `./tools/test.sh`
  - Result: pass

macOSの `get_system_ca_certificates` errorは終了コード0の既知非致命ログとして扱った。

## Documentation

- `docs/TEST.md` にCopy Debug Report、invalid click復帰、内部layer除外、前面overlay、tile size / hit同期のtest概要と手動確認項目を追記した。
- `docs/knowledge/DEV_GODOT.md` にclipboard copy、headless clipboard test方針、`PackedStringArray.join()` 非対応、EditorUndoRedoManager API差分、前面overlay、hex_size同期のノウハウを整理した。
- `tests/analog_test/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md` を追加した。

## 残リスク

- OS clipboardの実paste結果はheadlessでは確認していない。Godot Editor上のアナログテストで確認する。
- overlayの実視認性は自動テストではnode構造とstateまでの確認に留まる。実Editorでtile前面に見えることをアナログテストで確認する。
- `hex_size` 同期は現在のsample atlas / explicit atlas sizeに対する安定策であり、Godot TileSetのhex layout中心と完全一致しないケースがあれば `TileMapLayer.map_to_local()` 主導へ追加変更する。
- Editor UndoRedo UXは今回Plugin連携から外した。必要になった場合は `EditorUndoRedoManager` adapterを別計画で実装する。

## 判定

今回の計画範囲はTest pathで完了扱いにできる。手動Editor観察が必要な視認性とpaste結果は、追加したanalog testで確認する。
