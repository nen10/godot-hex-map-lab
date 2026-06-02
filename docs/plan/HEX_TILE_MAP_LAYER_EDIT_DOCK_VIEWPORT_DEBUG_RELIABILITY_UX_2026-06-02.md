# HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_UX_2026-06-02.md

## 対象

- Review: `docs/review/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_REVIEW_2026-06-02.md`
- Existing completed plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_IMPLEMENTATION_PLAN_2026-06-02.md`

## 目標UX

`Hex Map Edit` で `HexTileMapLayer` をtargetにした時、ユーザーは内部 `TileMapLayer` と親 `HexTileMapLayer` を区別せずに、見えているhex cellをclickして編集できる。Click結果はviewport上で同じcellに見え、Dock debug表示はcopy可能で、問題報告に必要な情報をそのまま取得できる。

## Operation Steps 素案

1. Sceneに `HexTileMapLayer` を1つ置く。
2. Debug fixtureまたはGeneration Dockで sample tile付きmapを表示する。
3. `Hex Map Edit` Dockを開く。
4. Dock debug表示をdrag selectionまたはcopy操作で取得できることを確認する。
5. Targetを `HexTileMapLayer` に設定する。
6. `Wall / Floor` modeで見えているfloor cellをclickする。
7. Clickしたcell自体がwall表示に変わる。
8. Highlight / markerはtileの前面に出る。
9. Last Editはcopy可能で、target、display、renderer、source、atlas、canonical/visual hexを報告できる。
10. 選択不能地点をclickしても、以降の有効cell clickは継続して反応する。
11. `Floor Tile` / `Wall Tile` / `Object` / `Label` modeでも、編集結果がviewportまたは前面overlayで確認できる。
12. Godot OutputにUndoRedo errorが出ない。

## Operation Steps 評価

| Step | 評価 | 目標 |
| --- | --- | --- |
| 1-3 target準備 | 有用 / 維持 | 既存 Dock と `HexTileMapLayer` targetを維持する。 |
| 4 debug copy | 有用 / 追加 | Dock上のstatus/detailをcopy可能にする。 |
| 5 target設定 | 有用 / 維持 | Auto / explicitのどちらでも操作targetが安定する。 |
| 6-7 visible click edit | 有用 / 維持 | 見えているcellと編集cellを一致させる。 |
| 8 foreground feedback | 有用 / 追加 | highlight / markerをtile前面に表示する。 |
| 9 copyable trace | 有用 / 追加 | 報告用debug textを直接コピーできる。 |
| 10 invalid click stability | 有用 / 追加 | 無効clickがEditor selection / targetを壊さない。 |
| 11 payload visibility | 有用 / 維持 | 既存 payload表示を正しい座標・前面表示へ移す。 |
| 12 UndoRedo errorなし | 有用 / 追加 | EditorUndoRedoManager errorを除去する。 |

## 干渉するUX

### 維持するUX

- Generation Dockから `HexTileMapLayer` にmapをapplyできる。
- `HexTileMapLayer` のloop display / duplicate tile copyを維持する。
- plain `TileMapLayer` targetは互換targetとして残す。
- `HexMapDocumentResource` 保存 / 読み込み / exportを維持する。

### 代替・廃止するUX

- 親 `HexTileMapLayer` と内部 `TileMapLayer` をユーザーがScene上で区別して操作するUXは廃止候補にする。
- UndoRedo連携は、Editor API差異により編集applyを壊す場合は廃止候補にする。
- `Label` の非選択debug表示は廃止候補にする。

## Hack扱い

- atlas coordを存在しない値にして背面highlightを確認する手順はhackであり、仕様根拠にしない。
- Importし直してclick反応を回復する手順はhackであり、仕様根拠にしない。
- 内部 `TileMapLayer` をユーザーが手動で選択してtarget差分を推測する手順はhackであり、仕様根拠にしない。

## 成功条件

- Dock debug / Last Edit / Target Status / Save Export detailがcopy可能である。
- `HexTileMapLayer` targetで、見えているtile cellとclick hit cellが一致する。
- Highlight / object marker / label markerがtile前面に表示される。
- 無効click後も有効clickが継続して反応する。
- Click後にGodot Outputへ `EditorUndoRedoManager.add_do_method` errorが出ない。
- 専用debug fixtureまたはanalog testで、上記を再実行できる。
