# CLEAN UI Roadmap 実行評価 2026-06-07

作成日: 2026-06-07  
対象: `godot-hex-map-lab-20260607-193151.zip`  
評価対象 roadmap: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/UX_ROADMAP.md`  
実行 queue: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/IMPLEMENTATION_QUEUE.md`  
参照元: `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`

---

## 0. 結論

CLEAN UI タスク群の実行は、**Resource/API の清潔化と test contract の再編としてはかなり成功**している。一方で、**Editor UI の情報設計としてはまだ「実画面の再編完了」ではなく、「Workspace shell と暫定統合の完了」に留まる**。

特に評価すべき成果は以下である。

- `HexMapDocumentResource` から `v1/v2/version` と旧 `map/tile_overrides/objects/labels` fields が消え、canonical schema に寄った。
- `HexTileCatalogResource.tile_set`、`HexTileCatalogEntry.scene`、`HexObjectDefinitionResource.scene`、`HexMapDocumentDependencyResource.resource` など、path string ではなく Resource reference を基準にする設計へ進んだ。
- `Hex Map Workspace` dock が導入され、`Document / Generate / Paint / Catalog / Layers / Validate / QA / Export` という UX responsibility map が定義された。
- path text 入力は多くが `EditorResourcePicker` / `EditorFileDialog` / read-only saved status に置き換えられた。
- 旧 headless test を守るために UX を歪めない方針が policy / tests / docs に反映された。
- 同梱された self-review / test result では、各 CLEAN task で `./tools/test.sh` が Godot `v4.6.2.stable.official.71f334935` 上で PASS した記録がある。

ただし、現時点で `COMPLETE` の意味を「ユーザーに提示される清潔な画面が完成した」と読むのは危険である。`HexMapWorkspace` はタブ名と responsibility map を持つが、実装上は `Generate` tab に `HexMapGenDock`、`Paint` tab に `HexMapEditTool` を載せるだけで、`Document / Catalog / Layers / Validate / QA / Export` tab は first-class screen としてはまだ実体を持たない。manual もこの staged state を説明しているが、ロードマップ上の `CLEAN-22`〜`CLEAN-26` の名前から期待される「screen redesign」とはまだ差がある。

したがって総合評価は以下とする。

| 観点 | 評価 | コメント |
|---|---:|---|
| Resource/API canonicalization | A- | 未公開 addon として清潔な schema に寄った。互換・migration の公開語彙はほぼ消えた。 |
| Resource reference UX | B+ | ResourcePicker / PackedScene / TileSet 参照への転換は良い。saved path は status / helper として残る。 |
| Editor screen UX | C+ | Workspace/tabs の設計は良いが、実画面は Generate/Paint への暫定集約が中心。空タブがUX上のリスク。 |
| Path text / numeric fallback 排除 | B | 通常 UI からの排除は進んだが、debug fallback option や hidden raw controls が実装上に残る。 |
| 自動テスト | A- | PASS 記録と coverage は厚い。ただし tab contents 不在を検出できていない。 |
| Manual / 操作手順 | B | manual と TEST の手順は更新済み。analog test 新規作成はユーザー方針どおり保留。 |
| Package readiness | B+ | package manifest / dist 再生成は良い。公開 upload 前の実操作確認は未実施。 |

推奨判定:

```text
CLEAN Roadmap execution = 機械的には COMPLETE
UX-first Product Readiness = まだ COMPLETE ではない
次に必要 = Workspace tab の実体化と、manual / tests の tab content contract 化
```

---

## 1. 評価の前提

今回の上位指針は以下である。

1. addon は未公開なので互換性維持を優先しない。
2. Core は安定しており、主問題は UI / API の提示の仕方である。
3. UI 層は破壊的に整理してよい。
4. UI の根拠は headless test ではなく、ゲーム開発上の UX合理性である。
5. headless test が UX 改善を妨げる場合、その test を壊してよい。
6. analog test は、UI の印象改善後まで保留する。

この評価では、`IMPLEMENTATION_QUEUE.md` の全 task が `COMPLETE` であること自体は事実として受け取りつつ、以下を分けて見る。

