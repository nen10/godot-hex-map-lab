# HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_UX_2026-06-02.md

## 目的

`HexTileMapLayer` を primary target とした Hex Map Edit Dock で、click 操作、target解決、tile表示設定、Last Edit trace、Dock layout を信頼できる UX にする。

## 参照

- Review: `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_REVIEW_2026-06-02.md`
- Completed target plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_COMMON_TARGET_IMPLEMENTATION_PLAN_2026-06-02.md`
- Existing visibility UX: `docs/complete_on_test/MANUAL_MAP_EDITING_EDITOR_VISIBILITY_UX_2026-06-02.md`
- Backlog related item: `docs/plan/REVIEW_BACKLOG_2026-06-02.md` U2-1

## Use Case

- Actor: Godot Editor で Hex Map Kit addon を使う制作者。
- Goal: `HexTileMapLayer` を選択し、任意の Edit Mode で click した結果が、viewport または Last Edit trace で判断できる。
- Scenario: generation dock で作った map を `HexTileMapLayer` に表示し、Hex Map Edit Dock で Auto target または explicit target を使って shape / wall / tile / object / label を編集する。
- Success state: target が自動解決され、default floor / wall tile が明示設定でき、scroll可能な edit dock 内で Last Edit が document変更、target apply、表示変化、表示不可理由を区別して示す。

## Operation Steps 素案と評価

| Step | 操作 / 観察 | 評価 | 目標 |
| --- | --- | --- | --- |
| 1 | generation dock の tab を開く | 有用 / 維持 | tab title が `Hex Map Generate` として表示される。 |
| 2 | Hex Map Edit Dock を開く | 有用 / 維持 | Dock 全体を縦scrollできる。 |
| 3 | Target を `Auto` にする | 有用 / 維持 | Scene Tree 選択中の `HexTileMapLayer` を target に解決する。 |
| 4 | Target を explicit `HexTileMapLayer` にする | 有用 / 維持 | Auto と異なり、選択後は固定 target として扱う。 |
| 5 | Default Floor / Wall tile を edit dock で設定する | 有用 / 追加 | source / atlas / alt を明示設定し、auto sample atlas に依存しない。 |
| 6 | Target から display tile 設定を読み取る | 有用 / 追加 | 現在の `HexTileMapLayer` / plain `TileMapLayer` の設定をUIへ反映する。 |
| 7 | `Shape` mode で click する | 有用 / 維持 | cell追加 / 削除が viewport と Last Edit に出る。 |
| 8 | `Wall / Floor` mode で click する | 有用 / 維持 | floor / wall tile が default tile 設定に従って切り替わる。 |
| 9 | `Floor Tile` / `Wall Tile` mode で click する | 有用 / 追加 | tile override が `HexTileMapLayer` viewport に反映される。 |
| 10 | `Object` / `Label` mode で click する | 有用 / 追加 | tile atlas変化がない場合も marker / label / highlight または Last Edit reason で成功が分かる。 |
| 11 | Last Edit を確認する | 有用 / 維持 | `target=no` / `display=no` の理由が表示される。 |

## 既存 UX との干渉

### HexTileMapLayer Common Target

`HexTileMapLayer` を primary target とする方針を維持する。今回の UX は表示可能になった target に対して、編集結果と trace を信頼できるようにする follow-up である。

### Plain TileMapLayer

plain `TileMapLayer` は互換 target として残す。Default Floor / Wall tile 設定は plain target にも適用可能にするが、Auto target の代表 UX は `HexTileMapLayer` とする。

### Object / Label 表示

Object / Label は tileそのものではない。viewport上で何を表示するかは marker / label overlay として設計し、floor / wall tile の atlas変更とは別の visual feedback とする。

## Hack 扱い

- Auto target が stale `_target_layer` を返す挙動。
- `display=no` を「失敗」と「表示対象外」の両方に使う挙動。
- default floor / wall tile を auto sample atlas または inferred tile に依存する挙動。
- Dock tab が default node name に見える挙動。
- edit dock の高さ不足を Godot dock の手動拡大だけで回避する挙動。

## UX 完了条件

- edit dock の Target `Auto` が Scene Tree 選択中 target に追従する。
- edit dock 内で default floor / wall tile を明示設定できる。
- `HexTileMapLayer` target で tile override edit が viewport に反映される。
- Object / Label edit は viewport feedback または明確な Last Edit reason を持つ。
- Last Edit が target解決、target apply、display renderer、tile coordsを分けて表示する。
- edit dock は scroll可能で、generation dock tab title は意味のある名前になる。
