# Hex Cell Button Editor UI 実装済み項目

`docs/plan/HEX_CELL_BUTTON_EDITOR_UI_POLICY_2026-05-31.md` と `docs/plan/HEX_CELL_BUTTON_EDITOR_UI_IMPLEMENTATION_PLAN_2026-05-31.md` をテスト確認済みとして扱う。

## 入出力

入力:

- layout spec: `flat_top`, `cell_radius`, `cell_gap`, `padding`, `shape_kind`, `shape_cells`, `center_cell`
- cell state maps: `pressable_cells`, `disabled_cells`, `label_by_cell`, `tooltip_by_cell`, `metadata_by_cell`
- Query Row source / item / current offset
- Query Row共通cell表示設定
- Distribution Editor pattern neighbor count

出力:

- layout entry: `id`, `hex`, `center`, `polygon`, `bounds`, `pressable`, `disabled`, `label`, `tooltip`, `metadata`
- `HexCellButtonPanel.cell_pressed(entry)` / `cell_hovered(entry)` / `cell_focus_changed(entry)`
- Query Rowの更新済みoffset
- Query Rowのsource label / item key combo
- Distribution Editorの既存pattern配置と同等の描画entry

## 実装状況

- [x] `HexCellButtonLayout` を追加し、directions / custom / ring / disc shape cellを生成する
- [x] `cell_gap` を `HexMapTileAdapter.hex_to_local(cell, cell_radius + cell_gap, flat_top)` のpitch補正として扱う
- [x] layout entryにcenter / polygon / bounds / pressable / disabled / label / tooltip / metadataを持たせる
- [x] `Geometry2D.is_point_in_polygon()` でbounds内かつhex外のpointを拒否する
- [x] `HexCellButtonPanel` を追加し、mouse press / hover / keyboard focus / optional label描画をentry単位で扱う
- [x] Query Row offset controlを矩形Button gridから `HexCellButtonPanel` へ移行する
- [x] Query Rowのサイズ指定を共通 `Query Cell` row の `Cell Radius` / `Gap` / `Padding` に変更する
- [x] Query Rowのsource選択をsource labelとItemKey comboに分離する
- [x] Query Rowのoffset panelをoffset表示ラベル横へ移動し、center cell hoverで現在offset tooltipを表示する
- [x] Distribution Editorの固定pattern配置を共通layout entryへ移行する

## テスト

- `tests/test_editor_plugin.gd`
  - layout: flat-top / pointy-top pitch、padding minimum size、polygon hit、custom / ring / disc hook
  - panel: hex内press / hover、label state、disabled cell無効、keyboard focus / press
  - Query Row: `HexCellButtonPanel` entry構成、共通cell radius / gap / padding、source label / item combo、center tooltip、offset更新、既存toric wrap / Crop Off連動
  - Distribution Editor: 3-neighbor patternのcenter / reference配置が既存表示と同等、pattern controlがlayout-backed draw methodに接続される

確認コマンド:

```sh
./tools/test.sh
```

実行結果: 全テスト通過。
