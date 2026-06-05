# EDITOR_DOCK_FILE_RESOURCE_SELECTION_POLICY_2026-06-05

## 目標UX

- `docs/complete_on_test/2026-06-05_EDITOR_DOCK_FILE_RESOURCE_SELECTION/UX.md`

## 候補

### 候補A: path / resource選択行を共通化する

採用。

内容:

- label、direct path `LineEdit`、Browse / Save / Dir button、action button、status / tooltipを一つの操作単位として扱う。
- Edit DockとGeneration Dockで同じ文言、filter、validation、disabled規則を使う。
- 共有helperを新規fileにするか、各Dockのfactory関数として実装する。両Dockで重複が増える場合は共有helperを採用する。

理由:

- `Atlas Image` だけを直すと、Document / Import / Export / Historyなどのpath入力UXがばらついたまま残る。

### 候補B: Edit DockのAtlas ImageだけBrowse対応する

不採用。

理由:

- ユーザー指摘の通り、path文字列入力フォームはasset項目以外にも多い。
- 同じ失敗要因が別rowへ残るため、レビュー指摘のUX改善として閉じない。

### 候補C: direct path入力はadvanced操作として残す

採用。

内容:

- `LineEdit` は残し、Browse / Save dialogで選んだpathを反映する。
- pathを貼り付けてEnterまたはaction buttonで実行する操作を維持する。
- 不正pathはbutton disabledまたはStatusで原因を出す。

理由:

- Godot editorでは `res://` pathを貼る操作が有用で、完全削除すると開発時の速度が落ちる。

### 候補D: direct path入力を完全廃止する

不採用。

理由:

- 既知pathを貼る操作、test helper、debug再現手順で不便になる。
- `EditorFileDialog` が使えないheadless testでも、setter / direct path経路は必要である。

### 候補E: ResourcePickerをresource選択の優先UIにする

採用。

内容:

- `HexMapDocumentResource`、`TileSet`、`HexObjectDatabaseResource`、`HexLabelDatabaseResource` は `EditorResourcePicker` を優先する。
- ResourcePickerが使えない環境ではpath selectorをfallbackとして使う。
- ResourcePickerでresourceを選んだ場合も、可能ならresource pathをStatusに出す。

理由:

- Godot標準のresource選択体験を使える。
- `.tres` pathの手入力よりresource typeの誤りを減らせる。

### 候補F: validationとbutton disabledを先に計算する

採用。

内容:

- Document Load / Save、Import Map、Export、Atlas Apply、Source Registry Load、History Dir、Generation Saveごとに必要条件を定義する。
- 条件を満たさないbuttonはdisabledにし、Statusまたはtooltipに理由を出す。
- 保存系は空pathのときSave dialogを開く。direct pathがあるときはそのpathへ保存する。

理由:

- 失敗後Statusだけでは、何を直すべきかが遅れて分かる。

### 候補G: Target由来documentの保存状態を固定する

採用。

内容:

- Target Reloadで作成されたdocumentは `document_source=target` と `dirty=true` 相当をStatusに出す。
- Save成功後は `document_source=save` または `path` 系の状態へ遷移し、保存pathを表示する。
- Export成功は `HexMapResource` 出力であり、document保存とは別に表示する。

理由:

- Targetの `hex_map` にだけ反映されているのか、project assetとして保存されたのかを区別できる。

### 候補H: Target TileSetのscene保存 / reload永続性を仕様化する

採用。

内容:

- `PackedScene.pack()` / reload testで、内部 `TileMapLayer.tile_set`、atlas source、tile size、source idが維持されるか確認する。
- internal child保存が不安定な場合、`HexTileMapLayer` 側のexport propertyまたは明示Resource propertyへTileSet境界を移す。

理由:

- Target TileSet境界にassetを置く方針は、scene保存を跨いで維持できる必要がある。

### 候補I: `Select Display Layer` を実装実態に合わせて改名する

採用。

内容:

- button文言は `Select Internal TileMapLayer` または同等の表現にする。
- 押下後Statusに、Editor selectionを内部layerへ移したこと、Edit Dock Auto targetは親 `HexTileMapLayer` に戻ることを出す。

理由:

- Godot標準TileMap panelを直接開く保証がないため、"open" 相当の表現は誤解を生む。

### 候補J: Overlay Tile payloadをmode別に保持する

採用。

内容:

- Floor Tile、Wall Tile、Overlay Tileそれぞれに最後の `source_id`、`atlas_coords`、`alternative_tile` を保持する。
- Overlay item keyはfree textに加え、document内既存key候補を選べる。
- `Read Target Tiles` / `Apply Target Tiles` がどのmode payloadへ作用するかをStatusに出す。

理由:

- Overlay専用TileSet sourceを使うprojectで、mode切替時にpayloadが混ざるリスクを減らせる。

### 候補K: Object scene layerをこの計画へ含める

不採用。

理由:

- Objectは画像atlas選択ではなく、Node / scene配置、interaction、game stateの設計を含む。
- `docs/review/HEX_TILE_MAP_LAYER_OBJECT_ASSET_BOUNDARY_REVIEW_2026-06-05.md` の判断通り、別計画で扱う。

## 破壊的変更

- Button文言を実装実態に合わせて変更する。
- path入力だけを通常操作としていたrowにBrowse / Save / Dir buttonを追加するため、Dock内のlayoutは変わる。
- Overlay Tile payloadはFloor / Wall Tile payloadと共有されなくなる。
- Target由来documentのSave成功後の `document_source` 表示は、既存debug reportの期待値更新を伴う。

## fallback扱い

- direct path入力はfallback / advanced操作として維持する。
- `EditorResourcePicker` が利用できない環境ではpath selectorで代替する。
- `EditorFileDialog` をheadless testで開けない場合、file selected handlerやsetterを直接呼ぶtestで検証する。

## UX Escalation

- path selector helperがDock固有状態を吸収しすぎる場合、共有helperは小さくし、validation定義だけを共通化する。
- Target TileSetがinternal childではscene保存されない場合、`HexTileMapLayer` の保存schema変更をこの計画内で明示的に扱う。
- Source Registryのresource detail表示がpath selectorだけでは不足する場合、Source Registry一覧UXの別計画へescalationする。
- Objectのscene配置やTileSet scene sourceが必要になった場合、Object asset boundary reviewを元に別Planning Flowを作る。
