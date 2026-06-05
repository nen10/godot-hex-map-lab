# EDITOR_DOCK_FILE_RESOURCE_SELECTION_UX_2026-06-05

## 対象

- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_REVIEW_2026-06-05.md`
- Completed implementation plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_PLAN_2026-06-03.md`
- Completed policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_POLICY_2026-06-03.md`
- Completed UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_UX_2026-06-03.md`

## 目標UX

Editor Plugin内のファイルpath / resource指定は、通常操作ではBrowse、Save dialog、Directory dialog、ResourcePickerで選べる。`LineEdit` への直接path入力は、既知pathを貼るadvanced操作として残す。ユーザーは `Atlas Image` だけでなく、Document load / save、Import Map、Export、Source Registry、Generate Historyなどのpath指定でも同じ操作感と状態表示を得る。

Target由来document、Target TileSet、Overlay Tile payload、標準TileMap連携は、path選択と同じStatus上で現在値・未保存状態・無効理由を確認できる。

## 入力対象の棚卸

### Hex Map Edit Dock

- Document: `HexMapDocumentResource` のload / save path。
- Import Map: `HexMapResource` のimport path。
- Export: `HexMapResource` のexport path。
- Target TileSet: `TileSet` resource picker。
- Atlas Image: image resource path。
- Object Database: `HexObjectDatabaseResource` picker。
- Label Database: `HexLabelDatabaseResource` picker。
- Overlay item key: direct textに加え、document内候補から選べる状態。
- Select Display Layer: 内部 `TileMapLayer` をEditor selectionへ送る補助操作。

### Hex Map Generation Dock

- Save `.tres`: `HexMapResource` / `HexOverlayResource` 保存先。
- Select Atlas Image: image resource path。
- Source Registry: `HexMapResource` / `HexOverlayResource` load / reload path。
- Generate History: resource directory path。
- Distribution Editor: distribution `.tres` load / save path。

## Operation Steps 素案

1. ユーザーはEdit DockでDocument rowのBrowseを押し、保存済み `HexMapDocumentResource` を選んでLoadする。
2. ユーザーはDocument rowのSave Asを押し、Target由来documentを `.tres` として保存する。
3. ユーザーはImport Map rowのBrowseを押し、`HexMapResource` を選んでImportする。
4. ユーザーはExport rowのSave Asを押し、現在documentを `HexMapResource` として保存する。
5. ユーザーはAtlas Image rowのBrowseを押し、画像を選んでTarget TileSetへ適用する。
6. Source Registry、Generate History、Generation Save、Select Atlas Imageでも同じ種類のBrowse / Save / Directory dialogを使う。
7. pathが空、resource typeが不一致、Targetがない、TileSet sourceがない場合、該当buttonはdisabledになり、Statusに理由が出る。
8. Target Reloadで作られたdocumentは、`Unsaved target document` として表示される。Save後は保存pathとdocument source状態が更新される。
9. Target StatusにはTileSet resource path、source数、tile size、floor / wall / overlay payload、Overlay visibilityを表示する。
10. `Select Display Layer` は `Select Internal TileMapLayer` として、標準TileMap panel表示を保証する操作ではなくEditor selectionを変える操作だと分かる。
11. Overlay Tile modeでは、Floor / Wall Tileとは別のpayloadを保持し、item key候補から選べる。
12. Scene保存 / reload後もTarget TileSet / atlas sourceが維持されるかを確認し、失われる場合は保存境界を明示する。

## Operation Steps 評価

| Step | 評価 | 目標 |
| --- | --- | --- |
| 1-4 document / map path | 有用 / 追加 | direct path入力に頼らずLoad / Save / Import / Exportできる。 |
| 5 atlas image | 有用 / 追加 | Target TileSetへ画像を適用する通常操作をBrowseへ寄せる。 |
| 6 generation側path | 有用 / 追加 | path選択UXをDock間で揃える。 |
| 7 validation | 有用 / 追加 | 押して失敗するbuttonを減らし、理由をStatusに出す。 |
| 8 target由来document | 有用 / 追加 | 未保存状態とSave後の状態遷移を誤認しにくくする。 |
| 9 Target Status | 有用 / 追加 | TileSet / payload / visibilityの診断情報をまとめる。 |
| 10 standard editor bridge | 有用 / 維持 | Godot標準TileMap画面との接続を、実装実態に合う文言で維持する。 |
| 11 overlay payload | 有用 / 追加 | mode切替時にFloor / Wall / Overlay payloadが混ざる事故を減らす。 |
| 12 scene persistence | 有用 / 追加 | Target TileSet設定がscene保存境界で維持されるか確認する。 |

## 干渉するUX

### 維持するUX

- direct path `LineEdit` はadvanced / paste操作として維持する。
- `EditorResourcePicker` が使えるresourceはpickerを維持する。
- Generation Dockの既存 `EditorFileDialog` 操作は維持し、Edit Dock側へ同じ操作感を展開する。
- Target TileSet境界にassetを置き、documentへasset path / TileSet referenceを保存しない方針を維持する。

### 代替・廃止するUX

- 通常操作としてpathを手入力してからLoad / Applyする前提は廃止候補にする。
- `Select Display Layer` という標準画面を開くように読める文言は、実装実態に合わせて置き換える。
- Overlay TileがFloor / Wall Tileと同じpayload UI状態を共有する挙動は廃止候補にする。

### 分離するUX

- ObjectのNode / scene配置、`TileSetScenesCollectionSource`、object専用layerは、Tile / Overlay画像path選択とは別計画にする。
- `apply_document_cell()` の全量document/resource処理の軽量化は、path選択UXではなくperformance / state差分適用計画に分ける。
- plain `TileMapLayer` legacy helperの内部整理は、Editor通常UXとCore互換の境界整理として別に扱う。

## Hack扱い

- pathを手入力しないと選択できない操作はhackであり、通常UXの仕様根拠にしない。
- ボタンを押してからStatusの失敗文を読むだけのvalidationはhackであり、button disabled / inline statusの代替にしない。
- Target由来documentを保存済みdocumentのように扱う表示はhackであり、未保存状態を隠す仕様根拠にしない。

## 成功条件

- Edit DockのDocument / Import Map / Export / Atlas ImageはBrowseまたはSave dialogから操作できる。
- Generation DockのSource Registry / Generate History / Save / Atlas Imageと、Edit Dockのpath操作に一貫したlabel / disabled / statusがある。
- direct path入力は残るが、通常操作はdialog / pickerで完結する。
- Target由来documentは未保存状態がStatusで分かり、Save後のpathとsource状態が明確になる。
- Target StatusでTileSet resource path、source数、tile size、floor / wall / overlay payload、Overlay visibilityを確認できる。
- Target TileSet / atlas sourceのPackedScene保存 / reload永続性を自動テストまたはanalog testで確認できる。
- Overlay Tile payloadはFloor / Wall Tile payloadとmode別に保持される。
