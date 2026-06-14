# UXファースト清潔仕様ロードマップ 2026-06-07

作成日: 2026-06-07  
対象: `godot-hex-map-lab-20260607-074812.zip`  
参照: `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`  
前提評価: `AUTOPILOT_DEVELOPMENT_EVALUATION_2026-06-07.md`  
目的: autopiloting 実装後に残った互換性・path text・test都合のUI設計を破棄し、未公開addonとしてゲーム開発上合理的なUX/APIへ統一する。

---

## 0. 最重要設計指針

このロードマップでは、以下を上位規則にする。

1. addon は未公開状態である。既存 `.tres`、v0.2/v0.3 intermediate schema、autopilot 中に生まれた互換APIを維持する必要はない。
2. Core の本質機能、つまり hex coordinate / grid / generation / adapter / runtime query の能力は概ね安定している。問題は、それらをゲーム開発者にどう提示するかである。
3. UI 層は柔軟に破壊・再編してよい。
4. UI と API は、headless test の都合ではなく、ゲーム開発上のUX合理性を根拠に設計する。
5. headless test がUX改善を妨げる場合、その test は破壊し、後から新UXに合わせて書き直す。
6. analog test は現時点では作らない。UI再編で印象が改善した後、ユーザー指示により作成する。
7. 互換性より、清潔な仕様・清潔な実装・清潔なテストを優先する。

---

## 1. 現状の問題整理

Autopilot 実装は、当初ロードマップの広い機能群を短期間でつないだ。その成果は大きい。特に、Level Document、Tile Catalog、Layer Stack、Validation、Gameplay Query、Object Placement、Generation QA、Package までの縦通しができている。

ただし、当初の「互換しながら前進する」設計方針が、未公開addonとしては余計な複雑さを生んでいる。

### 1.1 Resource schema が v1/v2 二重構造になっている

確認できる代表例:

```gdscript
# addons/hex_map_kit/adapter/hex_map_document_resource.gd
const VERSION_V1 := 1
const VERSION_V2 := 2

@export var map
@export var tile_overrides: Array = []
@export var objects: Array = []
@export var labels: Array = []
@export var version: int = VERSION_V1

@export var terrain_layers: Array[Resource] = []
@export var overlay_layers: Array[Resource] = []
@export var object_placements: Array[Resource] = []
@export var label_placements: Array[Resource] = []
@export var zones: Array[Resource] = []
```

これは公開済みaddonなら妥当だが、未公開状態では不要である。今後は `v2` ではなく、単に **唯一の `HexMapDocumentResource`** として清潔に定義する。

### 1.2 Compatibility / fallback が仕様に混ざっている

代表例:

- `migrate_v1_to_v2()`
- `ensure_v2_defaults()`
- `catalog_compatibility_warnings()`
- `fallback_source_id`
- `fallback_atlas_coords`
- `fallback_alternative_tile`
- `legacy objects`
- `compatibility single-layer path`

これらは「過去データを救う」ための補助として生まれたが、未公開addonでは過去データ救済を優先する必要がない。今後は fallback を通常仕様から外し、**未割当は validation issue として明示する**。

### 1.3 path text 入力がUXを壊している

現在のUIには `LineEdit` による `res://...` 入力が多く残っている。

代表例:

- document path
- import map path
- export path
- atlas image path
- source registry resource path
- tile catalog `tile_set_path`
- object definition `scene_path`
- dependency `dependency_path`
- runtime sample `document_path`

Godot Editor addon の通常UXとして、ユーザーに `res://...` 文字列を入力させるのは悪い。ユーザーは Resource picker、FileDialog、preview、最近使ったresource、drag & drop、Inspector連携で選べるべきである。

ただし、保存先やエクスポート先のように path が本質的に必要な操作は存在する。その場合でも、**文字列を主入力にしない**。FileDialogで選択し、pathは read-only status として表示する。

### 1.4 NEXT-05 の目的がコード量基準になっている

前回評価では `NEXT-05: Editor file-size containment` を置いたが、「巨大dockへの増築を止める」という表現は不十分である。コード行数はUXの良し悪しを直接決めない。

正しい判断基準は以下である。

- ユーザーの作業目的が同じなら、同じ画面・同じ文脈に置く。
- ユーザーの作業目的が違うなら、UI component / screen / data model を分ける。
- コード分割は、UX上の責務分離を反映する場合に行う。
- 大きいファイルだから分割するのではなく、異なるUX文脈が混ざったら分割する。

したがって、NEXT-05 は **UX情報設計によるEditor再編** として置き換える。

### 1.5 NEXT-04 は必要。ただし analog test ではなく manual 更新として進める

`Catalog / Validation / QA screen manual update` はロードマップに加える。これは analog test ではなく、現行画面・将来画面の操作目的を整理する manual 更新である。

