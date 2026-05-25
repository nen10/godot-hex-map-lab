# Multi Layer Editor Placement Mask / Adjacency 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Editor Dock の Overlay generation で Placement Mask と Adjacency Reference を指定する基本UIを実装済みとして扱う。

## 入出力

### Placement Mask

入力:

- Primary source toggle
- Primary item keys
  - comma separated `Any`, `Floor`, `Wall`
- Current Overlay source toggle
- Overlay item keys
  - comma separated user item key
- Mask set operation
  - `Any Item`
  - `All Items`

出力:

- `HexOverlayData.query_item_cells()` で求めた placement candidate cells
- selector が空の場合は current Primary floor cells を fallback candidates とする

### Adjacency Reference

入力:

- `Enable Adjacency Reference`
- Reference source toggles
  - Primary
  - Current Overlay
- Reference item keys
- Reference set operation
- Neighbor Radius
- Adjacency Rules
  - `default=0.2;1=0.8;2,1=0.4` 形式

出力:

- `generate_toric_adjacency_items` 用 reference cells
- probability rule dictionary
- neighbor radius

## 実装状況

- [x] Overlay mode で Placement Mask controls を表示する
- [x] Placement Mask が Primary item keys を候補cellへ変換する
- [x] Placement Mask が current Overlay item keys も候補sourceとして扱える
- [x] `Any Item` / `All Items` を `HexOverlayData.ITEM_QUERY_OR` / `ITEM_QUERY_AND` として扱う
- [x] `Enable Adjacency Reference` On で generation mode を `Markov Mesh` に切り替える
- [x] generation mode を `Uniform Distribution` に戻した場合、Adjacency Reference を Off にする
- [x] Adjacency Reference source/items から reference cells を作る
- [x] Adjacency Rules text を probability rules に変換する
- [x] Adjacency Reference On の Overlay generation が `generate_toric_adjacency_items` を使う

## テスト

- `tests/test_editor_plugin.gd`
  - Placement Mask の Primary `Wall` 指定が overlay candidates を wall cells に限定すること
  - Adjacency Reference On が Markov Mesh に切り替えること
  - Adjacency Reference controls を表示すること
  - Primary `Wall` reference と `1=1.0;default=0.0` rule により、参照cell近傍だけに item が生成されること
