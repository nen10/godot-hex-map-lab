# HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_PERFORMANCE_REVIEW_2026-06-03.md

## 目的

`Hex Map Edit` Dock の実Editor確認で残った、Target Reload後の編集初期化、編集反映の重さ、Target Auto、`HexTileMapLayer` / `TileMapLayer` 間の座標ずれ、長期的な表示アーキテクチャ課題を整理する。

## ユーザー確認結果

### 確認済み

1. Export機能で作成したデータをImportすると、viewport上に `TileMapLayer` のcell状態が視覚反映される。
2. Editにより `Shape`、`Wall / Floor`、`Floor Tile`、`Wall Tile` が動作する。
3. Cellサイズは正しく調整されている。

### 対応要望

1. `HexTileMapLayer` 選択時、Target Reloadだけではviewport編集が有効にならない。
   - `HexMapResource` importまたは `HexMapDocumentResource` load後は、Target Reload後に編集できる。
   - 独自node初期化に不足があるか調査する。
2. Edit結果のviewport反映が遅く、処理が重く感じられる。
   - `HexTileMapLayer extends TileMapLayer` の妥当性を確認する。
   - 内部 `TileMapLayer` のデータを使いつつ子layer / overlayを持つ構成や、Resource外部化の過剰さを別計画で検討する。
3. Target Autoが選択中の `HexTileMapLayer` ではなく、plain `TileMapLayer` を含む先頭layerに解決される。
   - Edit / Generatorで `HexTileMapLayer` のみをTargetにする影響を調査する。
4. `HexTileMapLayer` と `TileMapLayer` 間で原点・中心・paddingの扱いが微妙にずれ、cellが大量に並ぶとずれが蓄積する。
5. Debug reportが `docs/review/debug/HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_REPORT_2026-06-03.md` に記録された。

## 対応調査

### 1. Target Reloadだけで編集できない原因

`HexMapEditTool.viewport_input_enabled()` は、Target解決だけでなく `_document != null` を必須条件にしている。`refresh_target_layer_options()` / Target ReloadはTarget候補を再走査し、Targetを解決するが、`HexTileMapLayer.hex_map` からEdit Dock用の `HexMapDocumentResource` を作らない。

そのため、`HexTileMapLayer` がready済みで内部 `TileMapLayer` や `hex_map` を持っていても、Edit Dock側にdocumentがない状態ではviewport入力が無効になる。`HexMapResource` importまたは `HexMapDocumentResource` load後に回復する観察と一致する。

判定:

- 主因は `HexTileMapLayer._ready()` の不足ではなく、TargetからEdit documentを初期化する入口がないこと。
- Target Reload時、Auto target解決時、または明示Target選択時に、`HexTileMapLayer.hex_map` からmap-only documentを作る必要がある。
- 既存のLoad / Import / Save / Export UXは維持し、Target由来documentは「未保存の作業document」として扱う。

### 2. 編集反映の重さ

`HexMapEditTool._apply_hit()` は1clickごとに `HexMapDocumentAdapter.duplicate_document()` でbefore / afterを全量複製する。`_commit_document_change()` は `_apply_document_to_target()` を呼び、`HexTileMapLayer` targetでは `hex_layer.apply_document(_document)` を実行する。

`HexTileMapLayer.apply_document()` はdocumentを複製し、`HexMapResource` へ変換し、`apply_map()` と `_apply_document_payloads()` を呼ぶ。`_redraw()` は内部 `TileMapLayer.clear()` 後、全cellを `set_cell()` し直す。Debug reportでは `used=961` であり、1clickごとに961 cell規模の再構築が走る。

判定:

- 遅さの主因はGodot Editor固有ではなく、per-click全量document複製 + 全量TileMap redraw。
- `Wall / Floor`、`Floor Tile`、`Wall Tile` は対象cellのみ更新するincremental applyへ切り替える余地が大きい。
- `Shape` はcell追加 / 削除とpayload cleanupがあり、短期は全量再反映を許容し、段階的にincremental化する。

### 3. Target Autoとplain `TileMapLayer`

Edit Dockの `_editable_target_from_node()` は `HexTileMapLayer` とplain `TileMapLayer` の両方をTargetとして受け入れる。`_collect_target_layers_recursive()` もplain `TileMapLayer` を候補に含める。

Generator Dockも `_collect_tile_map_layers_recursive()` で `HexTileMapLayer` とplain `TileMapLayer` を同列に収集する。既存testにはplain `TileMapLayer` target維持を前提にしたものが多く、GeneratorのOverlay applyは現在plain `TileMapLayer` を要求している。

判定:

