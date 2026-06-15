# GRAPH-12 UX

## 達成したい体験（背骨の証明）

ユーザーが Build canvas で:
1. `Shape→Wall→Connectivity` を組む。
2. `Region Filter`（例「floor ∩ spawn から距離≤3」）を繋ぐ。
3. その **中間 selection を preview** する。
4. `Item Generator`（weighted item）に **selection を入力**として繋ぐ。
5. 出力を選び `[Promote output to Layer]` → 役割（overlay/object）を選ぶ。
6. **Document に「本当に使う層」ができる**（保存できる）。

## 避ける体験
- 中間 output を次 node に繋げない（＝背骨が無い）。
- Promote が Paint の手編集層を上書きする。
- Promote 後に何が変わったか分からない（status に「<role> 層へ N cells を promote」）。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| Promote 操作 | A: 選択 node の inspector ボタン / B: graph 末端 node | **A** | run 純粋・DESIGN-10 一致 |
| role 選択 | A: promote 時に選ぶ / B: 固定 | **A** | terrain/overlay/object を使い分け |
| 既存層保護 | A: generated 層のみ置換 / B: 全置換 | **A** | 手編集を守る |
