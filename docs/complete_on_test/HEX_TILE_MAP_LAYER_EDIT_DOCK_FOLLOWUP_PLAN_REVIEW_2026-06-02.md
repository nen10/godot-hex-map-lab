# HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_PLAN_REVIEW_2026-06-02.md

## 対象

- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_REVIEW_2026-06-02.md`
- UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_UX_2026-06-02.md`
- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_POLICY_2026-06-02.md`
- Implementation Plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_IMPLEMENTATION_PLAN_2026-06-02.md`

## Planning Flow Check

| Flow | 文書 | 判定 |
| --- | --- | --- |
| 1. UX の策定 | `HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_UX_2026-06-02.md` | Operation Steps、既存UX干渉、hack扱い、完了条件がある。 |
| 2. 実装方針の作成 | `HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_POLICY_2026-06-02.md` | 採用 / 不採用候補、破壊的変更、fallback、UX escalation がある。 |
| 3. 詳細な実装計画の作成 | `HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_IMPLEMENTATION_PLAN_2026-06-02.md` | 入力、出力、resource / scene schema、対象ファイル、Test path がある。 |
| 4. 計画のレビュー | この文書 | 既存UX干渉、閉じ方、テスト可能性を確認する。 |

## 既存 UX との干渉確認

### HexTileMapLayer common target

今回の計画は `HexTileMapLayer` common target の表示可能状態を前提に、その後の edit dock 操作と trace を改善する。common target の方針を壊さない。

### Manual Map Editing Editor Visibility

既存の target readiness / Last Edit trace は維持し、reason と renderer kind を追加する。`display=no` を単純な失敗表示として扱わず、mode別に表示可能性を説明する。

### Manual Edit Document / Payload Schema

Default Floor / Wall tile settings は `REVIEW_BACKLOG_2026-06-02.md` U2-1 と接続する。Document schema自体は変更せず、target apply settings と display helper を追加する。

### Generation Dock

Generation Dock の実ロジックは変更せず、tab titleだけを設定する。`HexTileMapLayer` primary apply は既存完了範囲を維持する。

## テスト可能性

- Dock title、scroll root、Auto target resolution、Last Edit reason は headless EditorPlugin test で確認できる。
- Tile override display は `HexTileMapLayer` の内部 display state / atlas coords で確認できる。
- Object / Label の見た目は marker / label display state を API 化すれば headless test できる。実際の見え方は analog test 候補として残す。

## 不足分類

| 不足 | 計画内対応 |
| --- | --- |
| 任意 Edit Mode で viewport変化がない | payload display apply / marker display / trace reason |
| Last Edit `target=no display=no` の意味が曖昧 | reason と renderer kind 追加 |
| atlas明示設定がない | Default Floor / Wall settings UI |
| edit dock scrollbarなし | ScrollContainer 化 |
| generation dock tab title不明 | dock name設定 |
| Target Auto不動 | live selection / first target resolution |

## レビュー判定

Planning Flow は実装へ進められる状態で閉じている。対象は edit dock follow-up として一つの実装単位にまとまっており、resource schema変更を避けつつ、UI、target解決、display helper、trace、test を接続している。
