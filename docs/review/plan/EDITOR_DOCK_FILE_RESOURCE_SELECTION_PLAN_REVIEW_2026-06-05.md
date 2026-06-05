# EDITOR_DOCK_FILE_RESOURCE_SELECTION_PLAN_REVIEW_2026-06-05

## 対象

- UX: `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/UX.md`
- Policy: `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/POLICY.md`
- Implementation Plan: `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/IMPLEMENTATION_PLAN.md`
- Implementation review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md`

## Planning Flow確認

| Step | 文書 | 判定 |
| --- | --- | --- |
| 1. UX の策定 | `UX.md` | Operation Steps、評価、既存UX干渉、hack扱い、成功条件がある。 |
| 2. 実装方針の作成 | `POLICY.md` | 複数候補、採用 / 不採用、破壊的変更、fallback、UX escalationがある。 |
| 3. 詳細な実装計画の作成 | `IMPLEMENTATION_PLAN.md` | 入力、出力、schema、対象ファイル、Test path、analog test候補がある。 |
| 4. 計画のレビュー | 本文書 | 既存UXとの干渉、実装対象の閉じ方、テスト可能性を確認する。 |

## 既存UXとの干渉

### Direct path入力

Browse / Save dialogを通常操作へ寄せても、direct path入力は残る。既存test helper、debug再現、`res://` path貼り付け操作は維持されるため、破壊的影響は小さい。

### ResourcePicker

ResourcePickerを優先しても、pickerが使えないheadless環境では直接setterやfile selected handlerで検証できる。UI実装時はResourcePickerとpath selectorが同じ状態を更新する必要がある。

### Generation Dock

Generation Dockには既に `EditorFileDialog` を使う操作がある。新計画はその挙動を壊さず、StatusとvalidationをEdit Dockと揃えることが中心である。

### Target TileSet

内部 `TileMapLayer.tile_set` を保存境界に置く方針は維持する。ただしscene保存 / reloadで維持されない場合は、`HexTileMapLayer` の保存schemaへ影響する。この場合は計画内の実装手順で明示的に扱う。

## 実装対象の閉じ方

含める:

- Edit DockとGeneration Dockのpath / resource選択UX。
- button disabled / Status / tooltipによる無効理由表示。
- Target由来documentの未保存 / 保存済み状態表示。
- Target StatusのTileSet / payload / overlay診断情報。
- Target TileSet / atlas sourceのPackedScene保存 / reload確認。
- `Select Display Layer` 文言とStatusの修正。
- Overlay Tile payloadのmode別保持とitem key候補。

含めない:

- `apply_document_cell()` の全量document/resource処理の軽量化。
- Object Node / scene layer、`TileSetScenesCollectionSource`、object専用layer。
- plain `TileMapLayer` legacy helperの内部到達経路整理。
- Source Registry一覧そのものの高度な比較 / 検索 / 並べ替えUX。

## テスト可能性

- path selectorのfile selected handler、direct setter、validation、Statusはheadless testで検証できる。
- `EditorFileDialog` の実際の操作感はanalog testで確認する。
- Target TileSetのPackedScene persistenceはheadless testで検証できる。
- 標準TileMap panelが表示されるかはGodot editor UI依存のため、analog testで観察する。
- Overlay payload分離はheadless testでmode切替とpayload値を検証できる。

## 不足と修正

計画はレビュー指摘のうちUX / state表示 / persistence確認を含めている。一方、performance差分適用とObject scene layerは意図的に分離している。これらは実装時に混ぜるとscopeが広がり、path選択UXの完了判定が曖昧になるため、別Planning Flowまたはreview backlogで扱う。

## 判定

Planning Flowとして成立している。`HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE` 計画は主要実装と自動テストが完了しているため、完了扱いにできる。残課題のうちpath / resource選択UXに接続できる項目は本計画に取り込み、接続できない項目は実装レビューへ残項目として明記する。
