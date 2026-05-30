# RUNTIME_INTERACTION_LOOP_PATH_POLICY_2026-05-31.md

## 目的

`HexTileMapLayer` を実行時の表示helperから、クリック入力、連結性クエリ、toric / infinite loop表示、視覚的に連続したpath表示を扱えるruntime layerへ拡張する。

## 現状

- `HexTileMapLayer` は `HexMapResource` を適用し、子 `TileMapLayer` にfloor / wallを反映する。
- `local_to_hex()` / `hex_to_local()`、`set_wall()` / `set_floor()`、`find_path()`、`draw_path()`、`highlight_cell()`、`is_map_connected()`、`connected_component()` は実装済み。
- クリックsignal、hover signal、toric representativeを展開した表示、loop表示上での連続path描画はない。

## 方針

代表案として、canonical map dataを正とし、表示だけをloop展開する。

runtime上のcell identityは常に `HexVector` のcanonical keyで扱う。toric loop表示では、同じcanonical cellに対する複数のvisual representativeを計算し、描画やクリックhit時に「表示上の代表」と「canonical cell」を分けて扱う。

## 比較事項

### 候補A: canonical data + visual representative

- Resource schemaを増やさずにtoric loop表示を扱える。
- クリックsignalではcanonical cellとvisual cellを両方返せる。
- TileMapLayer上の複製cellをどう描くかはruntime layer側で制御する。

採用候補。

### 候補B: TileMapLayerに複製cellを実際に配置する

- GodotのTileMapLayer表示とhit判定を利用しやすい。
- 同一canonical cellの複数representativeをresourceへ逆反映しないよう注意が必要。

loop表示が主用途の場合の補助案。

### 候補C: shader / canvas repeatで見た目だけ繰り返す

- 大量表示には向く。
- cell単位のクリック、highlight、path表示と接続しにくい。

初期実装の代表案にはしない。

## 破壊的変更候補

- `draw_path(path)` をcanonical path専用から、`draw_path(path, options)` へ拡張する。
- `local_to_hex()` はcanonical変換のみとし、loop表示のhit testは `local_to_cell_hit()` のような新APIへ分ける。
- `HexTileMapLayer` の内部 `_tile_map` を1枚固定から、base layer / loop copy layer / overlay draw layerの複数管理へ変える。

## Fallback扱い

canonical pathをそのままpolylineで描く現状は、toric loop表示に対してはfallbackとして扱う。toric wrapをまたぐpathが画面上で大きくジャンプする状態は仕様として固定しない。

Infinite mapについて、有限resourceを無限に複製表示するだけの状態はfallbackである。infiniteでは異なる座標を同一cellとして扱わない方針を維持する。

## 入出力

入力:

- `HexMapResource`
- local mouse position
- viewport rectまたは表示範囲
- loop display mode
- canonical path
- cyclic_size

出力:

- clicked canonical cell
- clicked visual representative
- hover canonical cell
- connected component cells
- loop表示用representatives
- continuous visual path segments

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

## テスト方針

- headless testではlocal座標からcanonical cell / visual representativeへの変換を検証する。
- toric pathは、wrapをまたぐ隣接cellが表示上で近いrepresentativeへ展開されることを検証する。
- connected component helperは既存Core結果との一致を維持する。
- debug sceneでloop表示とpath表示を目視確認できるようにする。

## 完了条件

- クリックsignalがruntimeで使える。
- toric pathが視覚的に連続するrepresentative列として描ける。
- infinite表示では異なる座標を同一canonical cellへ潰さない。
- `docs/TEST.md` にheadless testとdebug workflowが記録される。
