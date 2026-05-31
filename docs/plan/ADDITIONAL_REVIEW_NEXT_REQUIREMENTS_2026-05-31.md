# ADDITIONAL_REVIEW_NEXT_REQUIREMENTS_2026-05-31.md

## 目的

追加レビューで確認された実装結果から、完了扱いにできる範囲と次回計画へ採用する要件を分ける。

参照レビュー:

- `docs/review/GENERATIVE_REFERENCE_ITEMKEY_REVIEW_2026-05-31.md`
- `docs/review/RUNTIME_INTERACTION_LOOP_PATH_REVIEW_2026-05-31.md`
- `docs/review/MANUAL_MAP_EDITING_TOOL_REVIEW_2026-05-31.md`

判定は `docs/TEST.md` の Test path と現行 test 名を根拠にする。

## 完了扱いに移す範囲

### GENERATIVE_REFERENCE_ITEMKEY

レビュー上の不足はない。Core / Editor / cancel の各観点が test 化されている。

根拠:

- `tests/test_hex_map_generation.gd`
  - generated reference item key の動的参照
  - toric wrap
  - cancel 時の partial data
- `tests/test_editor_plugin.gd`
  - Generated Item Reference checkbox snapshot
  - checkbox On / Off による生成結果差分
- `docs/TEST.md`
  - `test_hex_map_generation.gd`
  - `test_editor_plugin.gd`

対応:

- `docs/plan/GENERATIVE_REFERENCE_ITEMKEY_POLICY_2026-05-31.md` を `docs/complete_on_test/` へ移動する。
- `docs/plan/GENERATIVE_REFERENCE_ITEMKEY_IMPLEMENTATION_PLAN_2026-05-31.md` を `docs/complete_on_test/` へ移動する。

### RUNTIME_INTERACTION_LOOP_PATH 初期実装

runtime input、loop-aware hit、toric visual representative、loop-aware path、connected component helper は test 化されている。

根拠:

- `tests/test_hex_tile_map_layer.gd`
  - runtime click / hover signal
  - toric visual cell から canonical cell への hit
  - infinite mode の visual identity
  - toric visual representative
  - visual path
  - `draw_loop_path()`
  - `connected_component_from_local()`
- `tests/test_debug_scenes.gd`
  - debug scene の loop / click 表示状態
- `docs/TEST.md`
  - runtime loop path / cell hit 表示の debug workflow

対応:

- `docs/plan/RUNTIME_INTERACTION_LOOP_PATH_IMPLEMENTATION_PLAN_2026-05-31.md` を `docs/complete_on_test/` へ移動する。
- `docs/plan/RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md` は次回の loop copy / manual edit 表示候補を含む方針として更新する。

### MANUAL_MAP_EDITING_TOOL 初期実装

document resource、adapter、dock、import / export、local click、Undo / Redo、HexTileMapLayer loop-aware hit は test 化されている。

根拠:

- `tests/test_hex_adapter.gd`
  - `HexMapDocumentResource` roundtrip
  - wall / floor edit
  - payload cleanup
  - tile override apply
  - `map_cell_to_vector()` roundtrip
- `tests/test_editor_plugin.gd`
  - Hex Map Edit Dock controls
  - generated resource import / export
  - local click edit
  - Undo / Redo
  - `HexTileMapLayer` toric visual duplicate から canonical cell 編集
- `docs/TEST.md`
  - Hex Map Edit Dock の manual workflow

対応:

- `docs/plan/MANUAL_MAP_EDITING_TOOL_IMPLEMENTATION_PLAN_2026-05-31.md` を `docs/complete_on_test/` へ移動する。
- `docs/plan/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md` は runtime loop display を利用する次回方針として更新する。

## 次回計画へ採用する要件

### 1. manual edit 用表示は runtime loop display を利用する

manual edit tool は toric duplicate や path 展開について runtime API を利用する。`HexTileMapLayer.local_to_cell_hit()` と visual representative API を使う。

入力:

- target `HexTileMapLayer`
- local mouse position
- loop display settings

出力:

- canonical edit cell: `hit["hex"]`
- visual representative: `hit["visual_hex"]`
- document mutation
- display refresh
- Undo / Redo action

### 2. loop duplicate は編集対象として見える必要がある

現在の outline-only duplicate は、クリック検証には十分だが、manual edit の表示としては fallback である。次回は canonical floor / wall tile を visual representative へ表示する。

代表候補:

- runtime-owned loop copy `TileMapLayer`
- visual cell entry API による copy layer 更新

### 3. visual cell と canonical cell を区別する

document 保存、Undo / Redo、export は canonical cell のみを更新する。UI status、hover、selection、highlight は visual representative を併記できる。

### 4. fallback 的な仕様を明示する

fallback として扱うもの:

- plain `TileMapLayer` を正として後から document へ復元する方式
- outline-only duplicate 表示
- object / label を Overlay item key へ詰める方式
- generated reference の Off 状態を新機能の代替仕様として扱うこと
- 長い Core API positional arguments を今後も拡張し続けること

## 次回に回す比較事項

- loop copy 表示を内部 `TileMapLayer` で実装するか、custom draw の tile surrogate で実装するか。
- manual edit Dock に loop display controls を持たせるか、target `HexTileMapLayer` の Inspector / scene state を正とするか。
- tile override の `item_key` を overlay item 用の将来拡張として残すか、次の schema revision で分離するか。
- object / label database の definition と placement の命名を分けるか。
- generated reference API を `options: Dictionary` 化するか。

このうち、次回実装計画では loop copy 表示と manual edit の visual representative 連携を代表案として進める。
