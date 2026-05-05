# EditorPlugin 実装計画

## 目的

Hex Map Kit を Godot 4 EditorPlugin として利用できる状態にする。
EditorPlugin は map data resource、TileMapLayer 表示、distribution 編集、サンプル TileSet セットアップをエディタ上で接続する。


## 詳細実装計画

### 生成機能

- 入力: generator / shape / size / wall probability / seed / connectivity / distribution
- 出力: `_current_data: HexMapData`、stats label、`HexMapResource`
- 次の実装単位:
  - 生成処理の進捗状態を Dock に保持する
  - 大きいマップ生成中に progress UI を更新する
  - 実行中 generation を cancel できる状態を持つ

### タイルセット管理機能

- 入力: `TileMapLayer`、orientation、tile size、floor/wall source id、atlas coords、sample atlas image
- 出力: `TileSet`、`TileSetAtlasSource`、floor/wall tile 設定、TileMapLayer cell
- 実装単位:
  - atlas 画像に関連する`TileMapLayer`側での公式ドキュメントへのリンクをマニュアルに追加する。dock上の項目との関係性を明示する。
  - atlas 画像への参照の選択機能(sample適用ボタンの置き換え)

### マップのマニュアル編集機能

方針案であり、Godot の既存編集機能と連携できる範囲を優先する。

- マップ形状編集機能
- 壁の配置(座標情報)の編集機能 (マップのペイント機能 - 壁有無)
  - リソースとして保存(保存したいLayerをDock上で選択)
- 座標ごとの壁タイル画像編集機能 (ペイント機能 - タイル画像選択)
- 座標ごとの床タイル画像編集機能 (ペイント機能 - タイル画像選択)
- 座標ごとのオブジェクト編集機能
- ラベル付き座標の編集・保存機能
- ラベルとタイルチップ画像データベースの連携
- マップオブジェクトデータベース作成機能
- Undo/Redo 対応

## 完了条件

- テストの完了
- headless testできない場合: UI ワークフローのドキュメント作成, 機能検証用のユーザー向けテスト作成

-> `docs/complete_on_test/`に移動する
