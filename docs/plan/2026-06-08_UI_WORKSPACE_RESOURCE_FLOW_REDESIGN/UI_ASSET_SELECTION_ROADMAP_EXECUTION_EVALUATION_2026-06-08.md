# UI Asset Selection / Workspace Refinement Roadmap 実行評価 2026-06-08

作成日: 2026-06-08  
対象: `godot-hex-map-lab-20260608-073901.zip`  
評価対象 roadmap: `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ROADMAP.md`  
実行 queue: `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`  
参照元: `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`

---

## 0. 結論

今回の roadmap 実行は、**前回の CLEAN UI 評価で最大課題だった「Workspace tab の実体化」と「sample preset を production workflow から切り離す」方向に大きく前進している**。

特に良い点は以下である。

- `Document / Generate / Paint / Catalog / Layers / Validate / QA / Export / Settings` の各 tab に component / asset slot contract が定義された。
- `HexMapWorkspaceAssetContext` により、Level Document、Tile Catalog、Layer Stack、Object DB、Label DB、Generation Profile、Validation Rule Suite、Export Profile が共有 asset context として扱われるようになった。
- `HexMapEditorAssetSlotState` / `HexMapEditorAssetSlotControl` により、`Not selected / Selected / Invalid / Warning` の asset slot state が導入された。
- sample mode は default OFF で、Settings / Samples に隔離され、production flow の completion proof には使われない方針が test にも入った。
- arbitrary project asset selection / create-new / Save As / validation route が各 screen API と headless test に入った。
- `CLEANUP-30` により numeric fallback が Settings / Debug の明示 opt-in に隔離された。
- `CLEANUP-31` により raw object id / raw label id / raw JSON properties などの通常表示が抑制された。
- `PKG-70` / `PKG-71` により sample package と clean project asset flow が分離して検証された。

ただし、現時点の評価では **「headless API と state contract はかなり良いが、実クリックUIとしてはまだ危ない箇所がある」** という判定になる。

特に重要な未完了・要修正点は以下である。

1. `HexMapEditorAssetSlotControl` の `Select...` / `Open` / `Validate` / `Learn With Sample` 系 signal が `HexMapWorkspaceAssetPanel` 側で実際の動作に接続されていない。headless tests は workspace API を直接叩いているため、実際にユーザーがボタンを押したときの no-op を見逃す可能性がある。
2. `HexMapSampleSettingsPanel` の `Open` / `Duplicate To Project` ボタンも signal を emit するだけで、Workspace 側に接続されていない。tests は `duplicate_sample_catalog_to_project()` を直接呼ぶため、実ボタンの結線を保証していない。
3. sample mode ON が `Generate` / `Paint` の sample catalog fallback を有効化する設計は、明示 opt-in ではあるが「main selector に learning candidate を混ぜる」ため、production flow と learning flow の分離としてはまだ甘い。
4. `dist/hex_map_kit-0.3.0.manifest.txt` が現在の addon tree より古い。package check で一時生成される manifest は 144 entries だが、committed dist manifest は 127 entries で、今回追加された asset slot / sample settings / workspace asset context 関連ファイルが欠けている。
5. `docs/TEST.md` の手動 debug section は旧 `Hex Map Edit Dock` 前提や `sample preset` 言及が残っており、今回の「sample は learning / Settings 側」という方針と一部ズレている。

総合評価:

| 観点 | 評価 | コメント |
|---|---:|---|
| Roadmap queue completion | A | 27 task すべて COMPLETE。self-review / test-result も揃っている。 |
| Asset selection state model | A- | Slot state / context / ResourcePicker 方針は良い。sample path classification に改善余地。 |
| Production asset workflow | B+ | create/select/save/validate のAPIとtestは強い。実ボタン結線が弱い。 |
| Sample separation | B | default OFF / Settings隔離は良い。sample mode ON の main fallback はまだやや混ざる。 |
| Workspace tab content | B+ | 前回より大きく改善。各tabに asset panel はある。screen UIの深さはまだ差がある。 |
| Test quality | A- | sample-only completionを防ぐ契約は良い。実クリック結線と dist freshness は不足。 |
| Manual/docs | B | main manual は更新済み。`docs/TEST.md` の旧手順が残る。 |
| Package readiness | C+ | package scriptは正しいが committed `dist` が古い。 |

