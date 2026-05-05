# TileMapLayer 拡張計画

## 概要

Hex Map Kit の TileMapLayer 周りを実行時利用可能な形に拡張する。
スクリプトからマップを操作できるカスタム Node を提供する。

---

## Phase 1: 実行時基盤

### 1.1 HexTileMapLayer
- `Node2D` 派生のカスタムシーンノード
- 子 `TileMapLayer` を自動管理
- プロパティ
  - `hex_map: HexMapResource` — マップデータリソース参照（変更時自動再描画）
  - `hex_size: float` — タイルサイズ (default 24.0)
  - `flat_top: bool` — flat-top / pointy-top 切替 (default true)
  - `floor_source_id / floor_atlas_coords` — 床タイル設定
  - `wall_source_id / wall_atlas_coords` — 壁タイル設定
- メソッド
  - `apply_map(resource)` — HexMapResource を読み込み TileMapLayer に反映
  - `local_to_hex(local_pos: Vector2) -> HexVector` — ローカル座標→Hex座標
  - `hex_to_local(hex: HexVector) -> Vector2` — Hex座標→ローカル座標
  - `is_wall(hex: HexVector) -> bool` — 壁判定
  - `is_floor(hex: HexVector) -> bool` — 床判定
  - `has_cell(hex: HexVector) -> bool` — セル存在判定
  - `get_cells() -> Array[HexVector]` — 全セル一覧

### 1.2 編集操作
- `set_wall(hex: HexVector)` — 指定セルを壁に（TileMapLayer 即時反映）
- `set_floor(hex: HexVector)` — 指定セルを床に
- `refresh_display()` — 全セル再描画

### 1.3 経路可視化
- `find_path(start: HexVector, goal: HexVector) -> Array[HexVector]` — 床セル上の最短経路
- `draw_path(path: Array[HexVector], color: Color)` — `_draw()` で経路線を描画
- `highlight_cell(hex: HexVector, color: Color)` — セルのハイライト表示
- `clear_highlights()` — 全ハイライト解除

---

## Phase 2: シーン統合

### 2.1 クリック操作
- `_input(event)` でマウスクリック座標→Hex座標変換→コールバック発火
- `cell_clicked(hex: HexVector)` シグナル

### 2.2 連結性クエリ
- `is_map_connected() -> bool` — 全床セルの連結判定
- `connected_component(hex: HexVector) -> Array[HexVector]` — 指定セルを含む連結成分

### 2.3 一括編集
- `fill_region(cells: Array[HexVector], wall: bool)` — 領域一括設定
- `randomize_walls(prob: float, seed: int)` — 壁ランダム再生成

---

## Phase 3: 有用機能

### 3.1 リアルタイム編集プレビュー
- マウスホバー時の Hex 座標表示
- 壁配置プレビュー（半透明表示）

### 3.2 アニメーション
- 壁変更時のトゥイーン
- 経路表示のアニメーション

### 3.3 マルチレイヤー
- 複数 TileMapLayer を管理（地形 + オブジェクト + 装飾）
- レイヤーごとの独立したタイルセット設定

###  マップのループ処理
    6.1. ∞マップ/Toricマップ実行時、カーソル追従によるループ表示機能
    6.2. 視覚的な経路長が最短(ジャンプしない)ように、ループ表示したマップ上で連結な経路表示(Toric Map:異なる座標でも同一になることがある,toricな近傍処理,連結な範囲内での始点・終点を選び直す)
    6.3. 視覚的な経路長が最短になるように、ループ表示したマップ上で連結な経路表示(∞ Map:異なる座標点は必ず区別する, non-toricな近傍処理)
