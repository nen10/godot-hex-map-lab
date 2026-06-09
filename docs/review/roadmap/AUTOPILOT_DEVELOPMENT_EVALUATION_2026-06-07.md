# Hex Map Kit autopiloting 開発状況評価 2026-06-07

評価対象リポジトリ: `godot-hex-map-lab-20260607-074812.zip`  
評価日: 2026-06-07  
評価者: ChatGPT  
比較対象: `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`  
中心確認ファイル: `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`

---

## 1. 総合評価

今回の autopiloting 開発は、当初ロードマップで示されていた大きな方向性、つまり **Level Document v2、Tile Catalog + Layer Stack、Validation Dashboard、Gameplay Query Layer、Object / Scene Placement、Generation QA / Seed Lab、Public Package / Examples** を、設計・実装・テスト・ドキュメントまで一通り接続するところまで到達している。

結論として、**UXを実現するための設計はおおむね成立している**。特に、ゲーム制作上の中心となる `Level Document v2`、asset identity としての catalog key、validation result、runtime query API、object definition / placement の責務分離は、当初ロードマップの問題意識に沿っている。

一方で、今回の実装は「内部API・Resource schema・headless test が強いMVP」であり、**画面上の完成UX、手動確認手順、配布物の整合性にはまだ改善余地がある**。特に、Catalog / Layer Stack / Generation QA / Object Property Editor まわりは、コードとテストは存在するが、ユーザーがGodot Editor上で迷わず操作できる screen workflow と analog test が不足している。

### 1.1 判定サマリ

| 観点 | 評価 | コメント |
|---|---:|---|
| UX実現に向けた設計 | A- | ロードマップの中心設計は成立。Document / Catalog / Layer / Validation / Runtime の責務分離がよい。 |
| 実装到達度 | B+ | queue上の全タスクは完了し、広範なコードとテストが追加された。UI完成度と配布整合性に課題。 |
| 自動テスト | A- | `./tools/test.sh` PASS記録が各taskにある。headless coverage は濃い。手元再実行はGodot不足で不可。 |
| 手動・画面操作手順 | C+ | 旧 analog test と workflow manual はあるが、新機能の画面操作手順が不足。 |
| 公開前品質 | B- | package script は強いが、committed `dist` が古い可能性と sample catalog の欠落参照がある。 |
| 保守性 | B | helper分割は進んだが、巨大dockファイルはさらに肥大化している。 |

---

## 2. 評価条件と確認方法

### 2.1 確認した主な成果物

- `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`
- `docs/review/autopilot/*_SELF_REVIEW_2026-06-07.md`
- `docs/review/autopilot/*_TEST_RESULT_2026-06-07.md`
- `docs/plan/2026-06-06_*/*`
- `addons/hex_map_kit/**/*.gd`
- `tests/*.gd`
- `docs/TEST.md`
- `docs/manual/*.md`
- `docs/api/API_REFERENCE.md`
- `examples/basic_runtime/*`
- `examples/editor_workflow/*`
- `tools/package_addon.sh`
- `dist/hex_map_kit-0.3.0.*`

### 2.2 確認できた事実

- autopilot queue の実装タスクは 42件、すべて `COMPLETE` として記録されている。
- `docs/review/autopilot/` には各taskの self-review と test result が揃っている。
- 多くの test result で `./tools/test.sh` が Godot `v4.6.2.stable.official.71f334935` 上で PASS と記録されている。
- `addons/hex_map_kit` は 123ファイル、主要 GDScript は約18,850行。
- `tests` は GDScript 約10,793行で、`test_editor_plugin.gd`、`test_hex_adapter.gd`、`test_hex_map_generation.gd` が特に大きい。
- `docs/manual`、`docs/api`、`examples/basic_runtime`、`examples/editor_workflow`、`dist` が追加・更新されている。

### 2.3 手元で再実行できなかった確認

この評価環境では Godot 実行ファイルが存在しないため、以下は再実行できなかった。

```sh
./tools/test.sh
```

結果:

```text
Godot executable not found. Set GODOT_BIN=/path/to/Godot.
```

したがって、本評価では **同梱された autopilot test result のPASS記録** と **静的なコード・ドキュメント確認** を分けて扱う。

