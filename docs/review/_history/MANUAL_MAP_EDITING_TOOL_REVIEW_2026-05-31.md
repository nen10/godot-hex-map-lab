# MANUAL_MAP_EDITING_TOOL 実装レビュー (2026-05-31)

## 対象

`docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md` および `docs/plan/MANUAL_MAP_EDITING_TOOL_IMPLEMENTATION_PLAN_2026-05-31.md` の要件に対する commit `8c9214c`。

## 総評

`HexMapDocumentResource`（map + tile_overrides + objects + labels）と `HexMapDocumentAdapter`（編集操作 helper）、`HexObjectDatabaseResource` / `HexLabelDatabaseResource`（定義 database）、`HexMapEditTool`（Editor Dock）が追加された。変更は11ファイル +1426行と最大規模。

resource-primary な編集 tool の初期実装として、document の roundtrip、wall/floor/tile override/object/label の cell 単位編集、UndoRedo action、Generate Dock からの import が揃っている。全テストパス。

---

## 当初の要件より優れている実装

### 1. `HexMapDocumentAdapter.duplicate_document()` / `copy_document_state()` による UndoRedo snapshot
Plan では「対象entry単位のbefore / after snapshot」が仕様化されていたが、実装は document 全体の deep copy による前状態保存を採用している。`duplicate_document()` が map resource の roundtrip 複製 + tile_overrides/objects/labels の deep copy を行い、UndoRedo action の undo 側で `copy_document_state(target, before)` によって完全復元する。cell 単位の delta undo より実装が単純で、バグの入り込む余地が少ない。

### 2. `set_cell_exists()` が削除時に tile_overrides/objects/labels も除去
cell 削除時に `_remove_cell_payloads(document, hex)` が tile_overrides、objects、labels の3つすべてから該当 cell の entry を削除する。cell が存在しなくなった後の孤立 payload を防ぐ設計。

### 3. `_replace_entry()` / `_remove_entry()` の汎用 key マッチング
`["cell"]`, `["cell", "kind", "item_key"]` のように照合キーを引数で指定する方式で、tile_override の upsert（kind+item_key が同じなら上書き、なければ追加）、object の upsert（cell 単位で一意）、label の upsert（cell 単位で一意）を同じ `_replace_entry()` で実現している。entry 型ごとに個別の CRUD を書かずに済んでいる。

### 4. `map_cell_to_vector()` の追加と roundtrip テスト
`HexMapTileAdapter.vector_to_map_cell()` の逆変換 `map_cell_to_vector()` が追加され、flat-top / pointy-top 両方で roundtrip することを `_test_map_cell_to_vector_roundtrips_offset_cells` が6方向すべて検証している。編集 tool が TileMapLayer の cell 座標から HexVector を復元するために不可欠な基盤。

### 5. `HexMapEditTool` が target layer の Auto 解決を持つ
生成 Dock と同様の `refresh_target_layer_options()` / `selected_tile_map_layer()` / `_find_target_tile_map_layer()` を持ち、編集 tool が独立した Dock として動作できる。

---

## 要件に対する実装の不足

### 1. Editor Plugin としての `forward_canvas_gui_input()` 接続が未実装

Plan では `forward_canvas_gui_input(event)` による viewport click forwarding が仕様化されているが、`hex_map_edit_tool.gd` には `_unhandled_input` や `_gui_input` がなく、click-to-edit の Editor viewport 連携が実装されていない。テストは `click_to_edit(document, hex, edit_mode, payload)` helper の直接呼び出しで検証している。

これは意図的な段階的実装と考えられる。Plan の実装手順 Step 1-4 (document/adapter/dock/picker) までが完了し、Step 5-6 (edit mode mutation, UndoRedo) は helper 経由でテスト可能な状態。Step 7 (TileMapLayer apply to document adapter) は adapter 側で実装済み。forward_canvas_gui_input 接続は Plugin 側 (`plugin.gd`) との統合が必要な次のステップ。

### 2. `apply_to_tile_map_layer()` が floor/wall の source_id/atlas_coords を options から受け取る

Plan では Dock に Tile payload controls (source_id, atlas_coords, alternative_tile) を持つことが仕様化されているが、`HexMapEditTool._tile_payload` はあるものの、apply 時に使う floor/wall の default tile 設定を指定する UI が未実装。`options` Dictionary 経由で `floor_source_id` 等を渡す設計になっているが、Dock 上の control と結線されていない。

---

## UI 上の改善点

### 1. Dock の縦長レイアウト

