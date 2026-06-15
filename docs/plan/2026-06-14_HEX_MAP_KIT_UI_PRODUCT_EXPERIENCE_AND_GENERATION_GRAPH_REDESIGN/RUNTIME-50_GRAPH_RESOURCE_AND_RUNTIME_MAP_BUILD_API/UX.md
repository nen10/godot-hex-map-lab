# RUNTIME-50 UX（API ergonomics）

## 使う人
ゲーム実行時に map を生成したい開発者（ユーザーのゲームコード）。

## 達成したい体験
- `var layer = HexTileMapLayer.new(); layer.build_from_graph(my_graph_res, seed)` の **数行で runtime map** が出る。
- 同 seed で再現、別 seed で別 map（variety）。
- graph resource を **プロジェクトに置くだけ**で動く（embed semantics で外部依存なし）。

## 避ける体験
- runtime build に editor / dock が必要（headless で完結させる）。
- semantics 解決に大量の手動配線が要る（embed で自動）。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| API 粒度 | A: `build()` data + `build_from_graph()` 適用 / B: 単一 | **A** | data 取得と node 適用を分離 |
| 失敗時 | A: validate error を返す / B: 例外 | **A** | runtime で握れる |
