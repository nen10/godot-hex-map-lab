# EditorPlugin 実装計画

## 目的

Hex Map Kit を Godot 4 EditorPlugin として利用できる状態にする。
EditorPlugin は map data resource、TileMapLayer 表示、distribution 編集、atlas TileSet セットアップをエディタ上で接続する。

実装済み仕様とテスト根拠は `docs/complete_on_test/EDITOR_PLUGIN.md` に移動する。

## 計画

### 生成機能

入力:

- generator: `Simple` / `Hex-inward Markov mesh model`
- shape: `Hexagon` / `Rectangle` / `Square` / `Torus`
- size: `Radius` / `Width` / `Height` / `Generation Radius`
- wall probability
- seed
- connectivity
- distribution preset id / custom `HexDistribution`

出力:

- `_current_data: HexMapData`
- stats label
- `HexMapResource`
- progress UI
- `generation_status()`


仕様分割:

- 大きいマップ生成中にフレームごと progress UI を描画更新する処理と、生成器の途中割り込みは同期 API `HexMapGenerator.generate_*() -> HexMapData` と矛盾する。
- -> generator を async / chunked 実行に分け、`progress(current, total)` と `cancel_requested` を各 chunk 境界...外周部分及びinner 1週ごとで処理する別仕様にする。

async / chunked 実行のテスト計画:

- 入力: generator request、chunk size、cancel request
- 出力: partial progress、completed `HexMapData`、cancelled status
- headless test: chunk ごとの progress 単調増加、cancel request 後に未完了 status で停止、cancel 後に `_current_data` を破壊しないこと
- editor workflow test: 大きい map で Dock の progress が描画更新され、Cancel がクリック可能であること


## 完了条件

- `docs/complete_on_test/EDITOR_PLUGIN.md` の実装済み項目が `tools/test.sh` で通る
- headless test できない editor lifecycle は UI workflow と検証観点を manual / plan に記録する
