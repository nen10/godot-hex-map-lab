# GRAPH-14 UX（API ergonomics）

## 使う人
RUNTIME-50（build）/ RUNTIME-51（load）/ Build canvas（save）。

## 達成したい体験
- canvas の graph を `.tres` に save し、後で load して同じ graph を得る（round-trip 無損失）。
- `to_dict()`/`from_dict()` で `GRAPH-10` runner にそのまま渡せる。
- embed snapshot で runtime 自己完結。

## 避ける体験
- save/load で node/edge/param が欠ける。
- Dictionary↔Resource 変換に外部知識が要る。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 変換 | A: to_dict/from_dict 対称 / B: 片方向 | **A** | runner と canvas 双方で使う |
