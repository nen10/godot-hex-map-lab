# EDITOR_OVERLAY_REMAINS Query Row Offset Control 現行実装

`docs/plan/EDITOR_OVERLAY_REMAINS.md` の 5. Query Row Offset Control は、後続のHex Cell Button Editor UI対応により `HexCellButtonPanel` ベースへ更新済みとして扱う。

## 入出力

入力:

- Query Row
- `Cell Radius`
- `Gap`
- `Padding`
- 六方向hex cell操作

出力:

- 2段構成のQuery Row
  - 上段: `AND|OR`、`Contain|Exclude`、`source / ItemKey`、offset、row操作
  - 下段: `HexCellButtonPanel` によるhex形状の六方向offset control
- 更新されたoffset
- Mask Query Row編集時のCrop Off連動

`Cell Radius` / `Gap` / `Padding` は Mask / Reference / Deductor Floor Source query controlで共有され、既存rowの `HexCellButtonPanel` にも反映される。

## 実装状況

- [x] Query Rowを2段構成にして、offset controlを `HexCellButtonPanel` へ移行する
- [x] 六方向cellを `HexMapTileAdapter.hex_to_local()` のflat-top / pointy-top配置に従って表示する
- [x] hex polygonと同じshapeでhit testする
- [x] `Cell Radius` / `Gap` / `Padding` でoffset controlの配置を変更できる
- [x] 既存のoffset更新、Mask Crop Off連動、Reference query編集時のCrop維持を維持する

## テスト

- `tests/test_editor_plugin.gd`
  - Query Rowが2段構成になること
  - Query Rowが `HexCellButtonPanel` を持つこと
  - offset controlがcenterと6方向entryを持ち、6方向だけpressableであること
  - `Cell Radius` / `Gap` / `Padding` 変更が既存rowのpanelへ反映されること
  - Mask / Reference / Deductor Floor Sourceの設定表示が同期すること
  - 既存のoffset、toric wrap、Crop Off連動が維持されること

確認コマンド:

```sh
./tools/test.sh
```

実行結果: 全テスト通過。
