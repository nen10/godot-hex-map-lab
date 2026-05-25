# Multi Layer Editor Overlay Item Pool 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Editor Dock の Uniform Overlay generation で複数 item key を扱う Item Pool を実装済みとして扱う。

## 入出力

入力:

- `Overlay` toggle On
- `Wall Generator / Overlay Generator = Uniform Distribution`
- Item Pool rows
  - `Item Name`
  - `Weight` または `Limit`
- `Add Item`
- `Item Num Limit`

出力:

- `generate_random_items` 用 item pool
  - `{ name, weight }`
- `generate_limited_items` 用 item pool
  - `{ name, limit }`
- `_current_overlay_data` の複数 item key

## 実装状況

- [x] Uniform Overlay mode で Item Pool rows を表示する
- [x] `Add Item` で item row を追加する
- [x] `Item Num Limit` Off では各 row の数値を `Weight` として扱う
- [x] `Item Num Limit` On では各 row の数値を `Limit` として扱う
- [x] Limit mode では `Placement Probability` を非表示にする
- [x] 空の item name は row index 由来の `ItemN` に補完する

## テスト

- `tests/test_editor_plugin.gd`
  - Weight `1.0` / `0.0` の複数 item pool で、0 weight item が生成されないこと
  - 複数 item limit が、それぞれの配置数として反映されること
  - `Add Item` policy が複数 item の既存 overlay data を保持して新しい item を追加すること

- item key ごとの tile mapping UI
