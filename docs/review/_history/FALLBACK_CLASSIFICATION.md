# FALLBACK_CLASSIFICATION.md

## 目的

fallback による実装の先走りを停止し、入力条件の段階で実行不能にするための分類を行う。

各 fallback を以下の3カテゴリに分類する:

- **RETAIN**: 仕様として意図された挙動。残す。
- **BLOCK**: fallback に頼った非想定の実行をしている。入力段階で拒否し、実行を停止する。
- **SPECIFY**: 仕様上未定義だが fallback に頼らず実行を止める必要がある。ブロック方法（警告/エラー/UI無効化）を要決定。

分類の基準:

1. `docs/plan/` 以下の3文書 (`MULTI_LAYER.md`, `MAPDATA_QUERY.md`, `EDITOR_OVERLAY_REMAINS.md`) に明示された挙動か
2. 明示されていない場合、データ不在時に暗黙の代替値を生成しているか
3. 代替値がユーザーの意図しない生成結果を引き起こしうるか

## 分類対象

各 fallback は `addons/hex_map_kit/editor/hex_map_gen_dock.gd` の行番号とともに記す。

---

## BLOCK カテゴリ: 入力段階で拒否し実行を停止すべき fallback

これらはデータ不在時に暗黙の代替値を生成し、ユーザーが意図しない生成結果を得る原因となる。
`MAPDATA_QUERY.md` の「空Maskはfallbackしない」方針を全般的に適用する。

### BLOCK-1: empty Placement Mask → floor cells への fallback

- **場所**: `hex_map_gen_dock.gd` `_overlay_mask_cells_for_snapshot()` (fallback 呼び出し元) → `_overlay_candidate_cells_for_snapshot()` (fallback 実体)
- **トリガー**: Query Row が未設定、かつ legacy Mask Items (Primary/Overlay check + text) の結果が空
- **fallback 内容**: `_current_data.floor_cells()` → shape-based cells と連鎖的に代替
- **問題**: ユーザーが Placement Mask を意図的に設定していない場合、全 floor cell が候補になり、予期せぬ全面生成が起きる
- **計画上の根拠**: `MAPDATA_QUERY.md`: "Mask query result が空の場合、fallback candidates へ置き換えない。警告を出し、空 candidate のまま生成する。"
- **ブロック方法**: query result が空なら空 candidate のまま Generate を実行せず、Dock 上の status で「Placement Mask が空です」と表示し Generate ボタンを無効化する

#### ユーザー要望

- まず、legacy Mask Items (Primary/Overlay check + text) はコードから排除してほしい。
- 選択中のShape・Sizeを基準とした領域にQuery Rowマスクをandして得る生成候補領域にOverlay生成を行う。
  - これは述語論理のAnyに相当する扱いを再現する。つまり、
    - Query Rowが0行の場合のDefault動作として、全 floor cell を候補にする。これは述語論理に従った自明な動作であり、fallbackパターンではない。
    - Query Rowが1行以上存在していてMask query result が空になるなら、生成候補領域は空(候補cell:0)となり、Generateは実行されない。 


### BLOCK-2: empty Item Pool → default item への fallback

- **場所**: `hex_map_gen_dock.gd` `_overlay_item_pool()`
- **トリガー**: `_overlay_item_pool_rows` が空、または全行の名前が空で `result.is_empty()`
- **fallback 内容**: `_overlay_item_name()` (default: `"OverlayItem"`) を weight 1.0 / limit で1件の pool として返す
- **問題**: ユーザーが Item Pool を設定していない Uniform Distribution モードで、`"OverlayItem"` という名前の item が暗黙生成される
- **計画上の根拠**: `MULTI_LAYER.md` は Item Pool をユーザー設定項目として定義している。空の場合はユーザーの設定ミスであり、自動補完の根拠がない
- **ブロック方法**: pool が空なら Generate を実行せず、status に「Item Pool にアイテムがありません」と表示

#### ユーザー要望

BLOCK ではなく RETAIN 扱いとする。ただし次の名称変更を行う。item poolは `"OverlayItem"` ではなく `"Item1"` の初期値を持つ。ほかの変更は不要。

