# MAPDATA_QUERY 実装レビュー (2026-05-29)

## ユーザーによる追記
この文章はagentによるレビュー結果です。ユーザー視点のメタレビューは【】に記載しました。

## 総評

`docs/plan/MAPDATA_QUERY.md` の要件である **Source Registry**、**Query Row**、**Mask Crop**、**Crop Off source stack**、**Generate History** の5機能が一括して実装され、全6テストファイルがパスしている。実装は `hex_map_gen_dock.gd` に +953 行、`test_editor_plugin.gd` に +260 行。保存済みマップデータの活用という計画の目的をほぼ達成している。

## 当初の要件より優れている実装

### 1. Hex 六方向ボタンによる offset 直感的操作
各 Query Row に `+Q`, `-R`, `+S`, `-Q`, `+R`, `-S` の6ボタンが付き、HexVector の方向に対する offset をボタン押下で直接操作できる。計画では「六方向近傍ボタン」を要望していたが、基底の方向名までラベル表示している点がユーザーにとって直感的。

### 2. Reload 機能の追加
計画は Load / Clear のみだったが、Reload ボタンが追加され、`resource_path` から再読み込みして `data` / `item_keys` / `display_name` を更新できる。外部ツールで `.tres` を編集した後の更新に有用。

### 3. Source display_name の同名 disambiguation
`_unique_source_display_name` により、同名ファイルの source が登録された場合 `filename (2)` / `filename (3)` のように suffix で区別する。tooltip に `resource_path` を表示するため、同名でも混同しない。

### 4. Query Row の `source_item` OptionButton が source_id を metadata で保持
`_refresh_source_item_options` で OptionButton を再構築しても、`set_item_metadata` で埋め込まれた `{source_id, item_key}` 辞書により選択状態を復元できる。これにより source registry 変更時の再描画が安全。

### 5. Offset の toric wrap が source 個別の `cyclic_size` を参照
`_offset_points` が各 source の `data.cyclic_size` を使って個別に toric wrap する。計画の「source 自身の `cyclic_size` で wrap する。非 toric source は wrap しない」に忠実。

### 6. `_overlay_crop_result_data` が `Any` item に universe 全体を格納し、非 `Any` item を別途保存
Crop result の保存形式が、crop universe 全体を `Any` として保持しつつ、`Contain` 由来 item のみ `source / ItemKey` の prefix 付き key で保存される。`Exclude` 由来 item は保存されない（計画通り）。Apply 時は `Any` をスキップして非 `Any` cell だけを描画する。

### 7. `_intersect_points` が HexMapData.make_set を利用した `O(n+m)` の交差計算
自前の二重ループではなく set 経由で行い効率的。

## 要件に対する実装の不足

~~### 1. 方向ボタンの逆方向 decrement 未実装 (重要【どうでもいい】)
計画に「反対方向の offset が正の場合は、押した方向を増やす前に反対方向を decrement する」とあるが、実装は `offset = offset.add(HexVector.directions()[direction_index])` で一方向の increment のみ。

```gdscript
# 現在の実装 (hex_map_gen_dock.gd 内 _on_query_row_direction_pressed)
offset = offset.add(HexVector.directions()[direction_index])
```

例えば `+Q` を押して offset が `(1,0,0)` のとき `-Q` を押すと `(0,0,0)` に戻るだけで、計画の意図する「反対方向を decrement してから increment」のロジックは入っていない。offset の正規化（冗長成分の除去）がユーザーに委ねられている。~~ 
【無用な指摘】

### 2. `_resource_for_save_button` / `_on_apply_layer_pressed` が `_apply_overlay_source_stack_to_current` を副作用として呼ぶ
Crop Off / Overlay モードの Save や Apply Layer ボタン押下時に、source stack の合成結果で `_current_overlay_data` が上書きされる。この副作用は計画に明示されている動作だが、ユーザーが「現在の状態を見るだけ」のつもりで Apply Layer を押した場合にも `_current_overlay_data` が書き換わる。保存と現在状態確認の操作が同一ボタンに集約されている。