ただし、`tools/package_addon.sh --check` はこの環境でも実行でき、現在の addon tree から一時 package manifest / zip を生成できることを確認した。

---

## 3. ロードマップ到達度

### 3.1 Goal A: Level Document v2

**評価: 達成度 高**

当初UXでは、`HexMapResource` と `HexMapDocumentResource` をゲーム制作で保存・検査・実行時ロードできる level document に育てることが狙いだった。

今回の実装では、`HexMapDocumentResource` が v1互換フィールドを残しつつ、v2用の typed resource 群を持つ構成になっている。

確認できた主な要素:

- `terrain_layers`
- `overlay_layers`
- `object_placements`
- `label_placements`
- `zones`
- `metadata`
- `dependencies`
- v1 -> v2 migration helper
- document summary
- validation result schema
- runtime load sample

特に、v1互換を残しながら v2 field を追加している点は妥当である。既存 `.tres` を壊さず、v2へ段階移行できる。

改善余地:

- v1 legacy fields と v2 fields の二重管理が残っているため、将来的には「canonical mutation path」を明確にする必要がある。
- `Array[Resource]` ベースの export は Godot制約上やむを得ない面があるが、public API としては typed accessor / validator / safe mutation helper をさらに厚くした方がよい。
- Human-readable JSON export は roadmap の自由ブレストにはあるが、今回のMVPの中心成果としてはまだ薄い。

### 3.2 Goal B: Tile Catalog + Layer Stack

**評価: 達成度 中〜高**

当初UXでは、`source_id / atlas_coords` の数値入力から、ゲーム開発者が理解できる logical tile / object key へ移行することが狙いだった。

今回の実装では、以下が確認できた。

- `HexTileCatalogResource`
- `HexTileCatalogEntry`
- `HexTileCatalogValidator`
- `HexLayerStackResource`
- `HexLayerStackEntryResource`
- catalog-backed adapter
- sample catalog resource
- catalog key を使う editor / adapter test
- layer stack apply path

設計としては良い。`catalog key` を中心に置き、atlas tile / scene tile / fallback を catalog entry に閉じ込める方向は、当初ロードマップの意図に合っている。

改善余地:

- Godot Editor上の「Catalog resource picker」「Catalog entry list」「Tile preview grid」が、完全な画面UXとして完成しているとは言いにくい。
- Layer Stack は Resource/API として成立しているが、「Layer stack作成ボタン」や「roleごとの可視性・lock・z_index操作」をユーザーが画面で理解できる導線は弱い。
- `source_id / atlas_coords` が advanced fallback に下がる思想は実装されているが、旧UIの数値入力との情報設計の整理は追加余地がある。

### 3.3 Goal C: Gameplay Query & Validation Layer

**評価: 達成度 中〜高**

当初UXでは、movement cost、unit profile、range preview、connectivity validation、runtime query API が重要視されていた。

今回の実装では、以下が確認できた。

- `HexMovementProfileResource`
- `HexGameplayLayerData`
- weighted path / movement range API
- profile-specific reachability validation
- debug overlay / range overlay state
- runtime query sample
- validation dashboard / validation result

`floor/wall` 二値から gameplay-facing query に進んでおり、設計方向は良い。

改善余地:

- danger / influence / visibility / line of sight / height / cover / dynamic occupancy はまだ未到達。
- movement profile の範囲では十分だが、ゲームジャンルごとの意味論を拡張するには validation rule plugin あるいは rule registry がほしい。
- debug overlay は headless状態のテストはあるが、画面での見え方・色・凡例・切替手順の analog test が不足している。

### 3.4 Goal D: Object / Scene Placement

**評価: 達成度 中〜高**

当初UXでは、object mode を marker から object placement / scene placement に昇格することが狙いだった。

今回の実装では、以下が確認できた。

- `HexObjectDatabaseResource v2`
- `HexObjectDefinitionResource`
- typed object placement schema
- object layer adapter
- scene tile prototype path
- direct instance prototype path
- object validation
- runtime object export

設計上、object definition と object placement が分離されている点は良い。authoring document と runtime export を分けようとしている点も、ロードマップの懸念に沿っている。

改善余地:

