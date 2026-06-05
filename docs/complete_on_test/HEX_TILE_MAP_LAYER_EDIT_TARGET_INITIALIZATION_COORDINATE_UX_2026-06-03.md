# HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_UX_2026-06-03.md

## 対象

- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_PERFORMANCE_REVIEW_2026-06-03.md`
- Existing completed plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_PLAN_2026-06-02.md`

## 目標UX

`Hex Map Edit` Dockでは、ユーザーがScene上で選択している `HexTileMapLayer` がそのまま編集対象になる。Target Reloadだけで既存表示mapを編集可能なdocumentとして扱い、見えているcellをclickした時に同じcellが軽く反応する。Tile / Overlay表示assetは固定埋め込みではなく、ユーザーがGodot標準TileSet / TileMap画面またはaddon Dockから選択して利用できる。ユーザーはplain `TileMapLayer` と `HexTileMapLayer` の内部表示layerを意識しない。

## Operation Steps 素案

1. Sceneに `HexTileMapLayer` を配置し、Generation Dockまたは保存済みresourceでmapを表示する。
2. ユーザーは表示assetを準備する。候補は、Godot標準TileSet / TileMap画面で作成したTileSetとする。画像ファイルをTileSet化するGodotの規定経路が、edit dockから起動できて、画像・TileSetを設定できる。
3. Scene Treeで `HexTileMapLayer` を選択する。
4. `Hex Map Edit` DockでTargetをAutoのままReloadする、または明示的に対象 `HexTileMapLayer` を選ぶ。
5. Dockは `HexTileMapLayer.hex_map` から未保存documentを自動作成し、Document statusにTarget由来であることを表示する。
6. `Shape`、`Wall / Floor`、`Floor Tile`、`Wall Tile`、`Object`、`Label`、Overlay要Tileで見えているcellをclickする。
7. Clickしたcellまたは対象overlay / markerだけがすぐ反応し、Last Editはdocument / target / displayの差分を報告する。
8. 端のcellや大量cellのmapでも、見えているcell中心とhit cell、highlight / marker中心が一致する。
9. Target候補には通常 `HexTileMapLayer` だけが表示され、内部 `TileMapLayer` とplain `TileMapLayer` はmanual editの通常候補に出ない。
10. Generator Primary applyも `HexTileMapLayer` targetを優先し、plain `TileMapLayer` は互換またはOverlay用として明確に分離される。

## Operation Steps 評価

| Step | 評価 | 目標 |
| --- | --- | --- |
| 1, 3-4 target準備 | 有用 / 維持 | 既存のGeneration / Target Reload操作を維持する。 |
| 2 asset選択 | 有用 / 追加 | Tile / Overlay表示assetを固定埋め込みではなくユーザー選択可能にする。 |
| 5 target由来document | 有用 / 追加 | Import / Loadなしでも既存 `HexTileMapLayer.hex_map` を編集開始できる。 |
| 6-7 軽い編集反映 | 有用 / 追加 | 全Edit Modeでcell / marker / overlay単位更新を優先し、per-click全量redrawを減らす。 |
| 8 座標一致 | 有用 / 維持 | 内部 `TileMapLayer` の表示中心を基準にhit / overlayを一致させる。 |
| 9 manual target簡素化 | 有用 / 追加 | ユーザーが内部layerやplain layerを区別しなくてよいTarget UXへ寄せる。 |
| 10 generator一貫性 | 有用 / 追加 | Primary mapのTarget概念をEdit Dockと揃える。 |

## 干渉するUX

### 維持するUX

- `HexMapResource` import、`HexMapDocumentResource` load / save、Exportを維持する。
- `HexTileMapLayer` のloop display、highlight、payload marker、debug report copyを維持する。
- Core adapterとしてplain `TileMapLayer` apply helperは維持する。
- Godot標準TileSet / TileMap画面で作成したTileSetと、addon Dockから選択するatlas画像の両方をasset準備経路として維持する。

### 代替・廃止するUX

- Manual Editの通常Targetとしてplain `TileMapLayer` を選ぶUXは廃止候補にする。
- 内部 `TileMapLayer` をScene Treeで選択して親 `HexTileMapLayer` を推測する操作は、Auto mappingのみ残し、Target候補としては出さない。
- Target Reload後にImport / Loadを別途要求する操作は廃止する。
- addonが生成したtactics画像を固定default assetとして暗黙利用するUXは廃止候補にする。

### 分離するUX

- Generator Overlay applyは現状plain `TileMapLayer` を使うため、Primary map targetの `HexTileMapLayer` 化と分離して扱う。
- 既存plain `TileMapLayer` adapterのテストはCore互換として維持し、Editor通常UXとは分ける。
- Overlay要Tileのmanual editはGenerator Overlay applyの全面統合とは分け、まず `HexTileMapLayer` 配下のoverlay表示layerに対する単一cell編集として扱う。
- Godot標準TileMap画面との連携強化と、addon Dockへのasset選択UI追加は、Target / TileSet境界で実装する。永続化schemaは増やさない。
- Object表示はTile / Overlay画像asset選択UXから分離し、Node / scene配置の整理として `docs/review/` 側へ移す。

## Hack扱い

- `HexMapResource` importまたはdocument loadでTarget Reload後の編集を回復する手順はhackであり、仕様根拠にしない。
- plain `TileMapLayer` を先頭に置かないことでAutoを回避する手順はhackであり、仕様根拠にしない。
- 独自 `hex_size` を手調整して表示cellとhitを合わせる手順はhackであり、仕様根拠にしない。
- addon内の特定PNGを固定で読み込ませる手順はhackであり、asset選択UXの仕様根拠にしない。

## 成功条件

- 選択中 `HexTileMapLayer` に `hex_map` があれば、Target Reload後にImport / Loadなしでviewport編集できる。
- Target Autoは選択中 `HexTileMapLayer` を優先し、plain `TileMapLayer` を通常Targetとして採用しない。
- `HexTileMapLayer` で見えているcell中心、click hit、highlight / marker中心が一致する。
- `Shape`、`Wall / Floor`、`Floor Tile`、`Wall Tile`、`Object`、`Label`、Overlay要Tileの1cell編集は全量redrawより軽い経路で反映される。
- Generator Primary Targetの候補表示が `HexTileMapLayer` 中心のUXへ整理される。
- Tile / Overlay表示assetを、Godot標準TileSet / TileMap画面とaddon Dockの両方からTarget TileSetへ設定できる。
- 生成済みtactics tile atlasは固定defaultではなく、ユーザーが選択できるsample / preset assetとして表示確認に使える。
