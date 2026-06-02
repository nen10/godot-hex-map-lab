# HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_REVIEW_2026-06-02.md

## 目的

`HexTileMapLayer` の viewport 表示と generation dock apply が確認できた後に残った、Hex Map Edit Dock の操作性・trace・target解決の不足を整理する。

## ユーザー確認結果

### 確認済み

- `HexTileMapLayer` は edit 用 viewport 表示が可能。
- `HexTileMapLayer` は generation dock の generate 結果表示 target として利用可能。

### 未達 / 追加要望

1. 任意の Edit Mode 選択時、click しても viewport 表示が変わらない。
2. Last Edit が `target=no display=no tile=<atlas coord> -> <same atlas coord>` になり、表示変化の理由が読めない。
3. atlas の自動読み込みに依存せず、edit dock に明示的な tile 設定項目が必要。
4. edit dock 全体に scrollbar が必要。
5. generation dock の tab title が `@Control@18525` のように見えるため、edit dock と同様に title を設定する必要がある。
6. edit dock の Target `Auto` が機能しない。

## 対応調査

### 1. Edit Mode と viewport 表示

`HexMapEditTool._apply_mode_to_document()` は mode ごとに document を更新している。

- `Shape`: map cell 追加 / 削除
- `Wall / Floor`: wall toggle
- `Floor Tile` / `Wall Tile`: `tile_overrides` 更新
- `Object`: `objects` 更新
- `Label`: `labels` 更新

一方、`HexTileMapLayer` target への apply は `HexMapDocumentAdapter.to_map_resource(_document)` を `hex_map` に設定しており、`tile_overrides`、`objects`、`labels` は表示に反映されない。plain `TileMapLayer` では `HexMapDocumentAdapter.apply_to_tile_map_layer()` が `tile_overrides` を反映するため、`HexTileMapLayer` と plain `TileMapLayer` で表示可能な document payload に差がある。

判定:

- `Floor Tile` / `Wall Tile` は `HexTileMapLayer` でも表示反映対象にする必要がある。
- `Object` / `Label` は tile 表示とは別の marker / label overlay として表示設計が必要。
- `Last Edit` は document payload 変化と viewport display 変化を別理由として表示する必要がある。

### 2. Last Edit `target=no display=no`

`Last Edit` は `document_changed`、`target_applied`、`display_changed` を表示するが、`display_changed` は source / atlas coords の差分だけで判定される。Object / Label のように tile atlas が変わらない mode では、document が変わっても `display=no` になりうる。

また Target `Auto` が stale target または null に解決されると、`target=no` になる。`Auto` が機能していない状態では、viewport click 後の target apply の有無を信頼しにくい。

判定:

- `target=no` は target解決失敗、apply失敗、target class mismatchを区別する。
- `display=no` は `visual_changed=false` と `visual renderer missing` を区別する。
- trace に mode別 payload summary を追加する。

### 3. atlas 明示設定

edit dock には tile override payload 用の `Tile Source` / `Atlas X` / `Atlas Y` / `Alt` があるが、default floor / wall display tile 設定はない。`HexTileMapLayer` の auto sample atlas と plain `TileMapLayer` の inferred tile settings に依存しているため、ユーザーが表示前提を明示的に固定できない。

判定:

- edit dock に Default Floor / Default Wall の source / atlas / alt 設定を追加する。
- Target から現在値を読み取る操作と、Target へ明示適用する操作を分ける。
- `HexTileMapLayer` では `floor_source_id` / `floor_atlas_coords` / `wall_source_id` / `wall_atlas_coords` を更新する。
- plain `TileMapLayer` では document redraw options として保持し、apply時に使用する。

### 4. edit dock scrollbar

generation dock は `_build_ui()` で `ScrollContainer` を root に置いている。edit dock は `VBoxContainer` を直接 `add_child(root)` しており、payload controls と detail labels が増えた状態で dock高さが足りない。

判定:

- edit dock root を `ScrollContainer` + inner `VBoxContainer` に変更する。
- 横scrollは disabled、縦scrollは必要時表示にする。

### 5. generation dock tab title

plugin は edit dock には `_edit_tool.name = "Hex Map Edit"` を設定しているが、generation dock の `_dock` には name を設定していない。そのため Godot の dock tab が default node name のまま表示される。

判定:

- plugin または `HexMapGenDock._ready()` で `name = "Hex Map Generate"` を設定する。
- Test では plugin source または dock instance name を確認する。

### 6. edit dock Target Auto

`HexMapEditTool._resolve_target_layer()` は option が Auto の場合でも、既存 `_target_layer` が valid ならそれを返す。そのため Editor selection が変わっても Auto が現在選択中 node に追従しない。

判定:

- Auto は live editor selection を第一候補、scene root 以下の最初の target を第二候補にする。
- explicit target selection は現在通り固定 target として扱う。
- Auto 選択時は `_select_target_in_editor_if_possible()` で selection を書き換えない。

## 分類

| 項目 | 種別 | 対応方針 |
| --- | --- | --- |
| Edit Mode の表示変化なし | 機能不足 | `HexTileMapLayer` に document payload display apply / overlay を追加する。 |
| Last Edit の理由不足 | trace不足 | mode別 payload summary と failure reason を追加する。 |
| atlas明示設定 | UI不足 | edit dock に default display tile settings を追加する。 |
| edit dock scrollbar | UI不足 | edit dock root を `ScrollContainer` 化する。 |
| generation dock tab title | UI不足 | generation dock `name` を設定する。 |
| Target Auto | bug | Auto target resolution を live selection / first scene target に修正する。 |

## 計画化

- UX: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_UX_2026-06-02.md`
- Policy: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_POLICY_2026-06-02.md`
- Implementation Plan: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_IMPLEMENTATION_PLAN_2026-06-02.md`
- Plan Review: `docs/plan/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_PLAN_REVIEW_2026-06-02.md`
