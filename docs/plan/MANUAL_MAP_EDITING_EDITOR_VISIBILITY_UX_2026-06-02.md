# MANUAL_MAP_EDITING_EDITOR_VISIBILITY_UX_2026-06-02.md

## 目的

Godot Editor 上で生成済み map を Hex Map Edit へ import し、viewport 上の cell を click したとき、document mutation、target layer redraw、保存、export の状態を Dock 上で判別できる UX を作る。

U1 の中心は manual edit の再設計ではなく、既存の resource-primary edit flow で何が起きたかを実 Editor 操作中に見えるようにすることである。

## 参照

- Backlog: `docs/plan/REVIEW_BACKLOG_2026-06-02.md` U1
- 既存方針: `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_POLICY_2026-05-31.md`
- viewport input plan: `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_VIEWPORT_INPUT_IMPLEMENTATION_PLAN_2026-06-01.md`
- loop display plan: `docs/complete_on_test/MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY_IMPLEMENTATION_PLAN_2026-05-31.md`
- analog test: `tests/analog_test/GENERATED_MAP_MANUAL_EDIT_ANALOG_TEST_2026-06-01.md`
- review: `docs/review/_history/MANUAL_RUNTIME_LOOP_DISPLAY_IMPLEMENTATION_REVIEW_2026-06-01.md`

## Use Case

- Actor: Godot Editor user
- Goal: viewport click 後に、編集対象 cell、document 更新、target redraw、保存/export の成否を Dock 上で確認できる。
- Scenario: 生成 Dock で保存した `HexMapResource` を Hex Map Edit へ import し、`TileMapLayer` または `HexTileMapLayer` を target にして wall / floor や shape を編集する。
- Success state: viewport 上の見た目が変わらない場合でも、Dock の情報から document 未更新、target apply 失敗、TileSet / atlas 設定不足、target class mismatch、save/export 失敗のどれかを切り分けられる。

## Operation Steps 素案と評価

| Step | 操作 / 観察 | 評価 | 目標 |
| --- | --- | --- | --- |
| 1 | 生成済み `HexMapResource` を Hex Map Edit へ import する | 有用 / 維持 | imported document の cell count、wall count、orientation を Dock に出す。 |
| 2 | `Target` で plain `TileMapLayer` または `HexTileMapLayer` を選ぶ | 有用 / 維持 | target path、target class、TileSet presence、floor / wall atlas 設定、loop display state を Dock に出す。 |
| 3 | target が可視 tile を描ける状態か確認する | 有用 / 追加 | `TileSet missing`、`floor/wall tile unset`、`HexTileMapLayer loop display` のような readiness を表示する。 |
| 4 | `Wall / Floor` mode で visible floor cell を click する | 有用 / 維持 | canonical hex、visual hex、before / after wall state、document mutation、target apply を同じ edit trace に出す。 |
| 5 | viewport 上の tile 変化を確認する | 有用 / 維持 | visual observation と Dock trace を照合できるようにする。 |
| 6 | viewport 上で変化が見えない場合に切り分ける | 有用 / 追加 | document changed / target applied / displayed tile changed / target used cells / atlas coords を表示する。 |
| 7 | Undo / Redo を実行する | 有用 / 維持 | Undo / Redo 後の document state と target redraw state を trace に更新する。 |
| 8 | document を Save する | 有用 / 追加 | saved path、save error、cell count、wall count、dirty 状態を表示する。 |
| 9 | `HexMapResource` として Export する | 有用 / 追加 | exported path、export error、cell count、wall count、resource type を表示する。 |
| 10 | Output panel の `print()` だけで debug する | 不要 / 廃止 | Dock 内の status / detail 表示を primary observation にする。 |
| 11 | last edit highlight を全履歴として残す | 不要 / 廃止 | last-only highlight を採用し、編集済み履歴表示は別 UI 候補へ分ける。 |
| 12 | 既存の `Edited <coordinate>` status | 有用 / 残置 | quick status として残し、詳細 trace への入口にする。 |

## 既存 UX との干渉

### Generate Dock Target

生成 Dock の Target は plain `TileMapLayer` を扱う既存 UX として維持する。Hex Map Edit では同じ target を選べるが、manual edit の状態表示では target class と TileSet readiness を明示する。

### Resource-primary Manual Edit

`HexMapDocumentResource` を編集結果の正とする UX を維持する。viewport 上の tile は document から再描画された表示結果として扱い、Dock trace は document mutation と target redraw を分けて表示する。

### Runtime Loop Display

`HexTileMapLayer` target では canonical hex と visual hex を区別する。loop display の設定値は target scene state として読み取り、Dock trace は click がどの visual representative から canonical cell へ解決されたかを表示する。

### Plain TileMapLayer Target

plain `TileMapLayer` は non-loop manual edit target として維持する。target が Godot 標準 node であること自体は失敗ではなく、TileSet、atlas、orientation、document apply の状態を Dock で判定できるようにする。

## Hack 扱い

- Output panel の `print()` を唯一の観察手段にする挙動。
- viewport の見た目だけから document mutation 成否を推測する挙動。
- `Edited <coordinate>` だけで target redraw 成否を推測する挙動。
- last edit highlight が蓄積し、最後に編集した cell と過去の編集済み cell を区別しない挙動。

これらは仕様根拠ではなく、Dock 内の target status と edit trace へ置き換える。

## UX 完了条件

- click 直後に、canonical / visual cell、before / after state、document changed、target applied が Dock 上で見える。
- target が plain `TileMapLayer` か `HexTileMapLayer` か、ユーザーが Dock 上で確認できる。
- TileSet / atlas / apply 設定不足が viewport 無変化と区別される。
- Save / Export 後の resource state が path と count で確認できる。
- last edit highlight は最後の編集対象だけを示す。