analog test は、UIの印象が改善した時点まで保留する。

---

## 2. 新しい設計方針

### 2.1 Canonical Resource Only

`v1` / `v2` / `legacy` / `migration` という公開概念を廃止する。

今後の公開API・manual・editor UI では以下の語彙を使う。

| 廃止語彙 | 置換後 |
|---|---|
| `HexMapDocumentResource v2` | `HexMapDocumentResource` |
| `ensure_v2_defaults()` | 不要。constructor/default field が常に正規形。 |
| `migrate_v1_to_v2()` | 削除。未公開互換は維持しない。 |
| `legacy objects` | 削除。`object_placements` と `HexObjectDatabaseResource.definitions` のみ。 |
| `compatibility fallback` | 削除。missing assignment は validation issue。 |
| `source_id / atlas_coords` normal UI | catalog entry editor 内の詳細値。通常paint UIには出さない。 |

### 2.2 Resource reference over path string

Resource同士の参照は、文字列pathではなく typed Resource 参照を基本にする。

| 現在 | 方針 |
|---|---|
| `HexTileCatalogResource.tile_set_path: String` | `tile_set: TileSet` または `tile_set_resource: Resource` |
| `HexTileCatalogEntry.scene_path: String` | `scene: PackedScene` |
| `HexObjectDefinitionResource.scene_path: String` | `scene: PackedScene` |
| `HexMapDocumentDependencyResource.dependency_path: String` | `resource: Resource` / `scene: PackedScene` / `script: Script` など typed slot |
| runtime export の `scene_path` | `scene` / `resource` を返す。path文字列は debug field に留める。 |

保存・読み込みの path は、Resource reference とは別問題である。`Save As...` や `Export...` は FileDialog を使う。LineEdit で手入力させない。

### 2.3 UIは「データ型」ではなく「ゲーム開発上の作業目的」で分ける

良い画面分割:

- **Document Header**: New / Open / Save / Save As / Dirty state / Validate summary
- **Generate**: seed、shape、generator pipeline、batch QA、promote
- **Paint / Edit**: brush、tile/object/label/zone placement、selection
- **Catalog**: tileset、entry list、preview、tags、scene tile / atlas tile
- **Layer Stack**: role、visible、locked、z-index、apply target
- **Validate**: error list、focus、rule group、fix suggestions
- **Runtime / Export**: runtime query sample、package/export

悪い画面分割:

- headless test が触りやすい単位
- line count が減る単位
- class が小さくなるだけの単位
- `source_id` や `path` など内部値の入力単位

### 2.4 Test はUXの従属物

今後の test 方針:

1. Core / adapter / resource validator は自動テストを厚く維持する。
2. Editor UI の headless test は、ユーザー価値のある状態遷移だけを見る。
3. widget の存在、LineEdit の文字列、内部ノード名、巨大dockの分割都合を仕様にしない。
4. UX改善で既存headless testが壊れたら、そのtestを削除・再設計する。
5. analog test は当面追加しない。

---

## 3. ロードマップ全体像

```text
Phase CLEAN-0: 方針リセット
  -> Phase CLEAN-1: Resource/API canonicalization
    -> Phase CLEAN-2: Resource参照UXへの置換
      -> Phase CLEAN-3: UX情報設計によるEditor再編
        -> Phase CLEAN-4: Catalog / Validation / QA manual update
          -> Phase CLEAN-5: Test再編
            -> Phase CLEAN-6: Package / sample 整合性
```

優先順位:

1. v1/v2・legacy・fallback を消して正規仕様を一本化する。
2. path text入力を Resource picker / FileDialog / preview UI に置き換える。
3. Editor file-size containment を UX情報設計の問題として再定義する。
4. Catalog / Validation / QA の manual を更新する。
5. analog test は作らない。

---

## 4. Phase CLEAN-0: 方針リセット

### CLEAN-00: Autopilot policy update

目的:

- 今後の Codex/autopilot が互換性維持やheadless test都合を上位に置かないようにする。

対象:

