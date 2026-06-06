# HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md

## 目的

Tile / Overlay asset選択UXのPlanning Flowから、`object atlas` という画像atlas前提の表現を切り離す。Object表示は、画像tileではなくユーザー作成Node / scene配置として扱う余地があるため、今後の判断材料をreview側へ分離する。

## 現状

- `HexMapDocumentResource.objects` は配置情報用のArrayであり、asset画像やTileSet referenceを保存するschemaではない。
- `HexObjectDatabaseResource` は `objects: Array` だけを持ち、画像atlasとしての構造を持たない。
- `docs/review/research/RESEARCH_TILE_MANAGEMENT.md` では、ユーザー作成Node / sceneを `TileSetScenesCollectionSource` でTileMapLayerへ配置する案が整理されている。

## 判断材料

- `object atlas画像` は、Tile / Overlayのatlas tileと同じ扱いにすると意味が曖昧になる。単なる画像spriteならOverlay要Tileまたはmarker表示で足りる。
- ユーザー作成NodeをまとめるContainerや `.tscn` 群であれば、`TileSetScenesCollectionSource`、Object専用 `TileMapLayer`、または `HexTileCatalog` のようなresourceで扱う方が自然である。
- ゲーム進行上のobjectは、表示だけでなくinteraction、trigger、state、spawn/despawn、save/loadを持つため、Tile / Overlay画像asset選択とは別の計画単位にする。

## Planへの反映

- `HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE` 計画では、Tile / Overlay asset選択だけを扱う。
- tactics object画像は同計画の完了条件、schema、test対象に含めない。
- Object mode自体はmanual editの配置payloadとして維持し、Node / scene配置UXは別計画で扱う。

## 後続候補

- Object専用layerを `HexTileMapLayer` 配下へ追加する。
- `TileSetScenesCollectionSource` を使い、ユーザー作成 `.tscn` をhex座標へ配置する。
- `HexObjectDatabaseResource` を、object id、scene path、display layer、gameplay propertiesを持つresourceへ拡張する。
