
# godot-hex-map-lab

- Unity C#で実装したHex座標系によるRandom Map生成機能をGodot4用にGDScriptとして移植する
  - `/Users/nenten/Desktop/cosmos/_archive/ecologic-survivor/ecologic-survivor/Assets/Script/HexTileSystem` を中心としたスクリプト群にによってUnity上での生成機能の実行確認済み
- マップ管理のためのアドオンとして利用できるようにする。
  - マップ表示ごとの選択要素
    - Hex Tileの論理サイズ
    - flat-top/pointy-top (元スクリプト実装はflat-topを想定)
    - マップの形状選択機能
      - toric (ループ表示)
      - non-toric (四角形/六角形)
  - 壁タイル配置箇所の生成ごとの選択要素
    - 壁のランダム生成時の生成用パラメータ
    - マップの連結性回復処理の有無
  - マップ上に配置する項目・タイルセットの管理機能を追加したい(未実装)
  - マップ生成機能アドオン化の際の利用形態
    - 実行時ランダム生成
    - シーンノード生成

## 開発マップ

### 完了項目

- Core: 四角形マップデータ生成機能
  1.1. Hex座標・距離・近傍列挙をGDScriptに移植
  1.2. ランダム壁生成をデータだけで実行
  1.3. 連結性判定・回復処理をデータだけで検証
  1.4. デバッグ表示

- Adapter: TileMapLayer/TileSet対応
  Coreの結果をTileMapLayer、Node2D、Resourceに変換する層。
  2.1. Adapter
  2.2. Godot実行による生成マップアルゴリズム実行結果の視覚的表示

- マップ生成・管理に関するさらなる機能追加
  - 経路アルゴリズムの視覚的表示
  - Toricマップ用のHex正方形マップの三角形9分割
  - Hex正方形マップの対称生成機能
    4.2. 外周から内側への壁生成アルゴリズム(対称生成機能)を移植(Core)
    4.3. 対称生成時の形状について(マップサイズに応じて必要があれば、タイリングが穴あきにならないよう外周の項目をduplicateして)Hex正方形マップの三角形9分割の各領域と対応つける。
    4.4. terminal 指向の連結性回復機能を移植

- 概念検証
  4.1 対称生成形状と正方形マップの関係に関する観察


### 実装中

- EditorPlugin化
  `docs/plan/EDITOR_PLUGIN.md` を参照

- マップ生成・管理に関するさらなる機能追加
  1. マップ実行用独自クラス拡張
    TileMapLayerは機能が汎用的でHex座標系に最適化されていない。
    hex-map-kit APIとの連携が強化された HexTileMapLayer クラスへと拡張し、座標データのレイアウト機能や実行時の汎用的な機能を強化したい。
  2. マップ上の地点選択機能
    5.1. マップ上での選択カーソル表示
    5.2. 選択地点間での経路アルゴリズムの視覚的表示
  3. マップのループ処理
    6.1. ∞マップ/Toricマップ実行時、カーソル追従によるループ表示機能
    6.2. 視覚的な経路長が最短(ジャンプしない)ように、ループ表示したマップ上で連結な経路表示(Toric Map:異なる座標でも同一になることがある,toricな近傍処理,連結な範囲内での始点・終点を選び直す)
    6.3. 視覚的な経路長が最短になるように、ループ表示したマップ上で連結な経路表示(∞ Map:異なる座標点は必ず区別する, non-toricな近傍処理)
  4. アセット管理・アセット生成・タイルノード等の動的生成に関する編集機能強化
 

## Structure

- addons/hex_map_kit/**
  - 配布用

- docs/**
  - document

## Docs

- `docs/TEST.md`: テスト実行方法
- `docs/algorithm/**`: 独自のデータ構造・数学的な詳細を伴うコードに関して、混乱を防ぐためのドキュメント群
  - `docs/algorithm/ALGORITHM_MAP_GENERATION.md`: map 生成アルゴリズム(移行済み部分のみ)
  - `docs/algorithm/ALGORITHM_ADAPTER.md`: Adapter 変換

## Test

```sh
./tools/test.sh
```

詳細は `docs/TEST.md` を参照


## Unity source reference

`/Users/nenten/Desktop/cosmos/_archive/ecologic-survivor/ecologic-survivor/Assets/Script/HexTileSystem`

## Debug用画像Asset

随時生成します。
マップタイルの場合、flat-top/pointy-topを区別して管理します。