- Editor上の object property editor は、key/value table、enum、resource reference まで自然に扱える完成UXにはまだ見えない。
- scene tile と direct instance の両系統は実装されているが、ユーザー向けには「どちらをいつ使うか」の選択導線がさらに必要。
- sample catalog の `object.spawn_marker` が `res://addons/hex_map_kit/debug/hex_spawn_marker.tscn` を参照しているが、該当sceneがリポジトリ内で見つからない。これは公開前に修正すべきである。

### 3.5 Goal E: Generation QA / Seed Lab

**評価: 達成度 中**

当初UXでは、batch generate、validation suite、score table、preview thumbnails、promote seed、golden seed tests が必要UXだった。

今回の実装では、Generate Dock に以下の headless/data API が追加されている。

- `run_generation_batch()`
- `generation_batch_results()`
- `generation_batch_score_table()`
- `promote_generation_batch_row()`
- `promote_generation_seed_to_document()`
- golden seed fixtures / tests

設計としては正しい。生成結果を document metadata / validation / promotion に接続する流れができている。

改善余地:

- 画面上の batch runner / score table / promote action / thumbnail preview は、まだ「ユーザーが触る完成ダッシュボード」として弱い。
- Pass/fail rule editor は未到達に見える。
- Score table の評価指標は今後増えるため、score schema と表示列の拡張方針を固めたい。

### 3.6 Goal F: Editor Architecture Refactor

**評価: 達成度 中**

当初UXでは、巨大dockを増築し続けず、Generate/Edit共通状態、session state、UI construction、mutation logic、viewport input adapter を分離することが狙いだった。

今回の実装では以下が追加されている。

- `HexMapEditorSessionState`
- `HexMapGenStateEvaluator`
- `HexMapEditMutationBuilder`
- `HexMapEditViewportInputAdapter`
- `HexMapDocumentInspector`
- `HexMapValidationDashboard`

方向性は良い。ただし、主要ファイルは依然として大きく、今回の実装でさらに増えている。

確認した規模:

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`: 4,385 lines
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`: 3,126 lines
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`: 1,886 lines
- `tests/test_editor_plugin.gd`: 4,400 lines

改善余地:

- helperを作るだけでなく、既存巨大ファイルから責務をさらに移動する必要がある。
- 新機能追加時に巨大dockへ直接UI/状態/validation/report logicを追加しないガードが必要。
- `test_editor_plugin.gd` も、機能別 test file へ段階分割すると保守性が上がる。

### 3.7 Phase 7: Public Package / Examples

**評価: 達成度 中〜高**

確認できた成果:

- `examples/basic_runtime`
- `examples/editor_workflow`
- `docs/api/API_REFERENCE.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MIGRATION_V0_2_TO_V0_3.md`
- `tools/package_addon.sh`
- `dist/hex_map_kit-0.3.0.zip`
- `dist/hex_map_kit-0.3.0.manifest.txt`

package script は良い。`--check` で一時 package を作り、dev-only path が混入していないか確認する構成になっている。

改善余地:

- committed `dist/hex_map_kit-0.3.0.manifest.txt` は 103 entries / 40 `.uid` entries だった。
- 現在の addon tree から `tools/package_addon.sh --check` で生成した manifest は 123 entries / 56 `.uid` entries だった。
- つまり、`dist` 配下の配布物が現在の addon tree より古い可能性が高い。

公開前には、`tools/package_addon.sh` で `dist` を再生成し、manifest差分を確認すべきである。

---

## 4. UXを実現する設計ができているか

### 4.1 できている点

今回の設計は、当初ロードマップの中心課題に対してかなり素直に対応している。

特に良い点:

1. **Level Document v2 を中心に据えたこと**  
   すべての後続機能の保存・検査・runtime load の土台として妥当。

2. **Asset identity を catalog key に寄せたこと**  
   `source_id / atlas_coords` の増殖を止める方向として正しい。

3. **ValidationResult を標準化したこと**  
   Editor UI、debug report、test、runtime handoff の間に共通言語ができている。

4. **Object definition と placement を分離したこと**  
   既存の曖昧な Array payload 増築を避けられている。

5. **Runtime query sample を入れたこと**  
   addonがEditor専用で終わらず、ゲーム実装から利用できるAPIへ進んでいる。

6. **Examples / API docs / migration guide を同時に進めたこと**  
   public package を意識した到達点として良い。

### 4.2 設計上の注意点

設計に致命的な破綻は見当たらない。ただし、以下は今後の事故点になりやすい。

#### 注意点1: v1互換とv2 canonical stateの二重管理

v1 fields を残した互換戦略は正しいが、v2が成熟するほど二重管理のバグが増える。

推奨:

- public mutation は v2 helper に寄せる。
- v1 fields は migration / compatibility / export fallback として扱う。
- v1/v2同期を直接テストする regression case を増やす。

#### 注意点2: Validation issue が Dictionary schema に寄っている

`HexMapValidationResult` が柔軟な Dictionary issue を持つ設計は、初期MVPとしては良い。一方、public APIとしては rule id / severity / scope / cell / object id などの accessor が必要になる。

推奨:

- rule id constants を用意する。
- issue creation helper を増やす。
- UI側が Dictionary key 文字列を直接組み立てないようにする。

#### 注意点3: Editor UIがAPI実装に追いついていない

Resource/API は広く実装されたが、画面上の情報設計はまだ追いついていない。

特に不足が大きいUX:

- Catalog entry list
- Tile preview grid
- Layer Stack作成・管理ボタン
- Batch generation score dashboard
- Object property editor
- Validation dashboardの手動操作手順
- Range/debug overlayの画面確認手順

#### 注意点4: Public package と sample asset の整合性

`sample_hex_tile_catalog.tres` の scene entry が存在しない scene path を指している可能性がある。これは初回体験を壊しやすい。

推奨:

- `res://addons/hex_map_kit/debug/hex_spawn_marker.tscn` を追加する。
- あるいは sample catalog の scene entry を package内に存在する path に変える。
- sample catalog が validator で clean になる test を追加する。

