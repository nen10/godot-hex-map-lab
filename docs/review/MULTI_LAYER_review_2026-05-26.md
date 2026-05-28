# MULTI_LAYER 実装レビュー (2026-05-26)

## ユーザーによる追記
この文章はagentによるレビュー結果です。ユーザー視点でレビューの正当性を【妥当】【把握】【疑問】【ユーザー対応】の四分類でメタレビューしました。評価に問題があれば任意に指摘してください。

## 総評

`docs/plan/MULTI_LAYER.md` の要件に対して、Core / Adapter / Editor の3層にわたる充実した実装が行われている。全30ファイル、+3018行の変更で、Overlay generation の全アルゴリズム、Placement Mask / Adjacency Reference のクエリ機構、Apply Policy、保存/復元、エディタ UI が揃っている。6つのテストファイルすべてがパスし、各機能に対して test-first で実装されている。

## 当初の要件より優れている実装

### 1. `HexMapData` の item key インターフェース統一 【妥当】
Primary Data と Overlay Data が `item_keys()` / `item_cells()` / `item_set()` / `has_item()` / `items_at()` という一貫したインターフェースを持ち、`HexOverlayData.item_selector()` / `query_item_cells()` / `query_item_set()` で OR/AND 集合演算を通じて Primary/Overlay を横断的に検索できる。これは計画に明示されていた以上の一般性を持つ設計。

### 2. `HexOverlayTileAdapter` の item order と sort による複数アイテム描画優先順位 【把握】
TileMapLayer が1 cell に複数 tile を保持できない制約に対し、item order で優先順位を付け、`to_tile_entries()` で stable sort した上で後勝ちで `set_cell()` する方式が実用的。計画では単に「1 cell に表示する tile を決める」とだけ記されていたが、item order と sort_z による優先順位制御が明確化されている。

### 3. interruptible API の統一的な result Dictionary 設計 【把握】
`generate_random_items_interruptible`、`generate_limited_items_interruptible`、`generate_toric_adjacency_items_interruptible`、`generate_symmetric_toric_items_interruptible` がすべて `{data, cancelled, progress, steps, total_steps}` の統一形式を返し、既存の `generate_symmetric_toric_walls_interruptible` との互換性も保たれている。

### 4. Deductor の既存 connectivity restore 再利用 【疑問 : 他未達事項の温床では？】
`deduct_items_for_connectivity()` が Overlay item cells を Primary の walls 相当として `HexMapData` に変換し、既存の `restore_connectivity_by()` をそのまま再利用する設計。コード重複がなく、Dense/Sparse/None の全方式に対応している。

### 5. `HexAdjacencyRuleEditor` の独立 Window 実装 【ユーザー対応 : 仕様変更予定】
Adjacency Rule Set の編集を専用ポップアップエディタとして分離し、`_on_adjacency_rule_editor_apply` でテキストを受け取るシンプルなコールバック設計。Apply/Cancel 両対応で、既存 Distribution Editor と同じパターンに従っている。

### 6. `_overlay_item_tile_configs` の fallback Wall タイル戦略 【把握】
Item Pool の row に tile mapping が設定されている item はそれを優先し、設定のない item key（例: Markov Mesh の Target Item で生成された key）は Dock の Wall tile source/atlas を fallback として使う。Toric adjacency や Symmetric toric で生成された item の tile mapping を都度設定せずに表示できる実用性が高い。

## 要件に対する実装の不足

### 1. `generate_toric_adjacency_items` の `item_keys` セレクタ未使用 【ユーザー対応 : 仕様制限, 複数 item key を区別する必要は存在しない】
`HexOverlayData` の selector API は `item_key`（単一）と `item_keys`（複数）の両方に対応しているが、`generate_toric_adjacency_items_interruptible` が `_adjacency_reference_stats` で参照する `reference_set` は、Editor Dock 側で `_overlay_reference_cells_for_snapshot` により単一の `Array[HexVector]` に解決済みの cell 集合が渡されている。このため selector の複数 key 機能は参照解決時にのみ使われ、アルゴリズム側は単一の flattened reference set として扱う。これは意図的な設計だが、将来的にアルゴリズム側でも複数 item key を区別する必要が生じた場合に API 拡張が必要になる。