- `AGENTS.md`
- `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
- `docs/policy/IMPLEMENTATION_POLICY.md`
- `docs/policy/TEST_DESIGN_POLICY.md`
- `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`

実施内容:

1. 「ロードマップUXはvalidate済み」に加えて、「未公開addonなので破壊的schema cleanup可」を明記する。
2. `compatibility` を原則ではなく例外に降格する。
3. `test要件はUX改善より優先しない` を明記する。
4. `analog testは保留` を明記する。
5. NEXT-03 analog test pack は `SUPERSEDED` または `DEFERRED_BY_USER` にする。
6. NEXT-04 / NEXT-05 を本ロードマップの task に置き換える。

Acceptance:

- policy docs に「UX合理性 > headless test > 互換性」の優先順位が明記される。
- analog test 新規作成が queue から外れる。
- Codex self-review が「既存testを守るためにUXを歪めたか」を確認する。

---

## 5. Phase CLEAN-1: Resource/API canonicalization

### CLEAN-10: `HexMapDocumentResource` 正規schema化

目的:

- `v1/v2` 区分を廃止し、唯一の正規 `HexMapDocumentResource` にする。

対象:

- `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_map_document_*_resource.gd`
- `tests/test_hex_adapter.gd`
- `docs/api/API_REFERENCE.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MIGRATION_V0_2_TO_V0_3.md`

実施内容:

1. `VERSION_V1` / `VERSION_V2` / `version` を削除する。
2. `ensure_v2_defaults()` を削除する。
3. legacy fields `map`, `tile_overrides`, `objects`, `labels` を削除する。
4. 正規fieldsを以下に統一する。
   - `terrain_layers`
   - `overlay_layers`
   - `object_placements`
   - `label_placements`
   - `zones`
   - `metadata`
   - `dependencies`
5. map本体は `terrain_layers[0].map` ではなく、必要なら `base_map` など明示的fieldに再設計する。`terrain_layers` と map identity が混ざる場合は整理する。
6. `MIGRATION_V0_2_TO_V0_3.md` は削除または `docs/review/_history/` に退避する。
7. API docs から `v2` 語彙を消す。

Acceptance:

- public docs に `v1` / `v2` が出ない。
- new document を作るだけで正規schemaになる。
- adapter tests は migration ではなく canonical document roundtrip を確認する。
- 旧schema fixture を守るtestは削除する。

### CLEAN-11: Adapterからmigration/compatibility層を削除

目的:

- Adapter の責務を「旧形式救済」から「正規Documentと表示/runtimeの変換」に戻す。

対象:

- `hex_map_document_adapter.gd`
- `hex_map_tile_adapter.gd`
- `hex_overlay_tile_adapter.gd`
- `hex_tile_map_layer.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`

実施内容:

1. `migrate_v1_to_v2()` を削除する。
2. `catalog_compatibility_warnings()` を削除する。
3. catalogless numeric fallback 表示を通常経路から削除する。
4. `HexMapDocumentValidator` に missing catalog / missing assignment / missing resource を検出させる。
5. Adapter は validation clean な document を前提に短くする。
6. display用 placeholder が必要なら、`MissingTilePlaceholderPolicy` のような明示的debug設定に隔離する。

Acceptance:

- Adapter の通常経路で `legacy` / `v1` / `fallback` が不要になる。
- catalog key 未設定は silent fallback ではなく validation issue になる。
- runtime apply は validation clean document で成功する。

### CLEAN-12: `HexObjectDatabaseResource` 正規化

目的:

- object database を `version + objects + definitions` の二重構造から、typed definitions のみにする。

対象:

- `addons/hex_map_kit/adapter/hex_object_database_resource.gd`
- `addons/hex_map_kit/adapter/hex_object_definition_resource.gd`
- `addons/hex_map_kit/adapter/hex_object_layer_adapter.gd`
- `examples/basic_runtime/runtime_query_sample.gd`
- object関連tests

実施内容:

1. `version` を削除する。
2. legacy `objects: Array` を削除する。
3. `definitions: Array[Resource]` を唯一の正規fieldにする。
4. `scene_path: String` を `scene: PackedScene` に置き換える。
5. `preview` / `preview_path` を `preview_texture: Texture2D` または `preview_icon: Texture2D` に置き換える。
6. runtime export は `scene_path` ではなく `PackedScene` 参照を返す。

Acceptance:

- object定義の作成・保存・ロードが typed resource だけで成立する。
- scene欠落は path文字列validation ではなく Resource null validation になる。
- runtime object export は scene resource を返す。

### CLEAN-13: `HexTileCatalogResource` 正規化

目的:

- Catalog を path文字列と fallback fields から解放し、asset identity の中核にする。

対象:

- `hex_tile_catalog_resource.gd`
- `hex_tile_catalog_entry.gd`
- `hex_tile_catalog_validator.gd`
- `hex_map_tile_adapter.gd`
- `hex_overlay_tile_adapter.gd`
- sample catalog resource

実施内容:

1. `tile_set_path: String` を `tile_set: TileSet` に置き換える。
2. `scene_path: String` を `scene: PackedScene` に置き換える。
3. `fallback_source_id` / `fallback_atlas_coords` / `fallback_alternative_tile` を削除する。
4. `source_id` / `atlas_coords` / `alternative_tile` は entry内部の詳細値として維持してよい。ただし通常paint UIでは直接編集させない。
5. entry type は `atlas` / `scene` / `placeholder` 程度に整理する。`fallback` type は廃止する。
6. sample catalog は package内で完結する Resource / PackedScene / TileSet 参照を持つ。

Acceptance:

- sample catalog が validator clean。
- catalog entry が path文字列なしで保存・ロードできる。
- missing tile/scene は validation issue になる。
- Floor/Wall/Overlay/Object assignment は catalog key を唯一の通常入力にする。

### CLEAN-14: Label / Dependency Resource 正規化

目的:

- Label と Dependency の `Array` / path string を清潔な typed Resource にする。

対象:

- `hex_label_database_resource.gd`
- `hex_map_document_dependency_resource.gd`
- `hex_map_document_validator.gd`
- docs/tests

実施内容:

1. `HexLabelDefinitionResource` を追加する。
2. `HexLabelDatabaseResource.labels: Array` を typed definitions に置き換える。
3. `dependency_path: String` を削除する。
4. dependency は `resource: Resource`、`kind`、`role`、`required` を持つ。
5. path表示は debug report で `resource.resource_path` から読み取るだけにする。

Acceptance:

- dependency validation が Resource null / type mismatch を検出する。
- manual/API に path文字列参照を標準手順として出さない。

---

## 6. Phase CLEAN-2: Resource参照UXへの置換

### CLEAN-20: Resource selection UI standard

目的:

- Editor UI 全体から editable path text を排除する。

対象:

- `hex_map_edit_tool.gd`
- `hex_map_gen_dock.gd`
- `hex_map_editor_path_selector.gd`
- `hex_map_editor_session_state.gd`
- `tests/test_editor_plugin.gd`

実施内容:

1. document / import / catalog / object database / label database は `EditorResourcePicker` を標準入力にする。
2. Save As / Export だけ FileDialog を使う。
3. LineEdit は path入力ではなく、read-only path/status表示にするか削除する。
4. session state は path文字列中心ではなく、Resource参照 + optional saved_path を持つ。
5. UI上の path は `Where is this saved?` という補助情報に降格する。
6. test は `_document_path_edit` の存在確認をやめる。

Acceptance:

- ユーザーが document path を手入力する通常導線がない。
- Resource picker / Browse / Save As の操作で完結する。
- 既存 path LineEdit を前提にした headless test は削除または新UX用に書き換える。

### CLEAN-21: Document Header redesign

目的:

- Document 操作を、path文字列ではなく作業状態として提示する。

新UI案:

```text
[New Document] [Open...] [Save] [Save As...] [Validate]
Document: Dungeon Entrance    Saved: res://maps/dungeon_entrance.tres    Dirty: yes
Catalog: Tactics Hex Catalog  Layer Stack: Tactics
Validation: 0 errors / 2 warnings
```

実施内容:

1. `New Document` は正規schema resource を生成する。
2. `Open...` は FileDialog / ResourcePicker で `HexMapDocumentResource` を選ぶ。
3. `Save` は既存 `resource_path` があれば保存、なければ Save As。
4. `Save As...` は FileDialog。
5. `Import Map` は通常導線から下げる。必要なら `Advanced / Convert HexMapResource...` にする。
6. `Export HexMapResource` は runtime/legacy fallback ではなく `Export...` action として隔離する。

Acceptance:

- document の保存状態が人間に読める。
- path文字列を編集しなくても全操作ができる。
- `v2` や `migration` 語彙が画面に出ない。

### CLEAN-22: Catalog Screen redesign

目的:

- Catalog を単なる OptionButton ではなく、asset identity を編集・理解する画面にする。

新UI構成:

```text
Catalog Resource: [ResourcePicker]
TileSet: [ResourcePicker]

