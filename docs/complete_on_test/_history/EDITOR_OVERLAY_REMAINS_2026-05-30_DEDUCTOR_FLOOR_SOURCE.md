# EDITOR_OVERLAY_REMAINS Deductor Floor Source 実装済み項目

`docs/plan/EDITOR_OVERLAY_REMAINS.md` の 6. Deductor Floor Source を実装済みとして扱う。

## 入出力

入力:

- Deductor Floor Source Query Rows
- Placement Mask Query Rows
- Overlay Generator = Markov Mesh
- Adjacency Rules Off
- Overlay Deductor mode

出力:

- Overlay Generate candidate cells
- Deductor floor cells
- Deductor適用後の `HexOverlayData`
- Deductor Floor Source status

Deductor Floor Source未指定時は、生成後に配置item集合のShape universe内complementをDeductorのfloor集合として使う。Deductor Floor Sourceが指定されている場合は、そのquery resultを連結性回復用floor集合として使い、Placement Mask candidatesとは分離する。query resultが空の場合は警告し、空floor集合のままDeductorへ渡す。

## 実装状況

- [x] `Markov Mesh` OverlayかつAdjacency OffのときだけDeductor Floor Source controlを表示する
- [x] Source Registryの行ベースqueryでDeductor floor cellsを指定できる
- [x] 未指定時は生成後の配置item集合のcomplementをDeductor floor cellsとして使う
- [x] 指定時はPlacement Mask candidatesとDeductor floor cellsを分離してsnapshotに保持する
- [x] `_generate_overlay_data_from_snapshot()` がsnapshot内のShape universe / Deductor Floor Source有無だけを参照してDeductorへfloor cellsを渡す
- [x] 空Deductor floor queryを警告し、fallbackしない

## テスト

- `tests/test_editor_plugin.gd`
  - Markov Mesh OverlayでDeductor Floor Sourceが表示される
  - Adjacency OverlayではDeductor Floor Sourceが非表示になる
  - 未指定時に生成後の配置item集合のcomplementがDeductor floor cellsになる
  - 指定時にPlacement Mask candidatesとDeductor floor cellsが分離される
  - Deductor floor query編集ではMask CropがOffに戻らない
  - 生成時に独立floor sourceがDeductorへ反映される
  - 空Deductor floor queryが空のままsnapshot化され、status warningを表示する

確認コマンド:

```sh
./tools/test.sh
```

実行結果: 全テスト通過。
