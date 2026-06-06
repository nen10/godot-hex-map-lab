# Hex Map Kit ブレスト / UX評価 / ロードマップ素案

作成日: 2026-06-06  
対象: `godot-hex-map-lab-20260606-180544.zip`  
目的: 現在の生成・編集機能から少し距離を取り、ゲーム開発上自然に必要になる Tile Map 管理機能を広く洗い出し、UX依存関係とロードマップ候補へ落とす。

---

## 0. 現状認識

### 0.1 すでに太い領域

リポジトリは、単なる hex 座標ライブラリではなく、かなり大きな Editor addon になっている。

- `README.md` 上の主対象は Hex 座標、map generation、`.tres` Resource、`TileMapLayer` 反映、`HexTileMapLayer` runtime helper、EditorPlugin dock。
- `plugin.cfg` は `version="0.2.0"`。
- `project.godot` は Godot `4.6` feature を持つ。
- `plugin.gd` は `Hex Map Generate` と `Hex Map Edit` の2つのdockを追加している。
- 大型ファイル:
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`: 3737 lines
  - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`: 2766 lines
  - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`: 1582 lines
  - `addons/hex_map_kit/core/hex_map_generator.gd`: 2177 lines
- `tests/test_editor_plugin.gd` は 3506 lines あり、Editor UXの headless test が非常に濃い。
- `HexMapDocumentResource` は `map / tile_overrides / objects / labels / version` を持つが、`HexObjectDatabaseResource` と `HexLabelDatabaseResource` は現状 `Array` だけの最小定義。

### 0.2 いまの設計の中心

現状は以下の方向に強い。

- procedural generation
- overlay generation
- query row / source registry / crop
- TileMapLayer apply
- manual edit
- runtime helper
- toric / loop display
- debug scene / headless test

逆に、ゲーム制作の「マップ管理」としては、以下がまだ大きく開いている。

- 地形・オブジェクト・イベント・ナビ・見た目の意味論的レイヤー分離
- tile / scene / object asset の catalog 化
- map document の versioning / migration / validation
- movement cost / danger / spawn / biome / region などゲーム側データ
- 大量mapの品質検査とseed比較
- runtime state と authoring state の分離
- 外部フォーマット / sample package / release artifact
- Editor UIの情報設計とパネル分割

---

## 1. 自由ブレスト

### 1.1 Map Document / Level Document

1. `HexMapDocumentResource v2` を作り、地形、overlay、object、label、zone、navigation、metadata を統合する。
2. `HexMapLevelResource` として、authoring map と runtime initial state を分ける。
3. document version migration を持つ。`version=1` から v2/v3 へ変換できる。
4. document validation を持つ。missing tile、unknown item key、orphan object、unreachable spawn を検出する。
5. document summary を標準化する。cells, walls, floors, objects, labels, zones, warnings。
6. map document の dependency list を出す。TileSet、atlas image、scene path、catalog resource、script class。
7. map document の dirty state と unsaved status を dock に出す。
8. saved `.tres` だけでなく、human-readable JSON export を作る。
9. runtime delta resource を作る。破壊された壁、開いた扉、取得済み宝箱などは base map から分離する。
10. replay / seed reproduction 用に generation snapshot を document metadata に保存する。

### 1.2 Layer Stack / TileMapLayer 管理

11. `HexLayerStackResource` を作る。terrain / decoration / object / collision / navigation / overlay / debug などの layer template。
12. Scene tree へ `HexTileMapLayer` root + child `TileMapLayer` 群を一括作成する。
13. Terrain layer、Object layer、Overlay layer、Debug layer を explicit に分ける。
14. layer ごとに `clear/apply/visible/locked/y_sort/z_index` を管理する。
15. layer template: `Tactics`, `Roguelike`, `Exploration`, `Puzzle`, `Strategy`。
16. `TileMapLayer` の plain helper 経路は legacy adapter として隔離する。
17. 既存の `Hex Map Generate` と `Hex Map Edit` dock は Layer Stack を共通 target として扱う。
18. map apply は `apply_document_to_layer_stack()` を主経路にし、単一 `TileMapLayer` apply を下位互換にする。
19. loop duplicate layer は layer stack 内の debug / projection layer として明示する。
20. layerごとの書き込み権限: generator writable, edit writable, runtime readonly など。

### 1.3 Tile Catalog / Asset 管理

21. `HexTileCatalogResource` を作る。logical key から `source_id / atlas_coords / alternative_tile / scene_path / tags` を引く。
22. Floor/Wall の source spin box 群を catalog key selector へ置き換える。
23. Overlay item pool の tile mapping も catalog key selector へ置き換える。
24. `TileSetAtlasSource` と `TileSetScenesCollectionSource` を同じ catalog UI で扱う。
25. tile preview grid を dock に出す。
26. catalog validation: missing source, image too small, invalid atlas coords, scene root not CanvasItem。
27. catalog entry tags: `terrain`, `wall`, `water`, `spawn`, `object`, `blocking`, `cost:3`。
28. Godot TileSet custom data layer から `movement_cost`, `blocks_path`, `terrain_kind` を読む。
29. TileSet terrains を使い、wall/floor edge variant を自動接続する。
30. alternative tile を weighted variant として扱う。
31. named tile preset を `res://addons/hex_map_kit/presets/` に置く。
32. asset import wizard: atlas画像を選び、hex orientation / tile size / source id / catalog entries を生成する。
33. TileSetを複数layerで共有する時の clone / external resource policy を明確にする。
34. generated overlayの未定義itemはWall tile fallbackではなく `unmapped item` warning へ寄せる案。
35. fallback表示は開発者向けでなく、ユーザー向けには「未割当」「表示なし」「代替表示」と分ける。

