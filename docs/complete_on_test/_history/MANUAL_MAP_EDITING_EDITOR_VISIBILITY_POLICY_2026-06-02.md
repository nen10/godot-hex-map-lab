# MANUAL_MAP_EDITING_EDITOR_VISIBILITY_POLICY_2026-06-02.md

## 目的

`docs/complete_on_test/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_UX_2026-06-02.md` の UX を実現するため、Hex Map Edit Dock に target readiness と edit trace を追加する。

## 現状

- viewport input は `EditorPlugin._handles()` と `HexMapEditTool.forward_canvas_gui_input()` に接続されている。
- `HexMapEditTool.last_edit_status()` は target path、mode、canonical hex、visual hex、exists、applied を返す。
- Dock の通常表示は `Edited <coordinate>` が中心で、document mutation と target redraw を分けて見られない。
- `debug_viewport_input` は `print()` 出力であり、analog test 中に見落とされやすい。
- `HexTileMapLayer` target の last edit highlight は前回 highlight を消さない。

## 方針

代表案として、Hex Map Edit Dock に compact status と detail trace を併設する。

compact status は従来の `Edited ...` を維持し、detail trace に target readiness、last edit、save/export checkpoint を表示する。trace は resource schema へ保存せず、Editor Dock session state として扱う。

## 比較事項

### 候補A: status label の文言だけを増やす

- 実装は軽い。
- target readiness、edit trace、save/export checkpoint が長文になり、狭い Dock で読みにくい。
- analog test の観察値を安定して引用しにくい。

不採用。

### 候補B: Dock 内に detail trace panel を追加する

- click 後の state を複数行で確認できる。
- target readiness と save/export checkpoint を同じ観察面へ置ける。
- headless test で label text または trace dictionary を検証できる。

採用。

### 候補C: modal dialog / popup で click 結果を出す

- 失敗時の注意喚起は強い。
- 連続 edit と Undo / Redo の操作を妨げる。

不採用。

### 候補D: `HexTileMapLayer` target だけを正規 target にする

- loop display と canonical / visual hit を扱いやすい。
- 生成 Dock から plain `TileMapLayer` を使う既存 UX と接続しづらい。

不採用。plain `TileMapLayer` と `HexTileMapLayer` の両方を扱い、Dock で要件を区別する。

### 候補E: last edit highlight は last-only selection にする

- 最後の click と Dock trace が一対一で対応する。
- 編集履歴の見た目は残らない。

採用。履歴表示は edit history UI が必要になった場合に別計画へ分ける。

## 破壊的変更候補

- `last_edit_status()` の返却 schema を拡張する。
- `debug_viewport_input` の主用途を Output panel から Dock detail trace へ移す。
- `HexTileMapLayer` に単一 highlight を外す helper を追加し、manual edit の last-only highlight に利用する。
- analog test の Operation Steps に target readiness と edit trace の観察点を追加する。

## Fallback 扱い

- `Edited <coordinate>` だけで成功扱いにする状態は fallback とする。
- Output panel の `print()` だけで viewport input を追跡する状態は fallback とする。
- target に TileSet がない、または atlas 設定が表示に向かない状態で、原因表示なしに viewport 無変化となる状態は fallback とする。
- last edit highlight が過去 edit を含む履歴表示のように蓄積する状態は fallback とする。

## 入出力

入力:

- selected `HexMapDocumentResource`
- selected `TileMapLayer` または `HexTileMapLayer`
- edit mode
- viewport / scene / local position
- hit dictionary
- before / after document snapshot
- target layer TileSet / atlas settings
- save / export path

出力:

- compact status text
- target readiness detail
- last edit trace
- save/export checkpoint trace
- last edit highlight
- `last_edit_status()` dictionary

## Escalation

計画中に以下が判明した場合、UX 文書へ Operation Steps の更新として戻す。

- plain `TileMapLayer` で多くの失敗が TileSet setup に集中する場合、Target 選択後の sample TileSet setup を Operation Steps に追加する。
- `HexTileMapLayer` が manual edit の主要 target として使われる場合、loop display readiness を target readiness の主要項目へ上げる。
- save/export の確認に Source Registry reload まで必要な場合、export checkpoint から Source Registry 用 analog step へ接続する。

## テスト方針

- `tests/test_editor_plugin.gd` で target readiness と edit trace dictionary を検証する。
- `tests/test_editor_plugin.gd` で viewport click 後の document changed、target applied、displayed tile state を検証する。
- `tests/test_editor_plugin.gd` または `tests/test_hex_tile_map_layer.gd` で last-only highlight を検証する。
- `tests/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md` に実 Editor 観察項目を追加する。

## 完了条件

- Dock detail trace だけで U1 の failure boundary を分類できる。
- plain `TileMapLayer` と `HexTileMapLayer` の target 要件が表示上区別される。
- Save / Export 後に保存された resource state が Dock 上で確認できる。
- last edit highlight が Dock trace の対象 cell と一致する。
