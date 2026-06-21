# Build Tab UX Implementation Handoff

**日付**: 2026-06-21
**対象**: Hex Map Kit addon Build tab (`addons/hex_map_kit/editor/`)

---

## 1. 実施した要件と成果物

### 1-1. Viewport Preview on Generate + Apply/Revert

**目的**: Generate ボタン押下後、生成結果をシーンのビューポートにプレビュー表示し、Apply/Revert で確定/破棄できるようにする。

**実装**:
- `hex_map_build_screen.gd`: `_on_generate_pressed()` が `_auto_preview_after_generate()` を呼び出し。`_promote_terminal_outputs()` でグラフの全終端ノード（terrain + overlay 両方）を promote
- `_apply_document_to_context_layer()`: `ensure_display_tiles()` で子 TileMapLayer 作成後、`HexMapDocumentApplier.prepare_document_apply()` + `apply_map()` を直接呼ぶ（`apply_document()` の `is_node_ready()` ゲート回避）
- Apply / Revert ボタンをコンテキストストリップに追加。Revert は promote 前の document state に復元

**問題**:
- テストの存在が不明。
- 結局viewportには表示できていない。


### 1-2. パラメータ編集UI（全ノード型対応）

**目的**: グラフノード選択時、読み取り専用テキスト表示を廃止し、パラメータ毎の編集コントロール（OptionButton, SpinBox, CheckBox, LineEdit）で編集可能にする。

**実装**: `hex_map_build_node_inspector.gd` を完全書き換え:
- `_build_param_controls()`: ノード型に応じた動的パラメータ行生成
- mode 変更で関連パラメータの表示/非表示を動的切替（`_param_visibility_for_type()`）
- Shape: shape 選択で width/height vs size vs radius を切替
- Wall Field: mode 選択で wall_probability vs distribution_id を切替
- Item Generator: mode 選択で placement_probability / probability_rules を切替
- Region Filter: mode 選択で item_key 表示切替
- Source: kind 選択で source_key 表示切替

**パラメータタイプ別コントロール**:
| パラメータ | コントロール型 |
|---|---|
| shape, mode, kind, method, write_policy, existing_policy, op, output_type, distribution_id, operation, orientation | OptionButton |
| wall_probability, placement_probability, noise_scale, noise_threshold | SpinBox (float) |
| width, height, size, radius, seed, neighbor_radius, shift_q/r/s | SpinBox (int) |
| toric, include_generated_reference | CheckBox |
| source_key, item_key, selectors, probability_rules | LineEdit |
| item_pool | 専用行エディタ（名前+weight +/-） |
| shift_offset | HexCellButtonPanel（hex方向パッド） |

**問題**: 
- テストの存在が不明
- 1-1.の問題により検証が進んでいない。設定したパラメータが生成に反映されている動線が確保できているのか検証されていない。


### 1-3. ノード/Edge 削除機能

**目的**: macOS の右クリック非対応問題を回避しつつ、ノード・edge の削除操作を提供する。

**実装**:
- `hex_map_build_graph_canvas.gd`: `delete_nodes_request` シグナル接続 + `_gui_input` で Delete/Backspace キー捕捉
- `remove_graph_node(node_id)`: 全接続除去 + GraphNode 破棄 + `_node_order` 更新 + dirty マーク
- `hex_map_build_screen.gd`: コンテキストストリップに [Remove] ボタン追加

**問題**: 
- テストの存在が不明。
- edge削除は機能していないため実装と実態に乖離があり混乱を招いている。

### 1-4. Markov Mesh + Adjacency Rules

**目的**: 旧Generateタブの Markov Mesh 壁生成と近傍参照 adjacency ルールをグラフノードの mode 選択として具体化。

**実装**:
- `hex_generation_node_types.gd`:
  - `_run_wall_field`: mode=`markov_mesh` → `generate_symmetric_toric_walls_interruptible()` を呼び出し、結果を入力セルにフィルター。`distribution_id` パラメータで Ilands(11)/Maze(20)/Discrete(24) 選択
  - `_run_item_generator`: mode=`adjacency_rules` → `generate_toric_adjacency_items_interruptible()` 呼び出し。`probability_rules`, `neighbor_radius`, `include_generated_reference` パラメータ表示

