# SCREEN-30 UX

## 達成したい体験
- 初心者: Profile を選び `[Generate]` だけで map が出る。
- 上級者: その生成は **canvas 上の graph** として開け、node を足して育てられる。
- 「simple で始めて graph に昇る」が地続き。

## 避ける体験
- simple と graph が**別物**で行き来できない。
- 初心者にいきなり空の graph canvas だけ見せて手が止まる（Simple 帯で入口を作る）。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 初心者導線 | A: Profile→Generate 帯 / B: canvas のみ | **A** | empty で手が止まらない |
| 昇格 | A: preset を canvas で開く / B: 別画面 | **A** | 地続きの学習 |
