# REVIEW_BACKLOG_2026-06-02.md

## 目的

`docs/review` 直下に蓄積したレビュー文書から、機能開発候補として Design Flow 化しうる未対応項目だけをユースケース単位で抽出する。

この文書は実装順序ではなく、ユーザーが重要性を判断するための候補一覧である。実装へ進める場合は、個別に入力・出力・resource schema・テスト概要を持つ plan を作る。

ユーザー確認事項、保留中の調査課題、除外項目、完了項目、抽出元レビューの扱いは `docs/plan/REVIEW_TRIAGE_2026-06-02.md` に分離する。

## 抽出方針

- `docs/TEST.md` と `docs/complete_on_test/` で完了根拠がある項目は含めない。
- ユーザー確認、analog test 実行結果待ち、調査未成熟な課題は含めない。
- ユーザーが「不要」と判断した項目は含めない。
- ユーザーが「優先度低い」と判断した項目は、実装候補として成立する場合だけ低優先候補として残す。
- fallback 記述は仕様根拠にせず、正規仕様へ置き換える必要がある場合だけ候補にする。

## U3. Runtime Loop Display / Gameplay Layer

Use case:

Runtime表示やmanual edit用表示で、toric duplicate、path、hover、connected componentを見た目とidentityの両方で一貫して扱う。

抽出候補:

1. loop display関連Inspector項目を整理する。
   - 説明: runtime input、hover、loop display、tile settingsが並列にexportされており、Inspector上で目的別に探しにくい。グループ化やカテゴリ分けを検討する。
   - Evidence: `RUNTIME_INTERACTION_LOOP_PATH_REVIEW_2026-05-31.md`
   - Test候補: script metadataやexport groupはheadlessで確認しづらいため、必要ならEditor観察。

2. toric period candidate計算の最適化を検討する。
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

## U7. Public Sample / API Package

Use case:

addonを外部利用できるように、sample project、sample scene、API reference、package構成を整える。

抽出候補:

1. 既存planの実行範囲を決める。
   - 説明: `docs/plan/pending/PUBLIC_SAMPLE_API_PACKAGE_POLICY_2026-05-31.md` と implementation plan が残っている。packaging scriptやexample projectを `tools/test.sh` 標準対象に入れるかoptionalにするかは判断が必要。
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

## U10. HexTileMapLayer State / Performance

Use case:

大きめmapでも、manual edit、Undo / Redo、Overlay applyが全画面再構築に見えず、Target内部stateと保存snapshotの境界を安全に扱える。

抽出候補:

1. target apply失敗時のdocument / target乖離を避ける。
   - 説明: `_apply_hex_tile_map_layer_edit_command()` はdocument更新後にtargetへcommandをapplyする。target applyがfalseの場合、表示は変わらないがSave対象だけ進む余地がある。
   - Evidence: `HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - Test候補: invalid commandまたはtarget apply失敗fixtureでdocument更新がskip / rollbackされる。

2. Generator Primary applyのstate API境界を読み取りやすくする。
   - 説明: 実装は `hex_map` setter経由でも成立しているが、計画意図に合わせるなら `load_map_resource()` 呼び出しへ揃えるか、setterが互換入口であることを短く説明する。
   - Evidence: `HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - Test候補: Generator Primary apply後の `HexTileMapLayer` state、display TileSet、orientation、floor / wall payload。

3. Target Status / Apply Statusを内部state境界が分かる文言へ整理する。
   - 説明: Primary mapとOverlayがどちらも `HexTileMapLayer` 内部layerへ書かれていること、Save / Export時はdocument snapshotが保存されることを通常statusで読み取りやすくする。
   - Evidence: `HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_REVIEW_2026-06-05.md`, `EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - Test候補: Target Statusのsemantic token、debug reportの詳細情報。

4. `EditorUndoRedoManager` 連携を必要時に別計画化する。
   - 説明: 現在はPluginから `EditorUndoRedoManager` を渡さず、headless `UndoRedo` の検証を維持している。Godot Editor本体のUndo stack統合が必要になった場合はadapterを作る。
   - Evidence: `HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_REVIEW_2026-06-02.md`, `HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - Test候補: EditorUndoRedoManager adapterのAPI差分、headless `UndoRedo` との分離。

## U11. Editor File / Resource Selection UX

Use case:

Document、Import / Export、Atlas Image、Source Registry、Generate Historyのpath操作で、上書き、失敗原因、通常statusとdebug detailの境界を誤認しない。

抽出候補:

1. Document rowの `Save` / `Save As` を分ける。
   - 説明: 現在の `Save As` buttonはpath設定済み時にdialogを開かず上書き保存する。Export rowと予測が揃わず、既存pathへ意図せず保存する可能性がある。
   - Evidence: `EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - Test候補: pathありDocumentのSave、path変更Save As、pathなしfallback。

2. Target Statusの通常表示とdebug reportの情報量を分ける。
   - 説明: Target StatusはTileSet path、source count、tile size、floor / wall / overlay payload、overlay visibilityを1行にまとめており、通常操作中に読み取りにくい。
   - Evidence: `EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - Test候補: 通常statusはready / document source / TileSet path / tile size程度、詳細はCopy Debug Reportへ残す。

3. invalid resource / path失敗原因を区別する。
   - 説明: 空入力系はbutton disabledで守られているが、存在しないpath、型違い `.tres`、texture load失敗、tile grid不一致などは押下後status中心で判明する。
   - Evidence: `EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`, `MANUAL_MAP_EDITING_TOOL_REVIEW_2026-05-31.md`
   - Test候補: missing path、unsupported resource type、load failed、invalid save directoryのstatus。

4. Source Registry失敗statusを分ける。
   - 説明: `load_mapdata_source()` はmissing pathとresource type mismatchが同じstatusになりやすい。Source Registryはquery source選択の入口なので失敗理由を分ける価値がある。
   - Evidence: `EDITOR_DOCK_FILE_RESOURCE_SELECTION_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - Test候補: missing path、HexMapResource、HexOverlayResource、unsupported resource、reload失敗。

## U12. Ordered Overlay Layer Architecture

Use case:

Effect、装飾Tile、ゲームUIなどを、Primary mapと独立した順序付きlayerとして編集・保存・表示できる。

抽出候補:

1. 順序付き複数Overlayを設計する。
   - 説明: 現行はPrimaryとOverlay表示が `HexTileMapLayer` に接続されたが、Floor / Wall修飾、Effect、ゲームUIなど複数layerの上下関係と編集対象選択を実現するゲーム開発UXの可能性が未設計である。
   - Evidence: `HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_REVIEW_2026-06-05.md`
   - Test候補: named overlay layer追加、z-order、active edit layer選択、保存schema、Generate Overlay適用先。
