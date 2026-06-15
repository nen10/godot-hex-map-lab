# SCREEN-40 UX

## 達成したい体験
- Catalog を開くと使える tile/object が **視覚 card** で並ぶ。
- card を選ぶと preview が見える。欠損は badge で分かる。

## 避ける体験
- raw source_id / atlas_coords が主面に並ぶ。
- tile と object が別画面で行き来が要る。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 主面 | A: card grid / B: ラベル list | **A** | 視覚で選ぶ |
| 欠損 | A: badge / B: テキスト | **A** | 一目で分かる |