Entries:
  key                 type    preview    tags              status
  terrain.floor       atlas   [tile]     terrain,floor     ok
  terrain.wall        atlas   [tile]     terrain,wall      ok
  object.spawn        scene   [scene]    object,spawn      ok

[Add Atlas Entry] [Add Scene Entry] [Validate Catalog]
```

実施内容:

1. Catalog resource picker を置く。
2. TileSet resource picker を置く。
3. entry list と preview を出す。
4. `source_id / atlas_coords` は entry editor の詳細欄に閉じ込める。
5. scene entry は PackedScene picker を使う。
6. missing entry は validation issue として表示する。
7. Floor/Wall/Overlay/Object paint controls は catalog key だけ選ぶ。

Acceptance:

- catalog key の意味を画面で理解できる。
- `source_id / atlas_coords` を通常paint UIで触らない。
- path文字列で scene を指定しない。

### CLEAN-23: Object Palette / Property Editor redesign

目的:

- object placement を marker ではなく、実ゲームの scene / trigger / spawn 管理として扱う。

実施内容:

1. Object Database picker を置く。
2. object definition list を表示する。
3. scene は PackedScene picker。
4. placement brush は object key を選ぶ。
5. property editor は型付きUIにする。
   - bool: CheckBox
   - int/float: SpinBox
   - string: LineEdit
   - enum: OptionButton
   - Resource: EditorResourcePicker
6. `object_id` 手入力は advanced/debug に下げるか削除する。
7. `properties` の raw dictionary text入力を通常UXにしない。

Acceptance:

- object placement の通常操作で JSON/dictionary/text を書かない。
- scene reference は PackedScene として選ぶ。
- placement property が type-aware UI で編集できる。

### CLEAN-24: Layer Stack Screen redesign

目的:

- Layer Stack を API ではなく、ユーザーが理解できる画面操作にする。

実施内容:

1. layer stack template picker を置く。
2. role list を表示する。
3. roleごとに visible / locked / z-index / writable source を表示する。
4. `Create Missing Layers` / `Apply Document` / `Clear Role` を置く。
5. plain `TileMapLayer` apply は通常画面から削除する。必要なら debug/advanced に隔離する。

Acceptance:

- ユーザーが terrain / overlay / object / debug layer の役割を画面で把握できる。
- layer stack の存在が manual と一致する。

### CLEAN-25: Generation QA Screen redesign

目的:

- QA batch/score/promotion を headless API から画面UXへ昇格する。

実施内容:

1. `Generate` 内に `Seed Lab` section を置くか、独立 `QA` tab を作る。
2. N seeds / validation rules / score metrics を選べる。
3. score table を表示する。
4. selected seed preview を表示する。
5. `Promote to Document` を置く。
6. promoted document の dirty state と metadata を表示する。

Acceptance:

- ユーザーが複数seedを比較し、選び、document化できる。
- score table が内部APIだけでなく画面に存在する。
- previewが未完成でも、選択・promotionの流れは画面で理解できる。

### CLEAN-26: Validation Screen refinement

目的:

- Validation dashboard をテスト用状態表示から、修正行動に接続する画面にする。

実施内容:

1. issue group: Document / Catalog / Layer / Object / Gameplay / Package。
2. issue severity: Error / Warning / Info。
3. click to focus cell / resource / catalog entry。
4. fix suggestion を表示する。
5. `Copy Debug Report` は維持するが、通常画面は短くする。

Acceptance:

- validation issue からユーザーが次の操作を理解できる。
- debug report は濃く、通常statusは短い。

---

## 7. Phase CLEAN-3: UX情報設計によるEditor再編

このPhaseは、旧 `NEXT-05: Editor file-size containment` を置き換える。

### CLEAN-30: Editor screen inventory by user task

目的:

- コードサイズではなく、ユーザーの作業目的で維持/分割/廃止を決める。

対象:

- Generate Dock
- Edit Dock
- Validation Dashboard
- Document Inspector
- Catalog controls
- Object controls
- QA controls

実施内容:

各UI要素を以下に分類する。

| 分類 | 意味 | 対応 |
|---|---|---|
| `keep-in-place` | 現画面の作業目的に合う | 維持 |
| `move-to-screen` | 別作業目的のため画面分離 | component化 |
| `merge-with-existing` | 同じ作業目的が重複 | 統合 |
| `advanced-only` | 通常ユーザーには不要 | 折りたたみ/Debug |
| `delete` | path text / legacy / fallback 由来 | 削除 |

Acceptance:

- `docs/review/roadmap/EDITOR_UX_COMPONENT_INVENTORY_2026-06-07.md` を作る。
- 「大きいから分ける」という理由を使わない。
- path text / fallback UI の削除候補が明記される。

### CLEAN-31: Workspace / Tab model decision

目的:

- Generate/Edit の2dock構成を維持するか、Hex Map Workspace 化するか決める。

判断基準:

- ユーザーが map document を中心に作業できるか。
- Catalog / Layer / Validate / QA が迷子にならないか。
- Godot標準Editorと衝突しないか。
- 画面幅が狭くても主要操作が破綻しないか。

候補:

1. 2dock維持 + shared document header
2. 1つの `Hex Map Workspace` dock + tabs
3. Main screen化

推奨初期案:

- まず 1つの `Hex Map Workspace` dock + tabs を検討する。
- tabs: `Document`, `Generate`, `Paint`, `Catalog`, `Layers`, `Validate`, `QA`, `Export`。
- 既存Generate/Editは内部componentとして再利用する。

Acceptance:

- UX判断文書を作る。
- 決定後、コード分割はその情報設計に従う。

### CLEAN-32: Component extraction by UX responsibility

目的:

- 巨大dockの増築を止めるのではなく、UX責務に沿ってcomponent化する。

分割候補:

| component | UX責務 | 備考 |
|---|---|---|
| `HexMapDocumentHeader` | New/Open/Save/Dirty/Validate summary | path text排除の中心 |
| `HexMapCatalogPanel` | catalog resource, entries, preview | Catalog screen |
| `HexMapLayerStackPanel` | role/layer管理 | Layer screen |
| `HexMapBrushPalette` | tile/object/label/zone brush | Paint screen |
| `HexMapObjectPalette` | object database and placement | Object UX |
| `HexMapGenerationPanel` | single generation | Generate screen |
| `HexMapSeedLabPanel` | batch/score/promotion | QA screen |
| `HexMapValidationPanel` | issues/focus/fix hints | Validate screen |
| `HexMapExportPanel` | export/package/runtime handoff | Export screen |

Acceptance:

- component化の単位が UX責務として説明できる。
- 単に行数を減らすための分割をしない。
- tests は componentの内部nodeではなく、画面操作目的を検証する。

### CLEAN-33: Delete redundant / harmful UI paths

目的:

- path text、numeric fallback、legacy import/export を通常UXから削る。

削除・降格候補:

- Document path LineEdit
- Import Map path LineEdit
- Export path LineEdit
- Atlas Image path LineEdit
- raw object id LineEdit
- raw properties dictionary LineEdit
- raw spawn condition text if enum/typed alternatives can be provided
- Floor/Wall source spin boxes in normal view
- Overlay numeric tile row in normal view
- plain TileMapLayer apply as primary action
- v2/migration wording in UI/manual/API

Acceptance:

- 通常画面から path text 入力が消える。
- advanced/debug へ残す場合は理由が書かれている。
- headless test がこれらのcontrolを期待していたら削除・更新する。

---

## 8. Phase CLEAN-4: NEXT-04 Manual update

### CLEAN-40: Catalog / Validation / QA screen manual update

目的:

- `NEXT-04` をロードマップに正式追加する。
- ただし analog test ではなく、操作目的別 manual 更新として行う。

対象:

- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MANUAL_SCRIPTING.md`
- `docs/api/API_REFERENCE.md`
- `README.md`