- **設計上の達成**: ユーザーが期待する UX / API の構造になっているか。
- **実装上の達成**: 実コードがその構造を実際の操作画面として提示しているか。
- **検証上の達成**: headless test / manual / self-review が、本当に UX の完成を保証できているか。

こちらの環境では Godot 実行ファイルがないため、`./tools/test.sh` の再実行はできなかった。

```text
Godot executable not found. Set GODOT_BIN=/path/to/Godot.
```

そのため、テスト評価は以下に基づく。

- zip 内の `docs/review/autopilot/CLEAN-*SELF_REVIEW_2026-06-07.md`
- `docs/review/autopilot/CLEAN-*TEST_RESULT_2026-06-07.md`
- `docs/TEST.md`
- 静的コード確認

---

## 2. Queue 実行状態

`docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/IMPLEMENTATION_QUEUE.md` を確認した範囲では、CLEAN task は 24 件あり、すべて `COMPLETE` になっている。

```text
CLEAN-00, CLEAN-30, CLEAN-10, CLEAN-11, CLEAN-13, CLEAN-12, CLEAN-14,
CLEAN-20, CLEAN-50, CLEAN-21, CLEAN-22, CLEAN-23, CLEAN-24, CLEAN-25,
CLEAN-26, CLEAN-31, CLEAN-32, CLEAN-33, CLEAN-40, CLEAN-41, CLEAN-51,
CLEAN-52, CLEAN-60, CLEAN-61
```

成熟度の分布は、おおむね以下である。

| maturity | 代表task | 評価 |
|---|---|---|
| `HEADLESS_TEST_COMPLETE` | CLEAN-10, 11, 12, 13, 14, 20, 21〜26, 32, 33, 51 | 実装と自動テストが伴っている。 |
| `DOCS_COMPLETE` | CLEAN-00, 30, 31, 40, 41, 52 | 方針・manual・decision record が中心。 |
| `PACKAGE_READY` | CLEAN-60, 61 | sample asset と package artifact の整合。 |

この実行管理は良い。前回の autopilot orchestration の狙いどおり、単発の人間承認ではなく、queue / self-review / test / repair を通じて完了へ進んでいる。

注意点は、`COMPLETE` が task-local acceptance を意味していることである。特に UI screen 系 task は、task 名から見ると「screen が完成した」ように見えるが、実際には staged extraction の一部として `HexMapEditTool` / `HexMapGenDock` に残している部分が多い。

---

## 3. UXを実現する設計ができているか

### 3.1 Resource/API 設計

評価: **できている。かなり良い。**

代表例:

```text
addons/hex_map_kit/adapter/hex_map_document_resource.gd
```

現在の `HexMapDocumentResource` は非常に小さく、公開 contract として以下に整理されている。

```gdscript
@export var terrain_layers: Array[Resource] = []
@export var overlay_layers: Array[Resource] = []
@export var object_placements: Array[Resource] = []
@export var label_placements: Array[Resource] = []
@export var zones: Array[Resource] = []
@export var metadata: HexMapDocumentMetadataResourceScript
@export var dependencies: Array[Resource] = []
```

`VERSION_V1` / `VERSION_V2` / `version` / `map` / `tile_overrides` / `objects` / `labels` が消えたことは、今回の最重要設計指針に合っている。未公開 addon としては、過去形の migration 語彙を残さず、正規仕様に一本化する方が合理的である。

また、以下も良い。

- `HexTileCatalogResource.tile_set: TileSet`
- `HexTileCatalogEntry.scene: PackedScene`
- `HexObjectDefinitionResource.scene: PackedScene`
- `HexMapDocumentDependencyResource.resource: Resource`
- `HexLabelDatabaseResource.definitions: Array[Resource]`

path string ではなく Godot の Resource 参照を持つ方向に寄っており、ゲーム開発者が Godot の Inspector / Resource workflow と自然に接続しやすい。

改善余地:

- `Array[Resource]` は Godot の editor serialization との相性上やむを得ない面があるが、API 利用者向けには typed helper を増やした方が良い。例: `terrain_layer_at(index)`, `add_object_placement(placement)`, `dependencies_of_kind(kind)`。
- `HexMapDocumentAdapter` には `debug_numeric_fallback_enabled` が残る。これは通常UXではなく debug-only として封じ込めるか、公開前に削除してもよい。

### 3.2 Catalog / Tile identity 設計

評価: **方向性は正しい。**

Catalog key を通常 UX の語彙にし、`source_id / atlas_coords` を TileSet entry detail に落としたのは良い。`sample_hex_tile_catalog.tres` も、TileSet と PackedScene を内包し、`terrain.floor`、`terrain.wall`、`overlay.treasure`、`object.spawn_marker` を持っている。前回評価時に懸念していた missing scene path は、`sample_spawn_marker.tscn` が同梱される形で改善されている。

改善余地:

- Catalog entry の `source_id / atlas_coords / alternative_tile` は Resource schema 上は必要だが、通常 paint UI では徹底的に非表示にすべきである。現状は hidden control と adapter fallback の両方が残るため、今後の修正で accidentally visible になりやすい。
- Catalog screen は `HexMapEditTool` 内に実装されており、Workspace の `Catalog` tab に first-class に載っていない。このため「Catalog を編集する」というユーザー目的が画面上でまだ見つけにくい。

### 3.3 Object / Label / Dependency 設計

評価: **v1/v2 cleanup としては成功。Object UXとしてはまだ粗い。**

Object database が `definitions` を持ち、object definition が `id / display_name / scene / tags / default_properties / preview_texture` を持つようになったのは良い。`scene_path` ではなく `PackedScene` を保持する方向も正しい。

一方で、実UIではまだ次が粗い。

- `variant` が raw text。
- `spawn_condition` が raw text。
- `Label ID` が raw text。
- Overlay item key も raw text + known option の併用。
- Object property editor は typed control を作るが、property schema の authoring UI と validation rule まではまだ弱い。

これは不合格というより、**Resource/API cleanup の次に UI semantics を詰めるべき領域**である。

### 3.4 Workspace / screen 情報設計

評価: **設計判断は良いが、実装は未完了。**

`docs/review/roadmap/EDITOR_WORKSPACE_MODEL_DECISION_2026-06-07.md` の判断、つまり「one `Hex Map Workspace` dock with tabs」は妥当である。Godot の Scene / Inspector / 2D viewport と並べて使う addon として、main screen ではなく dock を選んだのも合理的である。

しかし、実装を見ると `HexMapWorkspace` は以下だけを行っている。

```gdscript
for tab_name in HexMapWorkspaceComponentRegistry.tab_names():
    _add_tab_page(String(tab_name))
_mount_generation_panel()
_mount_edit_panel()
```

つまり実際に mount されているのは:

- `Generate` tab: `HexMapGenDock`
- `Paint` tab: `HexMapEditTool`

だけである。

`Document / Catalog / Layers / Validate / QA / Export` tab は存在するが、現段階では responsibility target であり、実際の作業画面としては空に近い。manual には「active controls are mounted in Generate and Paint」と書かれているため、実装側の認識は正直である。ただし、`CLEAN-22_CATALOG_SCREEN_REDESIGN`、`CLEAN-24_LAYER_STACK_SCREEN_REDESIGN`、`CLEAN-26_VALIDATION_SCREEN_REFINEMENT` という task 名と `COMPLETE` status からは、利用者が「各 screen が実体化した」と誤解しやすい。

ここは最重要改善点である。

---

## 4. 設計に問題がない場合の実装改善点

設計の芯は良い。改善すべきは「実装が設計をユーザーに見える形へ出し切れていない」点である。

### P0: Workspace tab を実体化する

現在の最大リスクは、タブ名だけが先行し、実体 UI が `Paint` に集まっていることである。

次に切るべき task:

```text
CLEAN-NEXT-01_WORKSPACE_TAB_CONTENT_MIGRATION
```

目的:

- `Document` tab に document header / inspector / save/export document actions を移す。
- `Catalog` tab に catalog picker / TileSet picker / scene picker / entry list / validate catalog を移す。
- `Layers` tab に layer stack template / role tree / create/apply/clear を移す。
- `Validate` tab に validation dashboard / issue focus / debug report entry を移す。
- `QA` tab に Seed Lab controls / score table / preview / Promote を移す。
- `Export` tab に runtime/export/package handoff と support/debug actions を置く。
- `Paint` tab には viewport paint に必要な brush / mode / target / last edit のみに絞る。

Acceptance:

- 各 tab が空でない。
- 各 tab の主要 user task がその tab だけで発見できる。
- `Paint` tab に Catalog / Validate / QA / Export 全部入りの長大 scroll が残っていない。
- Headless test は `workspace.tab_has_content("Catalog")` のような state contract を見る。内部 node path 固定を避ける。

### P0: `COMPLETE` の意味を補正する

現 queue は機械的には全完了だが、UX 上は staged completion である。`IMPLEMENTATION_QUEUE.md` に次のような追記を入れるとよい。

```text
All CLEAN tasks are task-local complete.
Workspace tab content migration remains product-readiness work.
The current Workspace exposes target tabs, but several tabs are responsibility placeholders until CLEAN-NEXT-01.
```

これを入れないと、次の autopilot が「全CLEAN完了済み」と解釈して実画面の仕上げを飛ばす可能性がある。

### P1: debug numeric fallback をさらに隔離する

`HexMapDocumentAdapter.apply_to_tile_map_layer()` には `debug_numeric_fallback_enabled` が残る。

これは通常 UI に見えなければ許容可能だが、清潔仕様を徹底するなら次のどちらかにする。

1. 完全削除し、catalog / assignment missing は validation issue のみにする。
2. `HexDebugTileApplyOptions` のような debug-only helper に隔離し、public manual / normal adapter path から消す。

推奨は 2。開発中の診断価値はあるが、通常の game authoring contract と混ぜない方がよい。

### P1: raw text controls の UX 再設計

path text の多くは解消したが、次の raw text はまだ UX として粗い。

- `Overlay Item`
- `Object Variant`
- `Spawn`
- `Label ID`
- object property の string fallback

これらは path text ほど致命的ではない。ただし、ゲーム開発 UX としては以下の方向が望ましい。

- Overlay item は catalog / overlay definition から選ぶ。
- Label ID は label database から選ぶ。
- Variant は definition が持つ enum / variant list から選ぶ。
- Spawn condition は raw text ではなく condition preset / tag / expression resource にする。
- property schema は object definition 側で編集できるようにする。

### P1: Catalog UI に preview / entry editor の実体を持たせる

現状は `Tree` に key/type/preview/tags/status を出すが、実画面としての Catalog Editor はまだ最小である。

強化案:

- entry detail panel を追加。
- Atlas entry は TileSet source / atlas coords を detail 内で編集し、paint 画面には出さない。
- Scene entry は `PackedScene` picker と preview/icon を出す。
- tag editor を `PackedStringArray` の raw edit ではなく chip / list UI にする。
- missing entry の fix suggestion を `Validate` と連動させる。

### P1: Tests が「空タブ」を見逃さないようにする

現在の `tests/test_editor_plugin.gd` は、Workspace の tab names と responsibility map は確認している。しかし、各 tab に実際の user task component があるかまでは弱い。

追加すべき state contract:

```text
workspace.tab_component_ids("Document") includes "document_header"
workspace.tab_component_ids("Catalog") includes "catalog_panel"
workspace.tab_component_ids("Layers") includes "layer_stack_panel"
workspace.tab_component_ids("Validate") includes "validation_panel"
workspace.tab_component_ids("QA") includes "seed_lab_panel"
workspace.tab_component_ids("Export") includes "export_panel"
```

ただし、これは node 名固定ではなく、Workspace が提供する public-ish query method で検証するべきである。

### P2: huge file 問題は UX責務移動の結果として解消する

