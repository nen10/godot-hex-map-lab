# SCREEN-41 UX

## 達成したい体験
- Layers を開くと role が **積み重なって視覚的に**見える。
- 各 role の visible/lock/writable が chip/toggle で即分かる・切れる。
- どの role が Build の promote 先 / Paint の手編集先かが分かる（writable source）。

## 避ける体験
- テキスト要約だけで stack が想像できない。
- writable source が何か分からない。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| stack | A: 視覚 tree / B: テキスト | **A** | 構造が見える |
| 属性編集 | A: toggle/chip / B: フォーム | **A** | 即操作 |