### BLOCK-3: `_overlay_candidate_cells_for_snapshot()` の shape-based fallback

- **場所**: `hex_map_gen_dock.gd` `_overlay_candidate_cells_for_snapshot()`
- **トリガー**: `_current_data` が null または `floor_cells()` が空
- **fallback 内容**: snapshot の shape 情報から hexagon/rectangle/torus の全 cell を生成して候補にする
- **問題**: `_current_data` が存在しない（=Primary 生成未実行）状態で Overlay 生成ができてしまう。生成結果は正規の Primary Data と紐づかない
- **計画上の根拠**: 計画は Primary Data の上に Overlay を生成する前提。Primary Data 不在での Overlay 生成は想定されていない
- **ブロック方法**: `_current_data == null` の場合、Overlay toggle を disabled にするか、Generate 実行時に「Primary マップデータがありません。先に Primary Generation を実行してください」と拒否

#### ユーザー要望

BLOCK-1 での要望と同様に、次の方針に従う。
- Primary Dataはマスクの一種であり、Overlay modeでは `_current_data` は読み込まれたデータと並列に扱われる。並列に扱えない状態になっているなら、legacy Mask Items 諸共`_current_data`は削除する。
- 選択中のShape・Sizeを基準とした領域にQuery Rowマスクをandして得る生成候補領域にOverlay生成を行うため、`_current_data`は実行に不要である。もし必要な書き方になっているなら、修正計画が必要である。
- "snapshot の shape 情報から hexagon/rectangle/torus の全 cell を生成して候補にする" はfallbackではなく正の動作であり、`_current_data`基準の実行方式を削除する。


### BLOCK-4: empty Item Name → `"ItemN"` への fallback

- **場所**: `hex_map_gen_dock.gd` `_overlay_item_pool_row_name()`
- **トリガー**: Item Pool row の name 入力が空
- **fallback 内容**: `"Item1"`, `"Item2"` など row index 由来の名前を自動生成
- **問題**: ユーザーが意図せず空名の row を残した場合、`"Item1"` という名前で生成され、後で `HexOverlayData` を見たときに意味不明な item key が混入する
- **計画上の根拠**: 計画は Item Name をユーザー入力項目として定義。空文字は明示的な入力不足
- **ブロック方法**: 空名の row が存在する場合、その row を赤くハイライトし、Generate ボタンを無効化する。または空名 row を無効行として扱い、pool から除外する

#### ユーザー要望

これはfallbackではなく親切の範囲であり REMAIN とする。


### BLOCK-5: `_overlay_item_name()` の default `"OverlayItem"` への fallback

- **場所**: `hex_map_gen_dock.gd` `_overlay_item_name()`
- **トリガー**: `_overlay_item_name_edit` が null または空文字
- **fallback 内容**: 定数 `OVERLAY_DEFAULT_ITEM_NAME` (`"OverlayItem"`) を返す
- **問題**: Markov Mesh の Target Item 名が空のまま Generate され、`"OverlayItem"` という名前で生成される
- **ブロック方法**: 空文字の場合は Generate ボタンを無効化し、status に「Target Item 名を入力してください」と表示

#### ユーザー要望

これはfallbackではなく親切の範囲であり REMAIN とする。


### BLOCK-6: `_parse_item_key_list()` の empty → default_keys への fallback

- **場所**: `hex_map_gen_dock.gd` `_parse_item_key_list()`
- **トリガー**: 入力テキストのパース結果が空
- **fallback 内容**: 呼び出し元が指定した `default_keys`（例: `["Floor"]`, `["Wall"]`, `current_overlay_data.item_keys()`）を返す
- **問題**: この関数は legacy Mask Items のテキスト入力（Primary/Overlay check + text field）で使われる。テキストフィールドが空のとき、暗黙的に `"Floor"` や `"Wall"` が使われる。ユーザーが意図せず空欄にした場合に予期せぬ item key でフィルタされる
- **計画上の根拠**: `MULTI_LAYER.md` は Mask Items をユーザーが選択するものと定義している。空欄は「選択なし」を意味する
- **ブロック方法**: 空結果の場合は selector を生成しない（空配列を返す）。呼び出し元の `_overlay_query_cells()` が空 selectors に対して空配列を返すため、結果として Mask が空になる。これは BLOCK-1 のブロックと連動して動作する

