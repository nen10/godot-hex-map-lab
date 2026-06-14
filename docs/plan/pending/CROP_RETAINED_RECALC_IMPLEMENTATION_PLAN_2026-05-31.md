# CROP_RETAINED_RECALC_IMPLEMENTATION_PLAN_2026-05-31.md

## 参照方針

- 方針: `docs/plan/CROP_RETAINED_RECALC_POLICY_2026-05-31.md`
- 採用案: 導入段階では `Crop Auto Refresh` checkboxを追加する。

## 対象ファイル

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## 入出力インターフェース

入力:

- Mask Query Rows
- Shape / Size controls
- Source Registry entries
- `Crop` checkbox
- `Crop Auto Refresh` checkbox
- `Apply Write`

出力:

- crop universe: `Array[HexVector]`
- crop result: `HexOverlayData`
- crop count label
- crop status label
- Apply / Save対象の `HexOverlayResource`

## UI計画

### 追加control

Mask Crop rowに `Auto Refresh` checkboxを追加する。

```gdscript
var _overlay_mask_crop_auto_refresh_check: CheckButton
var _overlay_mask_crop_status_label: Label
```

表示例:

- `Crop`
- `Auto Refresh`
- `Cells: N`
- `Crop updated.`

### 初期値

導入段階では `Auto Refresh = false` とする。破壊的変更として標準動作へ寄せる場合は `true` を初期値にし、reset経路を削除する。

## Data flow

### 新規helper

```gdscript
func _crop_auto_refresh_enabled() -> bool
func _refresh_crop_preview_after_edit(reason: String) -> void
func _set_crop_status(text: String) -> void
```

`_refresh_crop_preview_after_edit()` は以下を行う。

1. Crop Offなら何もしない。
2. Auto Refresh Offなら従来通りCrop Offへ戻す。
3. Auto Refresh OnならCrop Onを維持する。
4. `_overlay_crop_result_data()` を再評価する。
5. count labelとstatus labelを更新する。
6. 空結果やsource不正時はstatusに理由を出す。

### 置換対象

以下の呼び出しで `_reset_mask_crop_if_enabled()` を直接呼ばず、`_refresh_crop_preview_after_edit(reason)` を使う。

- Mask Query Row編集
- Mask Query Row offset変更
- Mask Query Row追加 / 削除 / 並べ替え
- Source Registry reload / clearによるMask Query Row変更
- Shape / Size変更

Reference Query RowとDeductor Floor Sourceは従来通りCrop reset対象にしない。ただし、Source Registry clearで参照sourceが削除され、Mask Query Rowも消える場合はCrop previewを再評価する。

## Resource schema

保存resourceのschema変更はない。

Crop resultは従来通り一時的な `HexOverlayData` として作成する。

- `cells`: crop universe
- `Any`: crop universe
- `Contain`由来item: `source display_name / ItemKey`
- `Exclude`由来item: 保存しない

追加する状態はEditor Dock session内のUI stateであり、`.tres` には保存しない。

## Apply / Save計画

- Crop Onの場合、Apply / Saveは常に `_overlay_crop_result_data()` の最新結果を使う。
- Auto Refresh Onでも、Apply / Save直前に再評価して古いcacheを使わない。
- 再評価結果が空の場合、statusに理由を表示する。
- Crop resultの`Any` itemは描画対象から除外する既存仕様を維持する。

## テスト計画

### 既存テスト更新

`_test_generation_dock_mapdata_crop_result_and_reset_rules()` を分割する。

- reset mode test
  - Auto Refresh OffでMask Query Row編集時にCrop Offへ戻る。
  - Reference Query Row編集ではCrop Offに戻らない。
- retained mode test
  - Auto Refresh OnでMask Query Row編集後もCrop Onを維持する。
  - 編集後のCrop countが新しいquery resultに一致する。

### 追加テスト候補

- `_test_generation_dock_crop_auto_refresh_shape_change()`
  - Crop On + Auto Refresh Onでhex radiusまたはrectangle sizeを変更する。
  - `Any` universe countとContain item countが更新される。
- `_test_generation_dock_crop_auto_refresh_apply_uses_latest_data()`
  - Crop On + Auto Refresh Onでqueryを変更し、Apply Layerを押す。
  - TileMapLayerに反映されたcellが最新query結果と一致する。
- `_test_generation_dock_crop_auto_refresh_empty_result_blocks_apply_save()`
  - 空結果になるqueryを作る。
  - statusに空結果が表示され、Apply / Saveが古いCrop resultを使わない。

## 実装手順

1. Mask Crop rowに `Auto Refresh` とstatus labelを追加する。
2. `_crop_auto_refresh_enabled()` を追加する。
3. `_reset_mask_crop_if_enabled()` 呼び出しを `_refresh_crop_preview_after_edit(reason)` に置き換える。
4. Apply / Save直前のCrop result再評価を明示する。
5. reset modeとretained modeのテストを追加する。
6. `docs/TEST.md` は実行手順が変わる場合だけ更新し、それ以外は `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` を更新する。
7. `./tools/test.sh` を実行する。

## 完了判定

- Crop保持再計算modeのOn/Offがテストで区別される。
- Auto Refresh OnでCrop result表示、Apply、Saveが同じ最新データを使う。
- Source Registry変更によるMask Query Row削除でも不整合な古いCrop resultを使わない。