`HexMapEditTool._build_ui()` は document path/load/save、import path/import、export path/export、target layer picker、edit mode、object/label database picker、tile payload controls (4 spinners)、object payload (2 edits)、label payload (2 edits)、status label を縦一列に配置する。Dock の高さがかなり必要になるため、折りたたみセクションまたはタブ切り替えの検討余地がある。

### 2. Edit mode が wall/floor tile ペイロードと object/label ペイロードを同時表示

すべての edit mode で tile payload controls (source_id, atlas_x, atlas_y, alternative_tile) が表示されている。Object モードや Label モードではこれらの control は無関係であり、非表示または disabled にすると操作性が向上する。

### 3. Status label が1行のみ

import 成功/失敗、save 成功/失敗、UndoRedo 結果がすべて同じ status label に上書きされる。操作履歴が残らないため、前の操作の成否を確認できない。

---

## 機能・コード上の改善点

### 1. `set_cell_exists()` が cell 追加時に `_ensure_map(document)` を呼ぶが、cell 削除時は呼ばない

`document.map == null` の状態で cell 削除が呼ばれた場合、`document.map.to_map_data()` が null アクセスになる。実際には cell 追加が先に走るため発生しにくいが、防御的でない。

### 2. `import_map_resource_from_path()` の `load()` が型安全でない

```gdscript
var resource = load(actual_path)
if not resource is HexMapResource:
```

`load()` は Resource 型を返すが、ファイルが存在しない場合は null を返す。null は `is HexMapResource` で false になるためエラーハンドリングは通るが、null の場合は「ファイルが存在しない」というより具体的なエラーメッセージを出せる。`ResourceLoader.exists()` での事前チェックがあると親切。

### 3. `_tile_payload` / `_object_payload` / `_label_payload` が Dock のフィールドとして露出

これらの payload は `@export` されていない内部 state であり、Dock の Inspector からは見えない。しかし、public メソッド `click_to_edit(document, hex, edit_mode, payload)` が外部から任意の payload を受け取るため、呼び出し元が意図しない payload 形式を渡す可能性がある。型チェックやバリデーションは現状 caller 任せ。

### 4. `_undo_redo` が外部注入依存

`set_undo_redo(undo_redo)` で EditorPlugin から `EditorUndoRedoManager` を受け取る設計。headless test では `_undo_redo` が null のままでも `click_to_edit()` が動作するよう `if _undo_redo != null` ガードが入っている。これはテスト容易性のための意図的な設計だが、UndoRedo なしの編集が発生しうることを呼び出し元が認識する必要がある。

---

## テストに対する評価

| 計画のテスト | 実装 |
|-------------|------|
| adapter: document roundtrip (map + payloads) | ✅ `_test_hex_map_document_roundtrips_map_and_payloads` |
| adapter: wall/floor edit → map data | ✅ `_test_hex_map_document_adapter_updates_wall_floor` |
| adapter: tile override → TileMapLayer | ✅ `_test_hex_map_document_adapter_applies_tile_overrides` |
| editor: dock controls build | ✅ `_test_map_edit_tool_builds_dock_controls` |
| editor: import generated resource → document | ✅ `_test_map_edit_tool_imports_generated_map_resource` |
| editor: click + UndoRedo | ✅ `_test_map_edit_tool_click_updates_document_with_undo_redo` |
| editor: local hit uses HexTileMapLayer | ✅ `_test_map_edit_tool_local_hit_uses_hex_tile_map_layer` |
| adapter: map_cell_to_vector roundtrip | ✅ `_test_map_cell_to_vector_roundtrips_offset_cells` (追加) |

全8テスト充足。`forward_canvas_gui_input` 連携は editor workflow test（手動確認）として plan に残っている。

---

## 不明点

### 1. `tile_overrides` の `item_key` フィールドの用途

Schema には `item_key: String` があるが、`set_tile_override()` の remove 条件は `source_id < 0` のみで、`item_key` は remove 条件に使われていない。また `apply_to_tile_map_layer()` でも `item_key` は使われず、tile_overrides の `kind` だけが floor/wall の一致判定に使われる。`item_key` は overlay item との関連付けを意図した将来拡張用と考えられるが、現時点では未使用フィールド。

### 2. object / label database と document の接続

`HexMapDocumentResource.objects` と `HexObjectDatabaseResource.objects` は同じ key 名だが、前者は配置結果（cell 単位の `{cell, object_id, properties}`）、後者は定義（`{object_id, display_name, default_properties}`）と役割が異なる。混同を避けるため、命名の区別（例: `placements` vs `definitions`）を検討する余地がある。