推奨判定:

```text
Roadmap implementation state: 機械的には COMPLETE
UX-production readiness: 主要方針は達成。ただし実ボタン結線と dist freshness は release blocker
次に必要: UI action wiring verification + sample route tightening + dist regeneration
```

---

## 1. Queue 実行状態

`IMPLEMENTATION_QUEUE.md` 上では、UI Asset Selection roadmap の scheduled task は 27 件あり、すべて `COMPLETE` である。

確認した task 群:

```text
ASSET-00, ASSET-01, ASSET-10, ASSET-11, ASSET-12,
SAMPLE-10, SAMPLE-11, SAMPLE-12,
WORKSPACE-10, WORKSPACE-11,
SCREEN-20, SCREEN-21, SCREEN-22, SCREEN-23, SCREEN-24, SCREEN-25, SCREEN-26, SCREEN-27,
CLEANUP-30, CLEANUP-31,
TEST-40, TEST-41, TEST-42,
DOC-50, DOC-51,
PKG-70, PKG-71
```

`docs/review/autopilot/*2026-06-08.md` には各 task の self-review と test result が存在し、多くの file に `./tools/test.sh` PASS が記録されている。

こちらの評価環境では Godot 実行ファイルがないため、再実行はできなかった。

```text
Godot executable not found. Set GODOT_BIN=/path/to/Godot.
```

したがって、テストに関する評価は以下に基づく。

- zip 同梱の PASS 記録
- `docs/TEST.md` の test path
- `tests/test_editor_plugin.gd` の静的確認
- addon / editor scripts の静的確認

---

## 2. 良かった点

### 2.1 Asset slot state model は良い

`HexMapEditorAssetSlotState` は今回の roadmap の中心成果として良い。

持っている状態:

```gdscript
STATUS_NOT_SELECTED
STATUS_SELECTED
STATUS_INVALID
STATUS_WARNING

SOURCE_NONE
SOURCE_PROJECT
SOURCE_SAMPLE
```

これにより、以前のような「sample preset があるから機能済み」という曖昧さではなく、各 asset slot が以下を表現できるようになった。

- required asset が未選択
- project asset が選択済み
- type mismatch
- warning
- explicit sample source
- sample source は current selection ではなく候補

`sample source` が `apply_sample_source()` を通してのみ current selection になる設計は、ロードマップ方針に合っている。

### 2.2 Workspace asset context は正しい方向

`HexMapWorkspaceAssetContext` が以下を一つの context として保持するようになった。

```text
level_document
tile_catalog
layer_stack
object_database
label_database
movement_profile
validation_rule_suite
generation_profile
export_profile
```

これは非常に良い。Generate / Paint / Validate / QA がそれぞれ sample を探しに行くのではなく、workspace context を共有することで、production project の asset selection を中心にできている。

### 2.3 Workspace tab は前回より明確に進んだ

前回評価では、Workspace tab はほぼ shell で、実体は `Generate` / `Paint` に偏っていた。今回は `WORKSPACE-10` / `WORKSPACE-11` により、各 tab が asset panel と component contract を持つようになっている。

現在の tab contract:

```text
Document: document_asset_panel
Generate: generation_panel
Paint: brush_palette, object_label_asset_panel
Catalog: catalog_asset_panel
Layers: layer_stack_asset_panel
Validate: validation_asset_panel, validation_issue_navigator
QA: qa_asset_panel
Export: export_asset_panel, export_destination_panel
Settings: settings_project_defaults_panel, sample_settings_panel
```

これは大きな前進である。少なくとも「空タブがある」状態からは脱している。

### 2.4 Sample default OFF は守れている