---

## 5. 実装上の改善点

### 5.1 最優先で直すべき改善

#### P1-1: sample catalog の欠落scene参照を修正する

確認内容:

```text
addons/hex_map_kit/assets/sample_hex_tile_catalog.tres
  key = "object.spawn_marker"
  scene_path = "res://addons/hex_map_kit/debug/hex_spawn_marker.tscn"
```

しかし、該当する `.tscn` がリポジトリ内で見つからなかった。

影響:

- Catalog validation で missing scene になる可能性がある。
- 初回ユーザーが sample catalog を使ったときに object / scene placement が壊れて見える。
- packageに含まれない debug path を sample asset が参照している可能性がある。

推奨修正:

1. packageに含める sample object scene を追加する。
2. sample catalog の `scene_path` をその scene に向ける。
3. `tests/test_hex_adapter.gd` に「sample catalog validates cleanly」を追加する。
4. `tools/package_addon.sh --check` でも required path として sample scene を確認する。

#### P1-2: `dist` artifact を再生成する

確認内容:

- committed `dist/hex_map_kit-0.3.0.manifest.txt`: 103 entries / 40 `.uid` entries
- 現在の addon tree から package check で生成した manifest: 123 entries / 56 `.uid` entries

影響:

- 配布zipが最新addon treeを反映していない可能性がある。
- 新規classの `.uid` がdistから欠けると、Godot側のclass認識やimportで不安定になる可能性がある。

推奨修正:

```sh
tools/package_addon.sh
```

その後:

```sh
tools/package_addon.sh --check
./tools/test.sh
```

#### P1-3: 新機能の analog test を追加する

自動テストは濃いが、今回増えたUXのうち、画面でしか判断できないものに対する手動手順が不足している。

追加推奨:

- `tests/analog_test/VALIDATION_DASHBOARD_CELL_FOCUS_ANALOG_TEST_2026-06-07.md`
- `tests/analog_test/CATALOG_SELECTOR_AND_TILE_PREVIEW_ANALOG_TEST_2026-06-07.md`
- `tests/analog_test/LAYER_STACK_EDITOR_WORKFLOW_ANALOG_TEST_2026-06-07.md`
- `tests/analog_test/OBJECT_PLACEMENT_EDITOR_ANALOG_TEST_2026-06-07.md`
- `tests/analog_test/GENERATION_QA_DASHBOARD_ANALOG_TEST_2026-06-07.md`
- `tests/analog_test/PACKAGE_CLEAN_PROJECT_ANALOG_TEST_2026-06-07.md`

