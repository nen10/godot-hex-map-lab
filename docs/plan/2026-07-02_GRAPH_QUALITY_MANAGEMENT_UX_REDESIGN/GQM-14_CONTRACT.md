# Contract: GQM-14_RESULT_RESOURCE_SAVE_SWITCH

あなたは reliable executor (Codex)。**Depth: integrated**。

## 必読（この worktree 内）
1. queue の `GQM-14` 行: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`
2. `RESOURCE_MODEL.md` §2（生成結果 resource の使用 field 限定: result_id / seed / primary_map / overlay_maps / generation_snapshot / metadata。score/validation 系 park field は書かない）と §6（リスト表示・thumbnail 禁止・即時切替）
3. `DESIGN_DIALOGUE.md` R2 Q-R2-3 確定: **(b) 出力 data 込み**（切替時に再生成しない）
4. 既実装: `HexGenerationResultResource` / `hex_map_asset_library.gd`（kind "results" が使える）/ build_screen の Apply/Revert・viewport projection 経路

## 実装要求
1. **名前付き保存**: 直近の Generate 結果（Result node 出力）を「Save result…」で project 層 `results/` へ保存（`HexMapAssetLibrary`）。内容は data 込み（substrate terrain + overlays + seed + graph snapshot + metadata）。park 系 field は書かない。
2. **リストと即時切替**: 「Results ▾」リスト（bundled は通常無し・project 一覧。**thumbnail なし・名前のみ**）。選択 → 保存済み data を**再生成なしで** viewport へ投影（既存 Apply/Revert 契約と整合: 切替は preview 扱いで、Apply で確定・Revert で戻る）。
3. **promote 導線**: 切替中の保存済み結果からも既存の promote（層書き込み）が機能する。
4. **配置**: Apply / Revert と同じ確定系アクションの並びに置く（header の 7 項目構成は変えない。Apply/Revert が下段 action row にあるならそこへ）。
5. **テスト**: 保存 → list → 切替（再生成が走らないこと= runner 呼び出しが発生しない or 出力同一性で担保）→ promote の一連。保存 resource の field 限定（score/validation 系が空のまま）の検証。

## Scope
- `addons/hex_map_kit/editor/hex_map_build_screen.gd` / 必要なら `hex_map_workspace.gd` の最小追従 / `adapter/hex_generation_result_resource.gd`（保存 helper の追加のみ・既存 field は削らない）
- `tests/test_build_screen_full.gd` / `tests/test_generation_promote.gd` / 新 test 可（tools/test.sh と docs/TEST.md 登録）
- queue の **GQM-14 行のみ** + `PROOF_LOG.md` + `docs/review/autopilot/GQM-14_RESULT_RESOURCE_SAVE_SWITCH_SELF_REVIEW_2026-07-03.md`（この名前どおり）
**禁止**: canvas / inspector / criteria_ui / generation の run 層 / 他 task 行 / pointer。thumbnail・score 表示は作らない。

## Acceptance
1. 上記 test 群 + `./tools/test.sh` exit 0
2. 1 commit（`feat(hex_map_kit): GQM-14 ...`）。commit 不能なら working tree 残しで正常終了