`HexMapEditorSessionState` では以下が default false である。

```gdscript
show_bundled_samples_in_main_selectors := false
use_bundled_sample_assets_for_scratch_documents := false
auto_create_project_copy_when_applying_sample := false
debug_numeric_tile_fallback_enabled := false
```

これは今回の方針に合っている。

特に、first-run CTA が `Learn with bundled samples` として Settings に遷移するだけで、sample catalog を勝手に Generate / Paint へ代入しない点は良い。

### 2.5 Clean project flow test は良い

`PKG-71` の clean project test は評価できる。sample mode OFF の状態で、以下を作る・選ぶ・検証する流れが test に入っている。

- project Level Document
- project Tile Catalog
- user TileSet
- project Object Database
- user PackedScene 由来 Object Definition
- validation issue の解消

これは「sample preset で動いたから完成」という誤判定を防ぐために有効である。

### 2.6 Raw controls の通常表示抑制は進んだ

`HexMapEditTool._refresh_payload_controls_visibility()` では、以下が通常表示から外れている。

- `source_id`
- `atlas_x / atlas_y`
- raw overlay item key
- raw object id
- raw object variant text
- raw spawn condition text
- raw JSON properties
- raw label id

代わりに、catalog option / object definition tree / scene picker / typed property editor / label definition tree が表示される方向になっている。これは今回の UI clean 方針に合っている。

---

## 3. 重要な問題点

### 3.1 AssetSlotControl の実ボタン結線が不足している

`HexMapEditorAssetSlotControl` は UI として以下のボタンを持つ。

```text
Select...
Create New...
Open
Clear
Validate
Learn With Sample
```

しかし、`HexMapWorkspaceAssetPanel` 側で接続されているのは主に以下だけである。

```gdscript
control.create_path_selected.connect(_on_create_path_selected)
control.clear_requested.connect(_on_clear_requested)
control.slot_state_changed.connect(_on_slot_state_changed)
```

`select_requested`、`open_requested`、`validate_requested`、`sample_requested` は panel / workspace 側に接続されていない。

影響:

- ユーザーが `Select...` を押しても、期待する resource picker / file dialog が開かない可能性が高い。
- `Open` を押しても Inspector focus / file open / resource focus が起きない可能性が高い。
- `Validate` を押しても slot-specific validation が起きない可能性が高い。
- `Learn With Sample` が表示される将来ケースで no-op になる可能性が高い。

headless tests は `workspace.create_tile_catalog()` や `workspace.create_object_database()` のような API を直接叩いているため、この実クリックUIの問題を見逃しやすい。

これは **release blocker 相当** と見る。

推奨 task:

```text
ASSET-NEXT-01 Wire asset slot UI actions
```

Acceptance:

- `Select...` が EditorResourcePicker focus または FileDialog を開く。
- `Open` が selected Resource を Inspector / filesystem で確認できる動作を持つ。
- `Validate` が slot-specific validation または owning screen validation を実行する。
- `Learn With Sample` は Settings / Samples へ誘導するか、sample source を明示適用する。
- tests は signal emit ではなく button press から workspace state change まで確認する。

### 3.2 SampleSettingsPanel の Open / Duplicate buttons が Workspace に接続されていない

`HexMapSampleSettingsPanel` は以下の signal を持つ。

```gdscript
open_sample_requested(sample_id, path)
duplicate_sample_requested(sample_id, path)
```

しかし `HexMapWorkspace` 側に接続が見当たらない。

現状 tests は以下のような direct method を呼んでいる。

```gdscript
panel.duplicate_sample_catalog_to_project(path)
HexMapSampleAssetDuplicator.duplicate_sample_catalog_to_project(path, context)
```

つまり、duplicate 機能そのものはあるが、**Settings UI のボタンを押した時に機能する保証が弱い**。

推奨 task:

```text
SAMPLE-NEXT-01 Connect Settings sample buttons to workspace actions
```

Acceptance:

- Settings / Samples の `Open` が sample resource を開く・Inspector focus する・または明確な status を出す。
- `Duplicate To Project` が FileDialog を開き、選択pathへ catalog/texture/scene を複製する。
- duplicate 後、project copy が Catalog slot へ `SOURCE_PROJECT` として入る。
- button press から結果までを headless test する。

### 3.3 Sample mode ON が main selectors へ混ざる設計はまだ少し危うい

現在の設計では sample mode OFF が default で、これは良い。

ただし、Settings の `Show bundled samples in asset selectors` を ON にすると、Generate / Paint の `tile_catalog()` が sample catalog fallback を返す経路がある。

```gdscript
if _tile_catalog == null and _sample_catalog_fallback_enabled():
    _tile_catalog = load(SAMPLE_TILE_CATALOG_PATH)
```

また docs でも「Sample mode ON exposes bundled learning candidates while keeping selected project assets primary」と説明している。

これはロードマップ上は許容範囲だが、ユーザーの今回の指針である **「sample preset はメインのゲーム開発経路とは別動線」** を厳密に読むなら、まだ少し混ざっている。

より清潔にするなら、次のどちらかが良い。

#### 案A: Demo Workspace Mode

Settings / Samples の `Learn with bundled samples` は、main selectors に候補を混ぜるのではなく、一時的な demo workspace context を開く。

```text
Production Context: project assets only
Demo Context: bundled samples only, clearly labeled
Duplicate To Project: Demo -> Production に移す唯一の道
```

#### 案B: Sample candidates visible but never fallback-selected

sample mode ON でも、Generate / Paint の actual catalog fallback としては使わない。

```text
OK: sample candidate listを見る
OK: Duplicate To Project
NG: no project catalogなのに Generate/Paint が sample catalogを自動使用する
```

推奨は案B。現在の設計からの差分が小さく、ユーザー指針により合う。

推奨 task:

```text
SAMPLE-NEXT-02 Remove sample fallback from main execution path
```

Acceptance:

- sample mode ON でも、project catalog 未選択なら Generate / Paint は `Not selected` または validation issue を出す。
- sample は candidate / preview / duplicate source に留まる。
- project asset を選択したらそれだけが execution source になる。
- tests は `show_bundled_samples_in_main_selectors = true` でも `_ensure_tile_catalog()` が sample catalogを実行用に返さないことを確認する。

### 3.4 Sample resource を手動選択した時の source classification が弱い

`HexMapEditorAssetSlotState.set_selected_resource()` の default source は `SOURCE_PROJECT` である。

```gdscript
func set_selected_resource(resource: Resource, path: String = "", source: String = SOURCE_PROJECT) -> void:
```

このため、ユーザーが ResourcePicker で `res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres` を直接選んだ場合、slot snapshot 上は `SOURCE_PROJECT` と扱われる可能性がある。

これは `TEST-40` の精神に反する抜け道になる。

推奨:

- `res://addons/hex_map_kit/assets/` 配下の bundled sample path は自動で `SOURCE_SAMPLE` に分類する。
- sample source が選ばれた場合は `Warning: bundled sample selected. Duplicate to project for production.` を出す。
- production completion test は sample path が `SOURCE_PROJECT` として通らないことを確認する。

推奨 task:

```text
ASSET-NEXT-02 Classify bundled sample paths as SOURCE_SAMPLE
```

### 3.5 committed dist が古い

今回の静的確認で、現在の addon tree と committed `dist/hex_map_kit-0.3.0.manifest.txt` が一致していなかった。

確認結果:

```text
addon source files: 144
committed dist manifest entries: 127
missing from committed dist: 17
package --check generated manifest entries: 144
missing from generated manifest: 0
```

committed dist に欠けている重要ファイル例:

```text
addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd
addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd
addons/hex_map_kit/editor/hex_map_sample_asset_duplicator.gd
addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd
addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd
addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd
addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd
```

`tools/package_addon.sh --check` は一時 package を正しく生成しているが、committed `dist` が更新されていない。