### 5.2 中期改善

#### P2-1: Catalog UIを「Resource/API」から「画面UX」へ上げる

必要な画面要素:

- Catalog resource picker
- Catalog entry list
- Tile preview grid
- Missing asset warning
- Atlas / scene / fallback type badge
- Floor / Wall / Overlay / Object default assignment

#### P2-2: Generation QA を dashboard として完成させる

必要な画面要素:

- Batch count / seed range input
- Run batch button
- Score table
- Sortable columns
- Validation pass/fail filter
- Preview thumbnail or ASCII preview
- Promote selected seed button
- Promoted document path / dirty state display

#### P2-3: Object property editor をUIとして整える

必要な画面要素:

- object definition picker
- placement list
- property key/value table
- type-aware editor for bool/int/float/string/resource
- enum候補
- scene preview or icon
- direct instance / scene tile mode indication

#### P2-4: 巨大ファイルの成長を止める

推奨分割:

- `HexMapGenDock` から generation QA panel を分離。
- `HexMapEditTool` から catalog panel / object panel / validation panel を分離。
- `HexTileMapLayer` から object layer adapter / gameplay overlay painter をさらに分離。
- `tests/test_editor_plugin.gd` を feature別に分割。

---

## 6. 自動テスト評価

### 6.1 良い点

`tools/test.sh` は以下をまとめて確認する構成で、test gate としてよく機能している。

- package manifest check
- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`

また、各 Autopilot task の test result に PASS が記録されており、修正ログも残っている。これは自走開発の評価として重要である。

特に良い coverage:

- v1 -> v2 migration
- v2 document roundtrip
- catalog entry apply
- catalog validation
- layer stack apply
- validation rule matrix
- movement profile / weighted path / range
- object definition / placement / runtime export
- generation batch score / promotion
- package manifest check
- runtime sample / editor workflow sample

### 6.2 不足している自動テスト

#### sample catalog clean validation

sample catalog はユーザー初回体験の入口なので、validatorで clean になることを保証した方がよい。

推奨テスト:

```text
sample_hex_tile_catalog.tres を load
HexTileCatalogValidator.validate_catalog(sample)
重大 error が 0 件であることを確認
scene entry の scene_path が ResourceLoader.exists() で true
```

#### committed dist と現在addon treeの一致

`tools/package_addon.sh --check` は現在treeから一時packageを作るが、committed `dist` が最新であるかは別問題である。

推奨テスト:

```text
tools/package_addon.sh --output-dir <tmp>
diff <tmp>/hex_map_kit-0.3.0.manifest.txt dist/hex_map_kit-0.3.0.manifest.txt
```

公開前CIではこの差分が空であることを求める。

#### UI panel単位の headless test分割

現状は `tests/test_editor_plugin.gd` に依存が集中している。新機能ごとに以下を分けるとよい。

- `tests/test_editor_catalog_ui.gd`
- `tests/test_editor_validation_dashboard.gd`
- `tests/test_editor_object_placement_ui.gd`
- `tests/test_editor_generation_qa_ui.gd`

---

## 7. 自動テストで確認できない要件と画面操作手順

### 7.1 現状評価

画面操作用の手続きは、**一部は提供されているが、今回の新機能群に対しては不足している**。

既存の analog test:

- generated map manual edit
- loop duplicate edit
- manual edit viewport/debug reliability

既存 manual:

- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_SCRIPTING.md`
- `docs/manual/MANUAL_PACKAGE.md`

ただし、`MANUAL_EDITOR_PLUGIN.md` は主に既存 Generate Dock 中心であり、今回の新機能である Catalog selector、Validation Dashboard、Object Placement、Generation QA dashboard、Layer Stack workflow を目的別に操作できる手順としては不足している。

### 7.2 追加すべき画面操作手順

以下の手順は、analog test として新規ファイル化することを推奨する。

#### 手順A: Validation Dashboard cell focus

目的: Validate結果を見て、エラー行から該当cellへ移動できることを画面で確認する。

Operation Steps:

1. Godot Editorで addon を有効化する。
2. `Hex Map Edit` dock を開く。
3. 意図的に missing catalog / object on wall / outside payload を含む document を読み込む。
4. Validation panel または Validate button を実行する。
5. Error list に grouped issue が表示されることを確認する。
6. cell-scoped issue を選択する。
7. selected cell / focus / status detail が該当cellへ同期することを確認する。
8. Copy Debug Report に validation summary が含まれることを確認する。

Expected Observations:

- error / warning の severity が区別される。
- cellがあるissueはcell情報を表示する。
- cellがないdependency issueはdocument-level issueとして表示される。
- 通常statusは短く、debug reportは詳細である。

#### 手順B: Catalog selector and tile preview

目的: 数値入力ではなく catalog key で Floor / Wall / Overlay / Object を指定できることを確認する。

Operation Steps:

1. sample catalog を指定する。
2. Floor default key を選ぶ。
3. Wall default key を選ぶ。
4. Overlay item key を選ぶ。
5. Object key `object.spawn_marker` を選ぶ。
6. 生成または編集を実行する。
7. keyがdocumentに保存され、fallback numeric fieldsが主UXになっていないことを確認する。
8. missing asset を意図的に作り、warningが出ることを確認する。

Expected Observations:

- ユーザーが `source_id / atlas_coords` を知らなくても操作できる。
- invalid catalog entry は silent fallback ではなく warning になる。
- scene tile entry の missing scene が検出される。

#### 手順C: Layer Stack workflow

目的: document を layer stack に適用し、role別layerに分かれることを確認する。

Operation Steps:

1. `HexTileMapLayer` root を作成する。
2. Layer stack template を適用する。
3. terrain / overlay / object / debug role の child layer が作られることを確認する。
4. v2 document を apply する。
5. Terrain tiles、overlay tiles、object layer が別roleに反映されることを確認する。
6. 旧 plain `TileMapLayer` apply path が互換経路として残ることを確認する。

Expected Observations:

- role名がユーザーに理解できる。
- layerごとの visible / z_index / lock 方針が破綻しない。
- Generate Dock / Edit Dock の target state が食い違わない。

#### 手順D: Object placement editor

目的: object definition と placement が画面操作で破綻しないことを確認する。

Operation Steps:

1. Object database を指定する。
2. object definition を選ぶ。
3. map上のcellへ object placement を追加する。
4. rotation / variant / properties / spawn condition を編集する。
5. Save document を実行する。
6. Reload document を実行する。
7. object placement が同じ内容で復元されることを確認する。
8. wall cell に配置した場合、validation が warning/error を出すことを確認する。

Expected Observations:

- definition と placement が混ざらない。
- properties が壊れず roundtrip する。
- object display layer と document state が同期する。

#### 手順E: Generation QA / Seed promotion

目的: 複数seedを比較し、選んだseedを Level Document に昇格できることを画面で確認する。

Operation Steps:

1. Generate Dock を開く。
2. batch count と seed range を指定する。
3. Batch generate を実行する。
4. score table を確認する。
5. validation pass/fail で比較する。
6. 任意のseedを選択する。
7. Promote to Level Document を実行する。
8. promoted document の metadata に seed / generator snapshot が入ることを確認する。
9. Save / reload 後に同じdocumentとして扱えることを確認する。

Expected Observations:

- score table が理解できる。
- promote操作がUndo/Redoまたは明確なdirty stateを持つ。
- validation failure のseedを誤って採用しにくい。

#### 手順F: Clean package install

目的: addon-only package を新規Godot projectへ入れた時に、examples / docs / sample catalog が破綻しないことを確認する。

Operation Steps:

1. `tools/package_addon.sh` で package を作成する。
2. 新規Godot 4.6.2 project を作る。
3. package zip から `addons/hex_map_kit` を導入する。
4. plugin を有効化する。
5. sample catalog を開く。
6. `examples/basic_runtime` 相当の runtime query scene を開く。
7. `examples/editor_workflow` 相当の document を作成する。
8. Validation を実行する。
9. missing script / missing uid / missing scene が出ないことを確認する。

Expected Observations:

- Plugin load error がない。
- sample catalog がcleanまたは期待warningのみ。
- Editor dock が開く。
- Runtime sample が editor-only dependency なしで動く。

---

## 8. 追加で重要な観点

### 8.1 CIがまだ見当たらない

