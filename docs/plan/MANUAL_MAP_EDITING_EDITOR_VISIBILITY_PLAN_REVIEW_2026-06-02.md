# MANUAL_MAP_EDITING_EDITOR_VISIBILITY_PLAN_REVIEW_2026-06-02.md

## Review Target

- UX: `docs/plan/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_UX_2026-06-02.md`
- Policy: `docs/plan/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_POLICY_2026-06-02.md`
- Implementation plan: `docs/plan/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_IMPLEMENTATION_PLAN_2026-06-02.md`
- Backlog source: `docs/plan/REVIEW_BACKLOG_2026-06-02.md` U1

## Judgement

Result: `plan_ready`

U1 の候補は、既存 manual edit 実装を作り直す計画ではなく、実 Editor 上で document mutation、target redraw、保存/export を観察できるようにする計画として閉じている。

## Planning Flow Check

| Flow | 文書 | 判定 |
| --- | --- | --- |
| 1. UX の策定 | `MANUAL_MAP_EDITING_EDITOR_VISIBILITY_UX_2026-06-02.md` | Operation Steps 素案、評価、既存 UX 干渉、hack 扱いがある。 |
| 2. 実装方針の作成 | `MANUAL_MAP_EDITING_EDITOR_VISIBILITY_POLICY_2026-06-02.md` | 採用 / 不採用候補、破壊的変更候補、fallback 扱い、UX escalation がある。 |
| 3. 詳細な実装計画 | `MANUAL_MAP_EDITING_EDITOR_VISIBILITY_IMPLEMENTATION_PLAN_2026-06-02.md` | 入力、出力、trace schema、対象ファイル、保存 schema、Test path、analog test 更新がある。 |
| 4. 計画のレビュー | この文書 | 既存 UX 干渉、閉じ方、テスト可能性を確認している。 |

## 既存 UX との干渉確認

### Generate Dock

生成 Dock の target apply UX は変更せず、Hex Map Edit 側で target readiness を表示する。既存の `TileMapLayer` target は維持されるため、U1 は Generate Dock の基本操作を妨げない。

### Manual Map Editing

`HexMapDocumentResource` を正とする方針を維持している。trace は session state であり、document schema を変えないため、既存の save / load / export flow と互換である。

### Runtime Loop Display

`HexTileMapLayer` target の canonical / visual distinction を Dock trace に表示する計画であり、runtime hit API の意味を変えない。last-only highlight は manual edit の選択表示として扱われる。

## 実装対象の閉じ方

- Target readiness、last edit trace、persistence checkpoint の3つに実装対象が分かれている。
- Trace schema は Dock session state として定義され、resource schema 変更がない。
- 対象ファイルは Editor tool、runtime highlight helper、test、analog docs に限定されている。
- U2 の document / payload schema 改修へ踏み込んでいない。

## テスト可能性

自動テスト:

- `tests/test_editor_plugin.gd` で target readiness、last edit trace、save/export checkpoint を検証できる。
- `tests/test_hex_tile_map_layer.gd` で single highlight removal を検証できる。

Interactive / analog:

- `tests/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md` に実 Editor 上の観察項目を追加する計画がある。
- `docs/TEST.md` の Hex Map Edit Dock 手動確認へ Target Status、Last Edit、Save / Export detail を接続する計画がある。

## 修正分類

### 修正対象

- Dock 内 detail trace を primary observation として追加する。
- last edit highlight を last-only にする。
- save/export checkpoint を Dock に表示する。

### 無視できるもの

- Output panel の debug print は補助として残ってもよい。primary observation ではない。
- Status label の短文は quick feedback として残ってもよい。

### 後続計画候補

- edit history UI として複数 highlight を扱う機能。
- object / label database definition と placement naming の整理。
- plain `TileMapLayer` 用の sample TileSet setup guide を manual に追加する判断。

## Review Result

Planning Flow は完了している。実装へ進める場合は `docs/plan/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_IMPLEMENTATION_PLAN_2026-06-02.md` の実装手順 1 から開始できる。
