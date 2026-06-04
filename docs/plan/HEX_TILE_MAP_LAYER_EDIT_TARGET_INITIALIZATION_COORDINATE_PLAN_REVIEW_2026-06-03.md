# HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_PLAN_REVIEW_2026-06-03.md

## 対象

- UX: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_UX_2026-06-03.md`
- Policy: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_POLICY_2026-06-03.md`
- Implementation Plan: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_PLAN_2026-06-03.md`
- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_PERFORMANCE_REVIEW_2026-06-03.md`

## Planning Flow確認

| Step | 文書 | 判定 |
| --- | --- | --- |
| 1. UX の策定 | `HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_UX_2026-06-03.md` | Operation Steps、既存UX干渉、hack扱い、成功条件がある。 |
| 2. 実装方針の作成 | `HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_POLICY_2026-06-03.md` | 複数候補、採用 / 不採用、破壊的変更、fallback、UX escalationがある。 |
| 3. 詳細な実装計画の作成 | `HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_IMPLEMENTATION_PLAN_2026-06-03.md` | 入力、出力、schema、対象ファイル、Test path、analog test候補がある。 |
| 4. 計画のレビュー | 本文書 | 既存UXとの干渉と実装対象の閉じ方を確認する。 |

## 既存UXとの干渉

### Document Load / Import

Target由来documentの自動作成は、既存Load / Importを置き換えない。保存済みdocumentを明示Loadした場合は、Load済みdocumentを優先する。Target由来documentは「未保存の作業document」として扱う。

### Plain `TileMapLayer` Manual Edit

plain `TileMapLayer` を通常Target候補から外す変更は、既存Editor testと互換操作に干渉する。Core adapterとしてのplain apply helperは維持し、UI通常経路からは外すことで目的の一貫性を優先する。

### Generator Dock

Generator Primary targetを `HexTileMapLayer` 中心にすると、plain `TileMapLayer` apply testの再分類が必要になる。Overlay modeは現時点でplain targetを要求するため、Primary / Overlayを同時に同一Target UXへ統合しない。

### Coordinate Helper

`hex_to_local()` を内部 `TileMapLayer.map_to_local()` 基準へ変更すると、toric代表計算や既存debug sceneの数値期待に影響する可能性がある。互換が必要な箇所では既存数式helperと表示helperを分ける。

## 実装対象の閉じ方

今回の短期計画は、manual editの初期化、Target解決、表示座標、per-click反応の改善に閉じる。

含める:

- Target由来document自動作成
- `HexTileMapLayer` 中心のManual Edit Target
- 内部 `TileMapLayer` 基準のhit / display center
- 全Edit Modeのcell / marker / overlay単位apply
- Overlay要Tileのmanual edit path
- tactics tile / object atlasの利用
- Generator Primary target方針の段階整理
- analog test更新

含めない:

- `HexTileMapLayer` 全体のsource-of-truth再設計
- Overlay applyの全面 `HexTileMapLayer` 統合
- `HexTileMapLayer extends TileMapLayer` への継承変更
- Object / Labelの本格的なレイアウト編集UI刷新
- 複数overlay layer / overlay stackの永続schema刷新

## テスト可能性

- Target由来document、Auto target、Target候補、cell / marker / overlay単位apply reasonはheadless editor plugin testで検証できる。
- 座標roundtripは `tests/test_hex_tile_map_layer.gd` で遠端cellを含めて検証できる。
- 実Editor上の反応速度、Target Reloadだけの操作感、遠端cell目視、tactics atlas表示はanalog testで確認する。

## 不足と修正

計画上、Generator Primary targetの `HexTileMapLayer` 中心化と複数overlay layerの永続schema刷新は作業範囲が広い。実装時はManual Edit修正を先に閉じ、Generator側はPrimary / Overlayのtarget分類テストを追加してから変更する。Overlay要Tileは短期では `tile_overrides kind=overlay` に閉じ、stack表現が必要になった時点で長期アーキテクチャ計画へ移す。

## 判定

Planning Flowとして実装に進める状態にある。ただしGenerator Target整理は、Manual Edit修正とは別PRまたは別実装段階に分けられる。
