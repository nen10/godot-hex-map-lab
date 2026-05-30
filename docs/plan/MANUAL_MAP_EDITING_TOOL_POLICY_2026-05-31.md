# MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md

## 目的

生成Dockとは別のEditor toolとして、Hex座標単位でshape、wall / floor、tile override、object、labelを編集できるmanual map editing toolを計画する。

生成処理は一括生成を目的とし、manual toolはユーザー操作とUndo / Redoを目的にする。両者の責務を分ける。

## 現状

- Editor Dockは生成結果、resource、TileMapLayer、distribution、atlas setupを接続している。
- `HexTileMapLayer.set_wall()` / `set_floor()` はruntime helperとして実装済み。
- Editor上のWYSIWYG paint、object database、label database、Undo / Redoはまだ独立した仕様が必要。
- `docs/plan/PENDING.md` に分割仕様がある。

## 方針

代表案として、resource-primaryな編集toolを作る。

編集の正はresource documentに置き、TileMapLayerは表示結果として同期する。クリック操作はEditor viewportからHex座標へ変換し、UndoRedo actionとしてresourceとTileMapLayerの両方へ反映する。

## 比較事項

### 候補A: `HexMapResource` を直接拡張する

- 既存resourceをそのまま編集できる。
- tile paint / object / labelまで入れると、core map data resourceが肥大化する。

小規模導入には向くが、長期の代表案にはしない。

### 候補B: `HexMapDocumentResource` を新設する

- primary map、tile overrides、objects、labels、orientationを1つの編集documentとして扱える。
- 既存 `HexMapResource` とのimport / exportが必要。

採用候補。

### 候補C: TileMapLayerを正として復元する

- Godot標準編集に近い。
- Hex Map Kit側のresource保存、Undo / Redo、object / label schemaとの整合が難しい。

代表案にはしない。

## 破壊的変更候補

- Editor DockのGenerate / Apply中心UIから、Map Documentを選択するEditor toolへ分離する。
- `HexMapResource`だけを保存対象にするflowを、`HexMapDocumentResource`中心へ移す。
- object / labelをOverlay itemとして扱う暫定案をやめ、専用schemaへ分ける。

## Fallback扱い

TileMapLayerへ直接paintし、後からmap dataへ復元する方式はfallbackとして扱う。仕様の正はresource documentに置く。

object / labelを単なるOverlay item keyへ詰める方式もfallbackである。object id、label id、property dictionaryを保存できるschemaを用意する。

## 編集対象

- shape cell追加 / 削除
- wall / floor切替
- floor tile override
- wall tile override
- object配置 / 削除 / property編集
- label配置 / 削除 / text編集

## 入出力

入力:

- selected `HexMapDocumentResource`
- selected editable `TileMapLayer`
- edit mode
- cursor local position
- paint payload
- object / label database resource

出力:

- updated `HexMapDocumentResource`
- updated `HexMapResource` export
- updated `TileMapLayer`
- UndoRedo action
- object / label database resource

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

補助resource:

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

object / label databaseはpayload候補の定義を持つ。cellごとの配置結果は `HexMapDocumentResource.objects` / `labels` に保存する。

entry例:

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

- resource roundtripでshape、wall / floor、tile override、object、labelが維持される。
- Undo / Redo actionがresourceとTileMapLayerの両方を戻す。
- Editor viewport clickからHex座標が得られ、edit modeに応じてpayloadが適用される。
- Generate Dockで作った `HexMapResource` をDocumentへimportできる。

## 完了条件

- manual editing toolが生成Dockと別責務で動く。
- 編集結果の正がresource documentに保存される。
- TileMapLayerはresource documentから再描画できる。
- headless testとEditor workflow testの両方が記録される。
