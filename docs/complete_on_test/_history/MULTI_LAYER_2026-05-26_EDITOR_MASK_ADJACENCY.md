# Multi Layer Editor Placement Mask / Adjacency 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Editor Dock の Overlay generation で Placement Mask と Adjacency Reference を指定する基本UIを実装済みとして扱う。

## 入出力

### Placement Mask

入力:

- Source Registry内の `HexMapResource` / `HexOverlayResource`
- Mask Query Rows
  - source / item key
  - `AND` / `OR`
  - `Contain` / `Exclude`
  - offset

出力:

- 現在のShape / サイズuniverse内で評価した placement candidate cells
- Query Row 0行の場合はShape universe全体
- Query Row が1行以上あり結果が空の場合はGenerate停止

### Adjacency Reference

入力:

- `Enable Adjacency Reference`
- Source Registry内の `HexMapResource` / `HexOverlayResource`
- Reference Query Rows
  - source / item key
  - `AND` / `OR`
  - `Contain` / `Exclude`
  - offset
- Neighbor Radius
- Adjacency Rules
  - `default=0.2;1=0.8;2,1=0.4` 形式

出力:

- `generate_toric_adjacency_items` 用 reference cells
- probability rule dictionary
- neighbor radius

## 実装状況

- [x] Overlay mode で Placement Mask controls を表示する
- [x] Placement Mask がSource RegistryのQuery Rowsを候補cellへ変換する
- [x] Query Row 0行をShape universe全通過として扱う
- [x] Query Row結果が空の場合はGenerateを停止する
- [x] `Enable Adjacency Reference` On で generation mode を `Markov Mesh` に切り替える
- [x] generation mode を `Uniform Distribution` に戻した場合、Adjacency Reference を Off にする
- [x] Adjacency Reference Query Rows から reference cells を作る
- [x] Adjacency Rules text を probability rules に変換する
- [x] Adjacency Reference On の Overlay generation が `generate_toric_adjacency_items` を使う

## テスト

- `tests/test_editor_plugin.gd`
  - Placement Mask のQuery Row指定が overlay candidates を該当 cells に限定すること
  - Query Row 0行がShape universe全体を候補にすること
  - Query Row結果が空の場合にGenerateしないこと
  - Adjacency Reference On が Markov Mesh に切り替えること
  - Adjacency Reference controls を表示すること
  - Primary `Wall` reference と `1=1.0;default=0.0` rule により、参照cell近傍だけに item が生成されること