### 2. Placement Mask の shape fallback が安全寄りすぎる 【ユーザー対応 : 仕様相談】
`_overlay_mask_cells_for_snapshot` で query 結果が空の場合、`_overlay_candidate_cells_for_snapshot` に fallback し、`_current_data` の floor_cells → shape-based cells と遷移する。この fallback チェーンがあるため、ユーザーが誤って空の Mask Items を指定してもユーザーにエラー通知されず、暗黙的に全 floor が candidate として使われる。意図しない全セル生成に気づきにくい。

### 3. Markov Mesh Overlay の Deductor floor 集合が候補セル全体 【妥当】
`_generate_overlay_data_from_snapshot` で Deductor に渡す `floor_cells` が `candidates`（= Placement Mask の結果）である。本来 Deductor は Placement Mask とは独立した floor 接続性を回復すべきだが、`CONNECT_DENSE` 時は候補セル全体の接続性を回復する動作となる。これは `MULTI_LAYER.md` の「"floor" cell集合は走査対象と独立に設定できる」という要件に対して、独立設定の UI が存在しない。現在は Deductor 専用の floor 集合を指定できない。

## UI 上の改善点

### 1. Item Pool row の Tile 設定が煩雑 【ユーザー対応 : レイアウト調整】
各 Item Pool row に `Tile: [source] [atlas_x] [atlas_y]` の SpinBox が3つ並ぶ。複数 item を扱う場合、これらの数値入力の視認性が低い。「Use Sample Tiles」や「Wall」の設定値からコピーするボタンや、dock 上部の Floor/Wall tile 設定を fallback として使うことがマニュアルに記載されているが、UI 上でのガイド表示がない。

### 2. Overlay controls の表示/非表示が多く、初期状態が情報過多 【ユーザー対応 : レイアウト調整】
`Overlay` toggle OFF のときは全 overlay control が非表示で、既存の Primary 生成 UI だけが表示される。ON にすると一気に Target Item、Item Pool、Placement Mask、Adjacency Reference、Apply Policy が展開され、初見では把握しづらい。セクションを折りたたみ可能にするか、Mode 変更に応じて段階的に表示するとよい。

### 3. Adjacency Rules テキストのエラー表示不在 【ユーザー対応 : 仕様変更予定】
`"bad=x"` のような不正な rules text は `parse_rules_text` で単に無視される。ユーザーに警告を出さないため、タイプミスに気づきにくい。

### 4. Overlay 生成後に Dock 下部の stats が切り替わるが、Primary データの stats 確認が困難 【妥当 : データ読み込み機能・管理機能も追加したい】
Overlay 生成後は `_update_stats()` が overlay stats を表示する。Primary データの walls/floors/connected 状態を見るには Overlay toggle を OFF にする必要がある。Overlay ON のまま Primary stats も確認できる表示があるとよい。

### 5. clear_layer=false の UI 露出なし 【妥当】
`HexOverlayTileAdapter.apply_to_tile_map_layer` は `clear_layer` パラメータを持つが、Editor Dock の Apply Layer や自動 apply では常に `clear_layer=true` で呼ばれている。`clear_layer=false` で既存 TileMapLayer セルを残す機能が UI から使えない。複数の Overlay レイヤーを同一 TileMapLayer に段階的に積むユースケースで必要になる可能性がある。

## 機能・コード上の改善点

### 1. `HexMapGenerator._adjacency_rule_probability` のキー型混在 【ユーザー対応 : 仕様変更予定】
`probability_rules` Dictionary のキーとして `int`（neighbor_count 単独）、`String`（`"1,0"` 形式）、`Vector2i`（`Vector2i(neighbor_count, component_count)`）の3種類が混在する。`parse_rules_text` は int または string でキーを作るが、`_adjacency_rule_probability` は `Vector2i` キーもチェックする。どの経路で `Vector2i` キーが作られるか不明瞭で、テストも `parse_rules_text` の string/int キーしか検証していない。