### 1.4 Object / Scene / Gameplay Entity

36. object mode を「marker」から「object placement」へ昇格させる。
37. `HexObjectDatabaseResource` を object definitions にする。`id, display_name, scene_path, tags, default_properties`。
38. object placement は `object_id, cell, rotation/variant, properties, spawn_condition` を持つ。
39. `TileSetScenesCollectionSource` による scene tile 配置を object layer の第一候補にする。
40. ただし多数の床/壁は scene tile にしない。大量地形は atlas のまま。
41. direct scene instance mode も持つ。AI unit / NPC / interactive entity は TileMapLayer 外の `Node2D` child として配置。
42. object group: spawn point, treasure, door, trap, portal, shop, enemy, cover, objective。
43. object property editor: key/value table、enum、resource reference。
44. object validation: duplicate unique object, object on wall, object outside map, missing scene。
45. spawn safety checker: spawn から出口まで到達可能か。
46. door / key / lock graph を map validation する。
47. room / region に object density rule を付ける。
48. object preview icon と actual scene representation を分ける。
49. object placement の Undo/Redo を document と display layer に同期する。
50. object mode は現状の `Array` payload から脱却するまで、公開UXでは実験扱いにする。

### 1.5 Gameplay Semantic Layers

51. Movement cost layer。floor/wall 二値ではなく、草地1、水3、沼5、不可侵など。
52. Unit profile 別 pathfinding。歩兵、飛行、船、壁抜け、敵専用ルート。
53. Dynamic occupancy layer。ユニット、移動中blocker、temporary hazard。
54. Danger / influence / visibility map。
55. Line of sight / field of view。hex ring/disc、遮蔽。
56. Tactical range preview。移動可能範囲、攻撃範囲、効果範囲。
57. Cover / height / elevation layer。hex tactics に重要。
58. Terrain effect rule。fire spreads, water conducts, poison cloud。
59. Region/zone layer。room id、biome id、encounter table、music zone。
60. Script hook per cell。`on_enter`, `on_exit`, `on_turn_start` などは直接セルに持たせすぎず、zone/objectに寄せる。
61. Path query cache。大量unitのための距離場 / flow field。
62. Connectivity profile。floor connectivityだけでなく、profile別 connectivity。
63. Validation: important points are mutually reachable for each movement profile。
64. Debug overlay: movement cost heatmap, component coloring, unreachable markers。
65. Export: gameplay semantic layer を runtime script から簡単に読む API。

### 1.6 Generation Pipeline / Design QA