実施内容:

1. manual を「機能列挙」ではなく「作業目的」単位にする。
2. `Catalog を作る / 選ぶ / entryを追加する / validateする` を説明する。
3. `Layer Stack template を選ぶ / 作る / applyする` を説明する。
4. `Validation issue を読む / focusする / 修正する` を説明する。
5. `Object placement を選ぶ / propertyを編集する / sceneを参照する` を説明する。
6. `Generation QA でseedを比較し、promoteする` を説明する。
7. `Copy Debug Report` は support/debug 用として説明する。
8. `v2` / `migration` / `legacy` 語彙を削除する。
9. path text入力を標準操作として説明しない。

Acceptance:

- manual だけ読めば、Resource picker 中心の操作が理解できる。
- Clean spec 後のAPI名と一致する。
- analog test ファイルは作らない。

### CLEAN-41: API docs clean vocabulary pass

目的:

- API reference から互換用語を消す。

実施内容:

1. `v2` 語彙を削除する。
2. `migrate_v1_to_v2` を削除する。
3. `scene_path` / `tile_set_path` を Resource reference API へ置換する。
4. runtime sample は `query_document(document: HexMapDocumentResource, ...)` を主APIにする。
5. path-based helper が必要なら `load_document_from_path()` のような補助APIとして下げる。

