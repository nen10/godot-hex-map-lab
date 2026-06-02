# REVIEW_BACKLOG_2026-06-02.md

## 目的

`docs/review` 直下に蓄積したレビュー文書から、未対応項目と今後の提案をユースケース単位で抽出する。抽出元レビューは整理後に `docs/review/_history/` へ移動する。

この文書は実装順序ではなく、ユーザーが重要性を判断するための候補一覧である。実装へ進める場合は、個別に入力・出力・resource schema・テスト概要を持つ plan を作る。

## 抽出方針

- `docs/TEST.md` と `docs/complete_on_test/` で完了根拠がある項目は未対応候補に含めない。
- ユーザーが「不要」と判断した項目は候補から除外する。
- ユーザーが「優先度低い」と判断した項目は低優先候補として残す。
- fallback 記述は仕様根拠にせず、正規仕様へ置き換える必要がある場合だけ候補にする。

## U1. Manual Map Editing の実Editor可視化

Use case:

Godot Editor上で生成済みmapをHex Map Editへimportし、viewport上のcellをclickしたとき、document mutation、target layer redraw、保存・exportの成否がユーザーに明確に見える。

Planning Flow:

- UX: `docs/plan/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_UX_2026-06-02.md`
- 方針: `docs/plan/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_POLICY_2026-06-02.md`
- 詳細: `docs/plan/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_IMPLEMENTATION_PLAN_2026-06-02.md`
- Review: `docs/plan/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_PLAN_REVIEW_2026-06-02.md`

抽出候補:

1. Viewport click後の表示反映を実Editorで切り分ける。
   - 説明: ユーザーレビューでは `Edited <clicked-coordinate>` がDockに表示される一方、editor viewport上のtile変化が見えない。documentが更新されたのか、target layer redrawが失敗したのか、TileSet / target class / apply設定の問題なのかを判別する必要がある。
   - Evidence: `MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md`
   - Test候補: analog rerun、クリック後のdocument wall count、target layer used cells、atlas coords、save/export後resource stateを確認する。

2. Plain `TileMapLayer` target と `HexTileMapLayer` target の表示要件を明確にする。
   - 説明: manual editはplain `TileMapLayer` fallbackと`HexTileMapLayer` loop-aware targetの両方を扱う。ユーザーがGodot標準 `TileMapLayer` を使ってよいか、Sample TileSet / floor-wall atlas / orientation applyが必要かをDock statusで判断できるようにする。
   - Evidence: `GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md`, `GENERATED_MAP_MANUAL_EDIT_FAILURE_ANALYSIS_2026-06-01.md`, `MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md`
   - Test候補: plain `TileMapLayer` と `HexTileMapLayer` の2ケースでviewport edit後のredrawを比較する。

3. Editor viewport input routingの実機確認をanalog testへ残す。
   - 説明: headlessでは`EditorPlugin._handles()`を直接実行できないため、`_handles()`とEditor selection syncの実挙動は実Editor観察が必要。
   - Evidence: `MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md`, `MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_PLAN_REVIEW_2026-06-01.md`
   - Test候補: pan / zoom済み2D viewport、Scene Tree selectionがtarget以外、Target Refresh後、explicit Target選択後のclick。

4. viewport debug情報をDock上で見える形にする。
   - 説明: `debug_viewport_input` はOutput panelへの `print()` であり、analog test中に見落とされやすい。target path、mode、viewport/scene/local position、canonical/visual hex、exists、appliedをDock内statusまたはdebug detailとして見られると失敗境界を報告しやすい。
   - Evidence: `GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md`, `MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md`
   - Test候補: outside cell、target missing、document missing、redraw applied false のstatus表示。

5. last edit highlightの扱いを決める。
   - 説明: 現状は最後に編集したcanonical cellをhighlightするが、前回highlightを消さないため編集済みcellが増える。履歴表示として残すか、last-only selectionとして更新するかを決める必要がある。
   - Evidence: `MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md`
   - Test候補: 連続2cell編集後のhighlight数とstatus。