### 3. Crop Off stack で異なる `cyclic_size` の source が混在する場合の警告のみで stack 続行
`_overlay_source_stack_data` は `push_warning` を出すだけで、異なる `cyclic_size` の source もそのまま合成する。計画の「異なる `cyclic_size` の source が混在する場合は警告対象として扱う」に対して、合成そのものを停止するオプションがない。
【`cyclic_size`はsource本来のものを使用するべきですが、優先度は高くないです。】

### 4. Query Row の item_key 変更が crop result の item key に即時反映されるが、ユーザー確認がない
行の source_item を変更すると `_on_query_row_edited` が走り Crop Off に戻す。しかし、source_item option を変えただけでは `_on_query_row_source_selected` が発火するが、Crop はすぐに Off になるため、Crop 状態での item_key 切替が実質不可能。これは計画で「Crop On 中に Mask Query Row 領域を編集した場合、Crop Off に戻す」とされているので意図通りだが、Crop result 確認中のうっかり操作防止策としてはやや過剰。
【優先度は低い】

## UI 上の改善点

### 1. Query Row が極端に横長
1行に `[AND/OR] [Contain/Exclude] [source / ItemKey選択] [offset表示] [+Q] [-R] [+S] [-Q] [+R] [-S] [Up] [Dn] [-]` と最大12個のウィジェットが横並びする。Dock の幅が狭い環境では視認性が著しく低下する。方向ボタンを折りたたみ可能にするか、2段にするレイアウトオプションが望ましい。
【6方向ボタンはいくつかの場面で使う可能性があり、よりグラフィカルなものを作成予定です。】

### 2. History / Dir ボタンの配置
`Seed` コントロールの横に `History` checkbox と `Dir` ボタンが追加されている。履歴保存は Seed よりもむしろ `Save .tres` や `Generate` に近い概念であり、別セクションに分離した方が意図が明確。

### 3. Source Registry の表示が `display_name [resource_type]` のみ
source の data 内容（cell 数、item 一覧）が UI 上で確認できない。リスト内の label をクリックで展開するか、tooltip で詳細表示するなどの拡張余地がある。
【Item:セル数 の一覧は可視化するのもよい】

~~### 4. Crop count 表示が `Cells: N` のみ
どの item が何 cell 持つかの内訳がない。特に `Any` を除外した非 `Any` の union だけがカウントされるが、どの item key 由来かがわからない。~~
【無用】

~~### 5. Query row に offset のリセットボタンがない
方向ボタンで offset を増やしたあと `(0,0,0)` に戻すには、逆方向のボタンを手動で押し続けるか、行を削除して再追加する必要がある。~~
【無用。そんなに戻したきゃItemKeyごと削除して追加し直せばいい】

## 機能・コード上の改善点

### 1. `_evaluate_query_rows` で universe は全 row の source cells 全 union
非 crop 時の universe が全 query row の全 source の全 cell を offset 付きで含む。これにより `Exclude` の補集合が極端に大きくなり、意図しない全マップが result に含まれる可能性がある。計画では universe = "現在の Shape / サイズの cells" と明記されていないが、実際の使用では query の文脈に応じた universe 制限があるべき。
【最優先 : "現在の Shape, サイズの cells" が universe でなければならない。しかし、実際の実行時には結果的にそうなるのでは。参照用に広く取れるようにしている可能性もある。】

### 2. `_on_save_pressed` の流れで `_resource_for_save_button` が null を返すと Save dialog が開かない
Crop Off / Overlay で Overlay source が0件の場合、`_apply_overlay_source_stack_to_current` が false を返し、`_resource_for_save_button` も null を返す。結果として Save dialog が表示されず、ユーザーに何が起きたか伝わらない。警告ログは出るが UI 上のフィードバックがない。

