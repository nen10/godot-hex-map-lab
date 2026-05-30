# HEX_CELL_BUTTON_EDITOR_UI_POLICY_2026-05-31.md

## 目的

Editor UIで使い回せる六角形cell button管理機能を作る。

`hex_dist_editor.gd` の価値は、矩形buttonではなく六角形cellを実際の近傍配置で並べている点にある。この配置を六方向button、近傍shape、flat-top / pointy-top切替、Editor UI用サイズ指定へ拡張し、Query Row offset controlもこの機能の利用例として簡潔に表示する。

既存の `QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_*` はQuery Row offset専用Controlの計画だったが、本計画ではより上位の「hex cell button UI管理」を正とする。

## 公式ドキュメント確認

確認した公式Godot documentation:

- Custom GUI controls: https://docs.godotengine.org/en/stable/tutorials/ui/custom_gui_controls.html
  - custom Controlは `_get_minimum_size()` でlayout用サイズを返し、`_gui_input()` でControl入力を扱える。
  - focusを持つControlではfocus状態を描画で示すことが推奨される。
- Control: https://docs.godotengine.org/en/4.4/classes/class_control.html
  - minimum sizeが変わるControlでは `update_minimum_size()` を使える。
- CanvasItem: https://docs.godotengine.org/en/4.5/classes/class_canvasitem.html
  - `draw_colored_polygon()` と `draw_polyline()` はlocal spaceのpointsを描画できる。
- Geometry2D: https://docs.godotengine.org/en/4.3/classes/class_geometry2d.html
  - `Geometry2D.is_point_in_polygon(point, polygon)` でpolygon内・境界上のpoint判定ができる。
- BaseButton: https://docs.godotengine.org/en/4.3/classes/class_basebutton.html
  - `pressed()` signal、`disabled`、`toggle_mode`、`get_draw_mode()` などbutton状態の参考になる。

## 現状

- `hex_dist_editor.gd` は `Control.draw` signalで、中心cellと1-3個の参照cellを描画している。
- 六角形polygonは `_draw_hex()` で `draw_colored_polygon()` と `draw_polyline()` を使って描く。
- 配置は `ref0` / `ref1` / `ref2` の固定Vector2で、flat-topのみを前提にしている。
- 既存Query Row offsetは `GridContainer` + text `Button` で六方向を表示している。

## 方針

代表案として、単一のcustom `Control` が複数のhex cell buttonを描画・hit test・状態管理する。

Godot標準 `Button` をcellごとに並べる方式は採用しない。子Controlの入力領域は矩形になり、六角形cell同士を詰めて配置する目的とずれるためである。代わりに、親Controlが全cellのpolygonを持ち、`_gui_input()` で `Geometry2D.is_point_in_polygon()` によるhit testを行い、button-likeなsignalをemitする。

## 比較事項

### 候補A: 標準 `Button` を六角形風に描画する

- Godotのbutton signal / focus / disabledをそのまま使える。
- 入力領域は矩形のまま残る。
- 隣接する六角形cellの矩形boundsが重なった場合、見た目とhit判定がずれる。

fallback候補。目的の一貫性に合わないため代表案にしない。

### 候補B: cellごとのcustom `Control` を並べる

- 各cellが独立したControlとして扱える。
- ただしControl dispatchは矩形boundsを基準にするため、正確なhex hitには親側調整が必要になる。
- focus neighbor設定はしやすい。

補助案。複数cellを密に配置するQuery Rowには不向き。

### 候補C: 単一custom `Control` が全cellを描画・hit testする

- `hex_dist_editor.gd` の描画資産を自然に拡張できる。
- polygon hit testにより、見た目と入力判定を一致させられる。
- focus / hover / pressed / disabled状態は自前で管理する必要がある。

採用候補。

### 候補D: `TextureButton` / `TextureRect` で六角形画像を並べる

- 見た目の調整は容易。
- flat-top / pointy-topやサイズ変更に対するgeometry再計算が別途必要。
- テーマ色やEditor状態の反映が複雑になる。

代表案にはしない。

### cell gapの解釈

候補:

