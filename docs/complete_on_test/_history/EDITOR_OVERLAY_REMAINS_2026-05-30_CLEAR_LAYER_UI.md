# EDITOR_OVERLAY_REMAINS Apply Write 統合済み項目

`docs/plan/EDITOR_OVERLAY_REMAINS.md` の 9. clear_layer=false の Editor UI は、独立した `Clear Layer` checkbox ではなく `Apply Write` に統合した状態を完了扱いとする。

## 入出力

入力:

- `Apply Write`
- Apply Layer
- Generate後のauto apply
- Target `TileMapLayer`
- current Primary / Overlay / Crop result data

出力:

- `Apply Write = Clear And Write` の置き換えapply
- `Apply Write = Add Item` の重ね書きapply

`Clear Layer` checkbox は削除済み。`Apply Write = Clear And Write` の場合は adapter へ `clear_layer=true` を渡し、`Apply Write = Add Item` の場合は adapter へ `clear_layer=false` を渡す。

## 実装状況

- [x] `Clear Layer` checkboxを削除する
- [x] `Apply Write` を Primary / Overlay 共通controlにする
- [x] Primary applyで `Apply Write` から `clear_layer` を決める
- [x] Overlay applyで `Apply Write` から `clear_layer` と `_current_overlay_data` 更新方式を決める
- [x] Crop result applyで `Apply Write` から `clear_layer` と `_current_overlay_data` 更新方式を決める
- [x] generation中は `Apply Write` を無効化する

## テスト

- `tests/test_editor_plugin.gd`
  - `Apply Write = Clear And Write` ではPrimary applyがtarget layerをclearする
  - `Apply Write = Add Item` ではPrimary applyがtarget layerをclearしない
  - `Apply Write = Clear And Write` ではOverlay applyがtarget layerをclearする
  - `Apply Write = Add Item` ではOverlay applyがtarget layerをclearしない
  - Crop result applyが `Apply Write` に従って `_current_overlay_data` を置換または合成する
  - 既存のTarget選択とTileMapLayer apply設定が維持される

確認コマンド:

```sh
./tools/test.sh
```
