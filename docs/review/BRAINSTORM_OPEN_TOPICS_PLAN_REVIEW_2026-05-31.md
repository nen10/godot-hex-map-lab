# BRAINSTORM_OPEN_TOPICS_PLAN_REVIEW_2026-05-31.md

この文章はagentによる計画文書レビューです。

## 対象

`docs/review/BRAINSTORM_OPEN_TOPICS_2026-05-30.md` の大きめの候補から作成した以下のplan文書。

1. Generative Reference ItemKey
   - `docs/plan/GENERATIVE_REFERENCE_ITEMKEY_POLICY_2026-05-31.md`
   - `docs/plan/GENERATIVE_REFERENCE_ITEMKEY_IMPLEMENTATION_PLAN_2026-05-31.md`
2. Query Row offset graphical control
   - `docs/plan/QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_POLICY_2026-05-31.md`
   - `docs/plan/QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_IMPLEMENTATION_PLAN_2026-05-31.md`
3. Crop保持再計算モード
   - `docs/plan/CROP_RETAINED_RECALC_POLICY_2026-05-31.md`
   - `docs/plan/CROP_RETAINED_RECALC_IMPLEMENTATION_PLAN_2026-05-31.md`
4. Runtime click / loop path / connected component helper
   - `docs/complete_on_test/RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md`
   - `docs/plan/RUNTIME_INTERACTION_LOOP_PATH_IMPLEMENTATION_PLAN_2026-05-31.md`
5. マップのマニュアル編集tool
   - `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md`
   - `docs/plan/MANUAL_MAP_EDITING_TOOL_IMPLEMENTATION_PLAN_2026-05-31.md`
6. 公開用 sample project / API reference / package整備
   - `docs/plan/PUBLIC_SAMPLE_API_PACKAGE_POLICY_2026-05-31.md`
   - `docs/plan/PUBLIC_SAMPLE_API_PACKAGE_IMPLEMENTATION_PLAN_2026-05-31.md`

## レビュー観点

- 各課題に方針文書と詳細実装計画がある。
- 方針文書に比較事項、破壊的変更候補、fallback扱いがある。
- 詳細実装計画に対象ファイル、入出力インターフェース、resource schema、テスト計画、実装手順、完了判定がある。
- 詳細実装計画で見つかった未確定事項が方針文書へescalationされている。
- 実装を開始せず、テスト可能な計画として閉じている。

## Findings

### Finding-01: 詳細実装計画の入出力インターフェースが文書ごとに薄い

Severity: Medium

初稿では、方針文書側に入力 / 出力があり、詳細実装計画側ではCore APIやUI計画に分散していた。実装時に参照する文書としては、詳細実装計画にも明示的な入出力インターフェースが必要。

対応:

- 以下の詳細実装計画に `入出力インターフェース` セクションを追加した。
  - `GENERATIVE_REFERENCE_ITEMKEY_IMPLEMENTATION_PLAN_2026-05-31.md`
  - `QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_IMPLEMENTATION_PLAN_2026-05-31.md`
  - `CROP_RETAINED_RECALC_IMPLEMENTATION_PLAN_2026-05-31.md`
  - `RUNTIME_INTERACTION_LOOP_PATH_IMPLEMENTATION_PLAN_2026-05-31.md`
  - `MANUAL_MAP_EDITING_TOOL_IMPLEMENTATION_PLAN_2026-05-31.md`
  - `PUBLIC_SAMPLE_API_PACKAGE_IMPLEMENTATION_PLAN_2026-05-31.md`

### Finding-02: Query Row graphical controlの矩形hit testが詳細計画だけに現れていた

Severity: Low

詳細実装計画では、初期実装として標準Buttonの矩形hitを使い、hex形状は補助描画に留める案を書いていた。この比較事項は方針文書側にも上げるべき。

対応:

- `QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_POLICY_2026-05-31.md` の候補Bとfallback扱いへ、矩形hit testの段階的実装を追記した。

### Finding-03: Runtime計画のinfinite表示が方針に比べて詳細不足

Severity: Medium

方針文書ではtoric / infinite loop表示を分けていたが、詳細実装計画の初稿はtoric representative中心で、infiniteで「異なる座標を同一cellにしない」ための具体的な扱いが薄かった。

対応:

- `RUNTIME_INTERACTION_LOOP_PATH_IMPLEMENTATION_PLAN_2026-05-31.md` に `infinite表示計画` を追加した。
- `loop_display_mode` を `None / Toric / Infinite` として明記した。
- infiniteではwrapせず、provider導入時も実座標cellを扱う方針を追記した。

### Finding-04: Manual editing toolのobject / label database resourceがschema化されていない

Severity: Medium

方針ではobject / label database resourceを出力に含めていたが、初稿のresource schemaはdocument内のplacement entries中心だった。payload候補を持つdatabase resourceの計画が必要。

対応:

- `MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md` に `HexObjectDatabaseResource` / `HexLabelDatabaseResource` の補助resource候補を追記した。
- `MANUAL_MAP_EDITING_TOOL_IMPLEMENTATION_PLAN_2026-05-31.md` に対象ファイル、入出力、resource schemaを追記した。

## 確認結果

- 6課題すべてに方針文書と詳細実装計画がある。
- 方針文書は比較事項、破壊的変更候補、fallback扱いを持つ。
- 詳細実装計画は入出力、対象ファイル、resource schema、テスト計画、実装手順、完了判定を持つ。
- 詳細計画で見つかった未確定事項は方針文書へ反映済み。
- 実装変更は行っていない。

## 残リスク

- 実装時にはGodot Editor実機の操作感確認が必要になる計画がある。
- packaging scriptやexample projectの実行時間は、実装時に `tools/test.sh` 標準対象へ入れるかoptionalにするか再判断が必要。
- `HexMapDocumentResource` は破壊的な設計候補であり、実装前に既存 `HexMapResource` との移行範囲を再確認する価値がある。