`.github/workflows` は確認できなかった。Autopilotが全taskを通過する設計になったなら、次はCIで Godot headless / package check を固定するのが重要である。

推奨CI:

- Godot 4.6.2 headless setup
- `tools/package_addon.sh --check`
- `./tools/test.sh`
- dist manifest freshness check
- sample catalog clean validation

### 8.2 「MVP API完成」と「ユーザーが迷わず触れるUX完成」を分ける

今回の到達は、かなり強いMVP API完成である。一方、ロードマップで求めていた「ゲーム開発者が自然に使えるUX」としては、画面上の導線がまだ薄い部分がある。

今後の評価では、以下を分けるとよい。

- Resource/API complete
- Headless test complete
- Editor screen workflow complete
- Analog test complete
- Manual complete
- Package install complete

### 8.3 Autopilot queue の完了判定を二段階にする

現在はすべて `COMPLETE` だが、画面UXやmanualが追いついていないものもある。

推奨status:

- `CODE_COMPLETE`
- `HEADLESS_TEST_COMPLETE`
- `EDITOR_WORKFLOW_COMPLETE`
- `ANALOG_TEST_COMPLETE`
- `PACKAGE_READY`

これにより、「実装は通ったが、画面操作手順がない」状態を明確にできる。

---

## 9. 推奨する次の自走タスク

### NEXT-01: Sample catalog package integrity

目的:

- sample catalog の missing scene / missing asset をなくす。
- package install 初回体験を壊さない。

Acceptance:

- `sample_hex_tile_catalog.tres` が validator clean になる。
- scene entry の `scene_path` が package内に存在する。
- test が追加される。
- `tools/package_addon.sh --check` がPASS。

### NEXT-02: Dist artifact freshness check

目的:

- committed `dist` と現在addon treeのズレを防ぐ。

Acceptance:

- `tools/package_addon.sh` で `dist` 再生成。
- committed manifest と一時生成manifestの差分チェックを追加。
- `./tools/test.sh` に統合、または release check script に統合。

### NEXT-03: New feature analog test pack

目的:

- 自動テストで確認できない新UXに、画面操作手順を与える。

Acceptance:

- `tests/analog_test/` に新規6本程度の手順書を追加。
- `docs/TEST.md` から参照。
- 各手順に Operation Steps / Expected Observations / Failure Signals / Evidence To Attach を含める。

### NEXT-04: Catalog / Validation / QA screen manual update

目的:

- `MANUAL_EDITOR_PLUGIN.md` を現行v0.3 UXへ更新する。

Acceptance:

- Catalog selector
- Layer Stack workflow
- Validation Dashboard
- Object Placement
- Generation QA / Seed promotion
- Copy Debug Report
- Clean package install

を目的別に説明する。

### NEXT-05: Editor file-size containment

目的:

- 巨大dockへの増築を止める。

Acceptance:

- 新規 feature panel は独立scriptへ移す。
- `HexMapGenDock` / `HexMapEditTool` の追加行数を抑える。
- `tests/test_editor_plugin.gd` から feature-specific tests を分離する。

---

## 10. 最終結論

今回の autopiloting 開発は、当初ロードマップの **設計上の芯** にはかなり届いている。

特に、以下は成功している。

- Level Document v2 の土台
- catalog key 中心の asset identity
- Layer Stack resource / apply path
- validation result / dashboard / debug report連携
- movement profile / weighted path / range query
- object definition / placement / runtime export
- generation batch / score / promotion API
- examples / docs / package script
- queue / self-review / test-result による自走開発記録

したがって、設計自体を大きく戻す必要はない。

次にやるべきことは、設計のやり直しではなく、**公開前のUX仕上げ** である。

優先順は以下。

1. sample catalog の missing scene / package整合性を直す。
2. `dist` を現在のaddon treeから再生成する。
3. 新機能用 analog test を追加する。
4. `MANUAL_EDITOR_PLUGIN.md` を v0.3 の画面操作中心に更新する。
5. Catalog / Validation / Generation QA / Object Placement を screen workflow として磨く。
6. 巨大dockと巨大editor testを段階分割する。

現在の状態は、**内部設計と自動テストは強い。画面UXと配布前検証を仕上げれば、当初ロードマップのMVPとしてかなり説得力がある**、という評価である。

