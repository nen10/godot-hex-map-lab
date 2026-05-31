# MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md

## 対象

- `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_IMPLEMENTATION_PLAN_2026-06-01.md`
- `docs/complete_on_test/RUNTIME_INTERACTION_LOOP_DISPLAY_TILE_COPY_IMPLEMENTATION_PLAN_2026-05-31.md`
- `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY_IMPLEMENTATION_PLAN_2026-05-31.md`

## 結果

- Result: pass_after_fix
- Reviewer: sub-agent review plus main integration response
- Verification: `./tools/test.sh`

## 指摘と対応

1. Viewport pan / zoom 時の座標変換リスク
   - 指摘: editor viewport 座標を scene 座標へ戻す際に `global_canvas_transform` を優先しないと、pan / zoom された 2D viewport でクリック位置がずれる可能性がある。
   - 対応: `HexMapEditTool._editor_viewport_position_to_scene_position()` は `global_canvas_transform`、`canvas_transform`、`get_canvas_transform()` の順に利用する。
   - Test: `tests/test_editor_plugin.gd` で viewport transform route と source guard を検証する。

2. Refresh 後の target selection sync 不足
   - 指摘: target を Refresh で維持した直後に Editor selection が同期されないと、`EditorPlugin._handles()` の対象 object が外れる可能性がある。
   - 対応: `HexMapEditTool.refresh_target_layer_options()` が解決済み target を selection sync する。
   - Test: `tests/test_editor_plugin.gd` で explicit target 選択と Refresh 維持時の sync を検証する。

3. visual representative の表示状態
   - 指摘: loop 表示付き manual edit の結果として、canonical / visual の区別を status / display state に残す必要がある。
   - 対応: `last_edit_status()` に canonical `hex` と `visual_hex` を保存し、`HexTileMapLayer` target では最後に編集した canonical cell を highlight する。
   - Test: `tests/test_editor_plugin.gd` で duplicate viewport edit 後の canonical / visual status と highlight を検証する。

## 残リスク

- Godot Editor の実 viewport forwarding と pan / zoom 済み表示での体感確認は headless test では代替できないため、`.test/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md` の再実行対象として残る。
- `HexTileMapLayer` の duplicate tile 表示は headless test で確認済みだが、実 TileSet atlas の見た目は Editor / debug scene で確認する。
