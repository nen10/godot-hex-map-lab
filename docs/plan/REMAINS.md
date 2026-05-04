# REMAINS.md

依頼するまで実行不要です。

## DOCUMENTATION

- editor plugin機能に関するmanualのレビュー・修正
- アドオン公開用リポジトリ内に配置するための、不特定ユーザー向けドキュメントの整備

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

- Open Questionな要望: Applay Layerボタン機能について、一歩引いて設計を検討をしたい。

#### 3.2 DISTRIBUTION EDITOR

`addons/hex_map_kit/editor/hex_dist_editor.gd`

- ユーザーが報告したテスト結果
  - テスト項目: 画面起動時の視認
    -  -> 各SpinBoxの値が0.0のまま。
    - 推測: プリセット読み込みが機能していない。
    - 本質的な要望: 大局的に言って、HexRandomizerでハードコードしたdistoribution管理を再検討して、ユーザーカスタムのdistoribution含む一貫した管理方法を実装したい。
    - そのCorollaryとして解決したい要望: 読み込んだプリセットやリソースファイルの値をSpinBox内に表示して欲しい
  - テスト項目: SpinBoxの値更新
    -  -> Boxの値が変わっても、対応するセルの色が変化していない。
    - 要望: 該当するセルの色をSpinBoxの値に関連させる。(0.9-(x/10) : x in [0.0 .. 8.0])
  - テスト項目: ボタン操作
    - ウインドウの[x]ボタンが機能しない

#### 3.3 ADAPT TILE_MAP_LAYER


- API側概念とTileMapLayer側概念の対応関係を整理・反映
 - TileShape: Hexagon に固定したい
 - TileOffsetAxis:  [Horizontal Offset, Vertical Offset] -> [pointy-top, flat-top]
   - Offset値はユーザーが用意するリソースと関係しないことが多い。pointy-top なのか flat-top なのかがユーザーに提示されるべき。
 - TileLayout: Stacked に固定したい
    - 各設定値ごとに、生成時に想定していたタイルの並びを反映するためには、Display用に必要な座標変換が変わっているかもしれない。
    - 表示用データのフォーマットがわからない。保存時に座標変換を行っているのかわからない。マニュアルを強化する。
      - { TileLayout, TileOffsetAxis }:
        - { Stacked, Horizontal Offset (pointy-top) } : Radius 2のHexagonをHexagonとして正しく表示できる。他の形状も問題は見られない
        - else :　全くおかしな表示になる。
        - 要望 : { Stacked, Vertical Offset (flat-top) } のケースは正しく表示できるようにしたい。
          - 実装計画
          - マップから複数の座標(半径2のl1disc,19個の点)を抽出する
          - それらすべてに対して表示上の正しい近傍(半径1)を与えるOffset座標を取得する
          - HexPointに引き戻して中心との差によるHexVectorとして全てのズレを数値的・視覚的に確認する。
          - ユーザーと協力して、変換のための関数を求める
