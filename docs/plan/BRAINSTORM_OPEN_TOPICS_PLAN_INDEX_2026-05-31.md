# BRAINSTORM_OPEN_TOPICS_PLAN_INDEX_2026-05-31.md

この文書は `docs/review/BRAINSTORM_OPEN_TOPICS_2026-05-30.md` の「大きめの候補」を、実装計画へ分割するためのindexである。

## 作成順

1. Generative Reference ItemKey
   - 方針: `docs/complete_on_test/GENERATIVE_REFERENCE_ITEMKEY_POLICY_2026-05-31.md`
   - 詳細: `docs/complete_on_test/GENERATIVE_REFERENCE_ITEMKEY_IMPLEMENTATION_PLAN_2026-05-31.md`
2. Query Row offset graphical control
   - 方針: `docs/complete_on_test/QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_POLICY_2026-05-31.md`
   - 詳細: `docs/complete_on_test/QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_IMPLEMENTATION_PLAN_2026-05-31.md`
3. Crop保持再計算モード
   - 方針: `docs/plan/CROP_RETAINED_RECALC_POLICY_2026-05-31.md`
   - 詳細: `docs/plan/CROP_RETAINED_RECALC_IMPLEMENTATION_PLAN_2026-05-31.md`
4. Runtime click / loop path / connected component helper
   - 方針: `docs/plan/RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md`
   - 完了済み詳細: `docs/complete_on_test/RUNTIME_INTERACTION_LOOP_PATH_IMPLEMENTATION_PLAN_2026-05-31.md`
   - 次回詳細: `docs/plan/RUNTIME_INTERACTION_LOOP_DISPLAY_TILE_COPY_IMPLEMENTATION_PLAN_2026-05-31.md`
5. マップのマニュアル編集tool
   - 方針: `docs/plan/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md`
   - 完了済み詳細: `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_IMPLEMENTATION_PLAN_2026-05-31.md`
   - 次回詳細: `docs/plan/MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY_IMPLEMENTATION_PLAN_2026-05-31.md`
6. 公開用 sample project / API reference / package整備
   - 方針: `docs/plan/PUBLIC_SAMPLE_API_PACKAGE_POLICY_2026-05-31.md`
   - 詳細: `docs/plan/PUBLIC_SAMPLE_API_PACKAGE_IMPLEMENTATION_PLAN_2026-05-31.md`

## レビュー

- レビュー文書: `docs/review/BRAINSTORM_OPEN_TOPICS_PLAN_REVIEW_2026-05-31.md`

レビューでは以下を確認する。

- 各課題に方針文書と詳細実装計画がある。
- 方針文書に比較事項・未確定事項・破壊的変更候補・fallback扱いが明記されている。
- 詳細実装計画が入力、出力、resource schema、対象ファイル、テスト方針を持つ。
- 詳細実装計画で新たな未確定事項が出る場合、対応する方針文書へescalationされている。
- 実装は行わず、実装可能な計画として閉じている。
