- HEXAGONは同一サイズでも、生成方法によってCell座標集合が変わります。
  - Mask時のUniverseに齟齬が生じます。Overlay / Primary, symmetric/uniform どちらでも、HexMapData.squareの両端を切り落とす形式に統一します。
  - Core APIの生成形状の修正のみで対応可能です。
  - 座標固有のテストがあれば破壊的に修正してください。
- _shape_universe_from_values の SHAPE_TORUS の toric 指定 について一つ確認
  - symmetric生成に関してtoricを別の経路で設定するなどしているなら、Universeとしての生成にはtoric指定が無意味であるからこのままでよい。
- Clear Layerフラグのコントロールがあります
  - Primary生成では常時機能するのがよく、Overlayモードでは "Apply Write"のモード選択によって決定される内容ではないか？
  - 個別にコントロールがあることが、不要な実行経路を作り出していそうで、混乱している
  - 確認のためマトリクスをドキュメントする
- _refresh_generation_block_state の status 復元ロジック
  elif _generation_status == GENERATION_BLOCK_EMPTY_MASK \
      or _generation_status == GENERATION_BLOCK_EMPTY_ADJACENCY_RULES:
      _set_generation_progress(0.0, "Ready")
  ブロック理由が解消されたときに "Ready" に戻すが、他のブロック理由が追加された場合に漏れる。ブロック理由のプレフィックス判定や _current_generation_block_reason() == "" との比較の方が堅牢。

## 対応メモ

### Hexagon Cell universe

`HexMapData.hexagon(radius)` を canonical な Hexagon universe とし、`HexMapData.square(radius * 2 + 1, false)` から `HexToricMapSplitRule.split_canvas[0]` と `[7]` を除外した cell 集合を返す。

これにより Primary の simple hexagon、Primary の symmetric hexagon、Overlay の simple hexagon universe、Overlay の symmetric hexagon universe は同じ radius に対して同じ cell 集合を使う。

`generate_symmetric_hexagon()` の symmetric wall source generation は full toric split canvas を使う。split 0/7 を生成前に欠落させると、参照条件、random draw order、分布密度、progress total、Unity source sequence が変わる。したがって欠けた split は source generation から除外する領域ではなく、final hexagon data に含めない領域として扱う。

### SHAPE_TORUS universe

`_shape_universe_from_values()` の `SHAPE_TORUS` は non-toric square cell set を universe として扱う。Universe は座標集合であり、toric 性は snapshot の `overlay_cyclic_size` によって adjacency / offset 側へ渡す。

### Apply Write matrix

`Clear Layer` checkbox は削除する。TileMapLayer adapter の `clear_layer` と current Overlay data の更新方式は、Primary / Overlay 共通の `Apply Write` だけで決める。

| 操作 | Apply Write | TileMapLayer apply | current data |
| --- | --- | --- | --- |
| Primary Generate / Apply Layer | Clear And Write | target TileMapLayer を clear して Primary data を書く | `_current_data` は生成結果 |
| Primary Generate / Apply Layer | Add Item | target TileMapLayer を clear せず、Primary data の cell だけを書く | `_current_data` は生成結果 |
| Overlay Generate / Apply Layer | Clear And Write | target TileMapLayer を clear して Overlay data を書く | `_current_overlay_data` を新しい Overlay data に置換 |
| Overlay Generate / Apply Layer | Add Item | target TileMapLayer を clear せず、合成後 Overlay data の cell だけを書く | `_current_overlay_data` に新しい Overlay data を合成 |
| Crop result apply | Clear And Write | target TileMapLayer を clear して Crop result data を書く | `_current_overlay_data` を Crop result data に置換 |
| Crop result apply | Add Item | target TileMapLayer を clear せず、合成後 Overlay data の cell だけを書く | `_current_overlay_data` に Crop result data を合成 |

`current Overlay data` は最新 Overlay resource / stats / save 対象を表す runtime state として残す。ただし、更新規則は `Apply Write` に一本化し、TileMapLayer 側だけが別の clear policy を持つ経路は作らない。

### Generation block status

block 表示 status は `Blocked: <reason>` 形式に統一する。`_refresh_generation_block_state()` は prefix によって block status を判定し、理由が解消されたときに `Ready` へ戻す。
