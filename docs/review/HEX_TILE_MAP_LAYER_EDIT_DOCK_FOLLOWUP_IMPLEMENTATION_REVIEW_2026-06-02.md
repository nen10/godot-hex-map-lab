# HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_IMPLEMENTATION_REVIEW_2026-06-02.md

## 対象

- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_POLICY_2026-06-02.md`
- Implementation Plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_IMPLEMENTATION_PLAN_2026-06-02.md`
- UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_UX_2026-06-02.md`
- Review input: `docs/review/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_REVIEW_2026-06-02.md`

## 実装確認

- Edit Dockを `ScrollContainer` + inner `VBoxContainer` 構成に変更した。
- generation dock tab nameを `Hex Map Generate` に明示設定した。
- Edit Dock Target Autoを live editor selection / first scene target 解決に変更し、explicit targetとは別フラグで扱うようにした。
- Edit Dockに Default Floor / Wall tile settings を追加した。
  - source id
  - atlas x / y
  - alternative tile
  - `Read Target Tiles`
  - `Apply Target Tiles`
- plain `TileMapLayer` redraw optionsに default alternative tile を通すようにした。
- `HexTileMapLayer.apply_document()` を追加し、`HexMapDocumentResource` の map / tile overrides / object / label を表示状態へ反映できるようにした。
- `HexTileMapLayer.display_state_for_hex()` を追加し、Last Edit trace が source / atlas / alternative / marker count を読めるようにした。
- Object / Label は初期表示として marker surrogate を `_draw()` で描くようにした。
- Last Edit traceに target resolution reason、target apply reason、renderer、source、atlas、alternative、marker count、payload summary を追加した。

## テスト確認

実行:

```sh
./tools/test.sh
```

結果:

- `tests/test_hex_core.gd`: passed
- `tests/test_hex_map_generation.gd`: passed
- `tests/test_hex_adapter.gd`: passed
- `tests/test_hex_tile_map_layer.gd`: passed
- `tests/test_editor_plugin.gd`: passed
- `tests/test_debug_scenes.gd`: passed

追加・更新した主な確認:

- `tests/test_hex_tile_map_layer.gd`
  - `HexTileMapLayer.apply_document()` が tile override / object marker / label marker display state を反映する。
- `tests/test_editor_plugin.gd`
  - Edit Dockがscroll containerを持つ。
  - generation dock tab nameが安定する。
  - Target Autoがeditor-selected targetを使う。
  - Default Floor / Wall tile settingsがplain `TileMapLayer` と `HexTileMapLayer` に反映される。
  - Floor Tile modeが `HexTileMapLayer` の表示atlasを変更する。
  - Object / Label modeが `HexTileMapLayer` の marker display state と Last Edit traceを変更する。

## 残リスク

- Object / Label は marker surrogate 表示であり、database-driven iconや実text描画は未実装。今回の要件では「viewport上で変化が分かる」範囲として完了扱いにする。
- atlas source / atlas coords が target `TileSet` に存在しない場合の見え方は Godot の `TileMapLayer` 表示可否に依存する。今回の対応では明示設定項目と readiness / Last Edit traceで設定不足を追跡できる状態にした。
- Dock上の default tile settings は項目数が多い。今後UI密度が問題になった場合はsection foldingを別計画にする。

## 判定

計画済み機能は Test path で確認済み。該当計画文書は `docs/complete_on_test/` へ移動してよい。