今回の方針どおり、ファイルサイズだけを理由に分割する必要はない。ただし現状では、`hex_map_gen_dock.gd` と `hex_map_edit_tool.gd` がまだ非常に大きく、異なる user task の UI construction / state / mutation / validation / debug が混在している。

これは line count そのものではなく、以下の UX 問題として扱うべきである。

- Catalog を触りたいユーザーが Paint scroll 内を探す必要がある。
- Validate を触りたいユーザーが Edit controls の末尾を探す必要がある。
- QA を触りたいユーザーが Generate control の一部として探す必要がある。
- Export / Debug / Runtime handoff が Document 保存と混ざる。

つまり分割理由は「巨大だから」ではなく、**ユーザー目的が混ざっているから**である。

---

## 5. 自動テストで確認できない要件に対する画面操作手順

評価: **manual は提供されている。analog test は方針どおり保留。**

確認できるもの:

- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MANUAL_SCRIPTING.md`
- `README.md`
- `docs/TEST.md`
- `tests/analog_test/README.md`

`MANUAL_EDITOR_PLUGIN.md` は user workflow として以下を説明している。

- Workspace tabs
- Document 作成・Open・Save・Validate
- Generate
- QA Seed Lab
- Catalog
- Paint terrain / objects / labels
- Layer Stack
- Validate and focus issues
- Debug Report
- Sample asset setup
- Distribution Editor

`docs/TEST.md` にも、手動操作確認として Document / Catalog / Layer Stack / QA / Validate / Copy Debug Report 等の確認手順が残っている。これは「自動テストでは確認しきれない画面操作上の妥当性」に対する最低限の手続きとして使える。

ただし、現時点では analog test 新規作成がユーザー方針により保留であり、これは正しい。UI の印象がまだ仕上がっていないため、今 analog test を書くと暫定 UI を固定してしまう。

改善点:

- manual には「タブはあるが active controls は Generate/Paint に暫定配置」と明記されている。この正直さは良いが、最終UXとしては弱い。
- 次の `CLEAN-NEXT-01` 後に、manual を「本当に Document tab / Catalog tab / Layers tab / Validate tab / QA tab / Export tab で操作する手順」へ更新する必要がある。
- analog test はその後でよい。

推奨する manual readiness gate:

```text
UI impression improved enough for user review
  -> user requests analog test creation
  -> create current-workspace analog test pack
  -> run manual observations
  -> only then lock UI operation procedures
