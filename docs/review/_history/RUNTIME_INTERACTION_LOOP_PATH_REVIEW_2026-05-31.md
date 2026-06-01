# RUNTIME_INTERACTION_LOOP_PATH 実装レビュー (2026-05-31)

## 対象

`docs/complete_on_test/RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md` および `docs/plan/RUNTIME_INTERACTION_LOOP_PATH_IMPLEMENTATION_PLAN_2026-05-31.md` の要件に対する commit `326e65d`。

## 総評

`HexTileMapLayer` に runtime input handling（`cell_clicked` / `cell_hovered` / `cell_hit_clicked` / `cell_hit_hovered`）、toric loop display（loop cell outline、visual representative for draw）、toric visual path（wrapをまたぐ連続経路）、connected component from local hit が追加された。

変更は `hex_tile_map_layer.gd` (+239行) と debug scene (+192行) が主で、かなり以前の計画から予告されていた「canonical data + visual representative」方式が初めて形になった。全テストパス。

---

## 当初の要件より優れている実装

### 1. `_toric_period_candidates()` による表示範囲適応の toric 展開
Plan では `HexToricCoordinate.unfolded_vectors()` の使用を想定していたが、実装は自前の `_toric_period_candidates()` で表示範囲（`rect`）から必要な周期オフセット範囲を自動計算する。`unfolded_vectors()` の `max_l1_norm` 制限では表示範囲全体をカバーできないケースに対応し、長方形 universe にも効率的である。

### 2. `_nearest_toric_period_candidate()` による「最も近い代表」選択
`visual_path_for_canonical_path()` が各 path segment で前 representative から最も近い toric period candidate を選ぶ。toric wrap をまたぐ経路が表示上で大きくジャンプせず、隣接する visual representative 間を線で結べる。これは policy document の「toric wrap をまたぐpathが画面上で大きくジャンプする状態は仕様として固定しない」を直接解決している。

### 3. `_effective_loop_display_rect()` の fallback 計算
`loop_display_rect` 未設定時に、全 `_data.cells` の bounding box + `hex_size * 2.0` の margin で自動計算する。ユーザーが表示範囲を明示指定しなくても、canonical map の周囲1ループ分の representative が表示される。

### 4. hover signal の重複 emit 抑制
`_emit_hover_hit()` は `_hovered_hit_key`（`canonical_key|visual_key` 形式）で前回と同じ hit を抑制する。高速なマウス移動時でも `cell_hovered` が毎フレーム emit されない。

### 5. infinite mode での visual cell identity 維持
`loop_display_mode == LOOP_DISPLAY_INFINITE` では toric wrap を行わず、visual hex をそのまま canonical hex として扱う。`exists` は finite resource 内の cell だけ true になる。この設計は「異なる座標を同一cellとして扱わない」という infinite map の要件を満たす。

---

## 要件に対する実装の不足

### 1. debug scene の `L` / `C` / `P` キーが headless test で検証されていない

`tests/test_debug_scenes.gd` には `_test_debug_scene_has_loop_display_click_modes` が追加されているが、toggle 値の初期化確認にとどまる。`L`/`C`/`P` の実際の押下による表示切替は Godot Editor 上の手動確認が必要。`docs/TEST.md` の Debug 実行セクションにキー説明が追加される予定だったが、commit 内の `docs/TEST.md` 差分を見ると debug scene のキー説明追加は行われていない。マニュアル確認用の記録として残す価値がある。

### 2. `draw_loop_path()` の line rendering が未実装

`draw_path()` は `_draw()` 内で `_display_path` の polyline を描画するが、`draw_loop_path()` は `visual_path_for_canonical_path()` で `_display_path` に visual representatives を設定するだけで、`_draw()` 側の path 描画ロジックに変更がない。`_display_path` が visual representatives であれば、`hex_to_local(hex)` で正しい位置に描画されるはずだが、元の `_draw()` 実装は canonical path を前提にしているため、visual path 対応が暗黙的である。実際に `hex_to_local` は HexVector の q/s/r 成分から計算するため、visual representative の座標も正しく描画される。

