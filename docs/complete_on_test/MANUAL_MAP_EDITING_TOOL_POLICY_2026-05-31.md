# MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md

## 目的

生成 Dock とは別の Editor tool として、Hex 座標単位で shape、wall / floor、tile override、object、label を編集できる manual map editing tool を維持し、runtime loop display の実装結果を manual edit 用表示へ接続する。

生成処理は一括生成を目的とし、manual tool はユーザー操作と Undo / Redo を目的にする。両者の責務を分ける。

## 対象範囲

- `HexMapDocumentResource` を編集結果の正とする。
- `HexMapResource` import / export を generated map と manual edit document の接続点にする。
- Editor viewport click を document mutation と Undo / Redo に接続する。
- loop 表示付き manual edit では `HexTileMapLayer.local_to_cell_hit()` を座標変換の正とする。
- manual edit 用表示では duplicate cell の tile と選択状態が視認できる状態を目標にする。
- Dock UI は edit mode ごとに必要な payload controls だけを表示する。

## 方針

代表案として、resource-primary な編集 tool を維持する。

編集の正は resource document に置き、TileMapLayer / HexTileMapLayer は表示結果として同期する。クリック操作は Editor viewport から Hex 座標へ変換し、UndoRedo action として resource と表示 layer の両方へ反映する。

loop 表示を使う manual edit では `HexTileMapLayer` を表示対象として優先し、runtime layer が返す hit dictionary を唯一の座標変換結果として扱う。`hit["hex"]` は document 更新対象、`hit["visual_hex"]` は表示上の duplicate / highlight / status 対象である。

## 比較事項

### 候補A: `HexMapDocumentResource` を正とする

- primary map、tile overrides、objects、labels、orientation を1つの編集 document として扱える。
- 既存 `HexMapResource` との import / export が必要。
- Undo / Redo と保存対象が明確になる。

採用済みの基盤案。

### 候補B: `HexMapResource` を直接拡張する

- 既存 resource をそのまま編集できる。
- tile paint / object / label まで入れると、core map data resource が肥大化する。

小規模導入向けの候補。

### 候補C: TileMapLayer を正として復元する

- Godot 標準編集に近い。
- Hex Map Kit 側の resource 保存、Undo / Redo、object / label schema との整合が難しい。

fallback として扱う。

### 候補D: manual edit 用表示に `HexTileMapLayer` を使う

- `local_to_cell_hit()` により canonical cell と visual representative を同じ hit dictionary で扱える。
- toric / infinite identity、loop path、connected component helper を runtime と editor で共有できる。
- manual edit 側は座標変換を再実装せず、document mutation と Undo / Redo に集中できる。

2. MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY の代表候補。

### 候補E: manual edit 用に独自 overlay view を作る

- Editor 専用の selection / handle 表示は作りやすい。
- runtime loop display と座標変換が重複し、目的の一貫性が弱くなる。

highlight や selection 補助の候補に留める。

## 破壊的変更候補

- Editor Dock の Generate / Apply 中心 UI から、Map Document を選択する Editor tool へさらに分離する。
- `HexMapResource` だけを保存対象にする flow を、`HexMapDocumentResource` 中心へ移す。
- object / label を Overlay item として扱う暫定案をやめ、専用 schema へ分ける。
- manual edit の loop 表示対象を plain `TileMapLayer` 互換から `HexTileMapLayer` 優先へ寄せる。
- payload controls を edit mode ごとに切り替え、Tile / Object / Label の入力を mode ごとの表示に整理する。

## Fallback扱い

TileMapLayer へ直接 paint し、後から map data へ復元する方式は fallback として扱う。仕様の正は resource document に置く。

object / label を単なる Overlay item key へ詰める方式も fallback である。object id、label id、property dictionary を保存できる schema を用意する。

plain `TileMapLayer` だけで toric visual duplicate を編集対象として扱う方式は fallback である。loop 表示付き manual edit は `HexTileMapLayer.local_to_cell_hit()` と visual representative を利用する。

outline だけの loop duplicate 表示で編集できる状態は暫定 fallback とする。manual edit の目的では、duplicate cell の tile と選択状態が視認できることを優先する。

## 編集対象

- shape cell 追加 / 削除
- wall / floor 切替
- floor tile override
- wall tile override
- object 配置 / 削除 / property 編集
- label 配置 / 削除 / text 編集
- toric visual duplicate からの canonical cell 編集
- loop 表示上の selected / hovered visual representative 表示

## 入出力

入力:

- selected `HexMapDocumentResource`
- selected editable `TileMapLayer` または `HexTileMapLayer`
- edit mode
- cursor local position
- hit dictionary
- paint payload
- object / label database resource
- loop display settings

出力:

- updated `HexMapDocumentResource`
- updated `HexMapResource` export
- updated display layer
- UndoRedo action
- object / label database resource
- edited canonical cell と visual representative の status

## Resource schema候補

代表案:

```gdscript
class_name HexMapDocumentResource
extends Resource

@export var map: HexMapResource
@export var tile_overrides: Array[Dictionary]
@export var objects: Array[Dictionary]
@export var labels: Array[Dictionary]
@export var version: int = 1
```

補助 resource:

```gdscript
class_name HexObjectDatabaseResource
extends Resource

@export var objects: Array[Dictionary]
```

```gdscript
class_name HexLabelDatabaseResource
extends Resource

@export var labels: Array[Dictionary]
```

object / label database は payload 候補の定義を持つ。cell ごとの配置結果は `HexMapDocumentResource.objects` / `labels` に保存する。

entry 例:

```gdscript
{
    "cell": Vector3i,
    "kind": "floor",
    "source_id": 0,
    "atlas_coords": Vector2i.ZERO,
    "alternative_tile": 0,
}
```

```gdscript
{
    "cell": Vector3i,
    "object_id": "chest",
    "properties": {},
}
```

```gdscript
{
    "cell": Vector3i,
    "label_id": "area_name",
    "text": "North Gate",
}
```

## テスト方針

- resource roundtrip で shape、wall / floor、tile override、object、label が維持される。
- Undo / Redo action が resource と表示 layer の両方を戻す。
- Editor viewport click から Hex 座標が得られ、edit mode に応じて payload が適用される。
- Generate Dock で作った `HexMapResource` を document へ import できる。
- `HexTileMapLayer` の toric visual duplicate を click したとき、document 上の canonical cell だけが更新される。
- loop 表示更新後も Undo / Redo と selected visual representative が矛盾しない。

## 完了条件

- manual editing tool が生成 Dock と別責務で動く。
- 編集結果の正が resource document に保存される。
- 表示 layer は resource document から再描画できる。
- loop 表示付き manual edit は runtime の `local_to_cell_hit()` と visual representative を利用する。
- headless test と Editor workflow test の両方が記録される。
