# HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_POLICY_2026-06-03.md

## 目標UX

- `docs/plan/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_UX_2026-06-03.md`

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

採用候補。

内容:

- Primary mapはbase internal `TileMapLayer`。
- Overlay tile itemは別internal `TileMapLayer` またはoverlay canvas child。
- Manual editで配置されるOverlay要TileとGenerator Overlay resultを同じ表示層に接続する。
- Object / Label markerはfront overlay child。

判断:

- Primary edit安定後に進める。
- Generator Overlay applyのplain target依存を解消する時に採用する。

## 破壊的変更

- `HexTileMapLayer.hex_map` を唯一のlive stateとして扱わなくなる。互換propertyとしてsnapshotを保持するか、setter / getterで内部stateと同期する。
- Manual Edit / Generator PrimaryのUI targetは `HexTileMapLayer` を標準とする。
- plain `TileMapLayer` targetはCore helperまたはmigration/import用途に移る。

## fallback扱い

- Resource全量再生成によるper-click表示更新はfallback扱いにしない。
- plain `TileMapLayer` をPrimary map nodeとして選び続けるUXはfallback扱いにしない。
- Godot標準TileMap editorで直接paintした結果をaddon semantic stateとして扱う挙動はfallback扱いにしない。

## UX Escalation

- `HexTileMapLayer` 内部stateが肥大化してResource schemaと重複しすぎる場合、state classを `HexMapDocumentResource` 互換のnon-Resource modelとして分離する。
- Overlay統合でGeneration Dockの操作が複雑になる場合、Primary / OverlayをtabまたはTarget typeで明示分離する。
- Godot標準TileMap editorとの併用要求が強い場合、plain `TileMapLayer` import helperを強化し、直接編集はaddon外のmigration pathとして扱う。