---

## UI 上の改善点

### 1. loop display の outline 色が固定

`_draw_loop_cell_outlines()` の `duplicate_color = Color(0.18, 0.44, 0.82, 0.26)` はハードコード。エディタテーマに応じた色調整は行われない。

### 2. `input_enabled` / `emit_hovered_cell` の Inspector 表示順

`@export var` の並びが: `hex_map`, `flat_top`, `hex_size`, `flat_top` チェック, `floor_source_id`, ..., `input_enabled`, `emit_hovered_cell`, `loop_display_enabled`, ... と混在している。runtime input 系のプロパティと表示系のプロパティをグループ化するか、カテゴリ分けすると Inspector での視認性が上がる。

---

## 機能・コード上の改善点

### 1. `_uses_toric_loop_identity()` と `_uses_toric_visuals()` の分離が意図的か

`_uses_toric_loop_identity()` は `loop_display_enabled && mode == TORIC && cyclic_size > 0` の3条件。`_uses_toric_visuals()` は `mode == TORIC && cyclic_size > 0` の2条件（`loop_display_enabled` を問わない）。前者は hit test で canonical wrap を行うか、後者は visual path/representatives 計算を行うかの判定。`loop_display_enabled = false` でも `visual_path_for_canonical_path()` が toric 展開する可能性があるが、実際には `_draw()` で `loop_display_enabled` チェック後に visual path を使うため、未使用の計算が走る可能性は低い。設計意図がコメントで説明されているとよい。

### 2. `_toric_period_candidates` の `offset_limit` 計算

periodic local 距離の `min(q_period, r_period)` を周期の基準に使っているが、hex grid の axial 座標は 120度の角度を持つため、q方向とr方向の周期が異なる場合がある。特に `flat_top` と `pointy_top` で hex_to_local の結果が回転するため、`min(q_period, r_period)` が実際の最小周期より小さくなり、`offset_limit` が過大になる可能性がある。実用上は問題ないが、厳密な最適化の余地はある。

### 3. `connected_component_from_local` の empty hit 処理

```gdscript
func connected_component_from_local(local_pos: Vector2) -> Array:
    var hit = local_to_cell_hit(local_pos)
    if not bool(hit["exists"]):
        return []
    return connected_component(hit["hex"])
```

`exists == false` の場合に空配列を返す。呼び出し元は empty check が必要だが、それは caller の責務として許容できる。

---

## テストに対する評価

| 計画のテスト | 実装 |
|-------------|------|
| signal: click/hover with canonical cell | ✅ `_test_runtime_input_signals_use_cell_hit` |
| toric hit: visual → canonical wrap | ✅ `_test_local_to_cell_hit_wraps_toric_visual_cell` |
| infinite: visual identity preserved | ✅ `_test_infinite_loop_mode_keeps_visual_cell_identity` |
| visual representatives: rect-filtered | ✅ `_test_visual_representatives_for_toric_cell` |
| visual path: nearest representative | ✅ `_test_visual_path_for_toric_path_uses_nearest_representatives` |
| connected component from local | ✅ `_test_connected_component_from_local_matches_core` |
| debug scene: loop display toggle modes | ✅ `_test_debug_scene_has_loop_display_click_modes` |

全7テスト充足。debug scene toggle test はキー押下ではなくプロパティ初期値を検証。

---

## 不明点

### 1. `visual_path_for_canonical_path` の anchor_local 引数がテストで使われていない

Plan では `anchor_local` による第1 representative の選択が仕様化されているが、テストでは `anchor_local = Vector2.ZERO`（デフォルト）のみが使われている。anchor 指定の効果を検証するテストがない。

### 2. loop display の TileMapLayer 複製描画が outline のみ

Plan では「Tileそのものをloop copy表示する段階では、内部にcopy用 `TileMapLayer` を追加し」とされているが、現状は `_draw_loop_cell_outlines()` による半透明 outline のみ。Tile そのものの複製表示は将来の拡張として残っている。