66. Generation pipeline graph。Shape -> Terrain -> Rooms -> Corridors -> Objects -> Validation -> Export。
67. Generator pass を Resource 化する。`HexGenerationPassResource`。
68. Seed lab。複数seedを一括生成し、指標で比較。
69. Validation rule suite。連結、spawn到達、object配置、密度、dead-end数。
70. Batch generation history。成功seedだけ残す。
71. Map score dashboard。壁率、平均経路長、分岐数、部屋数、危険度。
72. Golden seed tests。気に入ったseedの結果が壊れない。
73. Constraint solver 風の placement。町、宝、ボス、鍵、出口の距離制約。
74. Biome brush と procedural biome。
75. Pattern/stamp system。部屋、橋、入口、装飾塊を hex pattern として貼る。
76. Generator diff。passごとの変化を可視化する。
77. Undoable generation apply。生成結果を edit document に適用する操作自体を Undo/Redo。
78. Partial generation。選択regionだけ再生成。
79. Lock cells。手描きした重要セルは generator が触らない。
80. Generated vs manual を比較表示する。

### 1.7 Editor UX / 情報設計

81. `Hex Map Workspace` として main screen 化する案。
82. Generate / Edit / Validate / Catalog / Export を tabs に分ける。
83. 生成dockと編集dockの共通状態を `EditorSessionState` に切り出す。
84. `HexMapGenDock` から UI construction と state evaluation を分離する。
85. `HexMapEditTool` から document mutation と viewport input を分離する。
86. `HexMapDocumentInspector` を作り、selected resource の validation summary を出す。
87. map overview mini panel。全体縮小図、selected cell、visible rect。
88. command palette。`Generate`, `Validate`, `Export`, `Show Unreachable`。
89. brush palette。wall/floor/tile/object/zone を同じ入力体系へ。
90. mode-specific toolbar。選択中modeに必要なcontrolsだけ出す。
91. status detail を user-facing と debug-facing に分離する。
92. Copy Debug Report は維持。通常statusは短く、debug report は濃く。
93. Error list はクリックで該当cellへfocus。
94. narrow dock 対応。Source Registry / Query Row は折りたたみ可能にする。
95. keyboard shortcuts。paint, erase, sample tile, toggle wall。
96. brush shapes: single, line, ring, disc, flood fill, random scatter。
97. preview before apply。generator / catalog / validation の結果を overlay preview に出す。
98. compare mode。before/after、seed A/B。
99. selection set。複数cell選択、名前付きselection。
100. マニュアルは「操作目的」単位に再編する。機能列挙ではなく workflow guide。

### 1.8 Runtime / Large Map / Streaming

101. Chunked map document。巨大mapを chunk resource 群に分割する。
102. Lazy tile apply。visible rect だけ TileMapLayer に反映。
103. Infinite map generator。seed + chunk coord で生成。
104. Toric identity と visual representative を runtime API で標準化する。
105. Minimap generation。document から画像を生成。
106. Save/load delta。chunkごとの runtime 差分保存。
107. Runtime editing API。地形破壊、建設、ドア開閉。
108. Multiplayer deterministic map。seed + operations log。
109. Hot reload authoring map。Editorで保存したmapを実行中に再読み込み。
110. Performance dashboard。cell数、drawn tile count、apply time、query time。

### 1.9 Interop / Package / Distribution

111. Tiled / LDtk / JSON import/export。
112. PNG mask import。白黒画像や色画像から terrain/zone を作る。
113. CSV import/export for cells。
114. Godot asset library package。
115. examples/basic_runtime と examples/editor_workflow。
116. API reference を docs/api に分離。
117. addon-only zip と full dev repo を分ける。
118. CI で package manifest を検証。
119. public sample atlas と sample scene。
120. migration guide。v0.2 -> v0.3。

---

## 2. 破棄・保留しやすい案

### 2.1 すぐ破棄寄り

- 全床・全壁を scene tile にする。scene instance が大量になり、地形描画の主経路としては重い。
- Godot標準 TileMap editor を完全置換する。範囲が広すぎる。
- 汎用グラフmap / square grid / isometric grid まで抽象化する。Hex Map Kit の芯が薄まる。
- `TileMapLayer` 外の独自レンダラへ全面移行する。Godot TileSet資産を捨てることになる。
- object / label を現状の `Array` のまま拡張し続ける。後で schema migration が苦しくなる。
- すべてのゲームルールをセルに直接載せる。zone / object / runtime state と責務が混ざる。

### 2.2 保留してよい案

