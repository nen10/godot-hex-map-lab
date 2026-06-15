# PROCESS-60 UX（process-user）

## 対象 user
UI/graph task を実装・self-review する executor。

## 達成したい体験
- 「metric が通った＝完了」と誤解しない。metric は**回帰検知**であり、合格根拠は experiential DoD だと policy で読める。

## 避ける体験
- metric pass を製品品質の代理にして label-heavy 画面を完了にする（前回失敗）。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| metric の役割 | A: 回帰補助 / B: 合格根拠 | **A** | 製品目標と proxy を分離 |