- Manual Editの通常Targetは `HexTileMapLayer` に寄せるべき。
- plain `TileMapLayer` を完全に廃止すると、既存adapter test / generator overlay / 旧manual edit互換の整理が必要になる。
- Generator Primary applyを `HexTileMapLayer` へ寄せるのは妥当だが、Overlay applyの扱いは別途設計する。

### 4. 座標ずれとpadding

`HexTileMapLayer.local_to_cell_hit()` とhighlight / markerは `hex_size` と独自数式 `HexMapTileAdapter.hex_to_local()` を使う。一方、実際の表示cellは内部 `TileMapLayer` の `TileSet.tile_shape`、`tile_layout`、`tile_offset_axis`、`tile_size` に従う。

Godot公式APIには `TileMapLayer.local_to_map()` と `TileMapLayer.map_to_local()` があり、表示用map座標とlocal座標の変換はこのAPIが基準になる。独自hex数式が `TileSet` のhex layoutやtile sizeと完全に一致しない場合、中心・原点・paddingのずれがcell数に応じて蓄積する。

Debug reportでは `(0,0,0)`、`(30,0,0)`、`(0,-30,0)`、`(0,0,30)` のlocal positionが記録されており、遠端cellでの比較に使える。`used=961` の表示反映は成功しているため、次の調査は「表示TileMapLayerの `map_to_local(vector_to_map_cell(hex))` とEdit hit / overlay中心の差分」を数値化することになる。

判定:

- `HexTileMapLayer` の表示中心、hit判定、highlight / markerは内部 `TileMapLayer.map_to_local()` / `local_to_map()` を主基準に寄せる。
- 独自 `hex_to_local()` はCore視覚debugやtoric代表計算で使えるが、Editorで見えているcell操作の仕様根拠にしない。

### 5. `HexTileMapLayer extends TileMapLayer` の評価

`HexTileMapLayer` は現在 `Node2D` wrapperとして、base `TileMapLayer`、loop duplicate用 `TileMapLayer`、前面overlay childを管理する。これにより、Godot標準TileMap editorのpaint操作とaddon独自のmanual edit inputを分けられる。

`HexTileMapLayer` 自体を `TileMapLayer` 継承にすると、Godot標準 `TileMapLayer` として選択・編集される表面が増え、addonのTarget解決、内部loop表示、overlay表示、document payload表示と干渉しやすい。`TileMapLayer` の機能を利用する目的には、継承よりも内部childをauthoritative displayとして使う構成の方が現在の課題に合っている。

判定:

- 短期計画では `HexTileMapLayer extends TileMapLayer` は採用しない。
- 長期計画では、Resourceをper-clickの主データ経路にせず、`HexTileMapLayer` 内部stateと内部 `TileMapLayer` をincremental同期する構成を検討する。

## 分類

| 項目 | 種別 | 対応方針 |
| --- | --- | --- |
| Target Reloadだけで編集不能 | 初期化UX / state同期不足 | Target `HexTileMapLayer.hex_map` から未保存documentを初期化する。 |
| per-click反映が重い | 性能問題 | 全量document複製 / 全量redrawを減らし、cell単位applyへ段階移行する。 |
| Target Autoが先頭layerを選ぶ | Target解決bug / UX不一致 | 選択中 `HexTileMapLayer` を優先し、plain `TileMapLayer` を通常Targetから外す。 |
| Generator Targetにもplainが混ざる | UX一貫性課題 | Primary targetを `HexTileMapLayer` 中心に再設計し、Overlayは別扱いで検討する。 |
| 座標ずれ / padding蓄積 | 表示座標系bug | 内部 `TileMapLayer.local_to_map()` / `map_to_local()` を表示操作の基準にする。 |
| Resource外部化の重さ | アーキテクチャ課題 | Resourceを永続化snapshotに寄せ、live editはlayer内部stateで扱う別計画を作る。 |

## 計画化

短期のTarget初期化・Auto・座標・軽量化:

- UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_UX_2026-06-03.md`
- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_POLICY_2026-06-03.md`
- Implementation Plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_PLAN_2026-06-03.md`
- Implementation Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md`

長期のTileMapLayer-backedアーキテクチャ:

- UX: `docs/plan/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_UX_2026-06-03.md`
- Policy: `docs/plan/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_POLICY_2026-06-03.md`
- Implementation Plan: `docs/plan/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_PLAN_2026-06-03.md`
- Plan Review: `docs/plan/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_PLAN_REVIEW_2026-06-03.md`

## 参照

- Godot Docs: `TileMapLayer.local_to_map()` / `map_to_local()`: https://docs.godotengine.org/en/4.5/classes/class_tilemaplayer.html
- Godot Docs: `@tool`: https://docs.godotengine.org/en/4.5/tutorials/plugins/running_code_in_the_editor.html
