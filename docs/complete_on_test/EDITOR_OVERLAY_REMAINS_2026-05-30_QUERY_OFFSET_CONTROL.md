# EDITOR_OVERLAY_REMAINS Query Row Offset Control 実装済み項目

`docs/plan/EDITOR_OVERLAY_REMAINS.md` の 5. Query Row Offset Control を実装済みとして扱う。

## 入出力

入力:

- Query Row
- `Direction Size`
- 六方向button操作

出力:

- 2段構成のQuery Row
  - 上段: `AND|OR`、`Contain|Exclude`、`source / ItemKey`、offset、row操作
  - 下段: 3列配置の六方向offset control
- 更新されたoffset
- Mask Query Row編集時のCrop Off連動

`Direction Size` は Mask / Reference query controlで共有され、既存rowの六方向button sizeにも反映される。

## 実装状況

- [x] Query Rowを2段構成にして、六方向buttonを横一列から3列配置へ変更する
- [x] 六方向buttonを `+S` / `-R`、`-Q` / `+Q`、`+R` / `-S` の空間配置にする
- [x] `Direction Size` で六方向button sizeを変更できる
- [x] 既存のoffset更新、Mask Crop Off連動、Reference query編集時のCrop維持を維持する

## テスト

- `tests/test_editor_plugin.gd`
  - Query Rowが2段構成になること
  - 六方向controlが3列配置で6buttonを持つこと
  - `Direction Size` 変更が既存rowのbutton sizeへ反映されること
  - Mask / Referenceの `Direction Size` 表示が同期すること
  - 既存のoffset、toric wrap、Crop Off連動が維持されること

確認コマンド:

```sh
./tools/test.sh
```

実行結果: 全テスト通過。
