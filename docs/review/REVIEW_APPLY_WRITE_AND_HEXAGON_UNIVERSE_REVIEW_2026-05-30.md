# REVIEW_APPLY_WRITE_AND_HEXAGON_UNIVERSE 実装レビュー (2026-05-30)

## ユーザーによる追記

この文章はagentによるレビュー結果です。基本的な要件は達成されており、重要度は低いです。

## 対象

`docs/review/REVIEW_APPLY_WRITE_AND_HEXAGON_UNIVERSE_2026-05-30.md` の要件に対する staged 変更。

## 総評

4つの要件（Hexagon canonization、SHAPE_TORUS universe 確認、Clear Layer → Apply Write 統合、Block status prefix）すべてが実装され、全6テストファイルがパスしている。変更は Core API (`HexMapData.hexagon`、`HexMapGenerator.generate_symmetric_hexagon`)、Editor Dock (Apply Write 共通化、block status prefix)、テスト (`test_hex_adapter.gd` の center cell 更新、`test_hex_map_generation.gd` の canonical hexagon 検証、`test_editor_plugin.gd` の Apply Write matrix テスト) の3層にわたり、整合性が取れている。

---

## 要件に対する実装の不足

### 1. `_shape_universe_from_values` の `SHAPE_TORUS` が hex_radius 引数を使わない

Severity: Low

```gdscript
func _shape_universe_from_values(symmetric, shape, hex_radius, rect_width, rect_height, gen_radius):
    ...
    match shape:
        SHAPE_HEXAGON:
            return HexMapData.hexagon(hex_radius).cells
        SHAPE_RECTANGLE:
            ...
        SHAPE_TORUS, _:
            var radius = generation_radius
            return HexMapData.square(radius * 2 + 1, false).cells
```

`SHAPE_TORUS` 分岐は `generation_radius` を使うが、呼び出し元が誤って `hex_radius` 系の値だけ渡した場合、`gen_radius` が適切でなくともコンパイルエラーにならない。`SHAPE_TORUS` は symmetric 生成でのみ到達可能であることを assert するか、shape に対応する radius を明示的に選択するヘルパーがあると堅牢。

---

## UI上の改善点

### 1. Apply Write のラベルが `"Apply Write"` で機能を表現しきれていない

`Apply Write` は「TileMapLayer clear の有無」と「`_current_overlay_data` の置換/合成」の両方を制御する。ラベルだけではこの2つの意味が読み取れない。tooltip で補足するか、ラベルを `"Write Mode"` などに変更する余地がある。

### 2. `_existing_item_policy_option` が Overlay controls 内に残っている

`Apply Write` は Primary/Overlay 共通領域に移動したが、`Existing Item` は Overlay controls 内に残っている。Primary mode では常に非表示だが、Overlay mode でだけ表示される理由が UI 上で説明されていない。

---

## 機能・コード上の改善点

### 1. `_canonical_hexagon_cells()` がテストファイル間で重複

`test_hex_map_generation.gd` と `docs/review/REVIEW_APPLY_WRITE_AND_HEXAGON_UNIVERSE_2026-05-30.md`（対応メモ）の両方に hexagon canonical 化ロジックが記述されている。`HexMapData.hexagon(radius)` の実装と同一ロジックであり、テストでは `HexMapData.hexagon(radius).cells` を直接参照すれば重複を避けられる。

実際に `test_editor_plugin.gd` の `_test_generation_dock_shape_universe_uses_canonical_hexagon_and_square_torus` は `HexMapData.hexagon(2).cells` を期待値として使っており、重複がない。

`test_hex_map_generation.gd` の `_canonical_hexagon_cells()` は `HexMapData.hexagon(radius).cells` で置き換え可能。置き換えるとテストの自己完結性は下がるが、実装との不一致リスクも下がる。

### 2. `_apply_crop_result_to_tile_map_layer` の簡略化に伴う挙動変更

簡略化前は Crop result apply が独自の tile mapping を持っていた（全 item key に Wall fallback を一律適用）。簡略化後は `apply_current_overlay_data_to_tile_map_layer` に委譲し、`_overlay_item_tile_configs()` を使う。`_overlay_item_tile_configs()` は Item Pool に存在する item key には Pool row の tile 設定を使い、存在しない key には Wall fallback を使う。Crop result の item key は `"source.tres / ItemKey"` 形式であり、Item Pool に存在しないため、実質すべて Wall fallback になる。結果として同じ描画結果になるが、委譲の連鎖が長くなっている。

### 3. `_overlay_adjacency_rules()` が毎回 parse する

`_current_generation_block_reason()`、`_overlay_adjacency_rules()`、`_refresh_adjacency_rules_status()` の3箇所がそれぞれ `HexAdjacencyRuleSet.parse_rules_text_report(text)` を呼ぶ。`_refresh_controls()` 時に1回だけ評価してキャッシュすれば無駄な parse を減らせる。

---

## ドキュメントの一貫性

| ドキュメント | 状態 |
|-------------|------|
| `REVIEW_APPLY_WRITE_AND_HEXAGON_UNIVERSE_2026-05-30.md` (旧 user_review.md) | 対応メモ付き。要件の説明として十分 |
| `EDITOR_OVERLAY_REMAINS_2026-05-30_CLEAR_LAYER_UI.md` | Apply Write 統合に更新済み ✅ |
| `MANUAL_EDITOR_PLUGIN.md` | Apply Write 説明に更新済み ✅ |
| `FALLBACK_CLASSIFICATION.md` | `_overlay_write_policy` → `_apply_write_policy` 参照更新済み ✅ |
| `TEST.md` | 未更新（test_editor_plugin.gd のテスト概要に Apply Write の記述がない） |

`docs/TEST.md` の `test_editor_plugin.gd` 概要に Apply Write 統合と Hexagon canonization の記述を追加するとよい。

---

## 不明点

### 1. `HexMapData.hexagon(radius=0)` の挙動確認

`hexagon(0)` は `[HexVector.zero()]` を返す。`_shape_universe_from_values` で `hex_radius=0` が渡されるケースは想定されるか。現状の UI では `_hex_radius_spin.min_value = 1` なので UI 経由では発生しないが、snapshot のパラメータとして `0` が来た場合の動作は確認済み（テストあり）。

### 2. `OVERLAY_WRITE_POLICIES` → `APPLY_WRITE_POLICIES` のリネーム範囲

定数名は変更されたが、`overlay_write_policy` という名前の snapshot key も `apply_write_policy` に変更されている。snapshot を外部から構築するコードがあれば破壊的変更になるが、snapshot は Dock 内部でのみ生成されるため影響なし。

### 3. `_build_overlay_controls` から `Apply Write` が削除された影響

`Apply Write` は `_build_apply_write_controls()` に移動し、Primary / Overlay 共通領域に配置された。Overlay controls の先頭に `Overlay` toggle がなくなり、見た目の構造が変わっている。Godot Editor 実機での Dock 表示確認が推奨される。

---

## 推奨されるファイル名

`docs/review/user_review.md` → `docs/review/REVIEW_APPLY_WRITE_AND_HEXAGON_UNIVERSE_2026-05-30.md`

に変更済み。内容（Hexagon canonization + Apply Write 統合 + Block status prefix）を反映している。
