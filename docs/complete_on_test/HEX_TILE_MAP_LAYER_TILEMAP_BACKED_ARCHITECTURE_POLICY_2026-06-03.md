# HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_POLICY_2026-06-03.md

## 目標UX

- `docs/complete_on_test/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_UX_2026-06-03.md`

## 現状反映 2026-06-05

- `HexTileMapLayer` Target初期化、Target Status、internal `TileMapLayer` 座標API利用、Target TileSet / atlas path selectionは実装済みとして扱う。
- `display_tile_set_resource` によりTarget TileSet resourceのPackedScene永続化は解決済みとして扱う。
- Manual editのOverlay Tile / Object / Label表示責務は `HexTileMapLayer` 配下へ寄せる方向で完了済みとして扱う。
- このFlowの残りは、per-click editがdocument全量複製 / Resource変換 / `_data` 全量再構築へ戻る経路を、Target内部state command APIへ置き換えることに絞る。

## 採用候補

### 候補A: `HexTileMapLayer extends TileMapLayer`

不採用。

理由:

- Godot標準TileMap editorの対象nodeとaddon独自manual edit targetが同一になり、入力処理とTarget解決が干渉しやすい。
- loop duplicate用 `TileMapLayer`、overlay child、payload markerを同じnode配下で制御する現在の構成と相性が悪い。
- `TileMapLayer` 継承にしても、hex map semantics、document payload、toric identity、generator historyを自動的に得られるわけではない。

### 候補B: `Node2D` wrapper + 内部 `TileMapLayer` を維持する

採用。

内容:

- `HexTileMapLayer` はユーザーが選択するwrapper nodeのままにする。
- base表示、loop duplicate、overlay / markerは内部childに分ける。
- 座標と表示cell更新は内部 `TileMapLayer` APIを使う。

理由:

- Godotの表示性能と座標APIを使いながら、addon専用のTarget / overlay / toric semanticsを分離できる。

### 候補C: Resourceをlive editのsource of truthにする

不採用。

理由:

- 1clickごとにResource変換 / 複製 / 全量applyが走り、Editor操作が重くなる。
- Resourceは永続化・import/export・history snapshotには適しているが、live editの高速pathには過剰。

### 候補D: `HexTileMapLayer` 内部stateをsource of truthにする

採用。

内容:

- `HexTileMapLayer` 内にmap cells、walls、tile overrides、overlay tile entries、objects、labelsを保持するstateを持つ。
- `edit_cell()` / `set_wall()` / `set_tile_override()` などのAPIでstateと表示を同時にincremental更新する。
- `to_map_resource()` / `to_document_resource()` で保存用snapshotを生成する。
- `load_map_resource()` / `load_document_resource()` でResourceから内部stateを復元する。

### 候補E: `TileMapLayer` の表示cellからsemantic stateを逆算する

不採用寄り。

理由:

- atlas coordとwall / floor semanticsはユーザー設定に依存し、Object / Label / Overlay payloadを表現できない。
- 表示cellは結果であり、addonのsemantic stateの完全なsource of truthにはしにくい。

### 候補F: 内部stateと内部 `TileMapLayer` の双方向同期を限定的に行う

採用。

内容:

- 通常編集は内部stateから内部 `TileMapLayer` へ同期する。
- Debug / migration用途に限り、既存plain `TileMapLayer` からmapを読むimport helperを用意する。
- 表示中心 / hit判定は内部 `TileMapLayer` から読む。

### 候補G: Overlay要Tileを `HexTileMapLayer` 配下の専用表示層へ統合する

採用。

内容:

- Primary mapはbase internal `TileMapLayer`。
- Overlay tile itemは別internal `TileMapLayer` またはoverlay canvas child。
- Manual editで配置されるOverlay要TileとGenerator Overlay resultを同じ表示層に接続する。
- Object / Label markerはfront overlay child。

判断:

- Manual edit側の表示責務は完了済み構成を維持する。
- Generator Overlay applyにplain `TileMapLayer` 依存が残る場合は、同じoverlay state APIへ接続する。
- Object scene layer自体はObject Asset Boundaryの別Flowへ分離する。

### 候補H: Scene保存にdocument payloadを暗黙永続化する

不採用。

理由:

- file/resource selection UXでは、Target由来documentはunsaved snapshotであり、保存は明示操作として扱う。
- scene保存にdocument payloadを暗黙混入すると、scene保存とdocument保存の責務が重複する。
- `HexTileMapLayer` scene保存はTarget node構成、`hex_map` snapshot、`display_tile_set_resource` など表示に必要な設定までに留める。

Escalation:

- sceneをdocument保存媒体にしたい要求が上位UXで必要になった場合、`HexMapDocumentResource` subresourceを `HexTileMapLayer` に持たせる別Planning Flowで判断する。

### 候補I: Edit Dock Undo / Redoをdocument全量snapshotで続ける

不採用。

理由:

- per-click performance改善の主目的に反する。
- Target state command APIに対して、before / after最小差分またはinverse commandを持つ形に移行する。

### 候補J: まず専用state classを新設する

保留。

判断:

- 初回実装では `HexTileMapLayer` 内のdictionary / typed helperによる最小state APIを優先する。
- state肥大化やResource schemaとの重複が実装上の問題になった時点で、non-Resource state classへ分離する。

### 候補K: Object scene layerをこのFlowで実装する

不採用。

理由:

- Object scene layer、object database、scene resource boundaryはObject Asset Boundary reviewの範囲であり、Primary map live state高速化とは責務が異なる。
- このFlowではObject / Label marker stateのsnapshot roundtripと表示同期までを扱う。

## 破壊的変更

- `HexTileMapLayer.hex_map` を唯一のlive stateとして扱わなくなる。互換propertyとしてsnapshotを保持するか、setter / getterで内部stateと同期する。
- Manual Edit / Generator PrimaryのUI targetは `HexTileMapLayer` を標準とする。
- plain `TileMapLayer` targetはCore helperまたはmigration/import用途に移る。
- `apply_document_cell()` のようなdocument全量snapshot入力APIは、Editorの通常per-click経路から外す。

## fallback扱い

- Resource全量再生成によるper-click表示更新はfallback扱いにしない。
- plain `TileMapLayer` をPrimary map nodeとして選び続けるUXはfallback扱いにしない。
- Godot標準TileMap editorで直接paintした結果をaddon semantic stateとして扱う挙動はfallback扱いにしない。

## UX Escalation

- `HexTileMapLayer` 内部stateが肥大化してResource schemaと重複しすぎる場合、state classを `HexMapDocumentResource` 互換のnon-Resource modelとして分離する。
- Overlay統合でGeneration Dockの操作が複雑になる場合、Primary / OverlayをtabまたはTarget typeで明示分離する。
- Godot標準TileMap editorとの併用要求が強い場合、plain `TileMapLayer` import helperを強化し、直接編集はaddon外のmigration pathとして扱う。
- scene保存でdocument payloadを暗黙保存したい要求が強い場合、file/resource selection UXと衝突するため、上位UXで「scene document化」を別途判断する。