```

---

## 6. 追加で重要な観点

### 6.1 Public package 観点

`CLEAN-60` と `CLEAN-61` により sample catalog / package manifest / dist artifact は改善されている。`dist/hex_map_kit-0.3.0.manifest.txt` は addon-only の範囲に絞られ、sample catalog / sample tiles / sample scene を含む。

評価: **良い。公開前チェックの土台はある。**

ただし public upload は実施していない。これは正しい。未公開 addon では、UI の最終確認前に公開しない方がよい。

### 6.2 Documentation consistency

README / API / manual は clean vocabulary にかなり寄った。

良い点:

- `v2` / migration を public API として推さない。
- Resource-first / path-helper-secondary の書き分けがある。
- Catalog key を通常 authoring vocabulary として説明している。

注意点:

- manual が将来タブ構成を先取りしているため、実画面と読者の期待がズレる可能性がある。
- `MANUAL_EDITOR_PLUGIN.md` の staged extraction 説明は暫定として残し、tab migration 後に削除する。

### 6.3 Test design

テストは厚い。`docs/TEST.md` の記述を見る限り、adapter / layer / editor / debug scenes / package の coverage は広い。

良い点:

- `missing catalog key` が numeric fallback ではなく validation issue になることを確認している。
- Workspace / session / viewport routing の headless coverage がある。
- UI の raw source/atlas control 非表示を確認している。
- Catalog / Object / Validation / QA の state contract を広く確認している。

弱い点:

- `workspace exposes tabs` は確認しているが、各 tab に first-class content があることは保証していない。
- まだ private fields に触る test が多く、将来の UI再編で test がまた足枷になり得る。
- visual density / discoverability /操作感は当然ながら headless test では見えない。

結論:

```text
Core/API test は維持。
Editor test は private field existence から user-state query へ徐々に移す。
Analog test は今は作らず、Workspace tab content migration 後に再開する。
```

---

## 7. 推奨 follow-up task

### CLEAN-NEXT-01: Workspace tab content migration

Priority: P0

目的:

- 空タブ / 暫定タブをなくし、Workspace decision を実画面にする。

Acceptance:

- `Document / Catalog / Layers / Validate / QA / Export` に実UIが mount される。
- `Paint` から非Paint責務を移す。
- manual の staged extraction 文を削除できる。
- tests は各 tab の user task component presence と state contract を確認する。

### CLEAN-NEXT-02: Debug numeric fallback quarantine

Priority: P1

目的:

- `debug_numeric_fallback_enabled` と numeric fallback helper を normal adapter contract から隔離する。

Acceptance:

- normal apply path は missing catalog assignment を描画で補わない。
- debug fallback は debug helper または test-only option に限定される。
- public docs に fallback を normal workflow として書かない。

### CLEAN-NEXT-03: Overlay / Label / Variant / Spawn typed UX

Priority: P1

目的:

- path text ではないが、まだ raw text になっている authoring fields を typed workflow へ寄せる。

Acceptance:

- Overlay item は known item / catalog / overlay definition から選ぶ。
- Label ID は label database から選ぶ。
- Object variant は definition の variant list / enum から選ぶ。
- Spawn condition は preset / resource / validated expression になる。

### CLEAN-NEXT-04: Catalog detail editor and preview

Priority: P1

目的:

- Catalog を key list ではなく asset authoring screen にする。

Acceptance:

- entry detail editor がある。
- TileSet atlas / scene entry / tags / preview / validation status が一画面で理解できる。
- paint UI は catalog key selection に専念する。

### CLEAN-NEXT-05: Manual after real tab migration

Priority: P1

目的:

- staged extraction manual から、実画面に一致した操作 manual へ更新する。

Acceptance:

- Manual の各章が実タブと一致する。
- `docs/TEST.md` の手動確認手順も実タブに合わせる。
- analog test はまだ作らない。ユーザー指示まで保留。

### CLEAN-NEXT-06: Post-UI analog test pack, user-triggered

Priority: DEFERRED_BY_USER

目的:

- UIの印象が改善した後にのみ、操作感を固定する analog test を作る。

Acceptance:

- ユーザーが明示的に analog test 作成を指示する。
- Current workspace の最終に近い画面に対して作る。
- 旧UIの history analog tests は流用しない。

---

## 8. 最終評価

今回の CLEAN UI roadmap 実行は、**「清潔な仕様に向けた土台の自動実装」としては成功**している。

特に次は明確に前進した。

- v1/v2 互換語彙の廃止。
- Canonical document schema。
- Resource reference 中心の catalog / object / dependency。
- path text 通常入力の排除。
- Catalog key 中心の authoring vocabulary。
- Validation / QA / Object / Layer Stack の state と tests。
- Package artifact の整合。

一方で、CLEAN UI として最も重要な **「ユーザーが作業目的ごとに画面を見つけられるか」** はまだ仕上がっていない。Workspace tabs は存在するが、実際の作業UIはまだ `Generate` と `Paint` の暫定 container に偏っている。ここを放置すると、コード上は clean になったのに、利用者の体験としては「長いdockの中を探す」状態が続く。

したがって、次の一手は設計追加ではなく、**Workspace tab の実体化**である。

```text
次にやるべきこと:
1. CLEAN-NEXT-01 Workspace tab content migration
2. CLEAN-NEXT-02 Debug numeric fallback quarantine
3. CLEAN-NEXT-03 Typed UX for overlay/label/variant/spawn
4. CLEAN-NEXT-04 Catalog detail editor and preview
5. CLEAN-NEXT-05 Manual update after real tab migration
```

この順で進めれば、今回の autopilot 成果はかなり良い形で UX-first product に近づく。