## U2. Manual Edit Document / Payload Schema

Use case:

手動編集結果を `HexMapDocumentResource` として保存し、tile override、object、labelを迷わず編集・再利用できる。

抽出候補:

1. floor / wall default tile apply設定をHex Map Edit Dockに接続する。
   - 説明: documentのtile override payload controlsはあるが、target redraw時のdefault floor / wall source_id / atlas_coordsはDock UIから指定しにくい。
   - Evidence: `MANUAL_MAP_EDITING_TOOL_REVIEW_2026-05-31.md`
   - Test候補: Dockでdefault floor/wall tileを変更し、manual wall/floor edit後のtarget tileに反映する。

2. object / label databaseのdefinitionとplacement命名を分ける。
   - 説明: `HexMapDocumentResource.objects` は配置結果、`HexObjectDatabaseResource.objects` は定義候補であり、同じ名前だと用途が混同しやすい。
   - Evidence: `MANUAL_MAP_EDITING_TOOL_REVIEW_2026-05-31.md`, `ADDITIONAL_REVIEW_NEXT_REQUIREMENTS_2026-05-31.md`
   - Test候補: database definitionからplacement payloadを選び、document保存後もplacementとして復元する。

3. `tile_overrides.item_key` の扱いを決める。
   - 説明: 現状はfloor / wall kindでapplyされ、`item_key` はoverlay itemとの将来連携候補として残っている。schema revisionで分離するか、用途を定義するかを決める。
   - Evidence: `MANUAL_MAP_EDITING_TOOL_REVIEW_2026-05-31.md`, `ADDITIONAL_REVIEW_NEXT_REQUIREMENTS_2026-05-31.md`
   - Test候補: floor/wall overrideとoverlay item overrideを同じcellに持つ場合の保存・apply。

4. Resource load失敗時のstatusを具体化する。
   - 説明: `load()` がnullを返す場合も型不一致として扱われる。ファイル未存在、型違い、保存失敗を区別すると操作ミスを報告しやすい。
   - Evidence: `MANUAL_MAP_EDITING_TOOL_REVIEW_2026-05-31.md`
   - Test候補: missing path、wrong resource type、invalid save directoryのstatus。

## U3. Runtime Loop Display / Gameplay Layer

Use case:

Runtime表示やmanual edit用表示で、toric duplicate、path、hover、connected componentを見た目とidentityの両方で一貫して扱う。

抽出候補:

1. `_loop_tile_map` のscene save / reload roundtripを検証する。
   - 説明: loop copy layerはinternal childとして追加される。scene保存・再読み込み時にduplicate childが増えないこと、base/copy layer識別が維持されることを確認する。
   - Evidence: `MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md`
   - Test候補: `PackedScene.pack()` / instantiate後のinternal TileMapLayer数、tile_set共有、duplicate tile表示。

2. loop display関連Inspector項目を整理する。
   - 説明: runtime input、hover、loop display、tile settingsが並列にexportされており、Inspector上で目的別に探しにくい。グループ化やカテゴリ分けを検討する。
   - Evidence: `RUNTIME_INTERACTION_LOOP_PATH_REVIEW_2026-05-31.md`
   - Test候補: script metadataやexport groupはheadlessで確認しづらいため、必要ならEditor観察。

3. debug sceneのloop path / cell hit操作を手動確認項目として維持する。
   - 説明: headless testはtoggle stateとデータを確認するが、`L` / `C` / `P` の実キー操作と見た目はEditor/debug画面で確認する必要がある。
   - Evidence: `RUNTIME_INTERACTION_LOOP_PATH_REVIEW_2026-05-31.md`
   - Test候補: `tools/debug_generated_map.sh` で path連続性、cell hit表示、duplicate tile表示を観察する。

