# REVIEW_TRIAGE_2026-06-02.md

## 目的

`docs/plan/REVIEW_BACKLOG_2026-06-02.md` から分離した、機能開発候補ではないレビュー由来項目を管理する。

この文書は実装候補一覧ではない。ユーザー確認事項、保留中の調査課題、除外項目、完了項目、抽出元レビューの扱いを残すための整理台帳である。

## ユーザー確認事項

1. `_loop_tile_map` のscene save / reload roundtripを検証する。
   - 説明: loop copy layerはinternal childとして追加される。scene保存・再読み込み時にduplicate childが増えないこと、base/copy layer識別が維持されることを確認する。
   - Evidence: `MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md`
   - 確認候補: `PackedScene.pack()` / instantiate後のinternal TileMapLayer数、tile_set共有、duplicate tile表示。

2. debug sceneのloop path / cell hit操作を手動確認項目として維持する。
   - 説明: headless testはtoggle stateとデータを確認するが、`L` / `C` / `P` の実キー操作と見た目はEditor/debug画面で確認する必要がある。
   - Evidence: `RUNTIME_INTERACTION_LOOP_PATH_REVIEW_2026-05-31.md`
   - 確認候補: `tools/debug_generated_map.sh` で path連続性、cell hit表示、duplicate tile表示を観察する。

3. `GENERATED_MAP_MANUAL_EDIT` analog testを再実行可能な状態に保つ。
   - 説明: 旧analog resultはStep 14 failを記録している。実装修正後もユーザーから「Dock statusは出るがviewport変化が見えない」と報告されているため、再実行時の観察項目を追加する価値がある。
   - Evidence: `GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md`, `MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md`
   - 確認候補: click後のstatus、target tile coords、save/export result、Source Registry reload。

4. Editor analog testの実行結果を記録する。
   - 説明: `HEX_TILE_MAP_LAYER_MANUAL_EDIT_VIEWPORT_DEBUG_RELIABILITY_ANALOG_TEST_2026-06-02.md` はTarget Reload、dialog、Overlay Tile、遠端cell、Copy Debug Reportを確認する手順へ更新済みだが、実Editorでの実行結果文書は未確認である。
   - Evidence: `HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_REVIEW_2026-06-02.md`, `HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md`, `EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - 確認候補: 実Editor観察ログ、Copy Debug Report paste結果、標準TileMap panel表示、dialog表示、scene save / reload。

5. analog test内の固定 `.godot_user` path例を任意pathへ寄せる。
   - 説明: 通常テストの並列実行対象ではないが、同じ手順を複数回または複数人で実施する場合、固定pathは衝突しやすい。
   - Evidence: `UI_HEADLESS_TEST_UX_RELEVANCE_REVIEW_2026-06-05.md`
   - 確認候補: analog testのPreconditionsにrun-specific pathを指定する。

6. 大きめmapでmanual edit体感と処理時間を確認する。
   - 説明: headless testでは `apply_document_cell()` と全量 `_redraw()` に戻らないことを確認済みだが、Godot Editor上でのclick体感、hover/highlight、表示blinkの有無は未記録である。
   - Evidence: `HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_REVIEW_2026-06-05.md`, `HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - 確認候補: 961 cell程度のmanual wall/floor/tile edit、Undo / Redo、Overlay applyでLast Editと表示blink有無を観察する。

7. Direct Atlas Browseを任意tile size importへ拡張するか判断する。
   - 説明: 現状のAtlas Browseはsample / preset互換画像をすばやくTarget TileSetへ設定する補助入口である。任意tile size atlasはGodot標準TileSet画面を主経路とする限り、tile size selectorは必須ではない。
   - Evidence: `EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - 確認候補: 標準TileSet画面経由のcustom atlas、Direct Browse経由のsample-compatible atlas。

8. 任意tile sizeの扱いをUXとして確認する。
   - 説明: 任意tile sizeは共通TileSet機能により補完済み。Direct Atlas Browseを主経路にしない限り、追加実装ではなくユーザーによるUX検証のみ必要。
   - Evidence: `EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`

## 保留中の調査課題

1. Crop Retained Recalculationの既存planを実装するか、使用感確認まで保留するか判断する。
   - 説明: `docs/plan/pending/CROP_RETAINED_RECALC_POLICY_2026-05-31.md` と implementation plan は残っている。一方、ユーザー追記では「使用感が報告されていない状況で検討が先走っている」とされている。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`, `docs/plan/pending/CROP_RETAINED_RECALC_POLICY_2026-05-31.md`
   - 戻す条件: retained modeのユーザー価値が確認され、通常modeとの操作差がDesign Flowとして閉じる。