### 2. `HexMapGenerator._normalize_limit_item_pool` の remaining 管理と limit の再生成不可逆性 【疑問 : 複数itemに対する確率計算の仕様をユーザーは宣言していないため】
`_normalize_limit_item_pool` は `limit` を `remaining` にコピーし、生成中に `remaining` を減算する。同じ `item_pool` で再生成する場合、呼び出し元が毎回 `_normalize_limit_item_pool` を再呼び出しする前提だが、直接 `generate_limited_items` を複数回呼ぶと意図通りに動く（毎回 `_normalize_limit_item_pool` が走るため）。ただし、非 interruptible API が interruptible の wrapper であるため、両者の整合性は保たれている。

### 3. `HexMapGenDock._overlay_item_tile_configs` で fallback が毎回 Wall source/atlas の現在値を取得 【妥当 : 十分大きな(n=10程度) tile画像assetをサンプルとして作成・追加し、参照する。ゲーム的な実用性のある感じで。】
`_current_overlay_data.item_keys()` のうち item pool にない key すべてに同じ fallback config が割り当てられる。複数 item がすべて同じ tile で描画されるため、tile 上では区別できなくなる。これは仕様だが、stats に表示される item key と表示 tile の不一致が混乱を招く可能性がある。

### 4. `_generate_overlay_data_from_snapshot` の symmetric overlay deductor が `interrupt_options` の取り回しで Deductor 側の cancel を二重処理する可能性 【理解困難 : 対応は任せます】
`symmetric_toric_items_interruptible` の完了後、`deduct_items_for_connectivity` に同じ `interrupt_options` を渡している。すでに前段で progress が進んだ状態で Deductor が progress を上書きする。Deductor 内部の `_restore_progress_state` は progress range 未設定なので raw progress として動作するが、前段の `_interrupt_update` で `cancelled` フラグが残っている可能性がある。幸い、`_interrupt_update` は毎回 `interrupt_options["cancelled"] = false` にリセットするため実際の不具合は起きないが、依存関係が暗黙的。

### 5. `generate_symmetric_toric_items_interruptible` の `total_steps` 計算 【把握 : 対応不要】
```gdscript
int(wall_result.get("steps", candidates.size()))
```
`wall_result["steps"]` が symmetric toric wall generation のステップ数（canvas cell 数ベース）であり、`candidates.size()` は target cell 数ベース。この `steps` をそのまま item generation の progress 報告に使うため、progress bar の進行が wall generation の canvas 全体ステップ数で進み、item 生成対象外のセルまで進行に含まれる。ユーザー視点では progress が期待より早く進むように見える可能性がある。

### 6. `CLI` 経由での `item_keys` セレクタによる `item_cells` 参照の型安全性 【ユーザー対応 : 仕様制限, 現在の型のまま運用し、異なるデータ型を使用したい状況では別のMapを媒介して対応する】
`HexOverlayData._selector_item_set` は `source.item_cells(item_key)` を `has_method("item_cells")` でチェックする duck typing。`HexMapData` も `HexOverlayData` も `item_cells` メソッドを持つため問題ないが、将来データ型が増えた場合に意図しないオブジェクトが selector source になりうる。

### 7. `_overlay_candidate_cells_for_snapshot` の `SHAPE_TORUS` 分岐が symmetric を前提としている 【疑問 : 用途不明】
`SHAPE_TORUS` は `SHAPE_NAMES_SIMPLE` に含まれておらず、ユーザーが Simple モードで選択できないため実害はないが、コード上の分岐が symmetric 内でのみ意味を持つことがコメントなしでは判別しづらい。

## ドキュメントに対する要望