- chunk streaming。現状の cell 数と用途では早い可能性が高い。
- realtime collaborative editing。addonの芯から遠い。
- visual scripting generator graph。Resource pass で足場を作ってからで十分。
- Tiled/LDtk import。公開利用者が見え始めてから優先度を上げる。
- 3D hex mesh。別addon級。
- AI-assisted map generation。まず validation / score dashboard が先。

---

## 3. 大目標候補

### Goal A: Level Document v2

**狙い**  
`HexMapResource` と `HexMapDocumentResource` を、ゲーム制作で保存・検査・実行時ロードできる level document へ育てる。

**必要UX**

1. 新規Map Document作成。
2. 既存 `HexMapResource` import。
3. Layer stack template 選択。
4. Catalog / TileSet / scene dependencies 設定。
5. Validate Map 実行。
6. Save / Export。
7. Runtime load sample で使用。

**依存**

- 現行 `HexMapDocumentResource`
- `HexMapDocumentAdapter`
- `HexTileMapLayer`
- manual edit / import/export
- tests/test_hex_adapter.gd

**干渉**

- 現行 object / label `Array` の曖昧さ。
- plain `TileMapLayer` apply をどこまで正規経路にするか。
- Generate Dock が `HexMapResource` / `HexOverlayResource` を別々に扱う状態。

**評価**

- 有用性: 高
- 実装難度: 中〜高
- UX依存: 全機能の土台
- リスク: schema migration と既存tests更新が大きい

---

### Goal B: Tile Catalog + Layer Stack

**狙い**  
source_id / atlas_coords の数値入力から、ゲーム開発者が理解できる「logical tile / object key」へ移行する。

**必要UX**

1. Catalog resource picker。
2. Catalog entry list。
3. Tile preview。
4. Floor / Wall / Overlay / Object の default assignment。
5. Missing asset validation。
6. Layer stack作成ボタン。
7. Generate / Edit が catalog key で描画。

**依存**

- `HexMapTileAdapter`
- `HexOverlayTileAdapter`
- `HexMapEditTool` の target tile controls
- `HexMapGenDock` の tile settings / item pool tile mapping
- Godot TileSet / TileMapLayer

**干渉**

- 現行の Floor/Wall source SpinBox。
- Item Pool row の `Tile` controls。
- sample tile setup。
- 共有 TileSet clone policy。

**評価**

- 有用性: 非常に高
- 実装難度: 中
- UX依存: Goal A と相互依存
- リスク: TileSet標準編集との責務分界

---

### Goal C: Gameplay Query & Validation Layer

**狙い**  
単なる floor/wall ではなく、ゲーム実装が直接使う movement, range, visibility, spawn, region を Map Kit の価値にする。

**必要UX**

1. Movement profile resource。
2. Cost / blocker / zone layers。
3. Path preview。
4. Range preview。
5. Connectivity validation。
6. Error list to cell focus。
7. Runtime query API sample。

**依存**

- `HexGrid.shortest_path`
- `HexTileMapLayer.find_path`
- overlay / highlight / connected component
- document v2 semantic layers

**干渉**

- 現行 path は floor cell 前提。
- runtime occupancy と authoring map の分離が必要。
- UIが増えすぎるため Validate / Debug tab が必要。

**評価**

- 有用性: 非常に高
- 実装難度: 高
- UX依存: Goal A, B 後が望ましい
- リスク: ゲームジャンルごとの要件差

---

### Goal D: Object / Scene Placement

**狙い**  
object mode を marker から、実ゲームで配置できる scene / trigger / spawn 管理へ進める。

**必要UX**

1. Object database resource。
2. Scene path / preview icon / tags。
3. Object placement brush。
4. Per-object properties。
5. Object layer display。
6. Validate object placement。
7. Runtime instantiate / export policy。

**依存**

- `HexMapDocumentResource.objects`
- `HexObjectDatabaseResource`
- `HexMapEditTool` object mode
- Godot scene tile or direct instancing
- Tile Catalog / Layer Stack

**干渉**

- 既存 object payload は definition と placement が分かれていない。
- scene tile と direct instance の二系統をどう選ぶか。
- objectの実行時stateを authoring document に混ぜない設計が必要。

**評価**

