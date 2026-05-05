# REMAINS_FROM_USER_REVIEW.md

ユーザーによるレビュー -> 要望集

## DOCUMENTATION

< -- >

## TEST

< -- >

## FEATURE

### 3. EDITOR PLUGIN

#### 3.1 MAP GENERATION DOCK

`addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- ユーザーが報告したテスト結果
  - テスト項目: パラメータ設定
    - { 生成方法: "Hex-inward Markov mesh model" (symmetric gen) , 形状: Hexagon } の場合に、Generation Radius = 1を指定した
    -  -> Godotがフリーズし、OS側から強制終了しなければならなかった。
    - 要望: エラーハンドリングの追加
    - 要望: Generation Radius = 1であっても、アルゴリズムの本質には影響しないはず。動いて欲しい。ただし、ほとんどのランダム生成はdistributionを参照する代わりにwall probを参照することになる。

  > "Generation Radius = 1 の対称生成を wall probability 直接生成にしてフリーズ要因を避けました: addons/hex_map_kit/core/hex_map_generator.gd:175。"

  Generation Radius = 2の場合でも、Godotが停止します。テストを回しながらエラー原因を調査・検討し、対応お願いします。対象生成のアルゴリズムに対する理解を深めて進めたいです。


- Open Questionな要望: Apply Layerボタン機能について、一歩引いて設計を検討をしたい。
  - 動作が遅い感じがする。Generate&apply layer などにしたい。
  - 生成されたマップがHorizontal Offset, Vertical Offsetどちらに適しているのか、生成時にわからない。
    - 共通でないなら、生成時に選択できる必要がある。

#### 3.2 DISTRIBUTION EDITOR

`addons/hex_map_kit/editor/hex_dist_editor.gd`

< -- >

#### 3.3 ADAPT TILE_MAP_LAYER


- API側概念とTileMapLayer側概念の対応関係を整理・反映
 - TileShape: Hexagon に固定したい
 - TileOffsetAxis:  [Horizontal Offset, Vertical Offset] -> [pointy-top, flat-top]
 - TileLayout: Stacked に固定したい

