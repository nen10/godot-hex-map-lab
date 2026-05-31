# MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY_IMPLEMENTATION_PLAN_2026-05-31.md

## 参照方針

- 方針: `docs/plan/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md`
- runtime 方針: `docs/plan/RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md`
- runtime 前提 plan: `docs/plan/RUNTIME_INTERACTION_LOOP_DISPLAY_TILE_COPY_IMPLEMENTATION_PLAN_2026-05-31.md`
- 採用案: `HexTileMapLayer` の loop-aware hit と visual representative を manual edit 用表示の正とする。

## 対象範囲

`MANUAL_MAP_EDITING_TOOL` の document / adapter / dock / Undo / Redo 初期実装は test 確認済みとして `docs/complete_on_test/` へ移動済みである。本計画では、manual edit 用表示で loop duplicate を視認し、visual duplicate から canonical document を編集する workflow を対象にする。

## 対象ファイル

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/plugin.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## 入出力インターフェース

入力:

- selected `HexMapDocumentResource`
- target `HexTileMapLayer`
- edit mode
- mouse `InputEvent`
- local position
- hit dictionary
- tile / object / label payload
- loop display settings

出力:

- updated `HexMapDocumentResource`
- refreshed `HexTileMapLayer`
- UndoRedo action
- edited canonical cell
- selected / hovered visual representative
- status text

## 座標変換方針

manual edit tool は loop 表示時の toric wrap や representative 選択に runtime hit API を使う。

クリック処理:

1. `EditorPlugin._forward_canvas_gui_input(event)` が `HexMapEditTool.forward_canvas_gui_input(event)` へ渡す。
2. target が `HexTileMapLayer` の場合、target local position を `HexTileMapLayer.local_to_cell_hit(local_pos)` へ渡す。
3. `hit["exists"] == true` または edit mode が shape の場合だけ編集する。
4. document mutation は `hit["hex"]` に対して行う。
5. status / selection / hover は `hit["visual_hex"]` を保持する。
6. UndoRedo commit 後、target `HexTileMapLayer` を document から再描画し、loop display を refresh する。

plain `TileMapLayer` target は non-loop fallback として維持する。loop 表示付き編集では `HexTileMapLayer` target を代表案とする。

## 表示状態

manual edit tool は次の状態を持つ。

```gdscript
var _last_edit_hit: Dictionary = {}
var _hover_hit: Dictionary = {}
```

用途:

- status label に canonical / visual を表示する。
- selected visual representative を highlight する。
- Undo / Redo 後に canonical cell の状態と visual duplicate 表示を同期する。

highlight は runtime 側の overlay draw / highlight API を使う。独自 overlay view が必要な場合も、hit dictionary の `hex` / `visual_hex` を source of truth とする。

## UI計画

### loop display controls

代表案では target `HexTileMapLayer` の loop display settings を正とする。Dock には次の補助だけを置く。

- target が `HexTileMapLayer` かどうかの status
- current loop mode
- last hit canonical / visual
- refresh target display button

Dock 側で loop mode / rect / margin を直接編集する UI は候補として残す。初期実装では target scene state を正として表示する。

### payload controls

review で指摘された縦長 UI を整理する。

- Floor Tile / Wall Tile mode: tile payload controls を表示する。
- Object mode: object payload controls を表示する。
- Label mode: label payload controls を表示する。
- Shape / Wall-Floor mode: payload controls を畳む。

これは loop 表示と独立して実装可能だが、manual edit 用表示の操作性を保つため同じ次回計画に含める。

## Resource schema

`HexMapDocumentResource` schema は canonical document の保存に使う。

loop display state は scene / target layer の view state として扱う。保存対象は canonical document のみである。

## Fallback扱い

- plain `TileMapLayer` への local hit は non-loop 編集 fallback として維持する。
- `HexTileMapLayer` の outline-only duplicate だけで editing view を成立させる状態は fallback であり、runtime loop copy display 完了後に置き換える。
- visual representative は document 保存対象ではなく、表示状態として扱う。

## テスト計画

### `tests/test_editor_plugin.gd`

- `_test_map_edit_tool_forward_canvas_gui_input_edits_loop_visual_duplicate()`
  - target を loop display enabled の `HexTileMapLayer` にする。
  - visual duplicate の mouse event を `forward_canvas_gui_input()` へ渡す。
  - document の canonical cell が更新されることを検証する。
- `_test_map_edit_tool_refreshes_loop_display_after_edit()`
  - wall / floor edit 後に target layer の loop copy display が更新されることを検証する。
- `_test_map_edit_tool_undo_redo_preserves_loop_visual_identity()`
  - visual duplicate から編集し、Undo / Redo 後も canonical document と duplicate tile が同期することを検証する。
- `_test_map_edit_tool_mode_specific_payload_controls()`
  - edit mode ごとに関係する payload controls だけが表示されることを検証する。

### `docs/TEST.md`

Hex Map Edit Dock の手動確認に以下を追加する。

- `HexTileMapLayer` target で loop display を有効にする。
- duplicate tile を click して canonical cell が編集されることを確認する。
- Undo / Redo 後に duplicate tile 表示も戻ることを確認する。
- status に canonical / visual が区別して表示されることを確認する。

## 実装手順

1. runtime の loop copy display plan を完了し、`refresh_loop_display()` を利用可能にする。
2. `HexMapEditTool` に last hit / hover hit state を追加する。
3. `forward_canvas_gui_input()` の test を追加し、loop visual duplicate から canonical document が更新されることを固定する。
4. document commit 後に target `HexTileMapLayer.refresh_loop_display()` を呼ぶ。
5. selected / hovered visual representative の status と highlight を追加する。
6. edit mode ごとの payload controls 表示を整理する。
7. `docs/TEST.md` を更新する。
8. `./tools/test.sh` を実行する。

## 完了判定

- manual edit 用表示で loop duplicate tile が見える。
- visual duplicate click は canonical document だけを更新する。
- Undo / Redo 後、canonical document と loop duplicate 表示が一致する。
- manual edit tool は runtime `HexTileMapLayer` の hit dictionary を座標変換の正として扱う。
- headless test と Editor workflow test が `docs/TEST.md` に記録される。