これは公開前には blocker である。

推奨 task:

```text
PKG-NEXT-01 Regenerate committed dist artifacts and add freshness check
```

Acceptance:

- `tools/package_addon.sh` を実行して `dist` を再生成する。
- committed `dist/manifest` と fresh generated manifest が一致する test を追加する。
- `tools/test.sh` または release check に freshness check を入れる。

### 3.6 docs/TEST.md の手動手順が旧UIを一部残している

`docs/manual/MANUAL_EDITOR_PLUGIN.md` はかなり更新されている。一方、`docs/TEST.md` の Debug 実行 section には以下のような旧表現が残っている。

- `Hex Map Edit Dock`
- Generate Dock / Hex Map Edit という旧2-dock前提
- `Target TileSet / Atlas` の `Browse` または sample preset
- Advanced convert / Export path 手順

analog test を保留する方針は守られているが、`docs/TEST.md` の手動 debug section は現在の Workspace / Settings / Samples / project asset selection 方針と少しズレている。

推奨:

- `docs/TEST.md` の manual debug section を `Workspace manual smoke checklist` に差し替える。
- `sample preset` という語は `Settings / Samples learning flow` に限定する。
- 旧 `Hex Map Edit Dock` 名を避ける。
- analog test はまだ追加しない。

---

## 4. 各 Roadmap 観点の評価

### 4.1 ASSET-* 系

評価: **A-**

Asset slot inventory、slot state model、workspace context、create-new resource actions は良い。

特に、`ASSET-10` と `ASSET-11` は今後の UI を支える基礎としてかなり有用である。

改善点:

- ResourcePicker で sample path を選んだときの `SOURCE_SAMPLE` classification。
- `Select...` / `Open` / `Validate` button wiring。

### 4.2 SAMPLE-* 系

評価: **B**

default OFF、first-run CTA、Settings / Samples、duplicate to project の方向は良い。

ただし、sample mode ON が main selector / Generate / Paint fallback に流れる設計は、ユーザー指針から見るとやや甘い。

望ましい最終形:

```text
Settings / Samples: Learn / Preview / Duplicate
Production tabs: Project assets only
```

### 4.3 WORKSPACE-* 系

評価: **B+**

前回指摘した「タブだけで中身が薄い」問題はかなり改善した。

ただし、各 tab はまだ asset panel 中心であり、Catalog details、Layer role editor、Validation issue editor、QA score table などは、`HexMapWorkspace` の snapshot/API と既存 dock/panel の混合に見える。

この段階は良い中間地点だが、最終UIとしてはさらに deep screen 化が必要。

### 4.4 SCREEN-* 系

評価: **B+**

Document / Catalog / Layer / Object / Paint / Validate / QA / Export の screen API と tests が揃ったことは大きい。

ただし、実クリックUIへの接続と視覚的な screen depth はまだ課題。

特に `SCREEN-21 Catalog` は、catalog resource / TileSet / entry creation はあるが、entry editor / preview grid / missing fix UI はまだ発展余地がある。

### 4.5 CLEANUP-* 系

評価: **A-**

numeric fallback quarantine と raw text authoring replacement は方向が良い。

残る課題:

- fallback option をさらに execution path から外す。
- overlay / label / variant / spawn の schema-driven editor を厚くする。
- raw text control を hidden にするだけでなく、古い state mutation path を徐々に削除する。

### 4.6 TEST-* 系

評価: **A-**

sample-only completion を防ぐ test contract は非常に良い。

ただし、現在の test は programmatic workspace API を中心にしており、button click wiring を保証していない。

追加すべき coverage:

- Asset slot `Select...` button press behavior
- Asset slot `Validate` button press behavior
- Settings / Samples `Duplicate To Project` button press behavior
- `show_bundled_samples_in_main_selectors = true` でも execution source が sample fallback にならないこと
- committed `dist` freshness

### 4.7 DOC / PKG 系

評価: **B**

manual はかなり良い。package script も良い。