### 1. `docs/algorithm/ALGORITHM_ADAPTER.md` の Deductor セクション追加 【疑問 : ここは確定か不明】
現在の `ALGORITHM_ADAPTER.md` には Overlay Resource / OverlayTileAdapter の記載があるが、`deduct_items_for_connectivity` のアルゴリズム再利用設計についての記述がない。connectivity restore の既存実装を Overlay に流用するアーキテクチャ上の意図を文書化すべき。

### 2. `docs/manual/MANUAL_EDITOR_PLUGIN.md` の Placement Mask 説明の補強 【疑問 : 生成データ自体の複数読み込み機能が欲しい・伴って集合演算の仕様に改良を入れたいため現況記載の優先度が低い】
Manual には "Placement Mask: Primary / current Overlay の item keys から生成候補cellを作る" とあるが、`Mask Set: Any Item / All Items` の区別（OR/AND）の説明がない。また、Mask Items が空の場合の fallback 動作（全 floor cell が候補になる）も明示されていない。

### 3. Deductor floor 集合の UI 未提供に関する既知の制限の記載 【妥当】
計画に「通路生成処理(deductor)も生成アイテムに対して適用・削除可能とし、その場合の "floor" cell集合は走査対象と独立に設定できる」とあるが、現在の実装では候補セル全体が floor 集合として使われる。この制限を `MULTI_LAYER.md` または新規 plan ドキュメントに記録すべき。

### 4. `docs/plan/MULTI_LAYER.md` の参照セクションに未参照の実装項目 【妥当 : Layer読み込み機能よりは生成データ管理機能を充実したい】
現在参照として列挙された 10 の `complete_on_test` ドキュメントはすべて存在するが、plan 本体の「Editor Plugin / Adopter / Core 機能追加」セクション以下に記述された要件のうち、still planned なもの（例: TileMapLayer 拡張コンポーネント、Mask Source として Layer 直接参照）の優先度や着手状況が不明瞭。今後の計画として整理するか、完了したことの明示がほしい。

### 5. テスト概要の TEST.md 更新がテストファイル実体と一致しているか 【把握 : 対応不要】
`docs/TEST.md` のテスト概要セクションでは overlay 関連の記述が追加されているが、test_hex_adapter.gd と test_engine_plugin.gd の概要記述が一部簡略的（`Adjacency Rule Set の parse`、`Overlay Data の apply policy` など見出し語のみ）。各テストの検証項目が増えているため、適宜詳細を反映するとよい。

## 実装者追補 (2026-05-27)

この追補は、既存レビューとユーザーによるメタレビューを上書きせず、実装した側の観点から現行仕様・制限・次に計画化しやすい事項を整理する。

### 既存レビューへの評価

Core / Adapter / Editor の3層で実装範囲を見ている点は概ね妥当である。今回の変更は、Overlay Data の core API、保存用 Resource、TileMapLayer adapter、Editor Dock の生成・適用 UI までを一続きで追加しているため、単一ファイル単位ではなく data flow 単位で評価する方が実態に合う。

Target Layer 修正については、今回要望に対して実装・テスト・manual反映済みである。Target の `Auto: Selected / first scene layer` 維持、短い layer 表示名、`Add new layer...`、Scene Tree 選択中 `TileMapLayer` だけへの即時 apply、共有 `TileSet` の複製は `tests/test_editor_plugin.gd` と `docs/manual/MANUAL_EDITOR_PLUGIN.md` に反映されている。

Overlay 系は最小実用 UI として成立している。ただし、現在の Editor Dock は「現在の Primary Data / current Overlay Data」を中心に生成する設計であり、保存済み Overlay Resource を複数読み込んで Mask / Reference source として管理する UI はまだ限定的である。

### 仕様制限として扱う事項

