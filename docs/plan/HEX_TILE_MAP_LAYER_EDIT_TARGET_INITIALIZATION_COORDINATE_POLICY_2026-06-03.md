# HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_POLICY_2026-06-03.md

## 目標UX

- `docs/plan/HEX_TILE_MAP_LAYER_EDIT_TARGET_INITIALIZATION_COORDINATE_UX_2026-06-03.md`

## 採用候補

### 候補A: Target由来documentを自動作成する

採用。

内容:

- Targetが `HexTileMapLayer` で、Edit Dockにdocumentがない場合、`HexTileMapLayer.hex_map` から `HexMapDocumentAdapter.from_map_resource()` で未保存documentを作る。
- Target Reload、Auto target解決、明示Target選択の後に実行する。
- Document status / debug reportに `document_source=target` を残す。

理由:

- ユーザーが確認した「Import / Load後なら編集できる」状態を、Target Reloadだけで成立させる。

### 候補B: Import / Loadを必須のままにする

不採用。

理由:

- `HexTileMapLayer` がすでにmapを表示しているのに編集開始できないUXは、Target Reloadの意味と一致しない。
- Import / Loadで回復する手順はhack扱いにする。

### 候補C: Manual Edit Targetを `HexTileMapLayer` 通常候補に限定する

採用。

内容:

- Target listの通常候補は `HexTileMapLayer` のみとする。
- 内部 `TileMapLayer` を選択した場合は親 `HexTileMapLayer` へAuto mappingする。
- plain `TileMapLayer` は通常Target候補から除外する。

理由:

- ユーザーが親 `HexTileMapLayer` と内部表示layerを区別せず操作できる。
- Target Autoがscene内の先頭plain layerへ流れる事故を減らせる。

### 候補D: plain `TileMapLayer` Manual Edit互換を隠し設定として残す

条件付き採用。

内容:

- 既存testやCore adapter確認用に、明示的なlegacy flagまたはtest-only setterでplain target経路を残す。
- UI上の通常Target候補には出さない。

判断:

- 既存機能の検証を残す必要がある場合のみ採用する。
- ユーザー向けUXの根拠にはしない。

### 候補E: Generator Primary Targetを `HexTileMapLayer` 中心にする

採用候補。

内容:

- Primary map applyのTarget候補は `HexTileMapLayer` を優先する。
- `Add new layer...` は引き続き `HexTileMapLayer` を作る。
- plain `TileMapLayer` Primary applyはlegacyまたはCore helper扱いにする。

注意:

- Generator Overlay applyは現状plain `TileMapLayer` を要求するため、同時に全面廃止しない。
- 既存Generator testの更新範囲が広いので、Manual Edit修正より慎重に進める。

### 候補F: `HexTileMapLayer` の表示座標基準を内部 `TileMapLayer` に寄せる

採用。

内容:

- hexから表示中心への変換は `HexMapTileAdapter.vector_to_map_cell(hex, flat_top)` と内部 `_tile_map.map_to_local()` を使う。
- local clickからhexへの変換は、内部 `_tile_map.local_to_map()` と `HexMapTileAdapter.map_cell_to_vector()` を使う。
- highlight / marker / pathも同じ表示中心helperを使う。

理由:

- Godot `TileMapLayer` のhex layout、tile size、offset axisに追従できる。
- 独自hex数式とGodot tile layoutの微差による累積ずれを避ける。

### 候補G: `hex_size` 同期だけで座標ずれを解決する

不採用寄り。

理由:

- tile sizeから `hex_size` を同期しても、Godotのhex layoutにおける中心・padding・offset axisとの差を完全に説明できない。
- `hex_size` はhighlight polygonサイズやtoric計算の補助値として残し、表示中心の仕様根拠にはしない。

### 候補H: 全Edit Modeをcell / marker / overlay単位でtarget applyする

採用。

内容:

- document更新後、`HexTileMapLayer` targetでは変更cellのみ内部 `_tile_map.set_cell()` する。
- `Wall / Floor` は `HexTileMapLayer.set_wall()` / `set_floor()` または新しい `apply_document_cell()` を使う。
- `Floor Tile` / `Wall Tile` はtile override cacheをcell単位更新し、対象cellを再描画する。
- `Shape` は対象cellの追加 / 削除、payload cleanup、base tile erase / setだけを行う。shape変更によりloop duplicateやconnected helperの再計算が必要な場合だけ、その副作用範囲を限定して更新する。
- `Object` / `Label` は対象cellのmarker cacheとfront overlay childだけを更新する。
- Overlay要Tileはoverlay用internal `TileMapLayer` またはoverlay canvas childの対象cellだけを更新する。

理由:

- 961 cell規模のmapでper-click全量redrawが重いという実感に直接効く。
- `Shape`、`Object`、`Label` もゲーム制作上は連続編集されるため、Wall / Tileだけ軽量化しても操作体験が揃わない。

### 候補I: Overlay要Tileのmanual edit経路を追加する

採用。

内容:

- Edit DockにOverlay要Tile用のmodeまたはpayload kindを追加する。
- payloadは `item_key`、source id、atlas coords、alternative tileを持つ。
- 短期schemaは `HexMapDocumentResource.tile_overrides` の `kind=overlay` と `item_key` を利用する。既存 `HexMapDocumentAdapter.KIND_OVERLAY` を仕様根拠として扱う。
- 表示は `HexTileMapLayer` 配下のoverlay用internal `TileMapLayer` を採用候補にする。tile atlas表示が不要なdebug markerだけの場合はfront overlay canvasでもよい。

理由:

- Wall / Floor / Floor Tile / Wall Tile以外の任意Overlay要Tileを、Generator Overlayだけでなくmanual editからも配置できる。
- `HexTileMapLayer` をPrimary map nodeとして扱うUXと整合する。

### 候補J: `HexTileMapLayer extends TileMapLayer` へ変更する

不採用。

理由:

- Godot標準TileMap editor対象とaddon manual edit対象が同じnodeになり、入力・Target・overlay・loop duplicate表示が干渉しやすい。
- 現在のwrapper + 内部 `TileMapLayer` 構成の方が、表示基盤を使いつつaddon専用UXを分離できる。

## 破壊的変更

- Manual Edit UIの通常Target候補からplain `TileMapLayer` を外す。
- Target Autoの解決優先順位を、選択中 `HexTileMapLayer` / 内部layerから親wrapper / scene内 `HexTileMapLayer` の順へ変更する。
- `HexTileMapLayer.hex_to_local()` を表示中心基準へ寄せる場合、既存Core debugの期待値を更新する必要がある。互換維持が必要なら新helper名を使う。
- Generator Primary Targetを `HexTileMapLayer` 中心にする場合、plain `TileMapLayer` 前提のEditor testを更新する。
- Overlay要Tileを `tile_overrides` の `kind=overlay` として扱うため、既存 `tile_overrides` の意味が「floor / wall tile override」から「cellに紐づく表示tile payload」へ広がる。

## fallback扱い

- Import / Loadし直してTarget Reload後の編集を可能にする手順はfallback扱いにしない。
- plain `TileMapLayer` のScene Tree順序でAuto targetを制御する手順はfallback扱いにしない。
- 1clickごとに全cell再構築する挙動は、どのEdit Modeでもfallbackとして成功条件にしない。

## UX Escalation

- plain `TileMapLayer` Manual Editを完全に外すことで既存ユーザー操作が大きく失われる場合、legacy modeのUI露出を再検討する。
- Generator Overlay applyを `HexTileMapLayer` targetへ統合する必要が出た場合、`HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE` 計画へescalationする。
- 内部 `TileMapLayer.map_to_local()` 基準にしてもtexture origin由来の見た目差が残る場合、TileSet atlas sourceのtexture origin / tile shape設定を追加調査する。
- `tile_overrides` の `kind=overlay` だけでは複数overlay layerや複数item stackingを表現しきれない場合、`HexMapDocumentResource` のoverlay payload schemaを長期アーキテクチャ計画へescalationする。
