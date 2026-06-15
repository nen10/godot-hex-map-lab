# GRAPH-11 UX

## 対象 user

map の生成方式を組みたい開発者。

## 達成したい体験

- Build を開くと **最初に graph canvas** が見える（resource row でない）。
- palette から node を置き、port を線で繋ぐ。**型が合わない接続は弾かれる**（色とリジェクトで分かる）。
- node を選ぶと inspector に **その node の param** が出て編集できる。
- `[Generate]` で graph を実行し、選択 node の **中間 output を preview** できる。

## 避ける体験

- 先頭が Resource row / ラベル列。
- 接続が自由すぎて意味不明な graph ができる（型検証で防ぐ）。
- node に全 param が詰まって読めない（inspector に逃がす）。

## UX Candidate Matrix

| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| node 追加 | A: palette ボタン/右クリック / B: メニューのみ | **A** | 直感的・最初の3node を素早く |
| 接続 feedback | A: 型色 + reject / B: 後検証 | **A** | 迷いを即時に消す |
| preview 対象 | A: 選択 node の output / B: 最終のみ | **A** | 中間連鎖の確認（背骨要件） |