2. Object専用layerとscene object配置はGodot開発UXの調査後に扱う。
   - 説明: `Object` modeはdocument payload / marker表示として維持されているが、ユーザー作成Node / scene、`TileSetScenesCollectionSource`、object専用 `TileMapLayer` は未設計である。
   - Evidence: `HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md`, `HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - ユーザー意見: Godotでの標準的なLayer使用の実践について十分な調査及びユーザーヒアリングが必要。TileMapとObjectノード配置に関する開発UXの解像度が不足しており、実装計画段階には及ばない。最適な実装に向けて、現実装に紛れ込んでいるObject概念を全て除去することが課題となる。

3. `HexObjectDatabaseResource` のdefinitionとdocument placement命名を分ける。
   - 説明: `HexMapDocumentResource.objects` は配置結果、`HexObjectDatabaseResource.objects` は定義候補であり、同じ名前だと用途が混同しやすい。
   - Evidence: `MANUAL_MAP_EDITING_TOOL_REVIEW_2026-05-31.md`, `ADDITIONAL_REVIEW_NEXT_REQUIREMENTS_2026-05-31.md`, `HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md`
   - 戻す条件: Object概念を維持する方針が決まり、definition / placement のschema境界を設計できる。

4. plain `TileMapLayer` legacy helperの境界を整理するか判断する。
   - 説明: Editor通常UX、Generation Overlay、Core互換testのためにplain `TileMapLayer` 経路が残る。到達可能なUI経路とlegacy helperを明示しておかないと、Target整理時に混乱しやすい。
   - Evidence: `HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md`, `EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - 戻す条件: legacy helperを削除・隔離・明示維持するいずれかの方針が必要になった場合。

5. helper統合は利点が明確になってから扱う。
   - 説明: `_query_direction_*` map helper統合はレビュー候補にあったが、ユーザーは利点が不明と判断している。実装前に重複削減の効果を説明する。
   - Evidence: `HEX_CELL_BUTTON_EDITOR_UI_REVIEW_2026-05-31.md`
   - 戻す条件: helper統合による重複削減、bug減少、設計単純化が説明できる。

6. 完了承認済み機能のmanual / screenshot / section diagramはユーザー要望後に作る。
   - 説明: Source Registry、Query Row、Crop、Deductor、Apply Write、Generate HistoryまでDockが大きくなっているため、manual化候補はある。ただしmanualは仕様書ではなく、ユーザー要望または完了承認が条件。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`, `docs/policy/ANALOG_TEST_POLICY.md`

7. UI headless testの分割を検討する。
   - 説明: `tests/test_editor_plugin.gd` は広いUI面を1 scriptで順次検証している。将来さらに時間が増える場合は、Edit Dock、Generate Dock、cell panel、Distribution Editorへ分割する。
   - Evidence: `UI_HEADLESS_TEST_UX_RELEVANCE_REVIEW_2026-06-05.md`
   - 戻す条件: test実行時間、失敗時の切り分け、並列化のいずれかが問題になった場合。

## 除外した項目

- Reference Query Row空結果時の警告: ユーザーが不要と判断したため除外。
- Generative Reference ItemKeyの実装不足: レビュー上不足なし。関連計画は完了扱い。

## 完了項目

- Manual Map Editing の実Editor可視化: `docs/complete_on_test/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_IMPLEMENTATION_PLAN_2026-06-02.md` の範囲として完了扱い。
- Runtime loop copy display / manual loop displayの主要要件: `docs/complete_on_test/実施順序_2026-06-01.md` の範囲として完了扱い。
- Hex Cell Button Editor UIの主要要件: Codex対応結果とテスト通過により完了扱い。theme追従やdense panel境界hitなど用途依存の改善だけ backlog に残す。
- floor / wall default tile apply設定: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_IMPLEMENTATION_PLAN_2026-06-02.md` と `tests/test_editor_plugin.gd` の default tile settings確認により完了扱い。
- `tile_overrides.item_key` の扱い: overlay tileが `kind=overlay` と `item_key` を持つdocument tile overrideとして実装され、`tests/test_editor_plugin.gd` で保存・表示が確認されているため完了扱い。
- Hex Map Edit Dock follow-upの主要要件: scroll container、Target Auto、Default Floor / Wall tile settings、generation dock tab name、HexTileMapLayer payload display、Last Edit traceは `HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_IMPLEMENTATION_REVIEW_2026-06-02.md` の範囲で完了扱い。
- Viewport debug reliabilityの主要要件: Copy Debug Report、invalid click復帰、内部display layer除外、前面overlay、tile size / hit同期、EditorUndoRedoManager error回避は `HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_REVIEW_2026-06-02.md` の範囲で完了扱い。
- Target初期化・座標系の主要要件: Target Reloadからのtarget由来document、`HexTileMapLayer` 優先Target、内部 `TileMapLayer.map_to_local()` / `local_to_map()` 基準、Target TileSet操作は完了扱い。
- Target TileSet / atlas sourceのscene保存 / reload永続性: `display_tile_set_resource` と `tests/test_hex_tile_map_layer.gd` の `PackedScene.pack()` / instantiate確認により完了扱い。
- File / resource selectionの主要要件: Document / Import Map / Export / Atlas ImageのBrowse / Save As、`Select Internal TileMapLayer`、Target由来documentの保存状態、Overlay Tile payload mode分離は `EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md` の範囲で完了扱い。
- UI headless testの方針追加と並列実行基盤: `docs/policy/TEST_DESIGN_POLICY.md`、`tools/test.sh` の `TEST_JOBS` / test run directoryにより完了扱い。
- `apply_document_cell()` の全量document / resource変換を通常per-click経路から外す対応: `HexTileMapLayer` command APIと `tests/test_editor_plugin.gd` のcounting testにより完了扱い。

