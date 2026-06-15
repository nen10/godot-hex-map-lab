# GRAPH-13 POLICY

## 採用方針
- **cancel/progress は既存資産再利用**: generator の `interrupt_options`（chunk/progress/cancel）を runner→node run に通す。
- **dirty 最小再実行**: node 単位 cache を上流変更で無効化。
- **N batch は半オプション**: 既定 N=1、randomize off。主導線を律速しない。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | 注意 | dirty フラグは cache の付帯状態（真実は graph model）。二重真実にしない |
| legacy | なし | |

## State / Invariant
| invariant | 内容 |
|---|---|
| dirty 整合 | 上流変更 → 下流必ず dirty。dirty node は次 run で再計算 |
| cancel 安全 | cancel 後の状態は一貫（部分結果を Document に書かない） |
| N=1 既定 | 初期表示は N=1・randomize off |

## baseline 整合
`GENERATION_GRAPH_MODEL.md` §5（Run UX）、`GRAPH-10/11`。