Acceptance:

- API docs の最初の導線が Resource object ベースになる。
- path helper は主導線ではない。

---

## 9. Phase CLEAN-5: Test再編

### CLEAN-50: Headless editor test destruction pass

目的:

- 旧UIを守るtestを削除・破壊し、新UXの邪魔をしない状態にする。

対象:

- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- editor UI helper tests

実施内容:

1. `_document_path_edit`、`_import_map_path_edit`、`_export_path_edit`、`_target_atlas_path_edit` の存在を要求するtestを削除する。
2. old path handler tests を Resource picker / FileDialog action tests に置換する。
3. old fallback/numeric tile controls を要求するtestを削除する。
4. node名ではなく「document selected」「catalog entry selected」「validation issue selected」など状態遷移を確認する。
5. UI再編中に test が邪魔なら、該当testを一時削除し、実装後に新規testを書く。

Acceptance:

- test が旧UIを固定しない。
- UX改善PRで test を破壊することが許可される。
- 新test は clean UI の state contract を見る。

### CLEAN-51: Resource/API canonical tests

目的:

- 互換testではなく、正規仕様testを厚くする。

追加/更新するtest:

- canonical document save/load
- canonical document adapter roundtrip
- catalog Resource reference save/load
- PackedScene object definition save/load
- dependency Resource validation
- missing catalog key validation
- no silent fallback apply
- runtime query with Resource argument
- package sample catalog validator clean

