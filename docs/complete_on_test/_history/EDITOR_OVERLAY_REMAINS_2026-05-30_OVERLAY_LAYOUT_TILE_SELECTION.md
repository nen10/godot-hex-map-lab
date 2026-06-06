# EDITOR_OVERLAY_REMAINS Overlay Layout / Tile Selection 実装済み項目

`docs/plan/EDITOR_OVERLAY_REMAINS.md` の 8. Overlay Layout と Tile Selection を実装済みとして扱う。

## 入出力

入力:

- Overlay mode
- Item Pool row
- Dock上部のFloor tile設定
- Dock上部のWall tile設定

出力:

- `Overlay Items` section
- Item Pool rowの `Floor Tile` copy button
- Item Pool rowの `Wall Tile` copy button
- copy後の item tile source / atlas coords

Item Pool rowは従来通り個別の source / atlas coords を直接編集できる。`Floor Tile` / `Wall Tile` は、現在のDock tile設定をrowへコピーして、数値入力だけに依存しない設定flowを提供する。

## 実装状況

- [x] Overlay Itemsをsectionとして分ける
- [x] Item Pool rowへ `Floor Tile` copy buttonを追加する
- [x] Item Pool rowへ `Wall Tile` copy buttonを追加する
- [x] copy後のtile mappingをOverlay applyで使う
- [x] generation中はcopy buttonを無効化する

## テスト

- `tests/test_editor_plugin.gd`
  - `Floor Tile` がFloor source / atlas coordsをItem Pool rowへコピーする
  - `Wall Tile` がWall source / atlas coordsをItem Pool rowへコピーする
  - copy buttonがrowに表示される
  - copyしたtile mappingがOverlay applyに使われる
  - 未定義itemは既存のWall fallback policyを使う

確認コマンド:

```sh
./tools/test.sh
```

実行結果: 全テスト通過。
