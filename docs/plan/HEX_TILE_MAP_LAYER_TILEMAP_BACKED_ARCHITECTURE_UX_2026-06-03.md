# HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_UX_2026-06-03.md

## 対象

- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_PERFORMANCE_REVIEW_2026-06-03.md`
- Related short-term plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_PLAN_2026-06-03.md`

## 目標UX

`HexTileMapLayer` はGodot上のhex map編集対象として、内部 `TileMapLayer` の表示性能と座標APIを使いながら、addon固有のhex map semanticsを保持する。Resourceは保存・読み込み・export用のsnapshotであり、1clickごとのlive edit経路は `HexTileMapLayer` 内部stateと内部 `TileMapLayer` のincremental同期で完結する。

## Operation Steps 素案

1. ユーザーはSceneに `HexTileMapLayer` を1つ置く。
2. Generator DockでPrimary mapを生成し、選択中 `HexTileMapLayer` にapplyする。
3. `HexTileMapLayer` は内部stateと内部 `TileMapLayer` を更新し、Resource保存なしでviewport表示を維持する。
4. Edit Dockで同じ `HexTileMapLayer` をTargetにし、cellを編集する。
5. 編集は対象cellまたは必要最小範囲だけを更新し、viewportで即時確認できる。
6. Save / Export時に、`HexTileMapLayer` の内部stateから `HexMapResource` または `HexMapDocumentResource` を生成する。
7. Load / Import時はResourceから `HexTileMapLayer` 内部stateを復元する。
8. Overlay要Tile / Object / Labelも、表示layerやoverlay childとして `HexTileMapLayer` 配下にまとまる。

## Operation Steps 評価

| Step | 評価 | 目標 |
| --- | --- | --- |
| 1 target配置 | 有用 / 維持 | `HexTileMapLayer` をユーザーが扱う唯一のPrimary map nodeにする。 |
| 2 generation apply | 有用 / 維持 | Generatorから直接表示できる体験を維持する。 |
| 3 live state | 有用 / 追加 | Resource保存に依存せず、layer内部で表示とsemantic stateを保持する。 |
| 4-5 manual edit | 有用 / 維持 | 対象cellの即時編集を軽くする。 |
| 6-7 persistence | 有用 / 維持 | Resourceはsnapshot / interchangeとして維持する。 |
| 8 overlay統合 | 有用 / 追加 | Primary / overlay / markerを1つのnode配下で扱えるようにする。 |

## 干渉するUX

### 維持するUX

- `HexMapResource` / `HexMapDocumentResource` による保存・読み込み・exportを維持する。
- `HexMapTileAdapter` のCore adapter機能を維持する。
- `HexTileMapLayer` のloop display、toric visual duplicate、path、highlightを維持する。

### 代替・廃止するUX

- Resourceをlive edit中の主データ経路にするUXは廃止候補にする。
- plain `TileMapLayer` をPrimary map編集nodeとして扱うUXは廃止候補にする。
- `HexTileMapLayer` を `TileMapLayer` と同じGodot標準TileMap editor対象として操作するUXは採用しない。

## Hack扱い

- Resourceを毎click複製して全量applyすることでviewport反映する手順はhackであり、性能設計の仕様根拠にしない。
- plain `TileMapLayer` の既存cellからwall / floor semanticsを推測し続ける手順はhackであり、Primary map編集の仕様根拠にしない。

## 成功条件

- `HexTileMapLayer` が内部stateから `HexMapResource` / `HexMapDocumentResource` を出力できる。
- Generator Primary apply、Edit Dock apply、Save / Exportが同じ内部stateを扱う。
- per-click編集は全量document複製 / 全量tile redrawに依存しない。
- 内部 `TileMapLayer` の `set_cell()` / `local_to_map()` / `map_to_local()` を表示・座標基準として活用する。
- Overlay tile / marker / labelの表示責務が `HexTileMapLayer` 配下に整理される。