4. toric period candidate計算の最適化を検討する。
   - 説明: 表示範囲に応じた `_toric_period_candidates()` は正しく動くが、period基準が過大なcandidate数を生む可能性がある。性能問題が出た場合に最適化対象にする。
   - Evidence: `RUNTIME_INTERACTION_LOOP_PATH_REVIEW_2026-05-31.md`, `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`
   - Test候補: 大きいtoric sizeと広いdisplay rectでentry数と処理時間を測る。

## U4. Query Row / Hex Cell Editor UI

Use case:

Source Registry、Mask Query Row、Reference Query Row、Deductor Floor Sourceを、狭いDockでも誤操作しにくく、resourceとitem keyの関係が読み取りやすいUIにする。

抽出候補:

1. Query Row全体の構成を再検討する。
   - 説明: ユーザーはResource名 label + ItemKey combo、スクロール可能なcombo、offset label隣のhex cell panel、SpinBox風Up/Downを要望した。多くは実装済みだが、Query Row全体の見た目・配置は継続して観察対象。
   - Evidence: `HEX_CELL_BUTTON_EDITOR_UI_REVIEW_2026-05-31.md`
   - Test候補: source数・item key数が多いfixtureでpopup高さ、row幅、offset操作を確認する。

2. HexCellButtonPanelのtheme追従を検討する。
   - 説明: `_entry_fill()` 色はハードコード。Editor dark/light themeとの整合やDistribution Editor既存色との統一が必要になった場合に扱う。
   - Evidence: `HEX_CELL_BUTTON_EDITOR_UI_REVIEW_2026-05-31.md`, `RUNTIME_INTERACTION_LOOP_PATH_REVIEW_2026-05-31.md`
   - Test候補: theme切替時の色コントラストを画像または手動で確認する。

3. Denseなpressable hex panelの境界hit仕様を決める。
   - 説明: `cell_gap = 0` の境界clickはentry順序に依存して決定論的に処理される。現Query Rowでは重大ではないが、将来disc/ringなど密なpressable panelを使う場合は仕様化が必要。
   - Evidence: `HEX_CELL_BUTTON_EDITOR_UI_REVIEW_2026-05-31.md`
   - Test候補: disc shapeで境界点をclickしたときの選択規則。

4. helper統合は利点が明確になってから扱う。
   - 説明: `_query_direction_*` map helper統合はレビュー候補にあったが、ユーザーは利点が不明と判断している。実装前に重複削減の効果を説明する。
   - Evidence: `HEX_CELL_BUTTON_EDITOR_UI_REVIEW_2026-05-31.md`
   - Test候補: helper統合後もQuery Row offset、label、tooltip、metadataが同じ。

## U5. Editor Dock UX / Overlay Generation

Use case:

Primary / Overlay generation Dockで、生成条件、source状態、write mode、crop状態がユーザーに読み取りやすい。

抽出候補:

1. Apply Write / Existing Item policyのラベルとdisabled表示を整理する。
   - 説明: `Apply Write` はtarget layerへの書き込みとcurrent overlay更新方式の両方を含み、意味が読み取りにくい。Primary modeではExisting Item policyをMerge相当で固定・disabledにする案がある。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`
   - Test候補: Primary / Overlay / Crop result applyのpolicy matrix。

2. Deductor Floor Source statusをユーザー向け文言にする。
   - 説明: `"Default: generated complement"` は実装者向けに見える。生成済みitemを除いたfloor候補であることを説明する文言へ変える。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`
   - Test候補: 未指定時と明示指定時のstatus。

3. Source Registry / Overlay source stackの状態表示を維持・拡張する。
   - 説明: itemごとのcell数やresource path、reload結果、stack合成対象数はquery source選択の判断材料になる。現行testに含まれる範囲は維持し、足りない表示があれば追加する。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`, `docs/TEST.md`
   - Test候補: `HexMapResource` / `HexOverlayResource` / empty stack / reload失敗。

4. Generate Historyの配置を見直す。
   - 説明: seed周辺よりSave / Generateに近い概念として配置した方が意図が明確になる可能性がある。ユーザー追記ではレイアウト調整予定。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`
   - Test候補: history追加、cancel時非追加、表示名。