- Placement Mask の query 結果が空の場合、現在は fallback により Primary floor cells または shape-based cells が候補になる。この挙動は作業継続性を優先したものだが、Mask Items の typo や空指定で意図しない全floor生成が起きうる。
- Markov Mesh Overlay の Deductor が連結性回復に使う floor 集合は、現在 Placement Mask で解決された candidates と同一である。`MULTI_LAYER.md` にある「floor cell集合は走査対象と独立に設定できる」という要件に対して、独立指定 UI はまだ提供していない。
- Mask / Reference source は Primary Data と current Overlay Data が中心である。保存済み `HexOverlayResource`、複数 Overlay、または `TileMapLayer` から復元したデータを直接 source として選ぶ管理 UI は未整備である。
- `HexOverlayTileAdapter.apply_to_tile_map_layer()` は `clear_layer=false` を持つが、Editor Dock の自動 apply / `Apply Layer` は現在 `clear_layer=true` のみを使う。既存 `TileMapLayer` cell を残して重ね書きする運用は adapter API では可能だが、Dock UI からは使えない。

### UI / 運用上の懸念

- Overlay controls は `Overlay` toggle On で Item Pool、Placement Mask、Adjacency Reference、Apply Policy がまとめて展開されるため、初見では情報量が多い。次に触るなら折りたたみ、段階表示、または mode 別 grouping が効果的である。
- Item Pool row の tile 指定は source / atlas_x / atlas_y の数値入力で、複数 item を扱うと視認性が落ちる。sample atlas の拡充、tile picker、または `Floor` / `Wall` 設定からコピーする UI があると運用しやすい。
- Adjacency Rules は `HexAdjacencyRuleSet.parse_rules_text()` で不正 entry を無視する。生成を止めない点は扱いやすいが、typo に気づきにくいため、editor 側で invalid entry の警告表示を追加する余地がある。
- Overlay 生成後の stats は Overlay stats を優先表示する。Primary stats は Overlay toggle Off で確認できるが、Overlay mode のまま Primary / Overlay を並べて確認する data management UI はまだない。

### 技術上の懸念

- Adjacency probability rule は `int`、`String`、`Vector2i` key を受ける。Core API の互換性としては柔軟だが、Editor 由来の `HexAdjacencyRuleSet` は `int` と `String` を作るため、将来は正規化方針を明文化した方がよい。
- Overlay Deductor は既存の `restore_connectivity_by()` を再利用するため実装の一貫性は高い。一方で、Overlay item を一時的に wall とみなす設計意図は algorithm docs にはまだ薄い。必要になった時点で `docs/algorithm/ALGORITHM_ADAPTER.md` または generation algorithm docs に反映する。
- `HexOverlayData` / `HexMapData` の item selector は duck typing による `item_cells()` 参照で成立している。現状の対象型では問題ないが、将来 source 種別を増やす場合は selector source の型または adapter 境界を整理する必要がある。

### 次に plan 化するなら

1. Overlay データ管理を追加する。保存済み `HexOverlayResource` や複数 Overlay を読み込み、Mask / Reference source として選べるようにする。
2. Mask 空結果の扱いを決める。fallback 維持、警告表示、または空生成のどれを正とするかを仕様化する。
3. Deductor floor 集合の独立指定 UI を追加する。Placement Mask とは別に、連結性回復の対象 floor source / items を選べるようにする。
4. Overlay UI を整理する。セクション折りたたみ、tile picker、sample atlas 拡充、copy-from-current tile controls などを検討する。
5. Adjacency Rule Set editor の入力検証を追加する。不正 entry の表示、clamp 結果の見える化、rule key の正規化方針を合わせて決める。

### ドキュメント方針

今回の追補では `docs/algorithm/ALGORITHM_ADAPTER.md` へは直接追記しない。Deductor や Overlay data management の仕様を次期 plan として固める段階で、algorithm docs に設計意図を移す。

完了済み扱いの機能は `docs/complete_on_test/MULTI_LAYER_2026-05-26_*.md` に分割済みである。この追補は完了済み扱いを取り消すものではなく、現行仕様の制限と次期改善候補をレビュー文脈で整理するための文書である。