### 3. `_save_generate_history_data` が `_complete_generation_from_thread` の `_set_generation_progress` の後、merge の前に呼ばれる
`_save_generate_history_data(data, ...)` の `data` は生成スレッドからの raw result。Overlay の場合、その後の merge 処理（`_current_overlay_data.apply_overlay(data, ...)`）の前に保存が走るため、計画の「Apply Policy 反映前の差分だけを保存」を満たす。ただし、`_save_generate_history_data` 内の `register_mapdata_source(resource, path)` が `_refresh_source_item_options` を呼び、これが UI を更新する。この UI 更新はメインスレッド上の `_complete_generation_from_thread` から呼ばれており問題ないが、生成完了処理の順序依存性が高い。
【どうでもいいのでは】

### 4. `_refresh_source_item_option` のパフォーマンス
source registry の全 entry の全 item_key を走査して OptionButton を毎回再構築する。source が増えると combo box の再構築コストが線形に増加するが、source 数は実用上高々数十と想定されるため問題にならない。
【呼ばれる箇所が最小限ならよい】

### 5. `_overlay_crop_universe` の `SHAPE_TORUS` 分岐
計画では `SHAPE_TORUS` はユーザーが Simple モードで選択できない（`SHAPE_NAMES_SIMPLE` に未掲載）。しかしコード上で `SHAPE_TORUS` への分岐が存在し、`_gen_radius_spin` から universe を生成する。この dead path は将来 Torus が Simple モードに追加された場合に備えたものだが、現状は到達不能。
【どうでもいいのでは】

### 6. `_add_query_row` が `_on_query_row_edited` を呼び、Crop Off にリセットするが、行追加自体は計画で「Crop On 中に Mask Query Row 領域を編集した場合、Crop Off に戻す」に該当する
行追加も「編集」に含まれるため動作は正しいが、ユーザーが Crop 結果を見ながら行を追加したいケースでは不便。
【どうでもいいのでは。Cropを得る計算が一瞬でUI操作に支障がないなら編集のたびにCrop更新・Applyを実行しても構わないが。】

### 7. `_on_query_row_source_selected` 内の `row["source_id"]` / `row["item_key"]` 更新が暗黙的
`_on_query_row_changed` では `row["operation_value"]` / `row["match_value"]` にキャッシュを書き込むが、`_on_query_row_source_selected` では `row["source_id"]` / `row["item_key"]` に直接書き込む。クエリ評価時には OptionButton の selected index から毎回読み取る `_query_row_operation` / `_query_row_match` がある一方、source_id は `row.get("source_id", -1)` で辞書から直接読む。書き込み方式に一貫性がない。
【何が言いたいのか理解できなかった】

## ドキュメントに対する要望

~~### 1. `docs/manual/MANUAL_EDITOR_PLUGIN.md` の Query Row 詳細
Manual には Mask Query Row の `AND / OR`、`Contain / Exclude`、offset が簡潔に記載されているが、以下が不足:
- 方向ボタンのラベル `+Q / -R / +S / -Q / +R / -S` の意味（HexVector 基底方向）
- `Exclude` の補集合計算における universe の定義
- `Crop Off` 時の universe が全 query source cell の和集合であること~~
【無用 : 誤った仕様を意図的に文書化して問題を生産しないでください】

### 2. Crop result item key の `source display_name / ItemKey` 形式が `.tres` 内部で確認可能であることの記載
Crop result を保存した `.tres` の `item_keys` に prefix 付きの key が含まれることをユーザーが認識できるドキュメントがほしい。
【どうでもいいのでは】

~~### 3. 計画上の未実装項目の記録
計画の方向ボタン decrement ロジックが未実装であることを `docs/plan/MAPDATA_QUERY.md` または follow-up plan として記録すべき。~~
【無用 : 誤った仕様を意図的に文書化して問題を生産しないでください】

