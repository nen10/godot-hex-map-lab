# SCREEN-31 UX

## 達成したい体験
- Paint を開くと brush と対象 layer が見え、すぐ塗れる。
- 塗った結果（`Last edit: painted N cells on Terrain`）が分かる。
- 「生成で作った土台を手で仕上げる」が自然。

## 避ける体験
- 先頭に Resource row/ラベル列。
- 今どの layer に塗っているか分からない。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 状態提示 | A: active layer/cell/last edit を常時 / B: 隠す | **A** | 手編集の手応え |
| catalog 参照 | A: brush は catalog key / B: 生 source_id | **A** | 語彙で扱う |