#### ユーザー要望

BLOCK-1 において legacy Mask Items (Primary/Overlay check + text)を削除するため検討不要。

---

## RETAIN カテゴリ: 仕様として意図された挙動。残す

これらは計画文書で明示された設計、またはアルゴリズムの本質的な一部である。

### RETAIN-1: 未定義 item の Wall tile fallback

- **場所**: `_overlay_item_tile_configs()`, `_apply_crop_result_to_tile_map_layer()`
- **内容**: Item Pool に tile mapping が設定されていない item key は Dock の Wall tile source/atlas で描画する
- **根拠**: `MAPDATA_QUERY.md`: "Item Pool mapping を優先し、未定義 item は Wall tile fallback を使う"
- **判定**: 仕様通り。残す

### RETAIN-2: Adjacency Rule の cascading key fallback

- **場所**: `hex_map_generator.gd` `_adjacency_rule_probability()`
- **内容**: `Vector2i(n,c)` → `"n,c"` → `n(int)` → `"n"(str)` → `"default"` → `0.0` の優先順位で確率を引く
- **根拠**: `MULTI_LAYER.md` の Adjacency Prob Rule Set 設計、`complete_on_test` での明示的ドキュメント化
- **判定**: アルゴリズムの本質的設計。残す

#### ユーザー要望

入力インターフェイスは修正を検討しているが、着手不要。

### RETAIN-3: Adjacency Rules の parse 失敗時の fallback probability

- **場所**: `hex_adjacency_rule_set.gd` `parse_rules_text_report()`
- **内容**: 全 entry が invalid の場合、指定された fallback_probability を `default` rule として使う
- **根拠**: `EDITOR_OVERLAY_REMAINS.md` §7: "有効ruleが1件もない場合はfallback probabilityを `default` ruleとして使う"
- **判定**: 仕様通り。ただし fallback probability の値の一貫性（Finding-02）は別途解決。残す

#### ユーザー要望

誤解された仕様である。
そのような動作がしたければ Uniform distribution を使用すればいいのであって、Adjacency Rulesにおいて実現する意味が存在しない。
このfallbackは実行してはいけない、機能削除する。defaultではない。


### RETAIN-4: Deductor Floor Source 未指定時の Placement Mask candidates 使用

- **場所**: `hex_map_gen_dock.gd` `_overlay_deductor_floor_cells_for_snapshot()` の `default_floor_cells` パラメータ
- **内容**: Deductor Floor Source query row が未設定の場合、Placement Mask candidates を Deductor の floor 集合として使う
- **根拠**: `complete_on_test/EDITOR_OVERLAY_REMAINS_2026-05-30_DEDUCTOR_FLOOR_SOURCE.md` で完了仕様として定義
- **判定**: 仕様通り。残す

#### ユーザー要望

実装記載を仕様だと誤解した判断にすぎない。
未設定なら生成された配置cell集合のcomplementをfloor集合として使うべきである。


### RETAIN-5: `apply_overlay()` の null guard

- **場所**: `hex_overlay_data.gd` `apply_overlay()`
- **内容**: overlay == null なら何もせず return
- **判定**: 防御的プログラミング。null は「処理不要」の明示的な意味を持つ。残す

### RETAIN-6: `_query_universe()` の Crop Off 時 source 全 union

- **場所**: `hex_map_gen_dock.gd` `_query_universe()`
- **内容**: Crop Off 時の universe = 全 query row の全 source の全 cell（offset + toric wrap 適用）
- **根拠**: 計画上の Crop Off universe 明示なしだが、source 由来の座標で評価するのは Query Row 設計の自然な帰結。`EDITOR_OVERLAY_REMAINS.md` §1 で Crop Off 時も universe を現在 Shape に制限するよう改訂されたが、これは別の修正対象（SPECIFY-1 参照）
- **判定**: 現在の挙動は残すが、§1 の改訂に従って修正するかは SPECIFY-1 で決定