### 4. `source / ItemKey` の選択肢が OptionButton でフラットリスト化されることの UI 説明
Source Registry に source を追加するたびに、全 source × 全 item_key の組み合わせが1つのドロップダウンに展開される。source が多い場合の操作性についてマニュアルに記載があるとよい。
【大量のsourceでまともなqueryを考えることは想定しない。】

### 5. `Generate History` のファイル命名規則
Manual にはファイル名の具体例 `20260529-153012-overlay-uniform-tree.tres` が記載されていない。`_history_condition_name` / `_history_item_name` の決定ロジック（overlay-uniform, overlay-limited, overlay-markov, overlay-adjacency, primary-uniform, primary-markov）をドキュメント化すべき。
【overlay-limited ではなく overlay-combination にしましょう。アルゴリズム上の名前とユーザー向けの表示は切り分けます。ドキュメントについてはどうでもいいかも】

## 実装者追補 (2026-05-30)

この追補は、既存レビューとユーザー追記を上書きせず、実装した側の観点から残すべき懸念を整理する。ユーザー追記で「無用」とされた指摘は次期課題として再採用しない。

### 実装済みとして扱う範囲

`docs/plan/MAPDATA_QUERY.md` の中心要件である Source Registry、Query Row、Mask Crop、Crop Off source stack、Generate History は実装・テスト・manual反映済みである。完了済み仕様は `docs/complete_on_test/MAPDATA_QUERY_2026-05-29.md` に移しており、このレビュー追補は完了扱いを取り消すものではない。

特に、保存済み `HexMapResource` / `HexOverlayResource` を Dock session 内の source registry として読み込み、Mask / Reference query に利用する流れは成立している。`TileMapLayer` 直接参照や TileMapLayer からの mapdata 復元ではなく、生成済み Resource を query source とする方針で整理済みである。

### 実装者観点で残る懸念

- Mask query の non-crop universe は最優先で整理したい。現在の実装は Crop Off の query universe を query row source cells の union として扱うため、`Exclude` の補集合や Overlay Generate candidate cells が現在の Shape / サイズ境界と直感的に一致しない可能性がある。参照sourceは広く取れてよいが、生成候補として使う Mask query result は現在Shape/サイズの universe で評価する方が仕様として明確である。
- Crop Off / Overlay の `Apply Layer` / `Save .tres` は、Source Registry 内の Overlay source stack を合成し、その結果を `_current_overlay_data` に反映してから実行する。この副作用は仕様通りだが、ボタン名だけでは「current overlay が更新される」ことが見えにくい。状態表示や確認用statsの改善余地がある。
- Crop Off source stack で異なる `cyclic_size` の Overlay source が混在した場合、現状は警告して処理を継続する。優先度は高くないが、source本来の `cyclic_size` を尊重する設計を維持しつつ、混在時の結果をUI上で確認しやすくする必要がある。
- Crop Off / Overlay で合成対象の Overlay source が0件の場合、警告ログだけで Save dialog は開かない。ユーザー操作としては失敗理由がDock上に見える方がよい。
- Query Row は現在横長で、六方向offset buttonを他の場面にも使うなら、専用のグラフィカルcontrolとして切り出す価値がある。
- Source Registry は `display_name [resource_type]` が中心で、itemごとのcell数やresource pathの視認性は限定的である。`Item: cell数` の一覧表示またはdetails表示があると、query sourceを選ぶ判断がしやすい。
- Generate History のユーザー向けcondition名は、実装上の `limited` ではなく `combination` として扱う方がよい。アルゴリズム関数名とファイル名・UI表示名は分離する。

### 次期planへの反映

上記のうち、次の実装に向けて整理すべき主要項目は `docs/plan/EDITOR_OVERLAY_REMAINS.md` に集約する。`MAPDATA_QUERY` の完了済み仕様は維持しつつ、Mask query universe、Source Registry可視化、Query Row layout、Generate History表示名、Overlay source stackの状態表示を次の改善対象として扱う。