**問題**: 
- 目的の時点で誤っている本来の設計が誤解されている。旧Generate Tabの機能意図が誤解されている。
- Item Generator 自体の生成方式が反映される必要がある。placement methodに依存して決定されるgenerate methodが旧Generate tabのstate遷移に一致しているかが不明。このgenerate methodはwall ノードのwall method(正しくはGenerate methodとする)と独立に設定できることを確認する必要がある。


### 1-5. Region Filter — shift (hexパッド) + item_key モード

**目的**: 旧Generateタブの Layer Shift（hex方向オフセット）と任意 item_key フィルタリングをノードに移植。

**実装**:
- `_run_region_filter`: `mode=query` (selectors + op) を **削除**。Set Operation ノードに機能移行済み
- `mode=item_key` 追加: 任意アイテムキーで HexMapData / HexOverlayData 両方からセル抽出
- `_apply_shift()`: shift_q/r/s パラメータで選択セルをオフセット
- `HexCellButtonPanel` を使った hex方向パッドUI（6方向ボタン + 現在値表示 + Reset）
- Result ノードの orientation を BFS 下流探索で取得し、hexパッドの flat_top レイアウトに反映

**問題**: 
- テストの存在が不明
- 1-1.の問題により検証が進んでいない。設定したパラメータが生成に反映されている動線が確保できているのか検証されていない。
- "`mode=item_key` 追加: 任意アイテムキーで HexMapData / HexOverlayData 両方からセル抽出"両方からではない。Overlayからのedgeが入力され、フィルターするItemkeyとして実装される必要がある。
- ItemKeyは入力されているOverLayで生成を計画されているKeyたちをドロップダウンで選択できるべき。
- Region FilterにItem Generator の出力を注入できないので検証不能


### 1-6. Result ノード（新設）

**目的**: terrain + overlay 出力を一元化し、1回の Generate で両方を promote 可能にする終端ノード。

**実装**:
- `NODE_RESULT` 追加（レジストリ + `_run_result` + パレット + タイトル）
- 入力: `terrain` (TERRAIN), `overlay` (OVERLAY)
- 出力: RESULT (`HexGenerationResultResource`)
- `_run_result`: 入力データを `primary_map` / `overlay_map` に格納
- `orientation` パラメータで flat_top / pointy_top 切替。promote 時に `layer.flat_top` に書き込み
- `_auto_preview_after_generate()`: RESULT 型出力を検出し terrain + overlay 両方 promote
- デフォルト垂直スライスチェーン末尾に Result ノード追加
**問題**: 
- テストの存在が不明
- 1-1.の問題により検証が進んでいない。設定したパラメータが生成に反映されている動線が確保できているのか検証されていない。

### 1-7. Set Operation ノード（新設）

**目的**: Region Filter と Item Generator の間で集合演算（union / intersection / difference）を可能にする。

**実装**:
- `NODE_SET_OPERATION` 追加
- 入力: `a` (SELECTION, required), `b` (SELECTION, optional)
- 出力: SELECTION
- 操作: union (A∪B), intersection (A∩B), difference (A\B)


### 1-8. ノード選択時の接続警告

**目的**: 必須入力未接続、出力未使用、型不一致を選択中ノードのインスペクターに警告表示。

**実装**: `_compute_connection_warnings()` でグラフモデルからエッジ情報を収集し、警告メッセージを生成。inspector に `connection_warnings` として受け渡し。

---

## 2. 変更ファイル一覧

