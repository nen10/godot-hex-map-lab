# EDITOR_OVERLAY_REMAINS clear_layer=false Editor UI 実装済み項目

`docs/plan/EDITOR_OVERLAY_REMAINS.md` の 9. clear_layer=false の Editor UI を実装済みとして扱う。

## 入出力

入力:

- `Clear Layer` checkbox
- Apply Layer
- Generate後のauto apply
- Target `TileMapLayer`
- current Primary / Overlay / Crop result data

出力:

- `clear_layer=true` の置き換えapply
- `clear_layer=false` の重ね書きapply

`Clear Layer` はデフォルトOnで従来挙動を維持する。Offの場合、adapterへ `clear_layer=false` を渡し、既存 `TileMapLayer` cellを残して生成結果のcellだけを上書きする。

## 実装状況

- [x] Tile Settingsに `Clear Layer` checkboxを追加する
- [x] Primary applyで `clear_layer` 設定を使う
- [x] Overlay applyで `clear_layer` 設定を使う
- [x] Crop result applyで `clear_layer` 設定を使う
- [x] generation中は `Clear Layer` を無効化する

## テスト

- `tests/test_editor_plugin.gd`
  - `Clear Layer` OnではPrimary applyがtarget layerをclearする
  - `Clear Layer` OffではPrimary applyがtarget layerをclearしない
  - `Clear Layer` OffではOverlay applyがtarget layerをclearしない
  - 既存のTarget選択とTileMapLayer apply設定が維持される

確認コマンド:

```sh
./tools/test.sh
```

実行結果: 全テスト通過。