削除するtest:

- v1 fixture load
- v1 -> v2 migration
- catalogless numeric fallback display
- legacy object array sync
- ensure_v2_defaults behavior

Acceptance:

- tests の失敗が旧互換削除を妨げない。
- clean spec のresource保存・検査・runtime利用が通る。

### CLEAN-52: Analog test deferral marker

目的:

- analog test を今は作らないことを明示する。

実施内容:

1. `docs/TEST.md` に「UI再編中は新規analog testを作らない」と書く。
2. 既存 analog test は history として維持してよいが、新UXの acceptance にしない。
3. 新UXの印象が改善した時点で、ユーザー指示により analog test roadmap を再開する。

Acceptance:

- NEXT-03 は実装対象から外れる。
- analog test 不足を理由に UI再編を止めない。

---

## 10. Phase CLEAN-6: Package / sample 整合性

### CLEAN-60: Sample asset integrity after clean references

目的:

- path文字列・debug path・missing scene を package sample から消す。

対象:

- `addons/hex_map_kit/assets/sample_hex_tile_catalog.tres`
- sample TileSet / PackedScene / Texture
- `tools/package_addon.sh`
- package tests

実施内容:

1. sample object scene を `addons/hex_map_kit/assets/` または `examples/` の package対象内に置く。
2. sample catalog entry は PackedScene reference を持つ。
3. debug directory の scene を sample catalog から参照しない。
4. package manifest に sample resource の依存が含まれることを確認する。
5. sample catalog validator が clean になる。

Acceptance:

- clean install で sample catalog が missing dependency を出さない。
- package check で sample dependency が通る。

### CLEAN-61: Dist regeneration after clean spec

目的:

- clean spec 後の addon package を最新treeに合わせる。

実施内容:

1. `tools/package_addon.sh` を実行する。
2. manifest を再生成する。
3. dev-only files が混入していないか確認する。
4. path text / migration docs / legacy docs が packageに入っていないことを確認する。

Acceptance:

- committed `dist` が current addon tree と一致する。
- package内に clean spec docs が入る。
- release upload はまだ行わない。

---

## 11. 実装キュー

このキューは `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md` の後続として扱う。

| id | 優先 | 依存 | 内容 | Acceptance |
|---|---:|---|---|---|
| `CLEAN-00` | P0 | none | Autopilot / policy reset | UX合理性 > test > compatibility が明文化される |
| `CLEAN-10` | P0 | `CLEAN-00` | `HexMapDocumentResource` 正規schema化 | v1/v2語彙・legacy fields・ensure_v2削除 |
| `CLEAN-11` | P0 | `CLEAN-10` | Adapter migration/compat削除 | fallbackではなくvalidation issueへ |
| `CLEAN-12` | P0 | `CLEAN-10` | Object database正規化 | `definitions` + PackedScene参照のみ |
| `CLEAN-13` | P0 | `CLEAN-10` | Tile catalog正規化 | TileSet/PackedScene Resource参照、fallback fields削除 |
| `CLEAN-14` | P1 | `CLEAN-10` | Label/Dependency正規化 | path string dependency削除 |
| `CLEAN-20` | P0 | `CLEAN-10`, `CLEAN-13` | Resource selection UI standard | path LineEdit通常導線削除 |
| `CLEAN-21` | P0 | `CLEAN-20` | Document Header redesign | New/Open/Save/Save As/Dirty/Validate導線 |
| `CLEAN-22` | P0 | `CLEAN-13`, `CLEAN-20` | Catalog Screen redesign | entry list/preview/resource picker |
| `CLEAN-23` | P1 | `CLEAN-12`, `CLEAN-20` | Object Palette redesign | type-aware property UI |
| `CLEAN-24` | P1 | `CLEAN-21` | Layer Stack Screen redesign | role/visible/lock/z-index/apply UI |
| `CLEAN-25` | P1 | `CLEAN-21` | Generation QA Screen redesign | seed table/promotion UI |
| `CLEAN-26` | P1 | `CLEAN-21` | Validation Screen refinement | issue focus/fix suggestion |
| `CLEAN-30` | P0 | `CLEAN-00` | Editor screen inventory | keep/move/merge/advanced/delete分類 |
| `CLEAN-31` | P1 | `CLEAN-30` | Workspace/tab model decision | 2dock/Workspace/MainScreen判断 |
| `CLEAN-32` | P1 | `CLEAN-31` | UX responsibility component extraction | UX責務に沿ったcomponent化 |
| `CLEAN-33` | P0 | `CLEAN-20`, `CLEAN-30` | harmful UI path削除 | path/numeric/fallback通常UI削除 |
| `CLEAN-40` | P1 | `CLEAN-21`, `CLEAN-22`, `CLEAN-25`, `CLEAN-26` | NEXT-04 manual update | Catalog/Validation/QA/Object/Layer目的別manual |
| `CLEAN-41` | P1 | `CLEAN-10`〜`CLEAN-14` | API docs clean vocabulary | v2/migration/path語彙削除 |
| `CLEAN-50` | P0 | `CLEAN-20` | Headless editor test destruction pass | 旧UI固定test削除 |
| `CLEAN-51` | P0 | `CLEAN-10`〜`CLEAN-14` | Resource/API canonical tests | clean spec保存・検査・runtime利用test |
| `CLEAN-52` | P0 | `CLEAN-00` | Analog test deferral marker | 新規analog testを作らないことを明記 |
| `CLEAN-60` | P1 | `CLEAN-12`, `CLEAN-13` | Sample asset integrity | sample catalog validator clean |
| `CLEAN-61` | P2 | `CLEAN-40`, `CLEAN-60` | Dist regeneration | packageがcurrent treeと一致 |

