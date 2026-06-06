# HEX_TILE_MAP_LAYER_COMMON_TARGET_PLAN_REVIEW_2026-06-02.md

## 対象

- UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_COMMON_TARGET_UX_2026-06-02.md`
- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_COMMON_TARGET_POLICY_2026-06-02.md`
- Implementation Plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_COMMON_TARGET_IMPLEMENTATION_PLAN_2026-06-02.md`

## Planning Flow Check

| Flow | 文書 | 判定 |
| --- | --- | --- |
| 1. UX の策定 | `HEX_TILE_MAP_LAYER_COMMON_TARGET_UX_2026-06-02.md` | Operation Steps、既存 UX 干渉、完了条件がある。 |
| 2. 実装方針の作成 | `HEX_TILE_MAP_LAYER_COMMON_TARGET_POLICY_2026-06-02.md` | 採用 / 不採用候補、破壊的変更、fallback、UX escalation がある。 |
| 3. 詳細な実装計画の作成 | `HEX_TILE_MAP_LAYER_COMMON_TARGET_IMPLEMENTATION_PLAN_2026-06-02.md` | 入力、出力、resource / scene schema、対象ファイル、Test path がある。 |
| 4. 計画のレビュー | この文書 | 既存 UX 干渉、閉じ方、テスト可能性を確認する。 |

## 既存 UX との干渉確認

### Generation Dock

`Add new layer...` が `HexTileMapLayer` を作るため、既存の plain `TileMapLayer` 作成 UX からは破壊的変更になる。ただし plain `TileMapLayer` target apply は残すため、既存 scene の target 利用は維持される。

### Hex Map Edit

manual edit は `HexTileMapLayer` target を代表 UX とする。plain `TileMapLayer` target は互換 fallback とし、Godot 標準 TileMap editor との入力競合がある場合は `HexTileMapLayer` を使う。

### Runtime Loop Display

`HexTileMapLayer` の internal base / loop copy layer schema は維持される。今回追加する display TileSet helper は tile source readiness を整えるもので、canonical / visual hit の意味を変更しない。

### Overlay Generation

Overlay apply は plain `TileMapLayer` を正とする。`HexTileMapLayer` に overlay layer を追加する設計は今回の実装対象から分離されている。これは Primary Generation と Manual Edit の共通 target を閉じるための scope 判断である。

## テスト可能性

- resource load 後の viewport 表示は、headless では TileSet source / atlas tile / used cells の存在で検証する。
- Editor input 競合そのものは headless では観察しにくいため、official docs と code path から判断し、必要なら analog test で観察する。
- `tools/test.sh` は `tests/test_hex_tile_map_layer.gd` と `tests/test_editor_plugin.gd` の Test path で自動確認する。

## 修正対象

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/knowledge/DEV_GODOT.md`

## レビュー判定

Planning Flow は実装へ進められる状態で閉じている。破壊的変更は `Add new layer...` と `HexTileMapLayer` の display TileSet 自動作成に限定され、plain `TileMapLayer` の既存 apply は互換経路として維持する。

実装後レビューでは、`HexTileMapLayer` の `hex_map` 読み込み、生成 Dock primary apply、Target list、sample setup、Generate後auto apply が headless test で確認された。Overlay apply は計画通り plain `TileMapLayer` の互換経路として残る。