問題は、committed `dist` が古いことと、`docs/TEST.md` の旧 manual debug 手順が残っていることである。

---

## 5. 次の推奨タスク

### `ASSET-NEXT-01_WIRE_ASSET_SLOT_UI_ACTIONS`

Priority: P0

目的:

- Asset slot の実ボタンが no-op にならないようにする。

対象:

- `HexMapEditorAssetSlotControl`
- `HexMapWorkspaceAssetPanel`
- `HexMapWorkspace`
- `tests/test_editor_plugin.gd`

Acceptance:

- `Select...` / `Open` / `Validate` / `Learn With Sample` が実動作を持つ。
- button press から workspace state change まで headless test する。
- ResourcePicker がある場合は `Select...` button を冗長にしない。不要なら button を消す。

### `SAMPLE-NEXT-01_CONNECT_SAMPLE_SETTINGS_BUTTONS`

Priority: P0

目的:

- Settings / Samples の `Open` / `Duplicate To Project` を実クリックで動作させる。

Acceptance:

- button press が Workspace action に接続される。
- Duplicate は FileDialog -> project copy -> Catalog slot project source まで進む。
- Open は Inspector focus / open status / resource preview のいずれかを持つ。

### `PKG-NEXT-01_REGENERATE_DIST_AND_FRESHNESS_CHECK`

Priority: P0

目的:

- committed `dist` を現在の addon tree と一致させる。

Acceptance:

- `dist/hex_map_kit-0.3.0.manifest.txt` が 144 entries 相当になる。
- asset slot / sample settings / workspace asset context scripts が dist に含まれる。
- fresh generated manifest と committed manifest の diff check がある。

### `SAMPLE-NEXT-02_REMOVE_SAMPLE_FALLBACK_FROM_MAIN_EXECUTION_PATH`

Priority: P1

目的:

- sample mode ON でも、production tabs の execution source は project asset selection を要求する。

Acceptance:

- `Generate` / `Paint` が project catalog 未選択時に sample catalog を execution source にしない。
- sample は visible candidate / duplicate source / demo material に留まる。
- tests は sample mode ON でも project asset missing state が維持されることを確認する。

### `ASSET-NEXT-02_CLASSIFY_BUNDLED_SAMPLE_PATHS_AS_SAMPLE_SOURCE`

Priority: P1

目的:

- user が ResourcePicker で addon sample を直接選んでも `SOURCE_PROJECT` にならないようにする。

Acceptance:

- `res://addons/hex_map_kit/assets/` の bundled sample path は `SOURCE_SAMPLE`。
- sample asset selected warning が出る。
- Duplicate To Project が推奨される。

### `DOC-NEXT-01_UPDATE_TEST_MANUAL_FOR_WORKSPACE_ASSET_FLOW`

Priority: P1

目的:

- `docs/TEST.md` の旧 Debug 実行手順を現行 Workspace / asset selection UX に合わせる。

Acceptance:

- `Hex Map Edit Dock` / old two-dock wording を削除または historical/debug に下げる。
- `sample preset` は Settings / Samples に限定する。
- analog test は追加しない。

---

## 6. 最終評価

今回の roadmap 実行は、前回の指摘に対してかなり正しく反応している。

特に、**sample preset を feature completion proof に使わない**、**project asset selection を production workflow とする**、**Workspace tab に asset slots を持たせる**、**sample mode を default OFF にする**、**clean project flow を test する** という点は、UX方針として正しい。

一方で、次の段階では「programmatic API でできる」から「ユーザーが実際にボタンを押してできる」へ評価基準を上げる必要がある。

最優先で直すべきは以下である。

```text
1. AssetSlotControl の Select/Open/Validate/Sample button wiring
2. SampleSettingsPanel の Open/Duplicate button wiring
3. committed dist の再生成
4. sample mode ON でも main execution fallback にしない設計の強化
5. bundled sample path を SOURCE_SAMPLE として分類
```

この5点を直せば、今回の asset selection roadmap はかなり強い UX foundation になる。