#### ユーザー要望

実装記載を仕様だと誤解した判断にすぎない。
Crop ON/Off によらず universe = 選択中のShape・Sizeを基準とした領域 である。
各sourceがToricな場合の個別cyclic_sizeの適用も必須である。困難な項目は計画をdocumentationして後段の相談に回す。


### RETAIN-7: `_overlay_adjacency_rules()` の Wall Probability fallback

- **場所**: `hex_map_gen_dock.gd` `_overlay_adjacency_rules()`
- **内容**: Adjacency Rules text が空または全無効な場合、`_wall_prob_slider.value` を fallback probability として parse に渡す
- **根拠**: `complete_on_test` で明示。RETAIN-3 の Editor Dock 側の呼び出し
- **判定**: 仕様通り。残す

#### ユーザー要望

RETAIN-3 でも指摘したが誤解された仕様である。
そのような動作がしたければ Uniform distribution を使用すればいいのであって、Adjacency Rulesにおいて実現する意味が存在しない。
このfallbackは実行してはいけない、機能削除する。


### RETAIN-8: `_source_entry_by_id()` の空辞書返却

- **場所**: `hex_map_gen_dock.gd` `_source_entry_by_id()`
- **内容**: 該当 source がない場合 `{}` を返す
- **判定**: データ不在の自然な表現。呼び出し元は `entry.is_empty()` でチェックする。残す

### RETAIN-9: `_overlay_source_stack_data()` の空 sources 時の null 返却と警告

- **場所**: `hex_map_gen_dock.gd` `_overlay_source_stack_data()`
- **内容**: Overlay source が0件の場合、`push_warning` を出して null を返す。呼び出し元の `_apply_overlay_source_stack_to_current()` は false を返す
- **根拠**: `MAPDATA_QUERY.md`: "対象 Overlay source が0件の場合は警告し、Apply / Save / current 更新を行わない"
- **判定**: 仕様通り。残す

### RETAIN-10: Generate History のファイル名 suffix

- **場所**: `_unique_history_resource_path()`
- **内容**: 同名ファイルが存在する場合 `-2`, `-3` の suffix を付与
- **根拠**: `MAPDATA_QUERY.md`: "同名ファイルが存在する場合は suffix を付ける"
- **判定**: 仕様通り。残す

### RETAIN-11: Generate History のディレクトリ選択キャンセルで checkbox Off

- **場所**: `_on_generate_history_dir_cancelled()`
- **内容**: ディレクトリ未設定でキャンセル時、checkbox を Off に戻す
- **根拠**: `MAPDATA_QUERY.md`: "選択をキャンセルした場合、checkbox は Off に戻す"
- **判定**: 仕様通り。残す

### RETAIN-12: `to_tile_entries()` の item_order 空時 `data.item_keys()` 使用

- **場所**: `hex_overlay_tile_adapter.gd` `to_tile_entries()`
- **内容**: item_order が空の場合、data の全 item key を描画順として使う
- **判定**: 全 item 描画が自然なデフォルト。残す

---

## SPECIFY カテゴリ: 仕様上未定義だが、実行可否の判断が必要なもの

### SPECIFY-1: Crop Off 時の Query universe を現在 Shape に制限するか

- **場所**: `_evaluate_query_rows()`, `_query_universe()`
- **現状**: Crop Off 時、`Exclude` の universe は全 source cell の和集合（RETAIN-6）
- **計画**: `EDITOR_OVERLAY_REMAINS.md` §1: "Crop Off でも Exclude の補集合が現在Shape/サイズ外へ広がらない"
- **要決定**: §1 の改訂を実装するか。実装する場合、現在 Shape universe を Crop Off でも使うよう `_query_universe()` を修正する
- **暫定**: 改訂を実装するなら universe 制限は仕様通り。実装しないなら現状維持（RETAIN-6）として扱う

#### ユーザー要望