- 有用性: 高
- 実装難度: 高
- UX依存: Goal A, B
- リスク: Godot標準の scene / TileSet / Node 配置との境界

---

### Goal E: Generation QA / Seed Lab

**狙い**  
生成できるだけでなく、ゲームとして成立する seed を探す・比較する・固定する。

**必要UX**

1. Batch generate。
2. Validation suite。
3. Map score table。
4. Preview thumbnails。
5. Promote seed to document。
6. Pass/fail rule editor。
7. Golden seed tests。

**依存**

- Existing generation core
- Generate History
- validation layer
- document metadata

**干渉**

- current Generate Dock は単発生成中心。
- validation rule が固まっていないと score が薄い。
- UIを dock に詰め込むと破綻する。

**評価**

- 有用性: 高
- 実装難度: 中〜高
- UX依存: Goal C があると強い
- リスク: batch UI と performance

---

### Goal F: Editor Architecture Refactor

**狙い**  
大型dockを増築し続けず、機能追加に耐える設計へ移す。

**必要UX**

1. 既存UXを壊さない。
2. Generate/Edit共通 target state。
3. Document/session stateの分離。
4. Dock UI と mutation logic の分離。
5. Viewport input adapter の分離。
6. Debug report維持。
7. testsの意味を維持したまま分割。

**依存**

- すべてのEditor機能
- `tests/test_editor_plugin.gd`

**干渉**

- 大規模。
- 直接価値は見えにくいが、後続機能の速度を決める。

**評価**

- 有用性: 高
- 実装難度: 高
- UX依存: 先にやるほど後が楽
- リスク: regression

---

## 4. UX依存関係

```text
F. Editor Architecture Refactor
  ├─ A. Level Document v2
  │   ├─ B. Tile Catalog + Layer Stack
  │   │   ├─ D. Object / Scene Placement
  │   │   └─ C. Gameplay Query & Validation Layer
  │   │       └─ E. Generation QA / Seed Lab
  │   └─ Runtime load / export samples
  └─ Existing Generate/Edit UX safety
```

別の見方:

```text
Map管理の中心
  A. Document schema
    B. Asset identity
      D. Object identity
    C. Gameplay semantics
      E. QA and generation selection
  F. Editor architecture は全部を支える土台
```

---

## 5. ロードマップ素案

### Phase 0: 現状棚卸しと設計境界の確定

成果物:

- `docs/review/roadmap/HEX_MAP_MANAGEMENT_BRAINSTORM_2026-06-06.md`
- `docs/review/roadmap/CURRENT_CAPABILITY_MATRIX_2026-06-06.md`
- `docs/review/roadmap/RISK_REGISTER_2026-06-06.md`

実施項目:

1. 現行Generate/Edit/Runtime/Documentの capability matrix を作る。
2. plain `TileMapLayer` 経路と `HexTileMapLayer` 経路を分類する。
3. object / label / overlay tile の現行schemaを「維持 / 廃止 / migration」に分類する。
4. Godot TileSet / scene tile / custom data / terrain の採用境界を書く。
5. Godot実行環境で `tools/test.sh` を基準確認する。

### Phase 1: Level Document v2 設計

成果物:

- `docs/plan/<date>_LEVEL_DOCUMENT_V2/UX.md`
- `docs/plan/<date>_LEVEL_DOCUMENT_V2/POLICY.md`
- `docs/plan/<date>_LEVEL_DOCUMENT_V2/IMPLEMENTATION_PLAN.md`

実施項目:

1. `HexMapDocumentResource v2` の schema 草案。
2. `terrain_layers`, `overlay_layers`, `object_placements`, `labels`, `zones`, `metadata`, `dependencies` を定義。
3. v1 -> v2 migration helper。
4. document summary / validation result schema。
5. tests: roundtrip, migration, missing dependency, object placement cleanup。

### Phase 2: Tile Catalog + Layer Stack MVP

成果物:

- `HexTileCatalogResource`
- `HexTileCatalogEntry`
- `HexLayerStackResource`
- catalog-backed apply adapter

実施項目:

1. Floor/Wall/Overlay item key を catalog key で引く。
2. source_id / atlas coords spin boxes は advanced fallback へ移す。
3. sample catalog resource を作る。
4. `HexTileMapLayer` child layers の role 名を明示。
5. validation: unmapped item / missing tile / missing TileSet。
6. tests: catalog entry apply, sample catalog, layer stack create, existing document apply。

