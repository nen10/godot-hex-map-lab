
# TEST.md


## 管理

(コマンド実行のみで完了する)テスト作成時、`tools/test.sh` を合わせて更新する
interactiveなテスト作成時、実行方法を簡潔にdocumentationする

### Test path

- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`

### テスト方針

テスト期待値と結果が異なる場合、安易に期待値を修正せず、UnityとGodotでの座標の扱いに違いがあるかなどの移行時の問題に注意を払い、正確な理解のもとで正しいテストを作成する。移行元Unityコード上のバグに由来すると判断できる場合、必ず指摘する。
データ上でのテストはスクリプトコマンドのみで検証を進めるが、幾何学的な問題があればグラフィカルな結果表示を作成し、ユーザーにテスト依頼しても良い。
GodotでのDebug実行によるテストが有用なケースについては、ユーザーにテストを依頼する。
ユーザーに依頼するテストはテストケースごとに表示を切り替えるinteractive性のあるテスト画面を作成する。
エディター機能についてはGodot上での操作によってユーザーがテストする。
座標計算等の視覚的なテストケースで問題が発生した場合、可能な限りグラフィカルなテストケースを追加してGodot上でのデバッグ実行可能な画面を作成したのち、ユーザーのアドバイスを受けます。

### テスト概要

- `tests/test_hex_core.gd`: HexVector/HexPoint、toric coordinate、近傍・連結・経路、9分割と対称生成領域タグを検証する。`symmetry_generation_tags()` が radius 1..9 の全 canvas cell を網羅し、`source` は raw draw position、`vector` は wrap 済み canvas position、`moved` は wrap 有無を表すことを検証する。phase2 outer_mod の pair/triple は raw 生成タイミング上の distinct な局所グループとして検証し、phase2 でも outer-to-center wave を通ることを検証する。
- `tests/test_hex_map_generation.gd`: rectangle/hexagon/toric square の生成、Primary Data の `Any` / `Floor` / `Wall` item key、Overlay Data の user item key、Placement Mask / Reference 用 item selector query、Uniform Distribution overlay item generation、Adjacency Reference overlay item generation、Markov Mesh overlay item generation、Overlay Deductor による item 削除、壁生成、割り込み可能な progress / cancel 付き壁生成と item 生成、shape API の interrupt option、連結性回復、dense/sparse/none の `restore_connectivity_by()`、terminal 接続、対称生成を検証する。dense/sparse 連結性回復は direct restore と生成 API 経由の progress / cancel、`0.35 -> 1.0` の restore progress range、単純 bridge、toric shortcut、Y 字 fixture、1-wall remote bridge、対称 toric square の接続を検証する。連結性回復の方向 seed は同距離 bridge の選択が seed で変わることと、restore / dense / sparse / terminal の各方式に適用できることを検証する。Generation Radius 1 / 2 も larger radius と同じ対称生成フローを通り、radius 3 / 6 / 9 は `DrawAreaCenter -> DrawAreaFromCenter` 後の completion pass で canvas 内・split 分布・protected floor・連結性回復を満たすことを検証する。
- `tests/test_hex_adapter.gd`: HexMapData から TileMapLayer 用 entry、flat-top / pointy-top の offset cell 変換、表示用 local 座標、HexMapResource / HexOverlayResource への変換、Adjacency Rule Set の parse / key正規化 / invalid entry report、Overlay Data の apply policy、Overlay item key から TileMapLayer tile への adapter、TileSet の Hexagon/Stacked/OffsetAxis 設定、sample atlas asset と atlas source 作成を検証する。
- `tests/test_hex_tile_map_layer.gd`: `HexTileMapLayer` の `HexMapResource` 適用、resource orientation に基づく TileMapLayer 反映、セル照会、壁/床編集、local/hex 座標往復、経路・ハイライト・連結性 helper を検証する。
- `tests/test_editor_plugin.gd`: 生成ドックの対称 Hexagon / Generation Radius 1 / 2、symmetric Square の toric connection UI 連動と `cyclic_size`、Generate ボタン限定実行、Overlay mode の button / controls 表示、Primary floor cells を候補にした Uniform Overlay generation、Uniform Overlay Item Pool の Add Item / weight / limit / item tile mapping / Floor-Wall tile copy、Placement Mask、Deductor Floor Source、Adjacency Reference、Adjacency Rule Editor、Adjacency Rules validation status、Item Num Limit、Overlay Apply Policy、OverlayResource save target、Dock 内 progress UI の Generate 時表示と成功時の最短表示時間後の非表示、modal progress window を生成しないこと、Core callback 由来の progress / cancel wiring、cancel 時に partial data を current map へ反映しないこと、orientation とClear Layerを含む TileMapLayer apply 設定、orientation 変更時の Tile Size swap、Target の Auto / 短い layer 名 / `Add new layer...` 表示、Refresh 後の Auto 維持、Scene Tree 選択中 TileMapLayer だけへの設定即時 apply、共有 `TileSet` の選択中レイヤー側複製、atlas image selection、sample TileSet setup、Generate 後の自動 apply、Apply Layer button の手動再反映、Distribution Editor のプリセット値表示、`.tres` 読み込み、recent custom distribution、preset 複製保存、SpinBox 値に基づく色、window close の cancel flow、Source Registry のLoad / reload / Clear / item cell count表示 / empty status、Mapdata Query Row のAND/OR・Contain/Exclude・offset・toric wrap・3列方向control・direction button size変更、Mask Query Row のCrop Off時Shape universe制限、Crop resultとCrop Off連動、Crop Off source stackとstatus表示、Generate HistoryのPrimary保存・Overlay差分保存・`overlay-combination`命名・cancel時非保存を headless で検証する。
- `tests/test_debug_scenes.gd`: debug scene の生成形状切替、toric 表示 domain、対称生成 overlay が toric canvas 全体を網羅すること、phase2 grouping 表示用データを検証する。


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

この画面は `HexMapGenerator` の rectangle / hexagon / toric square 生成結果を `HexMapTileAdapter.hex_to_local()` で描画する手動確認用です。`Space` で seed 更新、`Tab` で形状切り替え、`R` で連結性回復の切り替え、`O` で flat-top/pointy-top、`P` で中心から代表 floor への経路表示、`S` で toric square の 9 分割 overlay、`Y` で対称生成の外周から中心へ進む領域 overlay、`D` で toric square の square/hex domain 表示、`U` で同一 toric cell を糊代として複数配置する展開表示、`N` で toric square の一辺サイズを切り替え、`G` で toric square の通常ランダム生成 / 対称生成を切り替えます。サイズは `7` / `8` / `9` / `11` / `13` / `19` を確認します。`7` / `13` / `19` は Generation Radius `3` / `6` / `9` に対応する `radius % 3 == 0` の目視確認に使います。

対称 toric square 版の機能:

- toric square の生成結果表示: `G` で `mode=symmetric` にして確認する
- 連結性回復と経路表示: `R` / `P` で通常 toric と同様に確認する
- 9 分割 overlay: odd N で `S` を有効にして確認する
- 対称生成領域 overlay: odd N で `Y` を有効にして、生成結果と外周から中心への領域を重ねて確認する
- square/hex domain 表示: `D` で通常 toric と同様に確認する
- 糊代つき展開表示: `U` で通常 toric と同様に確認する