BLOCK, RETAIN-3, RETAIN-6 でも指摘したが、universe はShape/サイズで決定し、sourceを参照しない。
特にsource(正確には平行移動付きItemそれぞれ)ごとの個別cyclic_sizeについてuniverseに統合した座標計算を計画すれば、この判断は自明である。


### SPECIFY-2: Deductor Floor Source の空結果時の挙動

- **場所**: Deductor Floor Source query の結果が空（query row が設定されているが結果 cell が0件）
- **現状**: 警告を出し空 floor 集合を Deductor に渡す
- **要決定**: 空 floor 集合で Deductor を呼ぶと `deduct_items_for_connectivity` 内で `CONNECT_NONE` と同じく何も削除されない。この挙動を「仕様」とするか、「Deductor skip」として扱うか
- **暫定**: 空結果 = Deductor 実行不要。警告を出しつつ Deductor を skip する

#### ユーザー要望

実行後 Deducted cell数を表示するようにすれば十分である。


### SPECIFY-3: Deductor Floor Source universe の境界

- **場所**: Deductor Floor Source query の評価
- **現状**: Reference query と同様、source 由来座標を universe として使う
- **問題**: 現在 Shape 外の source cell が Deductor floor 集合に入りうる。candidate cells は Mask で制限されるため生成対象は広がらないが、Deductor の判断材料として Shape 外 cell を含めることの是非
- **要決定**: Shape 内に制限するか、source 由来座標のままとするか
- **暫定**: Mask query と同様に現在 Shape に制限する（§1 の方針と一貫させる）

#### ユーザー要望

BLOCK, RETAIN-3, RETAIN-6, SPECIFY-1 でも指摘したが、universe はShape/サイズで決定し、sourceを参照しない。
特にsource(正確には平行移動付きItemそれぞれ)ごとの個別cyclic_sizeについてuniverseに統合した座標計算を計画すれば、この判断は自明である。
Shape 外 cellはToricの場合に回収されることで十分である。


### SPECIFY-4: UI 初期化 race condition の null guard

- **場所**: `_overlay_query_operation()`, `_query_row_operation()`, `_query_row_match()`, `_apply_write_policy()`, `_overlay_existing_policy()`, `_overlay_neighbor_radius()`, `_overlay_cyclic_size_for_snapshot()` 他多数
- **現状**: 各 UI コントロールが null の場合、既定値（OR, Contain, CLEAR_AND_WRITE, MERGE, 1, 0 など）を返す
- **問題**: これらは `_ready()` 以前の呼び出しを防ぐ防御コード。`_ready()` 完了後は null にならない
- **要決定**: 防御コードとして残すか、`_ready()` 完了を前提として assert に置き換えるか
- **暫定**: 防御コードとして残す（安全性のため）。ただし、`_ready()` 後の呼び出しで null になることがないよう、必要に応じて assert を追加

#### ユーザー要望

機能的な価値が評価できないため、調整しない。


### SPECIFY-5: `_normalize_weight_item_pool()` / `_normalize_limit_item_pool()` のゼロ値スキップ

- **場所**: `hex_map_generator.gd`
- **現状**: weight <= 0 または limit <= 0 の item を警告なしでスキップ
- **問題**: ユーザーが weight=0 を意図的に設定した可能性と、入力ミスの区別がつかない
- **要決定**: スキップ時に警告を出すか、または入力段階（Dock）で 0 以下の値を拒否するか
- **暫定**: Core アルゴリズムとしては現状維持（入力値の validation は Editor Dock の責務）

#### ユーザー要望

機能的な価値が評価できないため、調整しない。


### SPECIFY-6: `_item_pool_entry_float()` / `_item_pool_entry_int()` の非 Dictionary item 時の既定値

- **場所**: `hex_map_generator.gd`
- **現状**: item が Dictionary でない場合、weight=1.0, limit=0 を既定値として返す
- **問題**: 非 Dictionary な item は API の誤用。暗黙の既定値よりもエラーの方が適切
- **要決定**: assert に置き換えるか、型チェックエラーを返すか
- **暫定**: assert に置き換える（API の誤用は早期発見すべき）

#### ユーザー要望

assertします。


---

## ブロック実装方針

ユーザー要望に従い整理する。