- `cell_gap` を `HexMapTileAdapter.hex_to_local(cell, cell_radius + cell_gap, flat_top)` に渡すpitch補正値として扱う。
- `cell_gap` を辺同士の最短距離として扱い、orientationごとにcenter間隔へ変換する。

代表案ではpitch補正値として扱う。Editor UIでは厳密な実寸gapより、既存hex layoutとの方向関係を保ったままcompact / wideを調整できることを優先する。

### label描画方式

候補:

- `draw_string()` でPanel自身がlabelを描く。
- cell上のtextは省略し、tooltipと外部labelで説明する。
- child `Label` をcell centerに重ねる。

代表案ではPanel自身が短いlabelを描く。長いtextはtooltipへ逃がす。child `Label` は矩形Controlの重なりを増やすため、初期実装では使わない。

## 破壊的変更候補

- Query Row offsetの既存text `Button` gridを廃止し、`HexCellButtonPanel` を使う。
- `hex_dist_editor.gd` の固定配置 `_draw_pattern()` を、共通layout builderへ置き換える。
- `+Q` / `-R` 等の常時text表示をやめ、hex cell上の短いlabelまたはtooltipへ移す。
- direction button size SpinBoxを「cell radius / gap / padding」のUI指定へ置き換える。

## Fallback扱い

矩形button、矩形hit、text-only direction gridはfallbackであり、仕様の中心にしない。

六角形描画だけを行い、hit判定が矩形のまま残る実装もfallbackである。本計画の正は、描画polygonとhit polygonを同じlayout entryから作ることに置く。

## Hex cell button model

### Layout spec

入力候補:

- `flat_top: bool`
- `cell_radius: float`
- `cell_gap: float`
- `padding: Vector2`
- `shape_kind: String`
- `shape_cells: Array[HexVector]`
- `pressable_cells: Dictionary`
- `center_cell: HexVector`
- `label_provider: Callable`
- `metadata_provider: Callable`

### Layout entry

出力候補:

```gdscript
{
    "id": String,
    "hex": HexVector,
    "center": Vector2,
    "polygon": PackedVector2Array,
    "bounds": Rect2,
    "pressable": bool,
    "disabled": bool,
    "label": String,
    "tooltip": String,
    "metadata": Dictionary,
}
```

layout entryは描画とhit testの単一source of truthにする。

## 近傍shape候補

- `directions`: center + six neighbors
- `ring`: `HexGrid.l1_ring(radius)`
- `disc`: `HexGrid.l1_disc(radius)`
- `custom`: 呼び出し側が渡す `Array[HexVector]`
- `distribution_pattern`: `hex_dist_editor.gd` の1-3 reference cells + center

代表案では、まず `directions` と `custom` を実装対象にする。`ring` / `disc` はlayout builderの同じ接口で追加できる。

`distribution_pattern` は `custom` の定型呼び出しとして扱う。既存 `hex_dist_editor.gd` のflat-top表示では、上側3近傍を direction index `[3, 2, 1]` の順に並べているものとして固定する。

## Query Row offsetへの適用

Query Rowは `HexCellButtonPanel` に以下を渡す。

- `shape_kind = "directions"`
- center cellは現在offsetのlabel表示のみ
- six neighborsをpressableにする
- neighbor metadataに `direction_index` と `HexVector.directions()[index]` を持たせる
- cell pressed時に `offset = offset.add(direction)` としてrowを再評価する

## テスト方針

- layout builderがflat-top / pointy-topで異なるcenter配置を作ること。
- `cell_radius` / `cell_gap` / `padding` がminimum sizeとpolygonに反映されること。
- polygon hit testが六角形外かつ矩形bounds内のpointを拒否すること。
- Query Row offsetが `HexCellButtonPanel` のpressed signalで更新されること。
- `hex_dist_editor.gd` のpattern表示が共通layout builderを使っても同等のcell配置を保つこと。

## 完了条件

- 六角形cell buttonのlayout生成、描画、hit test、pressed signalが文書化されたAPIで扱える。
- flat-top / pointy-top、近傍shape、Editor UI用サイズ指定を入力として受け取れる。
- Query Row offsetはこのUI管理機能を流用して表示・操作できる。
- `hex_dist_editor.gd` の六角形cell配置は共通機能へ移行可能な計画になっている。
