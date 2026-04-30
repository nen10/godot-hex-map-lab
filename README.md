
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

1. Core: マップデータ生成機能
  1.1. Hex座標・距離・近傍列挙をGDScriptに移植
  1.2. ランダム壁生成をデータだけで実行
  1.3. 連結性判定・回復処理をデータだけで検証
  1.4. デバッグ表示
2. Adapter: TileMapLayer/TileSet対応
  Coreの結果をTileMapLayer、Node2D、Resourceに変換する層。
3. EditorPlugin化
  インスペクタ、ドック、ボタン、シーンノード生成。

## Structure

- addons/hex_map_kit/**
  - 配布用

- docs/**
  - document


## Unity source reference

`/Users/nenten/Desktop/cosmos/_archive/ecologic-survivor/ecologic-survivor/Assets/Script/HexTileSystem`

## Debug用画像Asset

随時生成します。
マップタイルの場合、flat-top/pointy-topを区別して管理します。