| ファイル | 変更内容 |
|---|---|
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | Viewport preview, Apply/Revert, Remove button, _promote_terminal_outputs, _find_effective_flat_top, layer_stack auto-create, HexMapDocumentApplier preload |
| `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd` | 完全書き換え: 動的パラメータ編集UI, item_pool行エディタ, hexパッド, 接続警告, モード切替表示 |
| `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd` | delete_nodes_request, _gui_input Deleteキー, remove_graph_node, Result/SetOp 登録, デフォルトチェーンResultノード追加 |
| `addons/hex_map_kit/generation/hex_generation_node_types.gd` | NODE_SET_OPERATION, NODE_RESULT 追加, _run_wall_field markov_mesh, _run_item_generator adjacency_rules, _run_region_filter query削除+item_key追加+shift追加 |
| `tests/test_build_graph_canvas.gd` | palette ノード数 7→9 更新 |
| `tests/test_generation_graph.gd` | query→item_key テスト更新 |
| `tests/test_generation_promote.gd` | Result ノード追加に合わせたテスト更新 |
| `tools/graph12_visual_verify.gd` | preview→Apply/Revert ボタン検証に更新 |
| `docs/manual/ja/MANUAL_EDITOR_PLUGIN.md` | Build タブのドキュメント更新 |
| `docs/manual/ja/UI_EXECUTION_PATH_CHECK.md` | 用語・ワークフロー更新 |

**Core 変更**: なし。すべての生成ロジックは既存 `hex_map_generator.gd` / `hex_randomizer.gd` の static 関数を再利用。

---

## 3. テスト状況

全37テストスクリプトが `./tools/test.sh` でパス（exit 0）。ただし:
- `test_generation_promote.gd` は test_base.gd（`test_editor_plugin_test_base.gd:69`）の preload が inspector のコンパイル順序に依存しており、単独実行時に失敗する可能性がある。並列実行では問題なし。

---

## 4. 既知の未解決事項

### 4-1. Viewport 表示のエディター依存

動的追加された HexTileMapLayer ノードの `_ready()` が Godot エディター内で即時発火しないケースがある。`ensure_display_tiles()` + `apply_map(resource)` の直呼びでバイパスしているが、特定条件下（エディター初回起動時など）で `_tile_map` 未作成のまま `_redraw_with_options` が早期リターンする可能性が残る。

**指摘**: このような問題が実在するのかそもそも不明

### 4-2. item_pool エディタのラベル順序

`_build_param_controls` 内で item_pool エディタがラベル行より先に `_params_container` に追加されるため、表示順序が逆。UX 上の軽微な問題。

**指摘**: 対応済み

### 4-3. hex パッドが row 内に制約される

shift_offset 用の `HexCellButtonPanel`（160x140）が `HBoxContainer` の row 内に配置されている。旧コードでは独立した container 子要素だった。幅制約でレイアウトが崩れる可能性。

**指摘**: 表示はできています。hexpadとoffset表示を縦に積まず、横に積んで欲しい。

### 4-4. _build_option_control のフォールバック

`current_value` が選択肢と一致しない場合、index 0 を選択するが param 値は更新しない。表示とデータの不整合が発生しうる。

**指摘**: 何の話か意味不明


### 4-5. ノード間 state 管理は未実装

旧Generateタブの `HexMapGenStateEvaluator` 相当のグラフ横断 state 管理は未移植。現状は各ノードが自ノード内の mode で自パラメータのみ制御する。ノード間制約（例: Wall Field = random_probability 時に Item Generator adjacency_rules を無効化）は実装されていない。


**指摘**: 大問題

---

## 5. 今後の作業候補

1. **Viewport 表示の堅牢化**: `_ready()` 遅延に依存しない `_tile_map` 作成の保証
2. **ノード間 state 管理**: 旧タブの `HexMapGenStateEvaluator` 相当をグラフに移植
3. **item_pool UX 改善**: ラベル順序修正
4. **hex パッドレイアウト**: row 外に独立配置
5. **プレビュー機能**: RESULT 型出力の preview snapshot 生成
6. **ドキュメント**: 英語版マニュアルの更新


ノードグラフエディタの高さはもう少し稼ぎたい。横のボタン量に合わせるのではなく、ドック高さの2/3に連動する高さとしたい。グラフエディタ横のボタンはグラフエディタ下部に並べるようにする。ボタン文字サイズを少し小さくする。グラフ内ノード内文字サイズを少し小さくする。グラフ内ノードのサイズを広げられるようにできるか？普通に文字が切れている。
