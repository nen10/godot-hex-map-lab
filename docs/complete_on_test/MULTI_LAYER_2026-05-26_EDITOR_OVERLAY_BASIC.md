# Multi Layer Editor Overlay Basic 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Editor Dock から Overlay Data を生成し、Target `TileMapLayer` へ適用し、`HexOverlayResource` として保存対象にできる基本フローを実装済みとして扱う。

## 入出力

### Editor Dock Overlay Mode

入力:

- `Overlay` toggle
- `Wall Generator / Overlay Generator`
  - `Uniform Distribution`
  - `Markov Mesh`
- `Target Item`
- `Item Num Limit`
- `Apply Write`
  - `Clear And Write`
  - `Add Item`
- `Existing Item`
  - `Merge Existing`
  - `Replace Existing`
  - `Skip Existing`
- 現在の Primary Data

出力:

- `_current_overlay_data: HexOverlayData`
- `current_resource(): HexOverlayResource`
- Target `TileMapLayer` への overlay tile apply

## 実装状況

- [x] `Overlay` toggle が Generate button の表示を `Primary Generation` / `Overlay Generation` に切り替える
- [x] Overlay mode で `Target Item` を入力できる
- [x] `Uniform Distribution` の Overlay generation が現在の Primary floor cells を placement candidates として使う
- [x] `Item Num Limit` On の場合、`generate_limited_items` を使い、`Placement Probability` を非表示にする
- [x] `Item Num Limit` Off の場合、`generate_random_items` を使い、`Placement Probability` を使う
- [x] `Markov Mesh` の Overlay generation が `generate_symmetric_toric_items` を使う
- [x] `Apply Write = Add Item` が既存 `_current_overlay_data` に新しい overlay result を merge する
- [x] `current_resource()` が Overlay mode の current overlay を `HexOverlayResource` として返す
- [x] Generate 後の自動 apply / `Apply Layer` が Overlay mode では current overlay を Target `TileMapLayer` に適用する
- [x] Overlay tile apply は `Wall` tile source / atlas coords を item tile として使う

## テスト

- `tests/test_editor_plugin.gd`
  - Overlay toggle による Generate button と Overlay controls の表示
  - Uniform Distribution Overlay が Primary floor cells だけを候補にすること
  - Overlay generation 後も Primary Data を保持すること
  - Target `TileMapLayer` へ Overlay tile が自動 apply されること
  - Overlay mode の `current_resource()` が `HexOverlayResource` を返すこと
  - `Item Num Limit` が配置数を制限し、`Placement Probability` を非表示にすること
  - `Apply Write = Add Item` が既存 item data を保持して追加 item data を merge すること