## U6. Crop Retained Recalculation

Use case:

Crop結果を見ながら、shape、size、source、Mask Query Rowを調整したい場合に、Crop Offへ戻らず結果を再計算する。

抽出候補:

1. 既存planを実装するか、使用感確認まで保留するか判断する。
   - 説明: `docs/plan/CROP_RETAINED_RECALC_POLICY_2026-05-31.md` と implementation plan は残っている。一方、ユーザー追記では「使用感が報告されていない状況で検討が先走っている」とされている。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`, `docs/plan/CROP_RETAINED_RECALC_POLICY_2026-05-31.md`
   - Test候補: retained modeでQuery Row編集後にcrop resultが再評価される。通常modeは従来通りCrop Offに戻る。

## U7. Public Sample / API Package

Use case:

addonを外部利用できるように、sample project、sample scene、API reference、package構成を整える。

抽出候補:

1. 既存planの実行範囲を決める。
   - 説明: `docs/plan/PUBLIC_SAMPLE_API_PACKAGE_POLICY_2026-05-31.md` と implementation plan が残っている。packaging scriptやexample projectを `tools/test.sh` 標準対象に入れるかoptionalにするかは判断が必要。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`, `BRAINSTORM_OPEN_TOPICS_PLAN_REVIEW_2026-05-31.md`
   - Test候補: sample scene load、public API script test、addon package file list。

## U8. Core / Adapter Maintainability

Use case:

Core APIとDock snapshot境界を整理し、今後の生成方式追加時に引数や重複処理が増えすぎないようにする。

抽出候補:

1. Adjacency item generation APIを`options: Dictionary`化するか検討する。
   - 説明: generated reference対応で `generate_toric_adjacency_items` の引数が長くなっている。positional argumentsを増やし続けるのはfallback的で、options化の候補がある。
   - Evidence: `GENERATIVE_REFERENCE_ITEMKEY_REVIEW_2026-05-31.md`, `ADDITIONAL_REVIEW_NEXT_REQUIREMENTS_2026-05-31.md`
   - Test候補: 既存呼び出し互換、interruptible options、cancel。

2. Reference Source modelの一般化を検討する。
   - 説明: generated referenceはAdjacency Reference向け。random / symmetric toric itemsに統一的reference sourceを入れるかは、生成順序や確率独立性との相性を考える必要がある。
   - Evidence: `GENERATIVE_REFERENCE_ITEMKEY_REVIEW_2026-05-31.md`
   - Test候補: generated referenceが有効な生成方式と無効な生成方式を明示する。

3. toric source代表展開の共有化。
   - 説明: 同一 `cyclic_size` のQuery Rowが複数ある場合、代表逆引きmapを共有して評価コストを下げられる。ユーザー判断は低優先。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`
   - Test候補: 複数rowで結果一致、処理時間。

4. Adjacency Rules parse結果のcache。
   - 説明: 複数箇所でrules text parseが走る。ユーザー判断は低優先。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`
   - Test候補: valid / invalid status、全invalid block。

5. Shape universe計算をsnapshot経由に寄せる。
   - 説明: live UI stateを読む経路を減らし、generation thread境界を明確にする。ユーザー判断は低優先。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`
   - Test候補: UI値とsnapshot値のuniverse一致。

6. Deductor Floor Sourceの未使用引数とfallback由来名を整理する。
   - 説明: `_overlay_deductor_floor_cells_for_snapshot(default_floor_cells)` の引数は不要になっている可能性がある。ユーザー判断は低優先。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`
   - Test候補: snapshotだけで必要状態が残る。

## U9. Documentation / Analog Test

Use case:

レビューや実装結果を追いやすくし、Editor実操作が必要な範囲をユーザーが判断できる。

