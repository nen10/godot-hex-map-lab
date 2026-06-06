# RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md

## 目的

`HexTileMapLayer` を、クリック入力、連結性クエリ、toric / infinite loop 表示、視覚的に連続した path 表示を扱える runtime layer として維持し、manual edit 用表示からも再利用できるようにする。

## 対象範囲

- `HexTileMapLayer` の canonical data と visual representative を分離する。
- `local_to_cell_hit()` を manual edit 用表示の座標変換の正とする。
- toric / infinite loop 表示で、クリック対象と表示上の代表を区別する。
- loop duplicate を tile copy として表示する。
- path / connected component / highlight は canonical cell を正とし、表示時だけ representative を使う。

## 方針

代表案として、canonical map data を正とし、表示だけを loop 展開する。

runtime 上の cell identity は常に `HexVector` の canonical key で扱う。toric loop 表示では、同じ canonical cell に対する複数の visual representative を計算し、描画やクリック hit 時に「表示上の代表」と「canonical cell」を分けて扱う。

manual edit 用表示はこの runtime layer の結果を利用する。manual tool は `hit["hex"]` を document 更新対象、`hit["visual_hex"]` を表示上の選択・status・highlight 対象として扱う。

## 比較事項

### 候補A: canonical data + visual representative

- Resource schema を増やさずに toric loop 表示を扱える。
- クリック signal では canonical cell と visual cell を両方返せる。
- path、connected component、manual edit の更新対象を canonical に統一できる。

採用済みの基盤案。

### 候補B: runtime-owned loop copy `TileMapLayer`

- canonical `_tile_map` とは別に copy 用 `TileMapLayer` を持ち、visual representative の offset cell に同じ tile を描く。
- manual edit 用表示で、outline だけでなく実際の floor / wall tile を見ながら loop duplicate を編集できる。
- document / resource へは copy cell を保存せず、表示更新時に canonical cell から再構成する。

2. RUNTIME_INTERACTION_LOOP_DISPLAY_TILE_COPY の代表候補。

### 候補C: custom draw による tile surrogate 表示

- `CanvasItem._draw()` だけで duplicate の見た目を補える。
- TileSet の atlas / alternative tile / terrain 情報を再現しにくい。
- hit test と highlight の補助表示には使えるが、manual edit の WYSIWYG 表示としては弱い。

補助候補。

### 候補D: shader / canvas repeat で見た目だけ繰り返す

- 大量表示には向く。
- cell 単位のクリック、highlight、path 表示、manual edit の canonical 更新と接続しにくい。

補助候補。

## 破壊的変更候補

- `HexTileMapLayer` の内部 `_tile_map` を1枚固定から、base layer / loop copy layer / overlay draw layer の複数管理へ変える。
- `draw_path(path)` を canonical path 専用から、`draw_path(path, options)` へ拡張し、anchor / loop mode / color を明示できるようにする。
- `local_to_hex()` は canonical 変換のみとし、loop 表示の hit test は `local_to_cell_hit()` を正規 API として扱う。
- Inspector 上の input 系 export と loop display 系 export をグループ化し、manual edit で必要な表示設定を探しやすくする。

## Fallback扱い

canonical path をそのまま polyline で描き、toric wrap をまたぐ path が画面上で大きくジャンプする状態は fallback である。正規の path 表示は visual representative 列を使う。

outline だけの loop duplicate 表示は、manual edit 用表示に対しては fallback として扱う。manual edit では canonical cell の複製が編集対象として見える必要があるため、可能なら tile copy 表示へ破壊的に移行する。

finite resource を infinite map として複製表示し、異なる座標を同一 canonical cell として扱う状態は fallback である。infinite では異なる座標を同一 cell として扱わない方針を維持する。

## 入出力

入力:

- `HexMapResource`
- local mouse position
- viewport rect または表示範囲
- loop display mode
- canonical path
- cyclic_size
- manual edit target state

出力:

- clicked canonical cell
- clicked visual representative
- hover canonical cell
- connected component cells
- loop 表示用 representatives
- continuous visual path segments
- loop copy 表示用 tile entries

## Runtime API候補

Signals:

```gdscript
signal cell_clicked(hex, event)
signal cell_hovered(hex)
signal cell_hit_clicked(hit: Dictionary, event)
signal cell_hit_hovered(hit: Dictionary)
```

Methods:

```gdscript
func local_to_cell_hit(local_pos: Vector2) -> Dictionary
func visual_representatives_for_cell(hex, rect: Rect2, margin: int = 1) -> Array
func visual_path_for_canonical_path(path: Array, anchor_local: Vector2 = Vector2.ZERO) -> Array
func draw_loop_path(path: Array, color: Color) -> void
func visual_cell_entries_for_rect(rect: Rect2, margin: int = 1) -> Array
func refresh_loop_display() -> void
```

hit dictionary:

```gdscript
{
    "hex": HexVector,          # canonical
    "visual_hex": HexVector,   # unfolded / visual representative
    "local": Vector2,
    "exists": bool,
}
```

visual cell entry:

```gdscript
{
    "hex": HexVector,          # canonical
    "visual_hex": HexVector,   # unfolded / visual representative
    "map_cell": Vector2i,
    "is_canonical": bool,
}
```

## テスト方針

- headless test では local 座標から canonical cell / visual representative への変換を検証する。
- toric path は、wrap をまたぐ隣接 cell が表示上で近い representative へ展開されることを検証する。
- connected component helper は既存 Core 結果との一致を維持する。
- loop copy 表示は visual representative ごとの tile entry が canonical cell の floor / wall と一致することを検証する。
- manual edit 側の test では `HexTileMapLayer.local_to_cell_hit()` の hit dictionary を正として、visual duplicate から canonical document が更新されることを検証する。
- debug scene で loop 表示、path 表示、cell hit 表示を目視確認できるようにする。

## 完了条件

- クリック signal が runtime で使える。
- toric path が視覚的に連続する representative 列として描ける。
- infinite 表示では異なる座標を同一 canonical cell へ潰さない。
- manual edit 用表示で loop duplicate cell が編集対象として視認できる。
- `docs/TEST.md` に headless test と debug workflow が記録される。
