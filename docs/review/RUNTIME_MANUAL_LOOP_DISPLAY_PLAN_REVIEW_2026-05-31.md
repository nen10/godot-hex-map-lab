# RUNTIME / MANUAL LOOP DISPLAY 計画レビュー (2026-05-31)

## 対象

- `docs/review/ADDITIONAL_REVIEW_NEXT_REQUIREMENTS_2026-05-31.md`
- `docs/complete_on_test/RUNTIME_INTERACTION_LOOP_DISPLAY_TILE_COPY_IMPLEMENTATION_PLAN_2026-05-31.md`
- `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY_IMPLEMENTATION_PLAN_2026-05-31.md`
- `docs/complete_on_test/RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md`
- `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md`

## レビュー観点

- 追加レビューで完了扱いにできる範囲と、次回に残す範囲が混ざっていないこと。
- manual edit 用表示が `RUNTIME_INTERACTION_LOOP_PATH` の実装結果を利用すること。
- fallback 的な仕様が次回の正規仕様として固定されていないこと。
- 実装に必要な比較事項が policy 側へ escalation されていること。
- test と実装が可能な粒度で入出力と対象ファイルが書かれていること。

## 指摘と反映

### 1. loop duplicate の表示責務が曖昧

初期実装の outline 表示だけでは、manual edit 用表示として tile 状態を確認できない。runtime policy に runtime-owned loop copy `TileMapLayer` を候補として追加し、runtime implementation plan では visual cell entry と copy layer の schema を明記した。

### 2. manual tool が toric 座標変換を再実装する余地がある

manual tool 側で wrap / representative 選択を行うと runtime と editor で座標仕様が分かれる。manual policy と implementation plan に、`HexTileMapLayer.local_to_cell_hit()` の hit dictionary を座標変換の正とする方針を明記した。

### 3. plain `TileMapLayer` と loop editing の関係が未確定

plain `TileMapLayer` は non-loop fallback として維持し、loop 表示付き編集は `HexTileMapLayer` target を代表案とした。この判断を manual policy の比較事項と fallback 扱いへ反映した。

### 4. visual representative を document へ保存する誤実装の余地がある

document mutation は canonical `hit["hex"]` だけに行い、`hit["visual_hex"]` は表示・status・highlight 用として扱う。manual implementation plan のクリック処理と完了判定に明記した。

### 5. UI 改善が loop plan と混ざりすぎる可能性

payload controls の mode-specific 表示は操作性に関係するが、loop 表示の必須条件ではない。implementation plan では独立実装可能な同一計画内タスクとして扱い、resource schema や座標変換とは依存させない。

## レビュー結果

計画は実装可能な粒度に整理されている。

次回実装の順序は runtime loop copy display を先に完了し、その API を manual edit tool が利用する形が妥当である。現時点で追加の仕様作成を先に必要とする blocker はない。