抽出候補:

1. `GENERATED_MAP_MANUAL_EDIT` analog testを再実行可能な状態に保つ。
   - 説明: 旧analog resultはStep 14 failを記録している。実装修正後もユーザーから「Dock statusは出るがviewport変化が見えない」と報告されているため、再実行時の観察項目を追加する価値がある。
   - Evidence: `GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md`, `MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md`
   - Test候補: click後のstatus、target tile coords、save/export result、Source Registry reload。

2. 完了承認済み機能のmanual / screenshot / section diagramはユーザー要望後に作る。
   - 説明: Source Registry、Query Row、Crop、Deductor、Apply Write、Generate HistoryまでDockが大きくなっているため、manual化候補はある。ただしmanualは仕様書ではなく、ユーザー要望または完了承認が条件。
   - Evidence: `BRAINSTORM_OPEN_TOPICS_2026-05-30.md`, `docs/plan/policy/ANALOG_TEST_POLICY.md`
   - Test候補: manualではなくanalog observationとして必要箇所を分割する。

## 除外した項目

- Reference Query Row空結果時の警告: ユーザーが不要と判断したため除外。
- Generative Reference ItemKeyの実装不足: レビュー上不足なし。関連計画は完了扱い。
- Runtime loop copy display / manual loop displayの主要要件: `docs/complete_on_test/実施順序_2026-06-01.md` の範囲として完了扱い。ただし実Editor可視化とscene roundtripはこのbacklogに残す。
- Hex Cell Button Editor UIの主要要件: Codex対応結果とテスト通過により完了扱い。theme追従やdense panel境界hitなど用途依存の改善だけ残す。

## 抽出元レビューと扱い

| Source | 扱い |
| --- | --- |
| `docs/review/_history/BRAINSTORM_OPEN_TOPICS_2026-05-30.md` | U4-U9へ抽出 |
| `docs/review/_history/BRAINSTORM_OPEN_TOPICS_PLAN_REVIEW_2026-05-31.md` | U6-U7と計画化時の注意へ抽出 |
| `docs/review/_history/ADDITIONAL_REVIEW_NEXT_REQUIREMENTS_2026-05-31.md` | U1-U3、U8へ抽出。完了済みloop/manual主要要件は除外 |
| `docs/review/_history/GENERATIVE_REFERENCE_ITEMKEY_REVIEW_2026-05-31.md` | U8へ抽出 |
| `docs/review/_history/RUNTIME_INTERACTION_LOOP_PATH_REVIEW_2026-05-31.md` | U3へ抽出 |
| `docs/review/_history/RUNTIME_MANUAL_LOOP_DISPLAY_PLAN_REVIEW_2026-05-31.md` | 完了済みloop/manual主要要件として整理済み |
| `docs/review/_history/MANUAL_MAP_EDITING_TOOL_REVIEW_2026-05-31.md` | U2へ抽出。viewport inputは完了済みとして除外 |
| `docs/review/_history/MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_PLAN_REVIEW_2026-06-01.md` | U1へ抽出 |
| `docs/review/_history/MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md` | U1-U3へ抽出 |
| `docs/review/_history/GENERATED_MAP_MANUAL_EDIT_ANALOG_RESULT_2026-06-01.md` | U1とU9へ抽出 |
| `docs/review/_history/GENERATED_MAP_MANUAL_EDIT_FAILURE_ANALYSIS_2026-06-01.md` | U1へ抽出 |
| `docs/review/_history/GENERATED_MAP_MANUAL_EDIT_CODE_READING_2026-06-01.md` | U9へ抽出 |
| `docs/review/_history/HEX_CELL_BUTTON_EDITOR_UI_PLAN_REVIEW_2026-05-31.md` | U4へ抽出 |
| `docs/review/_history/HEX_CELL_BUTTON_EDITOR_UI_REVIEW_2026-05-31.md` | U4へ抽出 |
