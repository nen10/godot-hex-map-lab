## MULTI_LAYER.md

複数のレイヤー、複数の生成データを活用してマップ生成機能を強化する。
実装のための詳細な計画は日時名付きで別ドキュメントを作成し、本ドキュメントの編集は参照を追加する形にとどめる。

## 参照

- `docs/complete_on_test/MULTI_LAYER_2026-05-26_CORE_OVERLAY_UNIFORM.md`
  - Primary Item Key
  - Overlay Data
  - Uniform Distribution overlay item generation
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_MASK_REFERENCE_ADJACENCY.md`
  - Placement Mask / Reference item selector query
  - Adjacency Reference overlay item generation
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_SYMMETRIC_TORIC_ITEMS.md`
  - Markov Mesh overlay item generation without adjacency reference
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_OVERLAY_RESOURCE_ADAPTER_POLICY.md`
  - Overlay Resource / TileMapLayer adapter / Apply Policy
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_EDITOR_OVERLAY_BASIC.md`
  - Editor Dock basic Overlay generation / apply / save flow
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_EDITOR_OVERLAY_ITEM_POOL.md`
  - Editor Dock Uniform Overlay item pool weights / limits
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_EDITOR_MASK_ADJACENCY.md`
  - Editor Dock Placement Mask / Adjacency Reference UI
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_EDITOR_ITEM_TILE_MAPPING.md`
  - Editor Dock Overlay item key tile mapping
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_ADJACENCY_RULE_SET_EDITOR.md`
  - Adjacency Rule Set resource / editor
- `docs/complete_on_test/MULTI_LAYER_2026-05-26_OVERLAY_DEDUCTOR_CONNECTIVITY.md`
  - Overlay Deductor connectivity restore

## Editor Plugin / Adopter / Core 機能追加


- Generation Target
  - "Overlay" トグルボタン: Generateボタンを切り替える
    - Off - "Primary Generation"ボタン : Primary Data(床・壁データ)を作成する (既存機能)
      - Target Item : Wall 
    - ON  - "Overlay Generation"ボタン : Overlay Data(ユーザー定義の Itemデータ)を作成する (新規機能)
      - 既存の床・壁データ(Primary)や、他のデータ(Overlay)をフィルター条件にしてデータを作成する。生成アイテム名をユーザーが作成可能
      - "Generation Mode"が"Uniform Distribution"の場合、
        - Item Num Limit トグルボタン
          - OFF : [Add Item]が可能。複数の生成アイテム名を設定し、Placement Probabilityの範囲で一様分布で作成可能
            - Item Weights:アイテム間の生成比率として扱い、Placement Probabilityを項目全体の合計確率とする。
          - ON : 配置する個数上限を入力可能
            - Placement Probabilityを非表示にする。
            - アルゴリズム内で使用する確率は、残配置数/残走査cell数を使用する。
      - Target Item ("Markov Mesh")
        - Item Name(入力可能)
      - Item Pool ("Uniform Distribution", Item Num Limit: Off)
        - Item Name, Weight
        - ...
        - [Add Item]
      - Item Pool ("Uniform Distribution", Item Num Limit: On)
        - Item Name, Limit
      - アイテム名はWallなども可能、制限はつけない。


- Item Key:
  - Generationされた座標データの分類キー
  - Primary は Any, Floor, Wall を持つ。
  - Overlay はユーザー定義の Item Key を持つ。(新規機能)

### "Wall Generator / Overlay Generator":
  - Generation Mode - Algorithm(Primary) - Algorithm(Overlay, 新規API)
    - Markov Mesh - generate_symmetric_toric_walls - generate_symmetric_toric_items, generate_toric_adjacency_items 
    - Uniform Distribution - generate_random_walls - generate_random_items, generate_limited_items

### Overlay Generatorで使用するアルゴリズムについて
  - 生成の基本的なアルゴリズムはPrimaryと同様だが、機能拡張する。
  - ユーザー定義のアイテム名についてもadapterで対応する。
  - generate_symmetric_toric_items : Markov MeshかつEnable Adjacency Reference が Off の場合。generate_symmetric_toric_wallsのアルゴリズムについて、走査対象を生成対象cellに制限したバージョン。通路生成処理(deductor)も生成アイテムに対して適用・削除可能とし、その場合の "floor" cell集合は走査対象と独立に設定できる。
  - generate_toric_adjacency_items : Markov MeshかつEnable Adjacency Reference が On の場合。生成対象cellを単純に走査しながら各参照データでのNeighberを取得・確率決定・生成する。toric connectionをOnが推奨だが、hexagonなどNeighberが欠けるマップ形状でも一様に実行できるようにする。
  - generate_random_items : Uniform Distribution の場合。生成対象cellを単純に走査しながら一様分布に従って複数アイテムのうち1つを決定する。
  - generate_limited_items : Uniform Distribution かつ Item Num Limit がOnの場合。アイテムの確率は残配置可能数/残走査cell数を使用する。

### Overlay Generator向けのEditor Plugin項目について
  - Placement Mask
    - 生成候補のcellを決めるデータ
    - Mask Source: Primary Dataや Overlay Dataを選択する(複数可)
      - TileMapLayerが生成データを保持したり、データとして復元できるなら、そのLayerを選択しても構わない。
        - 必要なら、拡張コンポーネントを実装して、生成データを保持できるTileMapLayer拡張コンポーネントを参照してもよい。
    - Mask Items: Mask SourceたちのItem Keyから複数チェック(and, or等集合演算を選択可能)して生成候補のcell座標をまとめたデータ

  - Adjacency Reference
    - 生成確率を計算するときの参照を決めるデータ
    - Enable Adjacency Reference トグルボタン
      - On -> 連動して、Adjacency Prob Rule Setを有効化, Generation Modeを"Markov Mesh" にする
      - Generation Modeを"Uniform Distribution"に変更 -> 連動して、このトグルをOff
    - Reference Source:  Primary Dataや Overlay Dataを選択する(複数可)(Mask Sourceと同様の方式)
    - Reference Items: Reference SourceのItemDataから複数チェック(and, or等集合演算を選択可能)して参照cell座標をまとめたデータ
    - Neighbor Scope:
      - Adjacency Referenceでの生成用参照範囲データ。
      - Shape: Hex
      - Radius: 1

  - Probability Model: 確率設定 基本部分は共通だが、確率選択方式の機能拡張・アルゴリズム反映が必要
    - Placement Probability (Non-Ref.) (既存 Wall prob を共通に使用する。名称変更した。)
    - Markov Mesh Rule Set (既存 Wall Prob Rule Set 設定と共通,名称変更した。)
    - Adjacency Prob Rule Set (Enable Adjacency ReferenceがOnのとき、有効)
      - 周囲の壁数や床数など、指定したアイテムたちの隣接個数で確率を変える設定データ
        - データが生成済みの状況を前提とする。
        - Neighbor Scope(周囲 6 cell)のうち、Adjacency Referenceでまとめたデータ内のcell座標の(個数,連結成分数)に応じて、cellの生成アイテム確率を記述する(Markov Mesh Rule Set用編集Editorに類似した編集画面を追加する)

  - Apply Policy
    - [Clear And Write, Add Item]
    - [Merge Existing, Replace Existing, Skip Existing]
    - 生成後、TargetレイヤーにOverlayデータを適用する。
