# HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_PLAN_REVIEW_2026-06-03.md

## 対象

- UX: `docs/plan/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_UX_2026-06-03.md`
- Policy: `docs/plan/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_POLICY_2026-06-03.md`
- Implementation Plan: `docs/plan/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_PLAN_2026-06-03.md`
- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_PERFORMANCE_REVIEW_2026-06-03.md`

## Planning Flow確認

| Step | 文書 | 判定 |
| --- | --- | --- |
| 1. UX の策定 | `HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_UX_2026-06-03.md` | Operation Steps、既存UX干渉、hack扱い、成功条件がある。 |
| 2. 実装方針の作成 | `HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_POLICY_2026-06-03.md` | 複数候補、採用 / 不採用、破壊的変更、fallback、UX escalationがある。 |
| 3. 詳細な実装計画の作成 | `HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_PLAN_2026-06-03.md` | 入力、出力、schema、対象ファイル、Test path、analog test候補がある。 |
| 4. 計画のレビュー | 本文書 | 既存UXとの干渉と実装対象の閉じ方を確認する。 |

## 既存UXとの干渉

### Resource保存

Resourceをsnapshot扱いにしても、保存・読み込み・export自体は維持される。ただしlive edit中に `hex_map` Resource instanceが常に最新であるという期待は変わる可能性がある。互換propertyのgetter / setter設計が必要。

### Editor Plugin

Edit DockとGenerator Dockが同じTarget state APIを使うため、既存のplain `TileMapLayer` target testは再分類が必要になる。Core helperとして残すtestと、Editor通常UXから削除するtestを分ける。

### Overlay

Manual overlay tile editとGenerator Overlay applyを `HexTileMapLayer` 配下へ統合すると、現在plain `TileMapLayer` を要求するOverlay workflowに干渉する。Primary state APIの安定後に、Overlay表示層を別段階で設計する。

### Debug scenes

Core数式debugとGodot `TileMapLayer` 表示debugの役割を分ける必要がある。`HexMapTileAdapter.hex_to_local()` の確認画面はCore math debug、Editor操作は内部 `TileMapLayer` 基準として整理する。

## 実装対象の閉じ方

この計画は大きなアーキテクチャ再設計であり、短期修正の実装対象には含めない。

含める:

- `HexTileMapLayer` 内部state API
- Resource snapshot入出力
- Generator Primary / Edit Dock / Save Exportの共通Target state経路
- per-click incremental display sync
- Manual overlay tile edit / Generator Overlay統合の設計候補

含めない:

- 短期のTarget Reload初期化だけの修正
- 単なる `hex_size` 調整
- `HexTileMapLayer extends TileMapLayer` への継承変更
- Godot標準TileMap editorとの完全統合

## テスト可能性

- 内部state APIとResource snapshot roundtripはheadless testで検証できる。
- 大きいmapでの反応速度とEditor操作感はanalog testで検証する。
- Overlay要Tile統合は、Primary state APIが安定した後に別のテストまとまりとして追加する。

## 不足と修正

scene保存時に内部stateをどこまでexport property化するかは未確定である。実装前に、`hex_map` 互換propertyだけで足りるか、`HexMapDocumentResource` subresourceを持つべきかを追加reviewする。

## 判定

Planning Flowとして成立している。ただし実装は短期計画の完了後に着手し、Overlay要Tile統合とscene保存schemaはさらに小さく分割して判断する。
