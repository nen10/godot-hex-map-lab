# SCREEN-32 UX

## 達成したい体験
- Export を開くと「Godot へどう渡すか」が **3 card** で選べる（data / scene / graph）。
- 「遊べる」化ではなく「読み込める状態で渡す」と分かる。

## 避ける体験
- destination path 一覧だけの画面。
- 何が出力されるか不明な single ボタン。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 選択軸 | A: 目的(card) / B: 出力先 | **A** | 目的から選ぶ |
| 未実装 | A: disabled+tooltip / B: 非表示 | **A** | 存在と理由を見せる |