## 抽出元レビューと扱い

| Source | 扱い |
| --- | --- |
| `docs/review/_history/BRAINSTORM_OPEN_TOPICS_2026-05-30.md` | backlog / triageへ抽出 |
| `docs/review/_history/BRAINSTORM_OPEN_TOPICS_PLAN_REVIEW_2026-05-31.md` | Public sample候補とpending plan注意へ抽出 |
| `docs/review/_history/ADDITIONAL_REVIEW_NEXT_REQUIREMENTS_2026-05-31.md` | backlog / triageへ抽出。完了済み実Editor可視化とloop/manual主要要件は除外 |
| `docs/review/_history/GENERATIVE_REFERENCE_ITEMKEY_REVIEW_2026-05-31.md` | Core / Adapter Maintainabilityへ抽出 |
| `docs/review/_history/RUNTIME_INTERACTION_LOOP_PATH_REVIEW_2026-05-31.md` | Runtime候補と確認事項へ抽出 |
| `docs/review/_history/RUNTIME_MANUAL_LOOP_DISPLAY_PLAN_REVIEW_2026-05-31.md` | 完了済みloop/manual主要要件として整理済み |
| `docs/review/_history/MANUAL_MAP_EDITING_TOOL_REVIEW_2026-05-31.md` | Object関連は保留調査へ抽出。viewport inputは完了済みとして除外 |
| `docs/review/_history/MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_PLAN_REVIEW_2026-06-01.md` | 完了済み実Editor可視化として整理済み |
| `docs/review/_history/MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md` | Runtime確認事項へ抽出。実Editor可視化は完了済みとして除外 |
| `docs/review/_history/GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md` | analog確認事項へ抽出。実Editor可視化は完了済みとして除外 |
| `docs/review/_history/GENERATED_MAP_MANUAL_EDIT_FAILURE_ANALYSIS_2026-06-01.md` | 完了済み実Editor可視化として整理済み |
| `docs/review/_history/GENERATED_MAP_MANUAL_EDIT_CODE_READING_2026-06-01.md` | analog確認事項へ抽出 |
| `docs/review/_history/HEX_CELL_BUTTON_EDITOR_UI_PLAN_REVIEW_2026-05-31.md` | Query Row / Hex Cell Editor UIへ抽出 |
| `docs/review/_history/HEX_CELL_BUTTON_EDITOR_UI_REVIEW_2026-05-31.md` | Query Row / Hex Cell Editor UIと保留調査へ抽出 |
| `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_REVIEW_2026-06-02.md` | 主要要件は完了済みとして除外。Object / Label本格表示は保留調査へ抽出 |
| `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_IMPLEMENTATION_REVIEW_2026-06-02.md` | 主要要件は完了済みとして除外。UI密度やmarker surrogateの将来課題は backlog / triageへ抽出 |
| `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_REVIEW_2026-06-02.md` | 主要要件は完了済みとして除外。実Editor観察は確認事項へ抽出 |
| `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_REVIEW_2026-06-02.md` | 実Editor視認性、clipboard paste、Undo stack統合を backlog / triageへ抽出 |
| `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_PERFORMANCE_REVIEW_2026-06-03.md` | 短期要件は完了済みとして除外。large map performance、state境界、Object / layer課題を backlog / triageへ抽出 |
| `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md` | File/resource selection実装で完了した項目は除外。remaining項目を backlog / triageへ抽出 |
| `docs/review/_history/HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md` | Object関連の保留調査へ抽出 |
| `docs/review/_history/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_REVIEW_2026-06-05.md` | HexTileMapLayer stateとordered overlayへ抽出 |
| `docs/review/_history/EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md` | 完了済みfile/resource選択項目は除外。Save / status / invalid resource / analog確認を backlog / triageへ抽出 |
| `docs/review/_history/UI_HEADLESS_TEST_UX_RELEVANCE_REVIEW_2026-06-05.md` | policy / runner完了項目は除外。analog path、test split、technical guard整理をtriageへ抽出 |
