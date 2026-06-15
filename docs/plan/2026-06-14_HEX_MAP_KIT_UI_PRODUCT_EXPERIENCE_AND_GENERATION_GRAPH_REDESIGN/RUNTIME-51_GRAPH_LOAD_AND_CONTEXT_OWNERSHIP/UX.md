# RUNTIME-51 UX

## 達成したい体験
- `Load Graph` で graph resource を選ぶと、**既定では新しい HexTileMapLayer が生成**され、その node を選択した状態で graph と semantics が復元され編集できる。
- 既存の map を graph で駆動したい時だけ、`Overwrite selected HexTileMapLayer`（off 既定）を on にして読み込む。
- overwrite でも **Paint の手編集層は消えない**。

## 避ける体験
- graph を開いたら今の選択 node の resource が勝手に書き換わる（既定では新 node なので起きない）。
- 「今 dock が映しているのは選択 node か graph か」が分からない（常に node 1つが文脈所有）。
- overwrite で手作業が消える。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 既定動作 | A: 新規 node / B: 選択へ復元 | **A** | 既存追跡を壊さない |
| overwrite 露出 | A: off 既定 checkbox / B: 常時 | **A** | 破壊操作を明示同意に |
