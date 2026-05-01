
# TEST.md


## 管理

(コマンド実行のみで完了する)テスト作成時、`tools/test.sh` を合わせて更新する
intaractiveなテスト作成時、実行方法を簡潔にdocumentationする

### Test path

- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_debug_scenes.gd`

### テスト方針

テスト期待値と結果が異なる場合、安易に期待値を修正せず、UnityとGodotでの座標の扱いに違いがあるかなどの移行時の問題に注意を払い、正確な理解のもとで正しいテストを作成する。移行元Unityコード上のバグに由来すると判断できる場合、必ず指摘する。
データ上でのテストはスクリプトコマンドのみで検証を進めるが、幾何学的な問題があればグラフィカルな結果表示を作成し、ユーザーにテスト依頼しても良い。
GodotでのDebug実行によるテストが有用なケースについては、ユーザーにテストを依頼する。
ユーザーに依頼するテストはテストケースごとに表示を切り替えるintaractive性のあるテスト画面を作成する。
エディター機能についてはGodot上での操作によってユーザーがテストする。
座標計算等の視覚的なテストケースで問題が発生した場合、可能な限りグラフィカルなテストケースを追加してGodot上でのデバッグ実行可能な画面を作成したのち、ユーザーのアドバイスを受けます。


## 実行

```sh
./tools/test.sh
```

Godot の実行ファイルを明示する場合:

```sh
GODOT_BIN=/path/to/Godot ./tools/test.sh
```

Godot が出す終了コード 0の macOS 証明書関連の非致命的な ERROR は既知であり無視します。

## Debug 実行

flat-top/pointy-top の視覚的な近傍配置確認:

```sh
./tools/debug_hex_orientation.sh
```

この画面は `HexMapTileAdapter.hex_to_local()` の結果をそのまま表示する手動確認用です。`Both` / `Flat` / `Pointy` / `Parity` / `Custom` で表示ケースを切り替えます。`Parity` は Unity の `HexPoint.coord()` 相当の offset 変換を経由し、中心点の R 偶奇が違う場合の近傍配置を比較します。`Custom` は flat-top/pointy-top と中心座標 `q/s/r` を入力して近傍配置を確認します。

生成マップの視覚確認:

```sh
./tools/debug_generated_map.sh
```

この画面は `HexMapGenerator` の rectangle / hexagon / toric square 生成結果を `HexMapTileAdapter.hex_to_local()` で描画する手動確認用です。`Space` で seed 更新、`Tab` で形状切り替え、`R` で連結性回復の切り替え、`O` で flat-top/pointy-top、`P` で中心から代表 floor への経路表示、`S` で toric square の 9 分割 overlay を切り替えます。
