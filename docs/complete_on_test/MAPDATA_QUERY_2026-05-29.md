# MAPDATA_QUERY 実装済み項目

`docs/plan/MAPDATA_QUERY.md` の保存済みMapdata source、行ベースquery、Crop、Crop Off source stack、Generate Historyを実装済みとして扱う。

## 入出力

### Source Registry

入力:

- `HexMapResource`
  - `HexMapData` として復元する。
  - query item key は `Any` / `Floor` / `Wall`。
- `HexOverlayResource`
  - `HexOverlayData` として復元する。
  - query item key は保存済み user item key。
- resource path

出力:

- Dock session内の source entry
  - `display_name`
  - `resource_path`
  - `resource_type`
  - `data`
  - `item_keys`

同じ `resource_path` を読み込む場合は既存sourceをreloadする。Clearしたsourceを参照するMask / Reference query rowは同時に削除する。

### Query Row

入力:

- source / item key
- `AND` / `OR`
- `Contain` / `Exclude`
- offset

出力:

- query result cells

queryは行順に左から評価する。`Exclude` はquery universe内での補集合として扱う。sourceがtoric squareの場合、offset後の座標はsourceの `cyclic_size` でwrapする。

### Mask Crop

入力:

- Mask Query Row
- `Crop` checkbox
- 現在のShape / サイズ

出力:

- Overlay Generate candidate cells
- Crop result `HexOverlayData`
  - `Any`: crop universe全体
  - `source display_name / ItemKey`: `Contain`由来item

Crop On中にMask Query RowまたはShape / サイズを編集した場合、Crop Offへ戻す。Reference queryや生成item設定の編集ではCrop Offへ戻さない。

### Crop Off Source Stack

入力:

- Source Registry内の全 `HexOverlayResource` / `HexOverlayData` source
- `Apply Write`
- `Existing Item`

出力:

- stack result `HexOverlayData`
- 更新された `_current_overlay_data`
- Target `TileMapLayer` へのApply
- `HexOverlayResource` としてのSave対象

Source Registryの表示順にOverlay sourceを合成する。先頭sourceで初期化し、2件目以降は `APPLY_ADD_ITEM` と選択中のExisting policyで重ねる。`HexMapResource` sourceは合成対象外。

### Generate History

入力:

- `Generate History` checkbox
- 保存ディレクトリ
- Generate成功結果

出力:

- `.tres`
  - Primary: `HexMapResource`
  - Overlay: Apply Policy反映前の差分 `HexOverlayResource`
- 保存成功したsource registry entry

生成キャンセル時、生成失敗時、保存失敗時はsourceを追加しない。

## 実装状況

- [x] `HexMapResource` / `HexOverlayResource` をSource Registryへ読み込む
- [x] 同じpathの読み込みをreloadとして扱う
- [x] Source Clear時に参照query rowを削除する
- [x] Query Rowの `AND` / `OR`、`Contain` / `Exclude`、offset、toric wrapを扱う
- [x] Crop On時のcandidate cellsとCrop result dataを作る
- [x] Mask Query Row編集、Shape / サイズ変更でCrop Offへ戻す
- [x] Crop On / OverlayのApplyをShow Mask用途にする
- [x] Crop On / OverlayのSave対象をCrop resultにする
- [x] Crop Off / OverlayでSource RegistryのOverlay sourceをstackする
- [x] Crop Off stack resultをApply / Saveへ使う
- [x] Generate History成功時に`.tres`保存とsource追加を行う
- [x] Overlay Generate HistoryはApply Policy反映前の差分だけを保存する

## テスト

- `tests/test_editor_plugin.gd`
  - Source RegistryのLoad / reload / Clear
  - Query Row評価、offset、toric wrap
  - Crop result、Crop count、Crop Off連動
  - Crop Off source stackとApply Write / Existing Item policy
  - Generate HistoryによるPrimary source保存、Overlay差分source保存、cancel時非保存

確認コマンド:

```sh
./tools/test.sh
```

実行結果: 全テスト通過。