---

## 12. 最初に実行するべき順序

まずはこの順で進める。

```text
1. CLEAN-00  方針リセット
2. CLEAN-30  Editor screen inventory
3. CLEAN-10  HexMapDocumentResource 正規schema化
4. CLEAN-11  Adapter compatibility削除
5. CLEAN-13  Tile catalog正規化
6. CLEAN-12  Object database正規化
7. CLEAN-20  Resource selection UI standard
8. CLEAN-50  旧headless editor test破壊/再設計
9. CLEAN-21  Document Header redesign
10. CLEAN-22 Catalog Screen redesign
```

理由:

- 先に policy を更新しないと、Codex が互換性維持や既存test維持へ戻る。
- Resource schema を先に一本化しないと、UI再編が二重schemaを前提にしてしまう。
- path text UX は広く蔓延しているため、UI全体の標準として先に潰す。
- test破壊許可を明示しないと、旧UIが headless test によって保存される。

---

## 13. Codexへの標準プロンプト

```md
Goal:
Implement the next CLEAN roadmap task from docs/review/roadmap/UX_FIRST_CLEAN_SPEC_ROADMAP_2026-06-07.md.

Highest design policy:
- The addon is unpublished. Do not preserve v1/v2 compatibility unless the current CLEAN task explicitly says so.
- Prefer clean UX/API/spec/tests over compatibility.
- UI and API decisions must be based on game-development UX rationality, not headless-test convenience.
- If old headless editor tests preserve bad UI, delete or rewrite those tests.
- Do not create new analog tests. Analog tests are deferred by user instruction.

Process:
1. Read the CLEAN roadmap and current implementation.
2. Pick the first incomplete task by priority/dependency.
3. Create/update plan files if useful, but do not stop for approval.
4. Implement clean spec directly.
5. Remove obsolete compatibility code/tests/docs touched by the task.
6. Run relevant tests; if old tests fail because they assert obsolete UI/compatibility, rewrite or delete them.
7. Update docs/TEST.md only for the new clean test contract.
8. Write self-review with any remaining clean-spec debt.

Do not:
- Keep v1/v2 naming in public docs.
- Keep path text input as standard UI.
- Keep fallback behavior as normal user-facing behavior.
- Add analog test files.
```

---

## 14. 完了判定

このロードマップの完了条件:

1. Public docs から `v1` / `v2` / `migration` / `legacy` が消えている。
2. Resource schema が正規形一本になっている。
3. Resource reference が path string ではなく typed Resource / PackedScene / TileSet 中心になっている。
4. 通常UIから editable path text が消えている。
5. Catalog / Object / Layer / Validation / QA がゲーム開発上の目的別画面として理解できる。
6. headless test は clean UX の state contract を確認し、旧UIを固定していない。
7. analog test は追加されていない。
8. sample catalog / package が missing dependency を出さない。
9. NEXT-04 は manual 更新として完了している。
10. NEXT-05 は UX情報設計によるEditor再編として完了している。

---

## 15. 結論

Autopilot 実装は、当初ロードマップの機能面を広く接続した。一方で、未公開addonとしては、互換性維持のために残した v1/v2、legacy、fallback、path text 入力が次の負債になっている。

次にやるべきことは「さらに機能を足す」ことではなく、**作った機能をゲーム開発者が自然に使える清潔な仕様と画面へ統一すること**である。

特に重要なのは次の3点である。

1. Resource/API を canonical only にする。
2. path text 入力を Resource picker / FileDialog / preview に置き換える。
3. test都合ではなくUX合理性を基準にUIを壊して作り直す。

この3点が済めば、現在のCore能力はかなり強い土台として見えるようになる。