### Phase 3: Validation Dashboard

成果物:

- `HexMapValidationResult`
- Validate tab / panel
- error-to-cell focus

実施項目:

1. document dependency validation。
2. cell validation: outside map, orphan payload, missing catalog, object on wall。
3. gameplay-free validationから開始。
4. error list UI。
5. Copy Debug Report に validation summary 追加。
6. tests: validation rule cases。

### Phase 4: Gameplay Query Layer MVP

成果物:

- `HexMovementProfileResource`
- `HexGameplayLayerData`
- path/range/connected validation API
- debug overlay

実施項目:

1. movement cost / blocker layer。
2. weighted pathfinding。
3. movement range preview。
4. profile別 reachability validation。
5. path debug overlayをdocument semantic layerへ接続。
6. runtime sample script。

### Phase 5: Object / Scene Placement MVP

成果物:

- `HexObjectDatabaseResource v2`
- object placement schema
- object layer adapter
- scene tile or direct instance prototype

実施項目:

1. object definitions と placements を分離。
2. object editor UI。
3. object layer apply。
4. scene tile prototype。
5. direct instance prototype。
6. どちらを標準にするかレビュー。
7. validation: missing scene, object on wall, duplicate unique object。

### Phase 6: Generation QA / Seed Lab

成果物:

- batch generation runner
- score table
- seed promotion
- golden seed fixtures

実施項目:

1. validation suite を generation result へ適用。
2. N seeds generate。
3. pass/fail / score sort。
4. thumbnail or ASCII preview。
5. chosen seed を Level Document に promote。
6. tests: deterministic score, golden seed.

### Phase 7: Public Package / Examples

成果物:

- `examples/basic_runtime`
- `examples/editor_workflow`
- `docs/api`
- `tools/package_addon.sh`
- `dist/hex_map_kit-<version>.zip`

実施項目:

1. current pending public package plan を Level Document v2 後の API に合わせて更新。
2. minimal runtime sample。
3. editor workflow sample。
4. package manifest test。
5. README を利用者向けと開発者向けに分ける。

---

## 6. 最初に切ると強い具体的タスク

### Task 1: `CURRENT_CAPABILITY_MATRIX`

目的: 現状の何を残し、何を置換するか迷わないようにする。

項目:

- Core
- Resource
- Adapter
- Generate Dock
- Edit Dock
- Runtime Layer
- Test
- Manual
- Current UX
- Pain
- Future owner goal

### Task 2: `LEVEL_DOCUMENT_V2_UX`

目的: すべての後続機能の土台を作る。

Operation Steps 素案:

1. User creates `HexMapDocumentResource`.
2. User imports/generated terrain map.
3. User selects layer stack template.
4. User assigns tile catalog.
5. User places object / label / overlay.
6. User runs Validate.
7. User saves document.
8. Runtime scene loads document.

### Task 3: `HEX_TILE_CATALOG_POLICY`

目的: source_id / atlas_coords 入力の増殖を止める。

採用候補:

- catalog key を標準UXにする。
- numeric tile fields は advanced/debug に落とす。
- item pool tile config は catalog key を持つ。
- scene tile と atlas tile は catalog entry type で分ける。

### Task 4: `OBJECT_SCHEMA_BOUNDARY_REVIEW`

目的: 現行 object payload を増築して破綻する前に止める。

判定:

- `HexObjectDatabaseResource.objects: Array` は definition schema に置換候補。
- `HexMapDocumentResource.objects` は placement schema に置換候補。
- Object mode は marker/placement/scene instancing のどれかを明示する。

---

## 7. 結論

今の addon は「hex mapを生成・編集できる」段階にはかなり到達している。次の大目標は、生成アルゴリズムをさらに増やすよりも、ゲーム制作で扱う level document と asset identity を固めることが強い。

優先案:

1. Level Document v2
2. Tile Catalog + Layer Stack
3. Validation Dashboard
4. Gameplay Query Layer
5. Object / Scene Placement
6. Generation QA / Seed Lab

実装の前に、現行Generate/Edit/Runtimeの capability matrix を作ると、既存UXを壊すか維持するかの判断が速くなる。
